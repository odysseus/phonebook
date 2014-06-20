
names = File.read("names.txt")
names = names.split(",")

100.times do
  `ruby phonebook.rb add #{names[rand(names.length)].capitalize} "#{rand(1000000)}" hs.pb`
end

