$LOAD_PATH.unshift(File.join(here = File.dirname(__FILE__), 'lib'))

ENV["RACK_ENV"] = "production"

require 'bundler'
Bundler.setup(:runtime)

require 'webapp'
map '/' do
  run WebApp
end

map '/websync/redeploy' do
  run lambda{|env|
    Bundler::with_original_env do 
      require 'server_agent'
      agent = ServerAgent.new(here)
      agent.signal(:"redeploy-request")
      [200, 
       {"Content-type" => "text/plain"},
       [ "Ok" ] ]
    end
  }
end

