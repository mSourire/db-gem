module Selection

  def find id
    raise ArgumentError, "Provide correct id (integer)" if !id.is_a?(Fixnum)

    set_class_variables
    data = FSCommunicator.read_yaml_file(table_path)

    result = data[id]
    result.nil? ? nil : self.new({:id => id}.merge(result))
  end

  def all
    set_class_variables
    data = FSCommunicator.read_yaml_file(table_path)
    result = []
    data.each{ |record| result << self.new([record].to_h) }
    result
  end

  def where conditions
    raise ArgumentError, "Provide conditions (hash)" if !conditions.is_a?(Hash)

    set_class_variables
    data = FSCommunicator.read_yaml_file(table_path)

    checks = create_check(conditions)
    result = perform_check data, checks

    result.map!{ |e| self.new e}
  end

  def perform_check data, checks
    data ||= {}
    result = []
    data.each_pair do |id, record_data|
      checks.each do |check|
        unless check.call(record_data)
          break
        else
          checks.last == check ? result << {id => record_data} : next
        end
      end
    end
    result
  end

  def create_check conditions
    checks = []
    conditions.each_pair do |key, value|
      checks << lambda { |record_data| record_data[key] == value }
    end
    checks    
  end

end


