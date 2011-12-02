require 'webapp'
require 'test/unit'
require 'capybara'
require 'capybara/dsl'
class WebAppTest < Test::Unit::TestCase
  include Capybara::DSL

  attr_reader :theapp

  def setup
    WebApp.set :environment, :test
    Capybara.app = WebApp.new
  end

end
