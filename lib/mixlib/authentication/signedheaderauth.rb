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

require 'time'
require 'base64'
require 'digest/sha1'
require 'mixlib/authentication'
require 'mixlib/authentication/digester'

module Mixlib
  module Authentication

    module SignedHeaderAuth

      NULL_ARG = Object.new
      SUPPORTED_ALGORITHMS = ['sha1'].freeze
      SUPPORTED_VERSIONS = ['1.0', '1.1'].freeze

      DEFAULT_SIGN_ALGORITHM = 'sha1'.freeze
      DEFAULT_PROTO_VERSION = '1.0'.freeze


      # === signing_object
      # This is the intended interface for signing requests with the
      # Opscode/Chef signed header protocol. This wraps the constructor for a
      # Struct that contains the relevant information about your request.
      #
      # ==== Signature Parameters:
      # These parameters are used to generate the canonical representation of
      # the request, which is then hashed and encrypted to generate the
      # request's signature. These options are all required, with the exception
      # of `:body` and `:file`, which are alternate ways to specify the request
      # body (you must specify one of these).
      # * `:http_method`: HTTP method as a lowercase symbol, e.g., `:get | :put | :post | :delete`
      # * `:path`: The path part of the URI, e.g., `URI.parse(uri).path`
      # * `:body`: An object representing the body of the request.
      #   Use an empty String for bodiless requests.
      # * `:timestamp`: A String representing the time in any format understood
      #   by `Time.parse`. The server may reject the request if the timestamp is
      #   not close to the server's current time.
      # * `:user_id`: The user or client name. This is used by the server to
      #   lookup the public key necessary to verify the signature.
      # * `:file`: An IO object (must respond to `:read`) to be used as the
      #   request body.
      # ==== Protocol Versioning Parameters:
      # * `:proto_version`: The version of the signing protocol to use.
      #   Currently defaults to 1.0, but version 1.1 is also available.
      # ==== Other Parameters:
      # These parameters are accepted but not used in the computation of the signature.
      # * `:host`: The host part of the URI
      def self.signing_object(args={ })
        SigningObject.new(args[:http_method], args[:path], args[:body], args[:host], args[:timestamp], args[:user_id], args[:file], args[:proto_version])
      end

      def algorithm
        DEFAULT_SIGN_ALGORITHM
      end

      def proto_version
        DEFAULT_PROTO_VERSION
      end

      # Build the canonicalized request based on the method, other headers, etc.
      # compute the signature from the request, using the looked-up user secret
      # ====Parameters
      # private_key<OpenSSL::PKey::RSA>:: user's RSA private key.
      def sign(private_key, sign_algorithm=algorithm, sign_version=proto_version)
        # Our multiline hash for authorization will be encoded in multiple header
        # lines - X-Ops-Authorization-1, ... (starts at 1, not 0!)
        header_hash = {
          "X-Ops-Sign" => "algorithm=#{sign_algorithm};version=#{sign_version};",
          "X-Ops-Userid" => user_id,
          "X-Ops-Timestamp" => canonical_time,
          "X-Ops-Content-Hash" => hashed_body,
        }

        string_to_sign = canonicalize_request(sign_algorithm, sign_version)
        signature = Base64.encode64(private_key.private_encrypt(string_to_sign)).chomp
        signature_lines = signature.split(/\n/)
        signature_lines.each_index do |idx|
          key = "X-Ops-Authorization-#{idx + 1}"
          header_hash[key] = signature_lines[idx]
        end

        Mixlib::Authentication::Log.debug "String to sign: '#{string_to_sign}'\nHeader hash: #{header_hash.inspect}"

        header_hash
      end

      # Build the canonicalized time based on utc & iso8601
      #
      # ====Parameters
      #
      def canonical_time
        Time.parse(timestamp).utc.iso8601
      end

      # Build the canonicalized path, which collapses multiple slashes (/) and
      # removes a trailing slash unless the path is only "/"
      #
      # ====Parameters
      #
      def canonical_path
        p = path.gsub(/\/+/,'/')
        p.length > 1 ? p.chomp('/') : p
      end

      def hashed_body
        # Hash the file object if it was passed in, otherwise hash based on
        # the body.
        # TODO: tim 2009-12-28: It'd be nice to just remove this special case,
        # always sign the entire request body, using the expanded multipart
        # body in the case of a file being include.
        @hashed_body ||= (self.file && self.file.respond_to?(:read)) ? digester.hash_file(self.file) : digester.hash_string(self.body)
      end

      # Takes HTTP request method & headers and creates a canonical form
      # to create the signature
      #
      # ====Parameters
      #
      #
      def canonicalize_request(sign_algorithm=algorithm, sign_version=proto_version)
        unless SUPPORTED_ALGORITHMS.include?(sign_algorithm) && SUPPORTED_VERSIONS.include?(sign_version)
          raise AuthenticationError, "Bad algorithm '#{sign_algorithm}' (allowed: #{SUPPORTED_ALGORITHMS.inspect}) or version '#{sign_version}' (allowed: #{SUPPORTED_VERSIONS.inspect})"
        end

        canonical_x_ops_user_id = canonicalize_user_id(user_id, sign_version)
        "Method:#{http_method.to_s.upcase}\nHashed Path:#{digester.hash_string(canonical_path)}\nX-Ops-Content-Hash:#{hashed_body}\nX-Ops-Timestamp:#{canonical_time}\nX-Ops-UserId:#{canonical_x_ops_user_id}"
      end

      def canonicalize_user_id(user_id, proto_version)
        case proto_version
        when "1.1"
          digester.hash_string(user_id)
        when "1.0"
          user_id
        else
          user_id
        end
      end

      # Parses signature version information, algorithm used, etc.
      #
      # ====Parameters
      #
      def parse_signing_description
        parts = signing_description.strip.split(";").inject({ }) do |memo, part|
          field_name, field_value = part.split("=")
          memo[field_name.to_sym] = field_value.strip
          memo
        end
        Mixlib::Authentication::Log.debug "Parsed signing description: #{parts.inspect}"
        parts
      end

      def digester
        Mixlib::Authentication::Digester
      end

      private :canonical_time, :canonical_path, :parse_signing_description, :digester, :canonicalize_user_id

    end

    # === SigningObject
    # A Struct-based value object that contains the necessary information to
    # generate a request signature. `SignedHeaderAuth.signing_object()`
    # provides a more convenient interface to the constructor.
    class SigningObject < Struct.new(:http_method, :path, :body, :host, :timestamp, :user_id, :file, :proto_version)
      include SignedHeaderAuth

      def proto_version
        (self[:proto_version] or DEFAULT_PROTO_VERSION).to_s
      end
    end

  end
end
