Provides a simple database interface with an elementary ActiveRecord-like functional

WRITTEN in Ruby 2.2.1!

Usage examples:

```ruby
require 'db'

db = DB::Database.new :test

db.create_table :persons, name: "String", age: "Fixnum", sex: "String"

class Person < Record
  scope :women, -> { where sex: "f" }
  scope :men, -> { where sex: "m" }
end

man, woman = Person.new, Person.new
man.age, man.name, man.sex = 24, "Pavel", "m"
woman.age, woman.name, woman.sex = 16, "Olga", "f"
woman.save
man.save
brot = Person.new(:name => "Igor", :age => 14, :sex => "m")
mom = Person.new(:name => "Valentina", :age => 30, :sex => "f")
papa = Person.create(:sex => "m", :name => "Vitaliy", :age => 35)
mom.save
brot.save

Person.all

Person.find 3

Person.find(4).update age: 27

Person.where sex: "f"

#or the same, using scopes:

Person.women

Person.find(4).destroy

#The database can de deleted:

DB::Database.drop :test

#If there are several databases, it's possible to choose one of them:

db = DB::Database.use :corporation

#To drop a table:

db.drop_table :users
```
