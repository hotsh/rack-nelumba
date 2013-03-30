module Sinatra
  class Base
  end
end

module Rack
  class Lotus < Sinatra::Base
    VERSION = "0.0.1"
  end
end
