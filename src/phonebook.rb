require 'active_support/inflector'
require 'json'

# Class method to enable easy writing of a hash to a JSON file
class Hash
  def write_json_to_file filename
    File.write(filename, self.to_json)
  end
end

# Reads and parses the data from JSON
def getdata filename
  JSON.parse(File.read(filename))
end

module Phonebook
  # Creates a file of the given name to store the phonebook
  def create filename
    if not File.file?(filename)
      data = {"names" => {}, "numbers" => {}}
      data.write_json_to_file(filename)
      return "Success: Created #{filename}"
    else
      return "Error: File already exists, delete file or use add / remove / change to modify"
    end
  end

  # Adds an entry to the phonebook with the given name and number
  def add name, number, filename
    data = getdata(filename)
    uniquename = !data["names"].has_key?(name)
    uniquenum = !data["numbers"].has_key?(number)
    if uniquename and uniquenum
      data["names"][name] = number
      data["numbers"][number] = name
      data.write_json_to_file(filename)
      return "Success: Added #{name} - #{number}"
    else
      if not uniquename
        return "Error: #{name} already exists"
      else
        return "Error: #{number} already exists"
      end
    end
  end

  # Removes the entry for the given name from all data structures
  def remove name, filename
    data = getdata(filename)
    if data["names"].has_key?(name)
      number = data["names"][name]
      data["names"].delete(name)
      data["numbers"].delete(number)
      data.write_json_to_file(filename)
      return "Success: Removed #{name}"
    else
      return "Error: #{name} not found"
    end
  end

  # Changes the entry for the given name to the new values
  def change name, number, filename
    if data["names"].has_key?(name)
      remove(name, filename)
      add(name, number, filename)
      return "Success: Updated #{name} with #{number}"
    else
      return "Error: #{name} not found"
    end
  end

  # Constructs a string listing the results and their phone numbers,
  # could easily be modified to instead return a list
  def lookup patt, filename
    data = getdata(filename)
    pattern = Regexp.new(patt)
    matches = data["names"].each_key.select { |name| name =~ pattern }
    return "No matches found for #{patt}" if matches.empty?
    s = "Matches for #{patt}:\n-------------------------------\n"
    matches.each { |name| s += "#{name} : #{data['names'][name]}\n" }
    return s
  end

  def reverse_lookup numpatt, filename
    data = getdata(filename)
    pattern = Regexp.new(numpatt)
    matches = data["names"].each_value.select { |num| num =~ pattern }
    return "No matches found for #{numpatt}" if matches.empty?
    s = "Matches for #{numpatt}:\n-------------------------------\n"
    matches.each { |num| s += "#{data["names"].key(num)} : #{num}\n" }
    return s
  end

  # Parses the arguments, cleans and validates them, before finally
  # running the method called on the command line
  def process_request args
    # Parse the arguments
    response = "\n"

    # Ensure that an actual command was called
    commands = ["create", "lookup", "change", "add", "remove", "reverse"]
    if not commands.include?(args[0])
      response += "Error: Invalid argument, valid arguments are: (create lookup change add remove reverse)\n\n"
      return response
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
        response += "Error: Multiple .pb files found and none specified, please specify .pb file as the last argument\n\n"
      else
        response += "Error: .pb file not found, create a new phonebook using $ phonebook create <filename>.pb\n\n"
        return response
      end
    end

    # Ensure that the right number of arguments are passed for each command
    num_args = {"create"=> 2, "lookup"=> 3, "add"=> 4, "remove"=> 3, "reverse"=> 3, "change"=> 4}
    needed_args = num_args[args[0]]
    if args.count != needed_args
      if args.count > needed_args
        response += "Error: Too many arguments passed to #{args[0]}\n\n"
      else
        response += "Error: Too few arguments passed to #{args[0]}\n\n"
      end
      return response
    end

    # For any action other than create, ensure that the .pb file exists in
    # the directory
    if args[0] != "create"
      if !(File.file?(args[-1]))
        response += "Error: #{args[-1]} not found in the current directory, check for typos or create it using $ phonebook create <filename>\n\n"
        return response
      end
    end

    # If all the validations have passed, process the request
    case args[0]
    when "create"
      response += Phonebook.create(args[1])
    when "lookup"
      response += Phonebook.lookup(args[1], args[2])
    when "add"
      response += Phonebook.add(args[1], args[2], args[3])
    when "change"
      response += Phonebook.change(args[1], args[2], args[3])
    when "remove"
      response += Phonebook.remove(args[1], args[2])
    when "reverse"
      response += Phonebook.reverse_lookup(args[1], args[2])
    end

    response += "\n\n"
    return response
  end

end

