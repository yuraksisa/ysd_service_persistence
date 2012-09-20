module Persistence
  class Property
    #
    # It represents a String property
    #
    class String < Object
      
      def self.primitive 
        ::Object
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
        value.to_s
      end    
    
    end
  end
end