module Persistence
  module Model
    #
    # This module is a model extension which defines a new method to create model properties
    # The model properties are stored in @properties variable
    #
    module ModelProperty
      Model.append_extensions self 
      
      def self.extended(model)
        model.instance_variable_set(:@properties, {})
      end
      
      # Define a model property
      #
      # @param [Symbol] name
      # @param [Class] type 
      #   It's ignored in this moment (for DataMapper compatibility)
      #
      # @param [Hash(Symbol=>String)] options
      #   It's ignored in this moment (for DataMapper compatibility)
      #
      def property(name, type=nil, options={})

        property = Property.new(self, name, options)
        properties.store(name, property)
              
        # add the property to the child classes only if the property was
        # added after the child classes' properties have been copied from
        # the parent
        descendants.each do |descendant|
          descendant.properties.store(name, property)
        end

        create_reader_for(property)
        create_writer_for(property)

        return property
      
      end
      
      #
      # Gets the model properties
      #
      # @return [Hash] properties hash
      #
      def properties
        @properties ||= {}
      end

      # Defines the anonymous module that is used to add properties.
      # Using a single module here prevents having a very large number
      # of anonymous modules, where each property has their own module.
      # @api private
      def property_module
        @property_module ||= begin
          mod = Module.new
          class_eval do
            include mod
          end
          mod
        end
      end

      # Create the reader for the property
      #
      def create_reader_for(property)
        
        property_name          = property.name
        name                   = property.name.to_s
        reader_visibility      = property.reader_visibility
        instance_variable_name = property.instance_variable_name.to_s
      
        reader = <<-RUBY
          #{reader_visibility}
          def #{name}
            #{instance_variable_name} if defined?(#{instance_variable_name})
            #{instance_variable_name} = attribute_get(:#{name})
          end
        RUBY
        
        property_module.module_eval reader
      
      end
      
      # Create the writer for the property
      #
      #
      def create_writer_for(property)
       
        property_name          = property.name
        name                   = property.name.to_s
        writer_visibility      = property.writer_visibility
        writer_name            = "#{name}="
        
        writer = <<-RUBY
          #{writer_visibility}
          def #{writer_name}(value)
            attribute_set(:#{property_name}, value)
            attribute_get(:#{property_name})
          end
        RUBY
        
        property_module.module_eval writer
   
      end
   
    end # ModelProperty
  end # Model
end # Persistence