module Persistence
  class Property
    #
    # It represents a DateTime property
    #
    class DateTime < Object

      def self.primitive
        ::DateTime
      end

      # Typecasts an arbitrary value to a DateTime.
      # Handles both Hashes and DateTime instances.
      #
      # @param [Hash, #to_mash, #to_s] value
      #   value to be typecast
      #
      # @return [DateTime]
      #   DateTime constructed from value
      #
      # @api private
      def typecast_to_primitive(value)
        ::DateTime.parse(value.to_s)
        rescue ArgumentError
          value
      end

    
    end
  end
end