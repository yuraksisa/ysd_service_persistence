module Persistence
  module Model
    include Persistence::Support::Properties
    
    # Get the model descendants
    def self.descendants
      @descendants ||= []
    end
    
    def descendants
      @descendants ||= []
    end
    
    #
    # Hook executed when someone extend this module
    #
    def self.extended(descendant)
      descendants << descendant
      
      extra_extensions.each { |mod| descendant.extend(mod)         }
      extra_inclusions.each { |mod| descendant.send(:include, mod) }     
      
    end
  
    # Get a resource by its id (a String)
    def get(id)
      repository.get(build_path(id))
    end
    
    # Search for this model resources
    #
    # @params [Hash] options
    #
    #  It's a hash which contains the query options
    #
    #    :conditions => Instance of Conditions::AbstractComparison
    #    :order => Array with the order [key, order]
    #    :limit =>
    #    :offset =>
    #
    #  Examples:
    #
    #     MyEntity.all  # Retrieve all the instances
    #     MyEntity.all({:conditions => Conditions::Comparison(:name, '$eq', 'Mary')}) # Retrieve instance which name is 'Mary'
    #
    #  See Persistence::Query for more information about howto build the query
    #
    def all(options={})
      query = Query.new(repository, self, options)
      repository.read(query)
    end
    
    # Count this model resources
    #
    #
    def count(options={})
      query = Query.new(repository, self, options)
      repository.count(query)
    end
    
    # Create a new resource
    #
    def create(path, metadata)
      resource = new(path, metadata)
      resource.create
      resource
    end
    
    # Get the repository
    #           
    def repository(name=nil, &block)
      Persistence.repository(name || repository_name, &block)
    end           
     
    # Get the repository name
    #   
    def repository_name
      context = Repository.context
      context.any? ? context.last.name : default_repository_name
    end   
     
    # Get the default repository name
    #                   
    def default_repository_name
      Repository.default_name
    end       
    
        
    # Get the storage name for this model
    def storage_name
      defined?(@storage_name)?@storage_name:_storage_name
    end
            
    # Get the model name
    def model_name
      _name
    end
    
    # Get the prefix uri of this model resources
    def path_prefix    
      defined?(@uri_prefix)?@uri_prefix:_path_prefix 
    end
    
    # Build the uri
    def build_path(id)
      return File.join(path_prefix,id)
    end
    
    # Extract the key from a path
    def extract_key(path)
      path.sub(path_prefix+'/','')
    end
       
    # Load the resources of this model
    #
    # Resources : Array of hashes with the information
    #       
    def load(resources)
         
      resources.map do |loaded_resource|
    
        resource = self.allocate # Method of the Class Ruby class    
       
        resource.instance_variable_set(:@path, loaded_resource[:path])
        resource.instance_variable_set(:@metadata, {})
        resource.attributes=loaded_resource[:metadata]
        resource.instance_variable_set(:@repository, repository )
      
        resource
      
      end
    
      #resources
    
    end        
           
    # Extending the Model/Resource ---------------------------------------------------------
    
    # Appends a module for inclusion into the model class after Resource.
    #
    # This is a useful way to extend Resource while still retaining a
    # self.included method.
    #
    # @param [Module] inclusions
    #   the module that is to be appended to the module after Resource
    #
    # @return [Boolean]
    #   true if the inclusions have been successfully appended to the list
    #
    # @api semipublic
    def self.append_inclusions(*inclusions)
      extra_inclusions.concat inclusions

      # Add the inclusion to existing descendants
      descendants.each do |model|
        inclusions.each { |inclusion| model.send :include, inclusion }
      end

      true
    end

    # The current registered extra inclusions
    #
    # @return [Set]
    #
    # @api private
    def self.extra_inclusions
      @extra_inclusions ||= []
    end

    # Extends the model with this module after Resource has been included.
    #
    # This is a useful way to extend Model while still retaining a self.extended method.
    #
    # @param [Module] extensions
    #   List of modules that will extend the model after it is extended by Model
    #
    # @return [Boolean]
    #   whether or not the inclusions have been successfully appended to the list
    #
    # @api semipublic
    def self.append_extensions(*extensions)
      extra_extensions.concat extensions

      # Add the extension to existing descendants
      descendants.each do |model|
        extensions.each { |extension| model.extend(extension) }
      end

      true
    end

    # The current registered extra extensions
    #
    # @return [Set]
    #
    # @api private
    def self.extra_extensions
      @extra_extensions ||= []
    end
                                              
    private
    
    def _storage_name
      _name.concat("s")
    end
    
    def _path_prefix
      "/".concat(_name)
    end
    
    def _name
      name.scan(/\w+$/)[0].downcase
    end
          
  end # end Model
end # end Persistence