$LOAD_PATH.unshift(File.join(here = File.dirname(__FILE__), 'lib'))
Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > "1.9"
ENV["RACK_ENV"] = "development"

require 'bundler'
Bundler.setup(:runtime)

require 'ext/nocache'
use Rack::Nocache

require 'webapp'
map '/' do
  run WebApp
end

require 'websync/middleware'
require 'client_agent'
map '/websync/' do
  WebSync::Middleware.set :agent, ClientAgent.new(here)
  run WebSync::Middleware
end

