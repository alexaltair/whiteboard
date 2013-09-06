require 'active_support/inflector'

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

    def timestamp
      Time.now.to_s.split(' ')[0..1].join('').gsub(/\D/, '')
    end

    def create_file(directory, file_name, contents)
      Dir.chdir(directory)
      File.new("#{file_name}.rb", "w")
      File.write("#{file_name}.rb", contents)
      Dir.chdir("../..")
    end
  end
  @model_list = {}

  connection_methods = [:has_many, :has_one, :belongs_to, :has_and_belongs_to_many]
  Symbol.class_eval do
    def singularize
      self.to_s.singularize.to_sym
    end

    def pluralize
      self.to_s.pluralize.to_sym
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

  attr_accessor :name, :attributes, :methods, :has_many_of_these, :has_one_of_these, :belongs_to_these, :has_and_belongs_to_many_of_these

  def initialize(name)
    @name = name
    RailsModel.model_list[name] = self
    @attributes = {}
    @methods = {}
    @has_many_of_these = {} # Plural
    @has_one_of_these = {} # Singular
    @belongs_to_these = {} # Singular
    @has_and_belongs_to_many_of_these = {} # Plural
  end

  def has(attributes)
    # attributes is a hash where the key is the name of the instance variable, and the value is the type.
    @attributes.merge! attributes if attributes.is_a? Hash
    if attributes.is_a? Symbol
      id = attributes.to_s.singularize.+('_id').to_sym
      has id => :integer
    end
  end

  def can(method, description='')
    @methods[method] = description
  end

  def has_many(*others)
    others.each do |other|
      other = RailsModel.find_or_create(other.singularize)
      @has_many_of_these[other.name.pluralize] = nil
      other.belongs_to_these[@name] = nil
      other.has @name
    end
  end

  def has_one(*others)
    # Puts 'has_many other' on self.
    # For each thing in others, creates it if it doesn't exist, and adds 'belongs_to' to each.
    # Adds this RailsModel as an attribute to each thing on others.
    if !others[1].is_a? Hash
      others.each do |other|
        other = RailsModel.find_or_create(other)
        @has_one_of_these[other.name] = nil
        other.belongs_to_these[@name] = nil
        other.has @name
      end
    elsif join = others[1][:through]
      other = RailsModel.find_or_create(others[0])
      join = RailsModel.find_or_create(join)

      @has_one_of_these[join.name] = nil
      @has_one_of_these[other.name] = join.name

      other.belongs_to_these[join.name] = nil
      other.has join.name

      join.has_one_of_these[other.name] = nil
      join.belongs_to_these[@name] = nil
      join.has @name
    end
  end

  def belongs_to(*others, options)
    # Only used for polymorphism.
  end

  def has_and_belongs_to_many(other, options={})
    # Used for direct HABTM, or has_many to has_many.
    other = RailsModel.find_or_create(other.singularize)
    if options.empty?
      @has_and_belongs_to_many_of_these[other.name.pluralize] = nil
      other.has_and_belongs_to_many_of_these[@name.pluralize] = nil
    elsif join = options[:through]
      join = RailsModel.find_or_create(join)
      join.belongs_to_these[@name] = nil
      join.belongs_to_these[other.name] = nil
      join.has @name
      join.has other.name
      @has_many_of_these[other.name.pluralize] = join.name
      other.has_many_of_these[@name.pluralize] = join.name
    end
  end

  def make_model
    # Gets into the app/models directory and creates the file #{name}.rb, and writes the string to it.
    attr_names = @attributes.keys.map{ |key| ':' + key.to_s.gsub(/_id\Z/, '') }

    lines = []
    lines << "class #{@name.capitalize} < ActiveRecord::Base"
    lines << "  attr_accessible " + attr_names.join(', ') unless @attributes.empty?
    lines << ""
    @has_many_of_these.select{|k,v| v.nil?}.keys.each do |other|
      lines << "  has_many :#{other}"
    end
    @has_many_of_these.select{|k,v| !v.nil?}.each do |other, join|
      lines << "  has_many :#{other}, through: :#{join}"
    end
    @has_one_of_these.select{|k,v| v.nil?}.keys.each do |other|
      lines << "  has_one :#{other}"
    end
    @has_one_of_these.select{|k,v| !v.nil?}.each do |other, join|
      lines << "  has_one :#{other}, through: :#{join}"
    end
    @belongs_to_these.keys.each do |other|
      lines << "  belongs_to :#{other}"
    end
    @has_and_belongs_to_many_of_these.keys.each do |other|
      lines << "  has_and_belongs_to_many :#{other}"
    end
    lines << ""
    @methods.each do |name, description|
      lines << "  def #{name}"
      lines << "    \# #{description}"
      lines << "  end"
      lines << ""
    end
    lines << "end"

    RailsModel.create_file("app/models", @name, lines.join("\n"))
  end

  def make_migration
    table_name = @name.to_s.tableize
    class_name = 'Create' + table_name.camelize
    file_name = RailsModel.timestamp + '_' + class_name.underscore

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

    Dir.mkdir("db/migrate") unless File.exists?("db/migrate")
    RailsModel.create_file("db/migrate", file_name, lines.join("\n"))

    if !has_and_belongs_to_many_of_these.empty?
      has_and_belongs_to_many_of_these.keys.each do |other|
        other = other.singularize
        if @name < other
          sleep 1.01
          make_join_table_migration(other)
        end
      end
    end
  end

  def make_join_table_migration(other)
    table_name = @name.to_s.pluralize + '_' + other.to_s.pluralize
    class_name = 'Create' + table_name.camelize + 'JoinTable'
    file_name = RailsModel.timestamp + '_' + class_name.underscore

    lines = []
    lines << "class #{class_name} < ActiveRecord::Migration"
    lines << "  def change"
    lines << "    create_table :#{table_name}, id: false do |t|"
    lines << "      t.integer :#{@name}_id"
    lines << "      t.integer :#{other}_id"
    lines << ""
    lines << "      t.timestamps"
    lines << "    end"
    lines << "  end"
    lines << "end"

    Dir.mkdir("db/migrate") unless File.exists?("db/migrate")
    RailsModel.create_file("db/migrate", file_name, lines.join("\n"))
  end

end


def describe_models(&block)
  RailsModel.class_eval &block
end

def describe_associations(&block)
  RailsModel.class_eval &block
end