require 'active_support/inflector'
require 'json'

class Hash
  def write_json filename
    File.write(filename, self.to_json)
  end
end

def getdata filename
  JSON.parse(File.read(filename))
end

def create filename
  if not File.file?(filename)
    data = {"names" => {}, "numbers" => {}, "namelist" => [], "numlist" => []}
    data.write_json(filename)
    return "Created #{filename}"
  else
    return "File already exists, delete file or use add / remove / change to modify"
  end
end

def add name, number, filename
  data = getdata(filename)
  if not data["names"].has_key?(name)
    data["names"][name] = number
    data["namelist"].push(name)
    data["numlist"].push(number)
    data["numbers"][number] = name
    data.write_json(filename)
    return "Added #{name} : #{number}"
  else
    return "#{name} already exists"
  end
end

def remove name, filename
  data = getdata(filename)
  if data["names"].has_key?(name)
    number = data["names"][name]
    data["names"].delete(name)
    data["numbers"].delete(number)
    data["namelist"].delete(name)
    data["numlist"].delete(number)
    data.write_json(filename)
    return "Removed #{name}"
  else
    return "#{name} not found"
  end
end

def change name, number, filename
  if data["names"].has_key?(name)
    remove(name, filename)
    add(name, number, filename)
    return "Updated #{name} with #{number}"
  else
    return "#{name} not found"
  end
end

def lookup patt, filename
  data = getdata(filename)
  pattern = Regexp.new(patt)
  matches = data["namelist"].select { |name| name =~ pattern }
  return "No matches found" if matches.empty?
  s = "Matches for #{patt}:\n-------------------------------\n"
  matches.each { |name| s += "#{name} : #{data['names'][name]}\n" }
  return s
end

def reverse_lookup number, filename
  data = getdata(filename)
  return "#{number} : #{data["numbers"][number]}"
end

def process_request
  # Parse the arguments
  args = []
  ARGV.each do |item|
    args.push(item)
  end

  puts "\n"

  # Ensure that an actual command was called
  commands = ["create", "lookup", "change", "add", "remove", "reverse"]
  if not commands.include?(args[0])
    puts "Invalid argument, valid arguments are: (create lookup change add remove reverse)\n\n"
    return -1
  end

  # If the command involves the name as the second argument, titleize
  # the name for consistency
  namecommands = ["lookup", "add", "change", "remove"]
  if namecommands.include?(args[0])
    args[1] = args[1].titleize
  end

  # If there is only one .pb file in the current directory, that is the
  # implicit argument for the file
  if !(args[-1] =~ /pb/)
    files = Dir.entries(".").select { |f| f =~ /pb$/ }
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

  # Ensure that the right number of arguments are passed for each command
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

  # For any action other than create, ensure that the .pb file exists in
  # the directory
  if args[0] != "create"
    if !(File.file?(args[-1]))
      puts "#{args[-1]} not found in the current directory, check for typos or create it using $ phonebook create <filename>\n\n"
      return -1
    end
  end

  # If all the validations have passed, process the request
  case args[0]
  when "create"
    puts create(args[1])
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

process_request
