module FSCommunicator
  require 'fileutils'

  $default_path = "/tmp/"

  def create_directory name
    begin
      FileUtils.mkdir $default_path + name.to_s
    rescue Exception => e
      puts "Cannot create directory: #{e.inspect}"
    end
  end

  def write_file path, mode, data = nil
    begin
      File.open(path, mode.to_s) { |file| file.write(data) }
    rescue Exception => e
      puts "Cannot write file: #{e.inspect}"
    end
  end

  def read_file path
    begin
      File.read(path)
    rescue Exception => e
      puts "Cannot read file: #{e.inspect}"
    end
  end

  def read_yaml_file path
    data = read_file(path)
    YAML::load(data)
  end

  def file_exists? directory, file_name
    File.exist?($default_path + [directory.to_s, file_name.to_s].join("/"))
  end

  def dir_exists? directory
    Dir.exist?($default_path + directory.to_s)
  end

  def method_missing(method_name, *args)
    case method_name
    when :remove_file, :remove_directory
      path = $default_path + args.join("/")
      begin
        FileUtils.rm_rf path
      rescue Exception => e
        puts "#{method_name} failed: #{e.inspect}"
      end
    else
      super
    end
  end
end