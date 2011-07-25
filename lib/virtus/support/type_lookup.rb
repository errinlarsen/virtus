module Virtus

  # A module that adds type lookup to a class
  module TypeLookup

    TYPE_FORMAT = /\A(?:[A-Z]\w*)\z/.freeze

    # Returns a descendant based on a name or class
    #
    # @example
    #   MyClass.determine_type('String')  # => MyClass::String
    #
    # @param [Class, #to_s] class_or_name
    #   name of a class or a class itself
    #
    # @return [Class]
    #   a descendant
    #
    # @return [nil]
    #   nil if the type cannot be determined by the class_or_name
    #
    # @api public
    def determine_type(class_or_name)
      case class_or_name
      when singleton_class then determine_type_from_descendant(class_or_name)
      when Class           then determine_type_from_primitive(class_or_name)
      else
        determine_type_from_string(class_or_name.to_s)
      end
    end

    # Return the default primitive supported
    #
    # @return [Class]
    #
    # @api private
    def primitive
      raise NotImplementedError, "#{self}.primitive must be implemented"
    end

  private

    # Return the class given a descendant
    #
    # @param [Class] descendant
    #
    # @return [Class]
    #
    # @api private
    def determine_type_from_descendant(descendant)
      descendant if descendant < self
    end

    # Return the class given a primitive
    #
    # @param [Class] primitive
    #
    # @return [Class]
    #
    # @return [nil]
    #   nil if the type cannot be determined by the primitive
    #
    # @api private
    def determine_type_from_primitive(primitive)
      descendants.detect { |descendant| primitive <= descendant.primitive }
    end

    # Return the class given a string
    #
    # @param [String] string
    #
    # @return [Class]
    #
    # @return [nil]
    #   nil if the type cannot be determined by the string
    #
    # @api private
    def determine_type_from_string(string)
      if string =~ TYPE_FORMAT && const_defined?(string, false)
        const_get(string, false)
      end
    end

    if RUBY_VERSION < '1.9'
      def determine_type_from_string(string)
        if string =~ TYPE_FORMAT && const_defined?(string)
          const_get(string)
        end
      end
    end

  end # module TypeLookup
end # module Virtus