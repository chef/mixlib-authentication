require 'mixlib/log'

module Mixlib
  module Authentication
    class Log
      extend  Mixlib::Log      
    end
    
    Log.level :error
    
  end
end


