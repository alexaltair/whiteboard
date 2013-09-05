whiteboard
==========

A tool to remove redundancy and confusion from creating ActiveRecord models and associations.

This tool will be run from the command line when the user starts a new rails app. The user will write a small file in an intuitive DSL that describes their models and relationships. This tool will take that file and create the nessecary rails files, including models with attributes and associations, and migrations.

Stretch goals;
* Can _update_ a rails project with modified models
* Integrate with a schema design GUI
* Take in CSVs, infer associations and seed the database.