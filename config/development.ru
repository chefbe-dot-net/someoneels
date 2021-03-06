Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > "1.9"

# set development environment and launch dependencies
ENV["RACK_ENV"] = "development"
require 'bundler'
Bundler.setup(:development)

# chdir to root now
Dir.chdir(root = File.expand_path('../../',__FILE__)) do
  # update loadpath and load project
  $: << File.join(root,"lib")
  require 'someoneels'
  
  # middlewares
  use Rack::Nocache
  use Rack::CommonLogger

  # main appplication
  map '/' do
    run Someoneels::WebApp
  end

  # websync
  require 'websync/middleware'
  require 'someoneels/client_agent'
  map '/websync/' do
    WebSync::Middleware.set :agent, Someoneels::ClientAgent.new(root)
    run WebSync::Middleware
  end
end


