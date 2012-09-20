module Persistence
  class Property
    #
    # It represents an Integer property
    #
    class Integer < Object
      
      def self.primitive 
        ::Integer
      end
      
      # Typecast a value to a String
      #
      # @param [#to_s] value
      #   value to typecast
      #
      # @return [String]
      #   String constructed from value
      #
      # @api private
      def typecast_to_primitive(value)
        value.to_i
      end    
    
    end
  end
end