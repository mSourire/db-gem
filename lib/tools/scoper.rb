module Scoper
  def scope scope_name, condition
    define_singleton_method scope_name, condition
  end
end