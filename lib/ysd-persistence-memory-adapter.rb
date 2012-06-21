module Persistence
  module Adapters
    #
    # require 'ysd_persistence_content'
    # Persitence.setup(:default, {:adapter=>'memory'})
    #
    class MemoryAdapter < AbstractAdapter
      
      # @param [Symbol] name
      # @param [Hash] options 
      #   The repository options
      # 
      def initialize(name, options)
        super
        @records = {}        
      end
  
      # -------- CRUD BASIC methods : CReate, Update, Delete ----------------
  
      #
      # Create a resource
      #
      def create(resource, opts={})
   
        unless @records.has_key?(resource.model.storage_name)
          @records[resource.model.storage_name] = {}
        end
   
        @records[resource.model.storage_name][resource.key] = resource.attributes
      
      end
      
      #
      # Update a resource
      #
      def update(resource, opts={})
       
        unless @records.has_key?(resource.model.storage_name)
          @records[resource.model.storage_name] = {}
        end
        
        @records[resource.model.storage_name][resource.key] = resource.attributes if @records[resource.model.storage_name][resource.key]
       
      end
      
      #
      # Delete a resource
      #
      def delete(resource, opts={})
      
        unless @records.has_key?(resource.model.storage_name)
          @records[resource.model.storage_name] = {}
        end      
      
        @records[resource.model.storage_name].delete(resource.key) if @records[resource.model.storage_name][resource.key]
        
      end
  
      # ---- Retrieving information methods ---------------------------------
  
      #
      # @param [String] uri
      #   The Uniform Resource Identifier
      #
      def get(model, id, opts={})
                     
        result = nil          
                                                
        if @records[model.storage_name] and @records[model.storage_name][id]
          result = {:path => model.build_path(id), :metadata => @records[model.storage_name][id]}
        end

        result
      
      end
  
      #
      # Read resources
      #
      def read(query)
       
        result = []       
        
        if @records[query.model.storage_name]
        
          @records[query.model.storage_name].each do |key, value|
             result << {:path => query.model.build_path(key), :metadata => value.dup}  
          end
        
        end
                     
        query.filter_records(result)
        
      end
      
      # Count the number of resources that match the query
      # 
      # @param [Query] query
      #
      # @return [Numeric] 
      #   the number of elements that match the query
      # 
      def count(query)
        read(query).length
      end
        
    end #MemoryAdapter
  end #Adapters
end #Persistence