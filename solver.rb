Dir.chdir File.expand_path('..', __FILE__)
require 'timeout'
require 'bundler'
Bundler.require

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.current_driver = :selenium
# Capybara.app_host = 'http://www.nytimes.com'

class Solver
  include Capybara::DSL
  URL = 'http://www.nytimes.com/interactive/2015/07/03/upshot/a-quick-puzzle-to-test-your-problem-solving.html'

  def initialize
    @number = 0
    visit URL
    puts "sequence, result"
    loop{ try_next_sequence }
  end

  def sequence_as_string
    sprintf("%03d", @number)
  end

  def sequence
    sequence_as_string.split(//)
  end

  def answers
    @answers ||= []
  end

  def try_next_sequence
    page.execute_script "window.scrollBy(0,9999999999999)"
    inputs = all('#g-input .g-num')
    sequence.each_with_index do |n, index|
      inputs[index].set(n)
    end
    click_button 'Check'
    page.execute_script "$('html,body').stop()"
    if !page.has_selector?('.g-yours .g-answer', count: @number+1)
      raise 'failed to find new answer :('
    end
    @answers = all('.g-yours .g-answer').map(&:text)
    puts "#{sequence_as_string}, #{answers.last}"
    @number += 1
  end
end


Solver.new
