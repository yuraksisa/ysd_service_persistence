require 'date'
module Persistence
  class Property
    #
    # It represents a DateTime property
    #
    # Note: DateTime is not support in BSON, so we convert to Time UTC format
    #       So, the primitive is considered the Time class
    #
    class DateTime < Object

      def self.primitive
        ::Time 
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
        
        if value.kind_of?(::DateTime)
          result = value.to_time
        else
          result = ::DateTime.parse(value.to_s).to_time 
        end
                     
        return result
        
        rescue ArgumentError
          value
      end

    
    end
  end
end