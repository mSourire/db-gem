class Record
  include Validator
  extend Selection
  extend Scoper
  
  def initialize attributes = {}
    raise ArgumentError, "Provide correct attributes (hash)" if !attributes.is_a?(Hash)

    self.class.set_class_variables

    table_columns = self.class.table_schema[:columns]

    if record_id_passed? attributes
      id = attributes.keys.first
      other_attributes = attributes.values.first
      attributes = {id: id}.merge(other_attributes)
    end

    table_columns.each do |column|
      instance_variable_set "@#{column[0]}", attributes.has_key?(column[0]) ? attributes[column[0]] : nil
      set_attr_accessor(column[0])
    end
  end

  def save
    if !instance_variable_get(:@id).nil?
      record = construct_record
      validates_type
      update_record(record)
    else
      instance_variable_set(:@id, get_new_id)
      record = construct_record
      validates_type
      add_new_record(record)
      self.class.update_schema(instance_variable_get(:@id))
    end
  end

  def self.create attributes = {}
    new_record = self.new attributes
    new_record.save
  end

  def update attributes
    raise ArgumentError, "Provide correct attribute value (hash)" if !attributes.is_a?(Hash)

    attributes.each_pair do |attr, val|
      var = ["@", attr].join.to_sym
      instance_variable_set(var, val)
    end
    save
  end

  def destroy
    table_path = get_table_path
    data = FSCommunicator.read_yaml_file(table_path)
    id = instance_variable_get(:@id)
    self.class.write_table(table_path, data.reject{|k| k == id})
  end

  def self.set_class_variables
    t_name = self.name.downcase + "s"
    t_path = db_path + t_name
    t_sch_path = t_path + ".schema"
    t_schema = FSCommunicator.read_yaml_file(t_sch_path)

    new_variables = {:@@table_name => t_name, 
                     :@@table_path => t_path,
                     :@@table_schema_path => t_sch_path,
                     :@@table_schema => t_schema}

    new_variables.each{ |var, val| class_variable_set(var, val) }

    set_class_attr_accessor(new_variables.keys)
  end

  def self.set_class_attr_accessor variables
    variables.each do |var|
      var.to_s.delete('@').tap do |v|
        define_singleton_method v, proc { class_variable_get(var) }
        define_singleton_method "#{v}=", proc { |value| class_variable_set(var, value) }
      end
    end
  end

  def self.update_schema current_id
    table_schema[:last_id] = current_id
    FSCommunicator.write_file(table_schema_path, :w, table_schema.to_yaml)
  end

  def self.db_path
    [$default_path, $db_name, "/"].join
  end

  def self.write_table table_path, data
    FSCommunicator.write_file(table_path, :w, data.to_yaml)
  end

  private

  def record_id_passed? attributes
    attributes.keys.first.class == Fixnum
  end

  def set_attr_accessor var
    self.class.send(:define_method, var, proc { instance_variable_get("@#{var}") })
    self.class.send(:define_method, "#{var}=", proc { |value| instance_variable_set("@#{var}", value) })
  end

  def get_new_id
    self.class.table_schema[:last_id] + 1
  end

  def construct_record
    id = instance_variable_get(:@id)
    new_record = {id => {}}

    instance_variables.each do |var|
      if var != :@id
        new_record[id].merge!( var.to_s.delete('@').to_sym => instance_variable_get(var) )
      end
    end
    new_record
  end

  def add_new_record data
    FSCommunicator.write_file(get_table_path, :a, data.to_yaml.gsub("---\n", ''))
  end

  def update_record data
    table_path = get_table_path
    table_data = FSCommunicator.read_yaml_file(table_path)
    id = data.keys.first
    table_data[id] = data[id]
    self.class.write_table(table_path, table_data)
  end

  def get_table_path
    self.class.table_path
  end
end