require 'active_support/inflector'

class RailsModel

  class << self
    attr_accessor :model_list

    def model(name, options=nil, &block)
      new_model = new(name)
      new_model.has(options) if options
      new_model.instance_eval &block if block_given?
    end

    def models(*names)
      names.each { |name| model(name.to_s.singularize.to_sym) }
    end
  end
  @model_list = {}

  attr_accessor :name, :attributes

  def initialize(name)
    @name = name
    RailsModel.model_list[name] = self
    @attributes = {}
    @has_many = {}
    @has_one = {}
    @belongs_to = {}
  end

  def has(attributes)
    # attributes is a hash where the key is the name of the instance variable, and the value is the type.
    @attributes.merge! attributes
  end

  # def has_many(*others)
  #   # Puts 'has_many other' on self.
  #   # For each thing in others, creates it if it doesn't exist, and adds 'belongs_to #{self}' to each.
  #   # Adds self as an attribute to each thing on others.
  # end

  # def has_one(*others)
  #   # Puts 'has_many other' on self.
  #   # For each thing in others, creates it if it doesn't exist, and adds 'belongs_to' to each.
  #   # Adds this RailsModel as an attribute to each thing on others.
  # end

  # def belongs_to(*others, hash)

  # end

  def to_file
    # Gets into the app/models directory and creates the file #{name}.rb, and writes the string to it.

    lines = []
    lines << "class #{self.name.capitalize} < ActiveRecord::Base"
    attr_names = @attributes.keys.map{ |key| ':' + key.to_s.gsub(/_id\Z/, '') }
    lines << "  attr_accessible " + attr_names.join(', ') unless @attributes.empty?
    lines << ""
    lines << "end"

    file_string = lines.join("\n")
    File.new("testclasses/#{self.name}.rb", "w")
    File.write("testclasses/#{self.name}.rb", file_string)
  end

  def make_migration
    # Creates the migration files.
  end

end

def describe_models(&block)
  RailsModel.class_eval &block
end

def describe_connections(&block)

end