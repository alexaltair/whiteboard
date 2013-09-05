Steps
* Make a rails app with the name of the models file
* Make an empty set which will contain all the RailsModels
* Run the models file
* For each call to #create
  * Initialize a RailsModel for each new model in the block
  * Add to or modify model data structures according to the methods in the block
* Create class files for all the models
  * Maybe use 'rails generate model'
  * Add associations
* Create migration files for all the models
  * Add foreign_ids to the migration files
  * Create any join tables
  * Run 'rake db:migrate'


X belongs_to Y
  puts a y_id in the x table
X has_one Y
  puts an x_id in the y table
X has_many Y
  puts an x_id in the y table
X has_many Y :through Z
  puts an x_id in the z table
  Does it put a y_id on the z table if you don't type "Y has_many X :through Z"?
X has_one Y :through Z
  puts an x_id in the z table and a z_id on the y table
  What happens if you don't type "Z has_one Y"?
X has_and_belongs_to_many Y
  Makes a XsYs table, whose rows are pairs of x_ids and y_ids.
  What happens if you don't write "has_and_belong_to_many" in both places?
belongs_to vs has_one
has_many :through vs has_and_belongs_to_many
  Do you want the relationship to be a thing of its own, with attributes, validations, and callbacks?
X has_many Y, as: Z
  puts a x_id in the y table as a z_id, and a z_type which is x
self joins


dependent: :destroy?


model = Class.new(ActiveRecord::Base)
overriding method_missing()
define_method(:method_name, &block)

Rails::Generators::Base < Thor::Group