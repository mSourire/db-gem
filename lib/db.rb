module DB

  require 'yaml'

  require 'tools/fscommunicator'
  require 'tools/validator'
  require 'tools/scoper'
  require 'db/record'

  class Database
    extend  FSCommunicator
    include FSCommunicator

    def initialize db_name

      if self.class.exists? db_name
        load_db db_name
      else
        create_db db_name
      end
    end

    def create_table table_name, columns = {}
      table_name = table_name.to_s
      write_table(table_name)
      table_schema = construct_table_schema(columns)
      write_table_schema(table_name, table_schema)
    end

    def drop_table table_name
      remove_file($db_name, table_name)
      remove_file($db_name, table_name.to_s + ".schema")
    end

    def self.use db_name
      if self.exists? db_name
        self.new db_name
      else
        puts "No such database"
      end
    end

    def self.exists? db_name
      dir_exists?(db_name)
    end

    def self.drop db_name
      remove_directory db_name
    end

    private

    def create_db db_name
      $db_name = db_name
      create_directory($db_name)
    end

    def load_db db_name
      $db_name = db_name
    end

    def get_file_path file_name
      $default_path + [$db_name, file_name].join("/")
    end

    def write_table table_name
      table_path = get_file_path(table_name)
      write_file(table_path, :w, "---\n")
    end

    def write_table_schema table_name, data
      table_schema_name = table_name + ".schema"
      table_schema_path = get_file_path(table_schema_name)
      write_file(table_schema_path, :w, data.to_yaml)
    end

    def construct_table_schema data
      table_schema = {:columns => {}}
      table_schema[:columns].merge!(:id => "Fixnum").merge!(data)
      table_schema.merge!({:last_id => 0})
    end
  end
end