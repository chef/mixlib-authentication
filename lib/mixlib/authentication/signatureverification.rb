require 'ostruct'
require 'net/http'

require 'mixlib/authentication/signedheaderauth'
require 'mixlib/authentication/digester'

module Mixlib
  module Authentication
    class SignatureVerification

      include Mixlib::Authentication::SignedHeaderAuth
      
      attr_reader :hashed_body, :timestamp, :http_method, :user_id

      # Takes the request, boils down the pieces we are interested in,
      # looks up the user, generates a signature, and compares to
      # the signature in the request
      # ====Headers
      #
      # X-Ops-Sign: algorithm=sha256;version=1.0;
      # X-Ops-UserId: <user_id>
      # X-Ops-Timestamp:
      # X-Ops-Content-Hash: 
      def authenticate_user_request(request, user_lookup, time_skew=(15*60))
        Mixlib::Authentication::Log.debug "Initializing header auth : #{request.inspect}"
        
        headers ||= request.env.inject({ }) { |memo, kv| memo[$2.downcase.to_sym] = kv[1] if kv[0] =~ /^(HTTP_)(.*)/; memo }
        digester = Mixlib::Authentication::Digester.new        

        begin
          @allowed_time_skew   = time_skew # in seconds
          @http_method         = request.method.to_s
          @signing_description = headers[:x_ops_sign].chomp
          @user_id             = headers[:x_ops_userid].chomp
          @timestamp           = headers[:x_ops_timestamp].chomp
          @request_signature   = headers[:authorization].chomp.gsub!(/\n\t/,"\n")
          @host                = headers[:host].chomp
          @content_hash        = headers[:x_ops_content_hash].chomp
          @user_secret         = user_lookup


          file_param = request.params["file"]

          @hashed_body = if file_param
                           Mixlib::Authentication::Log.debug "Digesting file_param: '#{file_param.inspect}'"
                           if file_param.respond_to?(:has_key?)
                             tempfile = file_param[:tempfile]
                             digester.hash_file(tempfile)
                           else
                             digester.hash_body(file_param)
                           end
                         else
                           body = request.raw_post
                           Mixlib::Authentication::Log.debug "Digesting body: '#{body}'"
                           digester.hash_body(body)
                         end

          Mixlib::Authentication::Log.debug "Authenticating user : #{user_id}, User secret is: #{@user_secret}, Request signature is :\n#{@request_signature}, Hashed Body is #{@hashed_body}"
          
          #BUGBUG Not doing anything with the signing description yet [cb]          
          parse_signing_description
          candidate_block = canonicalize_request
          request_decrypted_block = @user_secret.public_decrypt(Base64.decode64(@request_signature))
          signatures_match = (request_decrypted_block == candidate_block)
          timeskew_is_acceptable = timestamp_within_bounds?(Time.parse(timestamp), Time.now)
          hashes_match = @content_hash == hashed_body
        rescue StandardError=>se
          raise StandardError,"Failed to authenticate user request.  Most likely missing a necessary header: #{se.message}"
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


