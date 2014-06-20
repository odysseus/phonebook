require_relative './phonebook.rb'

include Phonebook

args = []
ARGV.each do |item|
  args.push(item)
end

puts Phonebook.process_request(args)
