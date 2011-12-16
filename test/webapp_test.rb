require 'someoneels'
require 'test/unit'
require 'capybara'
require 'capybara/dsl'
class WebAppTest < Test::Unit::TestCase
  include Capybara::DSL

  attr_reader :theapp

  def setup
    Someoneels::WebApp.set :environment, :test
    Capybara.app = Someoneels::WebApp.new
  end

end
