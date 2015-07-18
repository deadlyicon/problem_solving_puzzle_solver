1000.times do |n|
  a, b, c = sprintf("%03d", n).split(//).map(&:to_i)
  answer = (a < b) & (b < c) ? 'Yes!' : 'No.'
  puts "#{a}#{b}#{c}, #{answer}"
end
