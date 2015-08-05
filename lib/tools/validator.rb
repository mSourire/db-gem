module Validator
  def validates_type
    self.class.table_schema[:columns].each do |column|
      unless column[1] == instance_variable_get("@#{column[0]}").class.to_s
        raise "@#{column[0]} variable has incompatible type. Check its value before saving"
      end
    end
  end
end