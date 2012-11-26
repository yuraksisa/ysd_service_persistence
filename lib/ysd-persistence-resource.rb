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
      catch :halt do
        before_save_hook
        before_create_hook
        repository.create(self)
        after_create_hook
        after_save_hook
      end 
    end
    
    # Update the resource
    def update
      catch :halt do
        before_save_hook
        before_update_hook
        repository.update(self)
        after_create_hook
        after_save_hook
      end
    end
    
    # Save the resource
    def save
      if new?
        create
      else
        update
      end 
    end

    # Delete the resource
    def delete
      catch :halt do
        before_destroy_hook
        repository.delete(self)
        after_destroy_hook
      end
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
    def initialize(key, data={})
       
      @path = model.build_path(key)
      @metadata = {}
      
      # Store the properties defined in the model in the metadata
      properties.each do |property_name, property|
        @metadata.store(property.name, '')
      end
      
      # Assign the values
      self.attributes=(data)
            
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
    
    # Retrieve all the exportable attributes
    def exportable_attributes
      attributes.clone
    end
    
    # Updates the attributes (more than one a time)
    def attributes=(data)
      
      model.process_hash(data).each do |key, value|
        attribute_set(key, value)
      end
      
      @metadata
      
    end
                
    # Retrieves an attribute value
    # 
    # @param [Symbol] name
    # 
    # @return the attribute value
    def attribute_get(name)
      
      name = name.to_sym
       
      if properties.has_key?(name)
        properties[name].get(self)
      else
        nil
      end
      
    end
    
    alias_method :[], :attribute_get
    
    # Sets an attribute value
    def attribute_set(name, value)
    
      name = name.to_sym
      
      if properties.has_key?(name)
        properties[name].set(self, value)
      else
        @metadata[name] = value
      end
        
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
    
    #
    # Check if the Resource instance is new
    #
    def new?
      not defined?@repository
    end
    
    #
    # Gets a json representation of the resource
    #
    def to_json(options={})
      exportable_attributes.merge({:key => key}).to_json
    end

    protected

    # Method for hooking callbacks before resource saving
    #
    # @return [undefined]
    #
    # @api private
    def before_save_hook
      execute_hooks_for(:before, :save)
    end

    # Method for hooking callbacks after resource saving
    #
    # @return [undefined]
    #
    # @api private
    def after_save_hook
      execute_hooks_for(:after, :save)
    end

    # Method for hooking callbacks before resource creation
    #
    # @return [undefined]
    #
    # @api private
    def before_create_hook
      execute_hooks_for(:before, :create)
    end

    # Method for hooking callbacks after resource creation
    #
    # @return [undefined]
    #
    # @api private
    def after_create_hook
      execute_hooks_for(:after, :create)
    end

    # Method for hooking callbacks before resource updating
    #
    # @return [undefined]
    #
    # @api private
    def before_update_hook
      execute_hooks_for(:before, :update)
    end

    # Method for hooking callbacks after resource updating
    #
    # @return [undefined]
    #
    # @api private
    def after_update_hook
      execute_hooks_for(:after, :update)
    end

    # Method for hooking callbacks before resource destruction
    #
    # @return [undefined]
    #
    # @api private
    def before_destroy_hook
      execute_hooks_for(:before, :destroy)
    end

    # Method for hooking callbacks after resource destruction
    #
    # @return [undefined]
    #
    # @api private
    def after_destroy_hook
      execute_hooks_for(:after, :destroy)
    end    

    private
  
    # Execute all the queued up hooks for a given type and name
    #
    # @param [Symbol] type
    #   the type of hook to execute (before or after)
    # @param [Symbol] name
    #   the name of the hook to execute
    #
    # @return [undefined]
    #
    # @api private
    def execute_hooks_for(type, name)
      model.hooks[name][type].each { |hook| hook.call(self) }
    end

  end
end
  
 