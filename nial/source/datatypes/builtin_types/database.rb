# coding: utf-8
require "json"
require_relative "builtintype"

##
# Represents a Database in the Nial language. The class will use a JSON-file behind the scenes but let the user interact with the JSON-file as if it was a simple SQL-server.
class Database < BuiltInType

  ##
  # Creates a new Database
  def initialize()
    super()
  end

  ##
  # Connects to Database.
  def connect(filename, scope, position)
    filename = filename.convert_to_text(scope, position)
    if filename.is_a?(Error) then return filename end

    # Resolve the path of ARGV[0] to an absolute path
    input_file_path = File.expand_path(ARGV[0])

    # Construct the path to the database file in the same directory
    db_path = File.join(File.dirname(input_file_path), "#{filename.value}.json")

    # Set the @filename instance variable to the path of the database file
    @filename = db_path

    return self.load_database
  end

  ##
  # Creates a new table in the Database. Takes a table name and the columns as
  # a List object as parameters.
  def create_table(table_name, columns, scope, position)
    table_name = table_name.convert_to_text(scope, position)
    if table_name.is_a?(Error) then return table_name end

    columns = columns.convert_to_list(scope, position)
    if columns.is_a?(Error) then return columns end

    table_name = table_name.value
    columns = self.convert_to_array(columns, scope, position)

    if not @database.has_key?(table_name)
      @database[table_name] = []
      @columns[table_name] = columns
    end
    save_database
  end

  ##
  # Inserts a new entry to the Database. Need the table name and a list
  # of values as parameters.
  def insert_into(table_name, values, scope, position)
    table_name = table_name.convert_to_text(scope, position)
    if table_name.is_a?(Error) then return table_name end

    values = values.convert_to_list(scope, position)
    if values.is_a?(Error) then return values end

    table_name = table_name.value
    values = self.convert_to_array(values, scope, position)
    
    row = Hash[@columns[table_name].zip(values)]
    @database[table_name] << row
    self.save_database
  end

  ##
  # Selects entries from the Database. A table name is required as parameter.
  # A Dictionary is optional as argument. If a Dictionary is provided
  # only the entries matching the Dictionary will be selected.
  # Example:
  # {"name": "John .*"} will select all entries from the Database where the name
  # starts with John. Regular expressions can be used here.
  def select(*args)
    self.load_database

    case args.length
    when 3
      table_name = args[0]
      conditions = nil
      sort_by = nil
      scope = args[1]
      position = args[2]
    when 4
      if args[1].is_a?(Dictionary)
        table_name = args[0]
        conditions = args[1]
        sort_by = nil
        scope = args[2]
        position = args[3]
      else
        table_name = args[0]
        conditions = nil
        sort_by = args[1]
        scope = args[2]
        position = args[3]
      end
    when 5
      table_name = args[0]
      conditions = args[1]
      sort_by = args[2]
      scope = args[3]
      position = args[4]
    else
      return "Argumenterror"
    end
               
    table_name = table_name.convert_to_text(scope, position)
    if table_name.is_a?(Error) then return table_name end
    table_name = table_name.value
    if not @database.has_key?(table_name) then return List.new end
    rows = @database[table_name]

    if conditions
      conditions = conditions.convert_to_dictionary(scope, position)
      if conditions.is_a?(Error) then return conditions end
      conditions = self.convert_to_hash(conditions, scope, position)
      rows = filter_rows(rows, conditions, scope, position) if conditions
    end

    if sort_by
      sort_by = sort_by.convert_to_text(scope, position)
      if sort_by.is_a?(Error) then return sort_by end
      rows = sort_rows(rows, sort_by.value)
    end

    rows = self.convert_to_list(rows, scope, position)
    return rows
  end

  ##
  # Delete an entry from the Database if the condition
  # provided is True.
  def delete(table_name, conditions, scope, position)
    self.load_database
    table_name = table_name.convert_to_text(scope, position)
    if table_name.is_a?(Error) then return table_name end
    table_name = table_name.value

    rows = @database[table_name]
    conditions = conditions.convert_to_dictionary(scope, position)
    if conditions.is_a?(Error) then return conditions end
    conditions = self.convert_to_hash(conditions, scope, position)

    #rows.reject! { |row| conditions.all? { |key, value| row[key] == value } }
    @database[table_name] = rows.reject { |row|
      conditions.all? {
        |key, value| row[key] == value
      }
    }

    self.save_database
  end

  ##
  # Delete an entire table from the Database
  def drop_table(table_name, scope, position)
    self.load_database
    table_name = table_name.convert_to_text(scope, position)
    if table_name.is_a?(Error) then return table_name end

    table_name = table_name.value
    @database.delete(table_name)
    @columns.delete(table_name)
    self.save_database
  end

  private

  def sort_rows(rows, sort_by)
    return rows.sort_by { |row| row[sort_by] }
  end

  def filter_rows(rows, conditions, scope, position)
    rows.select do |row|
      conditions.all? { |key, value|
        row[key].to_s.match(Regexp.new(value.to_s))
      }
    end
  end

  def load_database
    begin
      @database = File.exist?(@filename) ? JSON.parse(File.read(@filename)) : {}
    rescue
      return "Fileerror"
    end
    @columns = {}
    @database.each do |table_name, rows|
      @columns[table_name] = rows.empty? ? [] : rows[0].keys
    end
  end

  def save_database
    File.write(@filename, JSON.pretty_generate(@database))
  end

  def convert_to_array(list, scope, position)
    array = Array.new
    list.value.each { |item|
      if not [Text, Number].include?(item.class)
        return "Invalid datatype"
      else
        array << item.value
      end
    }
    return array
  end

  def convert_to_hash(hash, scope, position)
    new_hash = Hash.new
    hash.value.each { |key, value|
      if not [Text, Number].include?(key.class)
        return "Invalid datatype"
      elsif not [Text, Number].include?(value.class)
        return "invalid datatype"
      end

      new_hash[key.value] = value.value
    }
    return new_hash
  end

  def convert_to_list(array, scope, position)
    list = List.new
    array.each { |item|
      dict_values = Array.new
      item.each_pair { |key, value|

        current_pair = Array.new
        
        case key
        when Integer
          current_pair << Number.new(key)
        when String
          current_pair << Text.new(key)
        else
          return "invalid datatype"
        end

        case value
        when Integer
          current_pair << Number.new(value)
        when String
          current_pair << Text.new(value)
        else
          return "invalid datatype"
        end
        dict_values << current_pair
      }
      list.add(Dictionary.new(dict_values))
    }
    return list
  end
end

