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
# change <name> <number> <phonebook> -- Changes the number
#     err on not found
#     err on no phonebook
# remove <name> <phonebook>
#     err if not exists
#     err on no phonebook
# reverse-lookup <number> <phonebook>
#     err on no phonebook
#     err on not found

# Class to encapsulate phonebook functionality
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

  def change name, number
    if @book.has_key?(name)
      @book[name] = number
      @book["reverse"].delete(number)
      @book["reverse"][number] = name
      return "#{name} updated"
    else
      return "Change failed #{name} not found"
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

# The Do-er functions to create the object and perform the actions requested
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
  pb.reverse_lookup(number)
end

def add name, number, filename
  pb = Phonebook.init_from_file(filename)
  status = pb.add(name, number)
  File.write(filename, pb.book.to_json)
  return status
end

def change name, number, filename
  pb = Phonebook.init_from_file(filename)
  status = pb.change(name, number)
  File.write(filename, pb.book.to_json)
  return status
end

def remove name, filename
  pb = Phonebook.init_from_file(filename)
  status = pb.remove(name)
  File.write(filename, pb.book.to_json)
  return status
end

# Main Method, processing args
def main
  args = []
  ARGV.each do |item|
    args.push(item)
  end

  puts "\n"

  commands = ["create", "lookup", "change", "add", "remove", "reverse"]
  if not commands.include?(args[0])
    puts "Invalid argument, valid arguments are: (create lookup change add remove reverse)\n\n"
    return -1
  end

  namecommands = ["lookup", "add", "change", "remove"]
  if namecommands.include?(args[0])
    args[1] = args[1].capitalize
  end

  # If there is only one .pb file in the current directory, that is the
  # implicit argument
  if !(args[-1] =~ /pb/)
    files = Dir.entries(".").select { |f| f =~ /pb/ }
    if files.length == 1
      args.push(files[0])
    elsif files.length > 1
      puts "Multiple .pb files found and none specified, please specify .pb file as the last argument\n\n"
      return -1
    else
      puts "No .pb files found, create a new phonebook using $ phonebook create <filename>.pb\n\n"
      return -1
    end
  end

  num_args = {"create"=> 2, "lookup"=> 3, "add"=> 4, "remove"=> 3, "reverse"=> 3, "change"=> 4}
  needed_args = num_args[args[0]]
  if args.count != needed_args
    if args.count > needed_args
      puts "Too many arguments passed to #{args[0]}\n\n"
    else
      puts "Too few arguments passed to #{args[0]}\n\n"
    end
    return -1
  end

  # Check for file existence, if the .pb is not found in the current directory
  # output an error and halt the program... unless the action is create
  if args[0] != "create"
    if !(File.file?(args[-1]))
      puts "#{args[-1]} not found in the current directory, check for typos or create it using $ phonebook create <filename>\n\n"
      return -1
    end
  end

  # Filename exists
  case args[0]
  when "create"
    puts createpb(args[1])
  when "lookup"
    puts lookup(args[1], args[2])
  when "add"
    puts add(args[1], args[2], args[3])
  when "change"
    puts change(args[1], args[2], args[3])
  when "remove"
    puts remove(args[1], args[2])
  when "reverse"
    puts reverse_lookup(args[1], args[2])
  end

  puts "\n"
end

main
