Dir.chdir File.expand_path('..', __FILE__)
require 'timeout'
require 'bundler'
Bundler.require

# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app, :browser => :chrome)
# end

# Capybara.current_driver = :selenium

# Capybara.current_driver = :webkit
require 'capybara/poltergeist'
Capybara.current_driver = :poltergeist
Capybara.app_host = 'http://www.nytimes.com'
Capybara.app = ->(env){[200,{},['']]}

class Solver
  include Capybara::DSL
  URL = 'http://www.nytimes.com/interactive/2015/07/03/upshot/a-quick-puzzle-to-test-your-problem-solving.html'

  ANSWERS_FILE = Pathname.new(Dir.pwd)+'answers'
  RELOAD_LIMIT = 50

  def initialize
    @answer_file = ANSWERS_FILE.open('a')
    @number = ANSWERS_FILE.read.split("\n").length
    puts "sequence, result"
    reset!
    trap("INT") { @exiting; puts "Shutting down." }
    loop{
      break if @exiting
      break if @number > 999
      try_next_sequence
    }
  ensure
    @answer_file.try(:close) rescue nil
  end

  def reset!
    reset_session!
    visit URL
  end

  def sequence_as_string
    sprintf("%03d", @number)
  end

  def sequence
    sequence_as_string.split(//)
  end

  def try_next_sequence
    page.execute_script "window.scrollBy(0,9999999999999)"
    inputs = all('#g-input .g-num')
    sequence.each_with_index do |n, index|
      inputs[index].set(n)
    end
    answers_on_page = all('.g-yours .g-answer').length
    click_button 'Check'
    page.execute_script "$('html,body').stop()"
    if !page.has_selector?('.g-yours .g-answer', count: answers_on_page+1)
      raise 'failed to find new answer :('
    end
    answers = all('.g-yours .g-answer').map(&:text)
    puts "#{sequence_as_string}, #{answers.last}"
    @answer_file.puts "#{sequence_as_string}, #{answers.last}"
    @answer_file.flush
    @number += 1
    reset! if answers_on_page > RELOAD_LIMIT

  end
end


Solver.new
