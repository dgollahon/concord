require 'adamantium'
require 'equalizer'

# A mixin to define a composition
class Concord < Module
  include Adamantium::Flat, Equalizer.new(:names)

  # The maximum number of objects the hosting class is composed of
  MAX_NR_OF_OBJECTS = 3

  # Return names
  #
  # @return [Enumerable<Symbol>]
  #
  # @api private
  #
  attr_reader :names

  private

  # Initialize object
  #
  # @return [undefined]
  #
  # @api private
  #
  def initialize(*names)
    if names.length > MAX_NR_OF_OBJECTS
      raise "Composition of more than #{MAX_NR_OF_OBJECTS} objects is not allowed"
    end

    @names = names
  end

  # Hook run when module is included
  #
  # @param [Class|Module] descendant
  #
  # @return [undefined]
  #
  # @api private
  #
  def included(descendant)
    define_initialize(descendant)
    define_readers(descendant)
    define_equalizer(descendant)
  end

  # Define equalizer
  #
  # @param [Class|Module] descendant
  #
  # @return [undefined]
  #
  # @api private
  #
  def define_equalizer(descendant)
    descendant.send(:include, Equalizer.new(*@names))
  end

  # Define readers
  #
  # @param [Class|Module] descendant
  #
  # @return [undefined]
  #
  # @api private
  #
  def define_readers(descendant)
    attribute_names = names
    descendant.send(:attr_reader, *attribute_names)
    descendant.send(:protected, *attribute_names)
  end

  # Define initialize method
  #
  # @param [Class|Module] descendant
  #
  # @return [undefined]
  #
  # @api private
  #
  def define_initialize(descendant)
    ivars, size = instance_variable_names, names.size
    descendant.class_eval do
      define_method :initialize do |*args|
        args_size = args.size
        if args_size != size
          raise ArgumentError,
            "wrong number of arguments (#{args_size} for #{size})"
        end
        ivars.zip(args) { |ivar, arg| instance_variable_set(ivar, arg) }
      end
    end
  end

  # Return instance variable names
  #
  # @return [String]
  #
  # @api private
  #
  def instance_variable_names
    names.map { |name| "@#{name}" }
  end

  # Mixin for public attribute readers
  class Public < self

    # Hook called when module is included
    #
    # @param [Class,Module] descendant
    #
    # @return [undefined]
    #
    # @api private
    #
    def included(descendant)
      super
      @names.each do |name|
        descendant.send(:public, name)
      end
    end
  end # Public
end # Concord
