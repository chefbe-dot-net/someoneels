$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

def with_bundler(what)
  require 'rubygems' unless RUBY_VERSION >= "1.9"
  require 'bundler'
  Bundler.setup(what)
  yield if block_given?
end

namespace :cli do

  desc %q{Run the website locally}
  task :run do
    exec "rackup client.ru"
  end

  desc %q{Run all client tests}
  task :test do
    exec "bundle exec ruby -Ilib -Itest test/runall.rb"
  end

end


namespace :srv do

  def server_agent
    with_bundler(:runtime)
    require 'server_agent'
    ServerAgent.new(File.dirname(__FILE__))
  end

  desc %q{Restart the server website (bundle + restart.txt)}
  task :restart do
    server_agent.signal :"restart-request"
  end

  desc %q{Redeploy the server website (git pull then restart)}
  task :redeploy do
    server_agent.signal :"redeploy-request"
  end

end
