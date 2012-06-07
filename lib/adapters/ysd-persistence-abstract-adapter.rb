module Persistence
  module Adapters
    class AbstractAdapter
    
      attr_reader :name
      attr_reader :options
    
      # Constructor
      #
      def initialize(name, options)
        @name = name
        @options = options
      end
      
      # ---------------------------
      
      # creates a resource
      #
      def create(resource, opts={})
        raise NotImplementedError, "#{self.class}#create not implemented"
      end
      
      # updates a resource
      #
      def update(resource, opts={})
        raise NotImplementedError, "#{self.class}#update not implemented"
      end

      # updates multiple resources
      #
      def update_selection(model, selector, attributes, opts={})
        raise NotImplementedError, "#{self.class}#update_selection not implemented"
      end
      
      # delete a resource
      #
      def delete(resource, opts={})
        raise NotImplementedError, "#{self.class}#delete not implemented"
      end
      
      # delete multiple resources
      #
      def delete_selection(model, selector, opts={})
        raise NotImplementedError, "#{self.class}#delete_selection not implemented"
      end
      
      # Retrieves a resource by its uri (Uniform Resource Identifier)
      def get(model, id, opts={})
        raise NotImplementedError, "#{self.class}#get not implemented"
      end
      
      # Reads resources from a data source
      #
      def read(query)
        raise NotImplementedError, "#{self.class}#read not implemented"
      end
         
      # Count the number of elements 
      #      
      def count(query)
        raise NotImplementedError, "#{self.class}#count not implemented"
      end      
            
      # Creates a query for a model
      #
      def new_query(repository, model, conditions={}, opts={})
        Query.new(repository, model, conditions, opts)
      end
            
    end
  end
end