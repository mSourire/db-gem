Provides a simple database interface with an elementary ActiveRecord-like functional

WRITTEN in Ruby 2.2.1!

Usage examples:

```ruby
require 'db'

db = DB::Database.new :test
db.create_table :persons, name: "String", age: "Fixnum", sex: "String"

#Instance, class variables and attribute accessors are defined dynamically 
#on basis of table schemas. The agreement is that a table name must be given
#in lower case and represent a plural noun; the name of a corresponding class
#must be a singular capitilized noun. So, having a table called "persons",
#it's possible to define related to it class like this: 

class Person < Record
  scope :women, -> { where sex: "f" }
  scope :men, -> { where sex: "m" }
end

#And then:

######  CREATION
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


######  SELECTION
Person.all
Person.find 3
Person.where sex: "f", age: 18
Person.where sex: "f"  

#or the same, using scopes:
Person.women


######  UPDATE
Person.find(4).update age: 27
Person.women.each do |woman|
  woman.update age: 99
  woman.save
end

######  DELETION
Person.find(1).destroy

#To drop a table:
db.drop_table :users

#The database can de deleted:
DB::Database.drop :test


#If there are several databases, it's possible to choose one of them:
db = DB::Database.use :corporation
```


####### SAMPLE TABLE FILLING

YAML is used for tables markup.

```yaml
---
1:
  :name: Olga
  :age: 16
  :sex: f
2:
  :name: Pavel
  :age: 24
  :sex: m
3:
  :name: Vitaliy
  :age: 35
  :sex: m
4:
  :name: Valentina
  :age: 30
  :sex: f
5:
  :name: Igor
  :age: 14
  :sex: m
7:
  :name: Mihail
  :age: 25
  :sex: m
```
