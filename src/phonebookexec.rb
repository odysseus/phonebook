require_relative './phonebook.rb'

include Phonebook

puts Phonebook.process_request(ARGV)
