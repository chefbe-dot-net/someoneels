require 'websync'
require 'logger'
class ServerAgent < WebSync::ServerAgent

  ROOT = File.expand_path('../../', __FILE__)

  def logger
    @logger ||= begin 
      logger = Logger.new(File.join(ROOT, 'logs/server-agent.log'), 'monthly')
      logger.level = Logger::DEBUG
      logger
    end
  end

  def initialize(*args)
    super(*args)
    install_events
  end

  private

    def restart_application
      Bundler::with_original_env do
        Dir.chdir(ROOT) do
          logger.debug "Executing bundle install"
          logger.debug `bundle install --deployment --local`
          `touch tmp/restart.txt`
        end
      end
    end

    def install_events

      listen :"redeploy-request" do |*args|
        logger.debug("User redeploy-request received.")
        unless synchronize
          logger.info("Nothing to redeploy for now.")
        end
      end

      listen :"restart-request" do |*args|
        logger.debug("User restart-request received.")
        restart_application
        logger.info("Application restarted successfully.")
      end

      listen :production_up_to_date do |*args|
        logger.info("Working dir synchronized, restarting now...")
        signal :"restart-request"
      end

    end

end
