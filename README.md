whiteboard
==========

A tool to remove redundancy and confusion from creating ActiveRecord models and associations.

This tool will be run from the command line when the user starts a new rails app. The user will write a small file in an intuitive DSL that describes their models and relationships. This tool will take that file and create the nessecary rails files, including models with attributes and associations, and migrations.

Stretch goals;
* Can update a rails project with modified models
* Integrate with a schema design GUI
* Take in CSVs, infer associations and seed the database.

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
  Makes a Xs_Ys table, whose rows are pairs of x_ids and y_ids.
  What happens if you don't write "has_and_belong_to_many" in both places?
belongs_to vs has_one
has_many :through vs has_and_belongs_to_many
  Do you want the relationship to be a thing of its own, with attributes, validations, and callbacks?
X has_many Y, as: Z
  puts a x_id in the y table as a z_id, and a z_type which is x
self joins


dependent: :destroy?