require 'active_support/inflector'
require 'set'
require 'pp'

class RailsModel

  class << self
    attr_accessor :model_list

    def find_or_create(name)
      model_list[name] || new(name)
    end

    def model(name, options=nil, &block)
      new_model = find_or_create(name)
      new_model.has(options) if options
      new_model.instance_eval &block if block_given?
    end

    def models(*names)
      names.each { |name| model(name.singularize) }
    end
  end
  @model_list = {}

  connection_methods = [:has_many, :has_one, :belongs_to, :has_and_belongs_to_many]
  Symbol.class_eval do
    def singularize
      self.to_s.singularize.to_sym
    end

    connection_methods.each do |method|
      define_method(method) do |*args|
        if RailsModel.model_list.include? self
          RailsModel.model_list[self].send(method, *args)
        else
          method_missing(method, *args)
        end
      end
    end
  end

  attr_accessor :name, :attributes, :has_many_of_these, :has_one_of_these, :belongs_to_these

  def initialize(name)
    @name = name
    RailsModel.model_list[name] = self
    @attributes = {}
    @has_many_of_these = Set.new
    @has_one_of_these = {}
    @belongs_to_these = {}
  end

  def has(attributes)
    # attributes is a hash where the key is the name of the instance variable, and the value is the type.
    @attributes.merge! attributes
  end

  def has_many(*others)
    @has_many_of_these += Set.new(others)
    others.each do |other|
      other = RailsModel.find_or_create(other.singularize)
      other.belongs_to_these[self] = nil

      id = @name.to_s.singularize.+('_id').to_sym
      other.has id => :integer
    end
  end

  def has_one(*others)
    # Puts 'has_many other' on self.
    # For each thing in others, creates it if it doesn't exist, and adds 'belongs_to' to each.
    # Adds this RailsModel as an attribute to each thing on others.
  end

  def belongs_to(*others, options)
    # Only used for polymorphism.
  end

  def has_and_belongs_to_many(other, options={})
    # Used for direct HABTM, or has_many to has_many.
  end

  def to_file
    # Gets into the app/models directory and creates the file #{name}.rb, and writes the string to it.
    attr_names = @attributes.keys.map{ |key| ':' + key.to_s.gsub(/_id\Z/, '') }

    lines = []
    lines << "class #{@name.capitalize} < ActiveRecord::Base"
    lines << "  attr_accessible " + attr_names.join(', ') unless @attributes.empty?
    lines << ""
    @has_many_of_these.each do |other|
      lines << "  has_many :#{other}"
    end
    @belongs_to_these.keys.each do |other|
      lines << "  belongs_to :#{other.name}"
    end
    lines << "end"

    file_string = lines.join("\n")
    Dir.chdir("app/models")
    File.new("#{@name}.rb", "w")
    File.write("#{@name}.rb", file_string)
    Dir.chdir("../..")
  end

  def make_migration
    table_name = name.to_s.tableize
    class_name = 'Create' + table_name.camelize
    timestamp = Time.now.to_s.split(" ")[0..1].join('').gsub(/\D/, '')
    file_name = timestamp + '_' + class_name.underscore

    lines = []
    lines << "class #{class_name} < ActiveRecord::Migration"
    lines << "  def change"
    lines << "    create_table :#{table_name} do |t|"
    attributes.each do |name, type|
      lines << "      t.#{type} :#{name}"
    end
    lines << ""
    lines << "      t.timestamps"
    lines << "    end"
    lines << "  end"
    lines << "end"

    file_string = lines.join("\n")
    Dir.mkdir("db/migrate") unless File.exists?("db/migrate")
    Dir.chdir("db/migrate")
    File.new("#{file_name}.rb", "w")
    File.write("#{file_name}.rb", file_string)
    Dir.chdir("../..")
  end

end


def describe_models(&block)
  RailsModel.class_eval &block
end

def describe_connections(&block)
  RailsModel.class_eval &block
end