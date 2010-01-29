#
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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
        digester = OpenSSL::Digest::SHA1.new
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
        @hashed_body ||= ::Base64.encode64(OpenSSL::Digest::SHA1.digest(body)).chomp
      end      
    end
  end
end
