module Persistence
  class Repository

     # Get the list of adapters
     #
     def self.adapters
       @adapters ||= {}
     end

     # Get the adapter for this repository
     def adapter
     
       @adapter ||=
         begin
           adapters = self.class.adapters
           
           unless adapters.key?(@name)
             raise "Adapter not set: #{@name}. Did you forget to setup"
           end
           
           adapters[@name]
         end
     
     end
     
     # -----------------------------------
     
     # Get the default name of this repository
     def self.default_name
       :default
     end
     
     # -----------------------------------
     
     # Get the stack of current repository contexts
     #
     def self.context
       Thread.current[:persistence_respository_contexts] ||= []
     end
     
     # Execute a block in the scope of this repository
     #
     # @yieldparam [Repository] repository
     # 
     def scope

       context = Repository.context
       
       context << self # Adds itself to the context
       
       begin 
         yield self    # 
       ensure
         context.pop
       end
         
     end
        
     # -----------------------------------
     
     # Create a new query for resources
     #
     def new_query(model, conditions={}, opts={})
       adapter.new_query(self, model, conditions, opts)
     end
     
     # Read resources from the repository
     #
     def read(query)
     
       #TODO check that the query is valid       
       query.model.load(adapter.read(query))
       
     end

     # Count resources from the repository
     #
     def count(query)
     
       #TODO check that the query is valid
       adapter.count(query)
     
     end
     
     
     # Get a resource by its uri
     #
     # Example:
     # ------------------------
     #   /content/es/vision.erb
     #   /profile/delphiero
     #
     def get(uri)
       
       parsed_uri = parse_uri(uri)
                     
       models = Model.descendants.select do |descendant| parsed_uri[:path_prefix] == descendant.path_prefix end
       
       if models and models.first
         model = models.first
         result = adapter.get(model, parsed_uri[:id])
         result = model.load([result]).first if result 
       end
       
     end
     
     # -------------------------------------
     
     # Creates a resource
     #
     def create(resource, opts={})
       adapter.create(resource, opts)
     end
     
     # Updates a resource
     #
     def update(resource, opts={})
       adapter.update(resource, opts)
     end
   
     # Delete a resource
     #
     def delete(resource, opts={})
       adapter.delete(resource, opts)
     end
     
     # -------------------------------------   
     
     # Updates a selection of resources
     #
     def update_selection(model, selector, attributes, opts={})
       adapter.update_selection(resource, opts)
     end
   
     # Delete a selection of resources
     #
     def delete_selection(model, selector, opts={})
       adapter.delete_selection(model, selector, opts)
     end

     # ------------------------------------
     
     attr_reader :name
     
     private
     
     # Initializes a new repository
     #
     def initialize(name)
       @name = name.to_sym
     end
     
     # Parses an URI
     #  
     #   An URI has this form : /model/id
     #   Examples : /content/es/mycontent, content is the model and es/mycontent is the identifier
     #   
     # @param [String] uri
     #   The resource identifier
     # 
     # @result [Hash]
     #   :model_name is the model name
     #   :key is the resource key 
     #
     def parse_uri(uri)
        
        parse_info = uri.match(/(\/\w+)\/(.+)/).to_a.slice(1,2)
        
        if not parse_info
          raise "#{uri} is not a valid uri. The format is /model/id"
        end
                
        {:path_prefix => parse_info[0], :id => parse_info[1]}
        
     end

  end
end