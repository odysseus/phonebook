# Drops and recreates the seed data for the phonebook using
# random numbers and names.txt

# Parse the names.txt file
names = File.read("names.txt")
names = names.split(",")
names.each do |name|
  name.gsub!(/"/, "")
end

filename = "hs.pb"

# Remove the current file
if File.file?(filename)
  `rm #{filename}`
  `ruby phonebookexec.rb create #{filename}`
end

1000.times do
  `ruby phonebookexec.rb add "#{names[rand(names.length)]}_#{names[rand(names.length)]}" "#{rand(1000000)}" #{filename}`
end
