#
# Author:: Christopher Brown (<cb@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2009, 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'ostruct'
require 'net/http'
require 'mixlib/authentication'
require 'mixlib/authentication/signedheaderauth'

module Mixlib
  module Authentication
    class SignatureResponse < Struct.new(:name)
    end

    class AuthenticationError < StandardError
    end

    class MissingAuthenticationHeader < AuthenticationError
    end

    class SignatureVerification
      MANDATORY_HEADERS = [:x_ops_sign, :x_ops_userid, :x_ops_timestamp, :host, :x_ops_content_hash]

      include Mixlib::Authentication::SignedHeaderAuth
      
      attr_reader :timestamp
      attr_reader :http_method
      attr_reader :path
      attr_reader :user_id
      attr_reader :request

      def initialize
        @valid_signature, @valid_timestamp, @valid_content_hash = false, false, false
        @hashed_body = nil
      end

      # Takes the request, boils down the pieces we are interested in,
      # looks up the user, generates a signature, and compares to
      # the signature in the request
      # ====Headers
      #
      # X-Ops-Sign: algorithm=sha256;version=1.0;
      # X-Ops-UserId: <user_id>
      # X-Ops-Timestamp:
      # X-Ops-Content-Hash: 
      # X-Ops-Authorization-#{line_number}
      def authenticate_user_request(request, user_lookup, time_skew=(15*60))
        Mixlib::Authentication::Log.debug "Initializing header auth : #{request.inspect}"

        @request, @user_secret  = request, user_lookup
        @allowed_time_skew      = time_skew # in seconds

        digester = Mixlib::Authentication::Digester

        begin

          assert_required_headers_present
          extract_auth_params_from_request
          build_request_signature
          
          #BUGBUG Not doing anything with the signing description yet [cb]          
          parse_signing_description

          verify_signature
          verify_timestamp
          verify_content_hash

          #timeskew_is_acceptable = timestamp_within_bounds?(Time.parse(timestamp), Time.now)
          #hashes_match = (@content_hash == hashed_body)
        rescue StandardError=>se
          raise StandardError,"Failed to authenticate user request. Check your client key and clock: #{se.message}", se.backtrace
        end

        if valid_request?
          SignatureResponse.new(:name=>user_id)
        else
          nil
        end
      end

      def valid_signature?
        @valid_signature
      end

      def valid_timestamp?
        @valid_timestamp
      end

      def valid_content_hash?
        @valid_content_hash
      end

      def valid_request?
        valid_signature? && valid_timestamp? && valid_content_hash?
      end

      # The authorization header is a Base64-encoded version of an RSA signature.
      # The client sent it on multiple header lines, starting at index 1 - 
      # X-Ops-Authorization-1, X-Ops-Authorization-2, etc. Pull them out and
      # concatenate.
      def headers
        @headers ||= request.env.inject({ }) { |memo, kv| memo[$2.gsub(/\-/,"_").downcase.to_sym] = kv[1] if kv[0] =~ /^(HTTP_)(.*)/; memo }
      end

      private

      def extract_auth_params_from_request
        @http_method         = request.method.to_s
        @path                = request.path.to_s
        @signing_description = headers[:x_ops_sign].chomp
        @user_id             = headers[:x_ops_userid].chomp
        @timestamp           = headers[:x_ops_timestamp].chomp
        @host                = headers[:host].chomp
        @content_hash        = headers[:x_ops_content_hash].chomp
        Mixlib::Authentication::Log.debug "Authenticating user : #{user_id}, User secret is : \n#{@user_secret}"
      end

      def assert_required_headers_present
        MANDATORY_HEADERS.each do |header|
          unless headers.key?(header)
            raise MissingAuthenticationHeader, "required authentication header #{header.to_s.upcase} missing"
          end
        end
      end

      def build_request_signature
        # if there are 11 headers, the sort breaks - it becomes lexicographic sort rather than numeric [cb]
        @request_signature = headers.find_all { |h| h[0].to_s =~ /^x_ops_authorization_/ }.sort { |x,y| x.to_s <=> y.to_s}.map { |i| i[1] }.join("\n")
        Mixlib::Authentication::Log.debug "Reconstituted (user-supplied) request signature: #{@request_signature}"
      end

      def verify_signature
        candidate_block = canonicalize_request
        request_decrypted_block = @user_secret.public_decrypt(Base64.decode64(@request_signature))
        @valid_signature = (request_decrypted_block == candidate_block)

        # Keep the debug messages lined up so it's easy to scan them
        Mixlib::Authentication::Log.debug("Verifying request signature:")
        Mixlib::Authentication::Log.debug(" Expected Block is: '#{candidate_block}'")
        Mixlib::Authentication::Log.debug("Decrypted block is: '#{request_decrypted_block}'")
        Mixlib::Authentication::Log.debug("Signatures match? : '#{@valid_signature}'")

        @valid_signature
      rescue => e
        Mixlib::Authentication::Log.debug("Failed to verify request signature: #{e.class.name}: #{e.message}")
        @valid_signature = false
      end

      def verify_timestamp
        @valid_timestamp = timestamp_within_bounds?(Time.parse(timestamp), Time.now)
      end

      def verify_content_hash
        @valid_content_hash = (@content_hash == hashed_body)

        # Keep the debug messages lined up so it's easy to scan them
        Mixlib::Authentication::Log.debug("Expected content hash is: '#{hashed_body}'")
        Mixlib::Authentication::Log.debug(" Request Content Hash is: '#{@content_hash}'")
        Mixlib::Authentication::Log.debug("           Hashes match?: #{@valid_content_hash}")

        @valid_content_hash
      end


      # The request signature is based on any file attached, if any. Otherwise
      # it's based on the body of the request.
      def hashed_body
        unless @hashed_body
          # TODO: tim: 2009-112-28: It'd be nice to remove this special case, and
          # always hash the entire request body. In the file case it would just be
          # expanded multipart text - the entire body of the POST.
          #
          # Pull out any file that was attached to this request, using multipart
          # form uploads.
          # Depending on the server we're running in, multipart form uploads are
          # handed to us differently. 
          # - In Passenger (Cookbooks Community Site), the File is handed to us 
          #   directly in the params hash. The name is whatever the client used, 
          #   its value is therefore a File or Tempfile. 
          #   e.g. request['file_param'] = File
          #   
          # - In Merb (Chef server), the File is wrapped. The original parameter 
          #   name used for the file is used, but its value is a Hash. Within
          #   the hash is a name/value pair named 'file' which actually 
          #   contains the Tempfile instance.
          #   e.g. request['file_param'] = { :file => Tempfile }
          file_param = request.params.values.find { |value| value.respond_to?(:read) }

          # No file_param; we're running in Merb, or it's just not there..
          if file_param.nil?
            hash_param = request.params.values.find { |value| value.respond_to?(:has_key?) }  # Hash responds to :has_key? .
            if !hash_param.nil?
              file_param = hash_param.values.find { |value| value.respond_to?(:read) } # File/Tempfile responds to :read.
            end
          end

          # Any file that's included in the request is hashed if it's there. Otherwise,
          # we hash the body.
          if file_param
            Mixlib::Authentication::Log.debug "Digesting file_param: '#{file_param.inspect}'"
            @hashed_body = digester.hash_file(file_param)
          else
            body = request.raw_post
            Mixlib::Authentication::Log.debug "Digesting body: '#{body}'"
            @hashed_body = digester.hash_string(body)
          end
        end
        @hashed_body
      end

      # Compare the request timestamp with boundary time
      # 
      # 
      # ====Parameters
      # time1<Time>:: minuend
      # time2<Time>:: subtrahend
      #
      def timestamp_within_bounds?(time1, time2)
        time_diff = (time2-time1).abs
        is_allowed = (time_diff < @allowed_time_skew)
        Mixlib::Authentication::Log.debug "Request time difference: #{time_diff}, within #{@allowed_time_skew} seconds? : #{!!is_allowed}"
        is_allowed      
      end
    end


  end
end


