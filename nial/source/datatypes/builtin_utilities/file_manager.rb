require_relative "../../exceptions/error"
require_relative "baseutility"

##
# Represents a built in utility in the Nial language that lets the user
# work with files.
class FileManager < BaseUtility
  ##
  # Reads the content of the file filename and return the content as a Text object.
  # Parameter filename will be converted to a Text and returns ConversionError
  # exception if operation fails. The method can also return a FileError
  # exception if it cannot read the filename provided.
  def FileManager.read(filename, scope, position)
    filename = filename.convert_to_text(scope, position)
    if filename.is_a?(Error) then return filename end

    begin
      content = File.read(filename.value)
      return Text.new(content)
    rescue
      return FileError.new("File open error, failed to load \"#{filename.value}\"", scope, position)
    end
  end

  ##
  # Write the contents in the parameter data to the file filename.
  # Both parameters filename and data will be converted to Text objects
  # and returns ConversionError if operation fails. The method can also return
  # FileError exception if it fails to write to the filename provided.
  def FileManager.write(filename, data, scope, position)
    filename = filename.convert_to_text(scope, position)
    if filename.is_a?(Error) then return filename end

    data = data.convert_to_text(scope, position)
    if data.is_a?(Error) then return data end

    begin
      File.open(filename.value, "w") { |file|
        file.write(data.value)
        return Boolean.new(true)
      }
    rescue
      return FileError.new("File error, failed to write to \"#{filename.value}\"", scope, position)
    end
  end

  ##
  # Appends the contents in the parameter data to the file filename.
  # Both parameters filename and data will be converted to Text objects
  # and returns ConversionError if operation fails. The method can also return
  # FileError exception if it fails to append to the filename provided.
  def FileManager.append(filename, data, scope, position)
    filename = filename.convert_to_text(scope, position)
    if filename.is_a?(Error) then return filename end

    data = data.convert_to_text(scope, position)
    if data.is_a?(Error) then return data end

    begin
      File.open(filename.value, "a") { |file|
        file << (data.value)
        return Boolean.new(true)
      }
    rescue
      error = FileError.new("File error, failed to append to \"#{filename.value}\"", scope, position)
      return error
    end
  end
end
