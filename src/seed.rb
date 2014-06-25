require 'json'
require 'active_support/inflector'
require_relative './phonebook.rb'

include Phonebook
# Drops and recreates the seed data for the phonebook using
# random numbers and names.txt

# Parse the names.txt file
$names = File.read("names.txt")
$names = $names.split(",")
$names.each do |name|
  name.gsub!(/"/, "")
end

filename = "hs.pb"

# Remove the current file
if File.file?(filename)
  File.delete(filename)
end

def rand_nam
  $names[rand($names.length)].titleize
end

pb = {}
100_000.times do
  pb["#{rand_nam} #{rand_nam}"] = rand(1_000_000_000).to_s
end

pb.write_json_to_file("hs.pb")
