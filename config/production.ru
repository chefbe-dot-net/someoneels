Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > "1.9"

# set development environment and launch dependencies
ENV["RACK_ENV"] = "production"
require 'bundler'
Bundler.setup(:production)

# chdir to root now
Dir.chdir(root = File.expand_path('../../',__FILE__)) do
  # update loadpath and load project
  $: << File.join(root,"lib")
  require 'someoneels'
  
  # main appplication
  map '/' do
    run Someoneels::WebApp
  end

  # websync
  map '/websync/redeploy' do
    run lambda{|env|
      Bundler::with_original_env do 
        require 'someoneels/server_agent'
        agent = Someoneels::ServerAgent.new(root)
        agent.signal(:"redeploy-request")
        [ 200, 
         {"Content-type" => "text/plain"},
         [ "Ok" ] ]
      end
    }
  end
end

