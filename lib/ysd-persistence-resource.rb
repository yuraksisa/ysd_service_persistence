require 'json' if not defined?JSON
module Persistence
  #
  # It represents a generic resource stored in a repository
  #
  # A resource has an uri, or identifier, and metadata, a hash
  # with the resource information. 
  #
  # A resource can hold any set of data
  #
  module Resource
  
    # Creates the resource
    def create
      repository.create(self) 
    end
    
    # Update the resource
    def update
      repository.update(self)
    end
    
    # Delete the resource
    def delete
      repository.delete(self)
    end
    
    # Makes suere a class gets all the methods when it includes a Resource
    def self.included(model)
      model.extend Model
      model.instance_variable_set(:@path, nil)
      model.instance_variable_set(:@metadata, {})
    end
    
    alias_method :model, :class
    
    # Initializes a new instance of this resource using the uri and metadata
    #
    def initialize(key, metadata={})
      @path = model.build_path(key)
      @metadata = {}
      properties.each do |property_name, property|
        @metadata.store(property.name, '')
      end
      @metadata.merge!(model.process_hash(metadata))      
    end
    
    # ----- Dynamic resource attributes ----
    
    attr_reader :path        
    
    # Get the key part of the path
    def key
      model.extract_key(path)
    end
    
    # Retrieve all the attributes
    def attributes
      @metadata
    end
    
    # Updates the attributes (more than one a time)
    def attributes=(data)
      @metadata.merge!(model.process_hash(data))
    end
                
    # Retrieves an attribute value
    # 
    # @param [Symbol] name
    # 
    # @return the attribute value
    def attribute_get(name)
      @metadata[name.to_sym]
    end
    
    alias_method :[], :attribute_get
    
    # Sets an attribute value
    def attribute_set(name, value)
      @metadata[name.to_sym] = value
    end
    
    alias_method :[]=, :attribute_set
    
    # Method missing (For Metaproperties - NOT DEFINED -)
    def method_missing(method, *args, &block)
            
      # The getter
      if @metadata.has_key?(method)
        return attribute_get(method)
      else
        # The setter
        
        if (attribute=method.to_s.match(/(.+)=$/).to_a.last)
          attribute_set(attribute, args.first)
          return
        end
      end
      
      super
            
    end
    
    #
    # Gets the resource properties
    #
    def properties
      model.properties
    end
    
    # Gets the repository where the resource have been retrieved
    def repository
      defined?(@repository) ? @repository : model.repository
    end
    
    def to_json(options={})
      @metadata.merge({:key => key}).to_json
    end
  
  end
end
  
 