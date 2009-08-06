require 'mixlib/authentication'

module Mixlib
  module Authentication
    class Digester
      attr_reader :hashed_body
      
      def initialize()
        @hashed_body = nil
      end

      # Compare the request timestamp with boundary time
      # 
      # 
      # ====Parameters
      # time1<Time>:: minuend
      # time2<Time>:: subtrahend
      #
      def hash_file(f)
        digester = Digest::SHA1.new
        buf = ""
        while f.read(16384, buf)
          digester.update buf
        end        
        @hashed_body ||= ::Base64.encode64(digester.digest).chomp
      end
      
      # Digests the body, base64's and chomps the end
      # 
      # 
      # ====Parameters
      # 
      def hash_body(body)
        @hashed_body ||= ::Base64.encode64(Digest::SHA1.digest(body)).chomp
      end      
    end
  end
end
