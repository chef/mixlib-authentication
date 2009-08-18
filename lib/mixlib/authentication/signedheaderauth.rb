require 'time'
require 'base64'
require 'ostruct'
require 'digest/sha2'
require 'hmac'
require 'hmac-sha2'
require 'mixlib/authentication'
require 'mixlib/authentication/digester'

module Mixlib
  module Authentication
    module SignedHeaderAuth
      
      SIGNING_DESCRIPTION = 'version=1.0'

      # This is a module meant to be mixed in but can be used standalone
      # with the simple OpenStruct extended with the auth functions
      class << self
        def signing_object(args={ })
          OpenStruct.new(args).extend SignedHeaderAuth
        end
      end
	  
	  # Build the canonicalized request based on the method, other headers, etc.
      # compute the signature from the request, using the looked-up user secret
      # ====Parameters
      # private_key<String>:: user's RSA private key.
	  def sign(private_key)
        digester = Mixlib::Authentication::Digester.new
        @hashed_body = if self.file
                         digester.hash_file(self.file)
                       else
                         digester.hash_body(self.body)
                       end
        
		signature = Base64.encode64(private_key.private_encrypt(canonicalize_request)).chomp.gsub!(/\n/,"\n\t")
		header_hash = {
          "X-Ops-Sign" => SIGNING_DESCRIPTION,
          "X-Ops-Userid" => user_id,
          "X-Ops-Timestamp" => canonical_time,
          "X-Ops-Content-Hash" =>@hashed_body,
          "Authorization" => signature,
        }
        Mixlib::Authentication::Log.debug "Header hash: #{header_hash.inspect}"
        
        header_hash
	  end
      
      # Build the canonicalized time based on utc & iso8601
      # 
      # ====Parameters
      # 
      def canonical_time
        Time.parse(timestamp).utc.iso8601      
      end

      # Takes HTTP request method & headers and creates a canonical form
      # to create the signature
      # 
      # ====Parameters
      # 
      # 
      def canonicalize_request
        "Method:#{http_method.to_s.upcase}\nX-Ops-Content-Hash:#{@hashed_body}\nX-Ops-Timestamp:#{canonical_time}\nX-Ops-UserId:#{user_id}"
      end
      
      # Parses signature version information, algorithm used, etc.
      #
      # ====Parameters
      #
      def parse_signing_description
        parts = @signing_description.strip.split(";").inject({ }) do |memo, part|
          field_name, field_value = part.split("=")
          memo[field_name.to_sym] = field_value.strip
          memo
        end
        Mixlib::Authentication::Log.debug "Parsed signing description: #{parts.inspect}"
      end
      
      private :canonical_time, :canonicalize_request, :parse_signing_description
      
    end
  end
end
