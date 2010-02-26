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
    class SignatureVerification

      include Mixlib::Authentication::SignedHeaderAuth
      
      attr_reader :hashed_body, :timestamp, :http_method, :path, :user_id

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
        
        headers ||= request.env.inject({ }) { |memo, kv| memo[$2.gsub(/\-/,"_").downcase.to_sym] = kv[1] if kv[0] =~ /^(HTTP_)(.*)/; memo }
        digester = Mixlib::Authentication::Digester

        begin
          @allowed_time_skew   = time_skew # in seconds
          @http_method         = request.method.to_s
          @path                = request.path.to_s
          @signing_description = headers[:x_ops_sign].chomp
          @user_id             = headers[:x_ops_userid].chomp
          @timestamp           = headers[:x_ops_timestamp].chomp
          @host                = headers[:host].chomp
          @content_hash        = headers[:x_ops_content_hash].chomp
          @user_secret         = user_lookup

          # The authorization header is a Base64-encoded version of an RSA signature.
          # The client sent it on multiple header lines, starting at index 1 - 
          # X-Ops-Authorization-1, X-Ops-Authorization-2, etc. Pull them out and
          # concatenate.

          # if there are 11 headers, the sort breaks - it becomes lexicographic sort rather than numeric [cb]
          @request_signature = headers.find_all { |h| h[0].to_s =~ /^x_ops_authorization_/ }.sort { |x,y| x.to_s <=> y.to_s}.map { |i| i[1] }.join("\n")
          Mixlib::Authentication::Log.debug "Reconstituted request signature: #{@request_signature}"
          
          # Pull out any file that was attached to this request, using multipart
          # form uploads.
          # Depending on the server we're running in, multipart form uploads are
          # handed to us differently. 
          # - In Passenger (Cookbooks Community Site), the File is handed to us 
          #   directly in the params hash. The name is whatever the client used, 
          #   its value is therefore a File or Tempfile.
          # - In Merb (Chef server), the File is wrapped. The original parameter 
          #   name used for the file is passed in with a Hash value. Within the hash
          #   is a name/value pair named 'file' which actually contains the Tempfile
          #   instance.
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
          
          Mixlib::Authentication::Log.debug "Authenticating user : #{user_id}, User secret is : #{@user_secret}, Request signature is :\n#{@request_signature}, Hashed Body is : #{@hashed_body}"
          
          #BUGBUG Not doing anything with the signing description yet [cb]          
          parse_signing_description
          candidate_block = canonicalize_request
          request_decrypted_block = @user_secret.public_decrypt(Base64.decode64(@request_signature))
          signatures_match = (request_decrypted_block == candidate_block)
          timeskew_is_acceptable = timestamp_within_bounds?(Time.parse(timestamp), Time.now)
          hashes_match = @content_hash == hashed_body
        rescue StandardError=>se
          raise StandardError,"Failed to authenticate user request.  Most likely missing a necessary header: #{se.message}", se.backtrace
        end
        
        Mixlib::Authentication::Log.debug "Candidate Block is: '#{candidate_block}'\nRequest decrypted block is: '#{request_decrypted_block}'\nCandidate content hash is: #{hashed_body}\nRequest Content Hash is: '#{@content_hash}'\nSignatures match: #{signatures_match}, Allowed Time Skew: #{timeskew_is_acceptable}, Hashes match?: #{hashes_match}\n"
        
        if signatures_match and timeskew_is_acceptable and hashes_match
          OpenStruct.new(:name=>user_id)
        else
          nil
        end
      end
      
      private
      
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


