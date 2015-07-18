Dir.chdir File.expand_path('..', __FILE__)
require 'bundler'
Bundle.require

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.current_driver = :selenium
# Capybara.app_host = 'http://www.nytimes.com'

class Solver
  include Capybara::DSL

  def initialize
    @number = 0
    visit 'http://www.nytimes.com/interactive/2015/07/03/upshot/a-quick-puzzle-to-test-your-problem-solving.html'
    3.times{ try_next_sequence }
  end

  def sequence
    sprintf("%03d", @number)
  end

  def try_next_sequence
    inputs = all('#g-input .g-num')
    binding.pry
  end
end
