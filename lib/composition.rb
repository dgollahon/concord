require 'adamantium'
require 'equalizer'

# A mixin to define a composition
class Composition < Module
  include Adamantium::Flat, Equalizer.new(:names)

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
    if names.length > 2
      raise 'Composition of more than two objects is not allowed'
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
    define_initializer(descendant)
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
    @names.each do |name|
      descendant.send(:attr_reader, name)
    end
  end

  # Define initializer
  #
  # @param [Class|Module] descendant
  #
  # @return [undefined]
  #
  # @api private
  #
  def define_initializer(descendant)
    descendant.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
      def initialize(#{param_names})                         # def initialize(foo, bar)
        #{instance_variable_names} = #{local_variable_names} #   @foo, @bar = foo, bar
      end                                                    # end
    RUBY
  end

  # Return instance variable names
  #
  # @return [String]
  #
  # @api private
  #
  def instance_variable_names
    names.map { |name| "@#{name}" }.join(', ')
  end

  # Return param names
  #
  # @return [String]
  #
  # @api private
  #
  def param_names
    names.join(', ')
  end

  alias_method :local_variable_names, :param_names

end
