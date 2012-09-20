module Persistence
  # 
  # A model property
  #
  class Property
  
    attr_reader :name
    attr_reader :instance_variable_name
    attr_reader :reader_visibility
    attr_reader :writer_visibility
    
    class << self
      def determine_class(type)
        return type if type < Persistence::Property::Object    
        find_class(type.name)
      end
      def find_class(name)
        klass ||= const_get(name) if const_defined?(name)
        klass      
      end
    end
    
    def initialize(model, name, options)
      @model = model
      @name = name
      @instance_variable_name = "@#{@name}".freeze
      @options = options
      
      determine_visibility
    end
  
    # Determine the property visibility
    def determine_visibility
      
      default_accessor = @options.fetch(:accesosor, :public)
      
      @reader_visibility = @options.fetch(:reader, default_accessor)
      @writer_visibility = @options.fetch(:writer, default_accessor)
       
    end
    
    #
    # Get the property value for the resource
    #
    # @param [Resource]
    # 
    # @return [Object]
    #
    def get(resource)
      resource.instance_variable_get(:@metadata).fetch(instance_variable_name)
    end
    
    #
    # Set the property value for the resource
    #
    # @param [Resource]
    # @param [Object]
    # 
    # @return [Object]
    #
    def set(resource, value)
      resource.instance_variable_get(:@metadata).store(instance_variable_name, typecast(value))
    end
  
    #
    # Typecast the value to a primitive value
    #
    def typecast(value)
      if value.nil? || primitive?(value)
        value
      elsif respond_to?(:typecast_to_primitive)
        typecast_to_primitive(value)
      end
    end
    
    # Test a value to see if it matches the primitive type
    #
    # @param [Object] value
    #   value to test
    #
    # @return [Boolean]
    #   true if the value is the correct type
    #
    # @api semipublic
    def primitive?(value)
      value.kind_of?(self.class.primitive)
    end    
    
    #
    # Returns the primitive type
    #
    def self.primitive
      nil
    end
  
  end
end  
