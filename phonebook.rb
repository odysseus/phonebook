require 'json'

# Args needed to implement:
# create <filename> -- creates a new phonebook
#     err if exists
# lookup <name> <phonebook> -- Finds a person in the phonebook
#     err on not found
#     err on no phonebook
# add <name> <number> <phonebook> -- Adds a person to the book
#     err on dupe
#     err on no phonebook
# remove <name> <phonebook>
#     err if not exists
#     err on no phonebook
# reverse-lookup <number> <phonebook>
#     err on no phonebook
#     err on not found

class Phonebook

  attr_accessor :book

  def initialize
    @book = {}
    @book["reverse"] = {}
  end

  def self.init_from_file filename
    if File.file?(filename)
      pb = Phonebook.new
      pb.book = JSON.parse(File.read(filename))
      return pb
    else
      return "File not found"
    end
  end

  def read_from filename
    @book = JSON.parse(File.read(filename))
  end

  def add name, number
    if !@book.has_key?(name)
      @book[name] = number
      @book["reverse"][number] = name
      return "#{name} : #{number} added"
    else
      return "#{name} already exists"
    end
  end

  def remove name
    if @book.has_key?(name)
      number = @book[name]
      @book.delete(name)
      @book["reverse"].delete(number)
      return "#{name} removed"
    else
      return "#{name} not found"
    end
  end

  def lookup name
    if @book.has_key?(name)
      @book[name]
    else
      "#{name} not found"
    end
  end

  def reverse_lookup number
    if @book["reverse"].has_key?(number)
      @book["reverse"][number]
    else
      "#{number} not found"
    end
  end

  def create filename
    if !File.file?(filename)
      File.open(filename, "w") { |f| f.write(@book.to_json) }
      return "Phonebook created"
    else
      return "Already exists"
    end
  end

end

def createpb filename
  return "Phonebook already exists" if File.file?(filename)
  pb = Phonebook.new
  pb.create(filename)
end

def lookup name, filename
  pb = Phonebook.init_from_file(filename)
  pb.lookup(name)
end

def reverse_lookup number, filename
  pb = Phonebook.init_from_file(filename)
  pb.reverse(number)
end

def add name, number, filename
  pb = Phonebook.init_from_file(filename)
  status = pb.add(name, number)
  File.write(filename, pb.book.to_json)
  return status
end

def remove name, filename
  pb = Phonebook.init_from_file(filename)
  status = pb.remove(name)
  File.write(filename, pb.book.to_json)
  return status
end

def main
  args = []
  ARGV.each do |item|
    args.push(item)
  end

  case args[0]
  when "create"
    puts createpb(args[1])
  when "lookup"
    puts lookup(args[1], args[2])
  when "add"
    puts add(args[1], args[2], args[3])
  when "remove"
    puts remove(args[1], args[2])
  when "reverse"
    puts reverse_lookup(args[1], args[2])
  end
end

main
