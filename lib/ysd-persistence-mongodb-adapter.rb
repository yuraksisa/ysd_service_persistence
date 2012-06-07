require 'mongo'

module Persistence
  module Adapters
    #
    # MongoDB adapter
    #
    class MongodbAdapter < AbstractAdapter
 
       # Initialize
       #
       def initialize(name, options)
         super
       end
    
       # -------- CRUD BASIC methods : CReate, Update, Delete ---------
    
       #
       # Create a resource
       #
       def create(resource, opts={})
            
          with_connection do |connection|
      
            database = connection.db(options[:database])      
            
            attributes = resource.attributes.dup
            if not resource['_id']
              attributes.merge!({'_id' => resource.key}) 
            end
            
            document = database[resource.model.storage_name].insert(attributes, opts.merge(:safe => true))
    
          end
      
       end
  
       #
       # Update a resource
       #
       def update(resource, opts={})
  
         with_connection do |connection|
    
           database = connection.db(options[:database])
           database[resource.model.storage_name].update({'_id' => resource['_id'] || resource.key}, resource.attributes, opts.merge(:safe => true))  
           # TODO : Analizar la respuesta de la actualizacion [Hash] ( key "n" indica el numero de operaciones)
         
         end
      
         resource
      
       end
  
       # 
       # Deletes a resource
       #
       def delete(resource, opts={})
       
         with_connection do |connection|
        
           database = connection.db(options[:database])
           database[resource.model.storage_name].remove({'_id' => resource['_id'] || resource.key}, opts.merge(:safe => true))
           # TODO : Analizar la respuesta de la actualizacion [Hash] ( key "n" indica el numero de operaciones)
      
         end       
       
       end  
    
       # ---- Retrieving information methods ---------------------------------
  
       # Get a resource by its id
       #
       def get(model, id, opts={})                 
         result = nil
         
         with_connection do |connection|
           database = connection.db(options[:database])     
           result = database[model.storage_name].find_one({:_id => id}, opts) 
         end
       
         if result
           {:path => model.build_path(result['_id']), :metadata => result}
         end
         
       end  
  
       # Read resources from a data store
       # 
       def read(query)
         
         # Build the conditions 
         conditions = build_conditions(query.conditions)
         
         # Build the options
         q_options = {}
         add_fields!(q_options, query.fields)
         add_order!(q_options, query.order)
         add_limit_offset!(q_options, query.limit, query.offset)
                          
         # Query         
         result = []
         with_connection do |connection|
           database = connection.db(options[:database])    
           result = database[query.model.storage_name].find(conditions, q_options).to_a.map do |element|
             {:path => query.model.build_path(element['_id'].to_s), :metadata => element }
           end 
         end       
         
         result
                     
       end
  
       # Count the number of resources that match the query
       #
       def count(query)
       
         # Build the conditions
         conditions = build_conditions(query.conditions)
         
         num_of_docs = 0
         with_connection do |connection|
           database = connection.db(options[:database])
           num_of_docs = database[query.model.storage_name].count({:query => conditions})
         end
         
         num_of_docs
       
       end
  
      
  
       # --------------------------------------------
  
       #
       # Updates a set of resources
       #
#       def update(model, selector, attributes, opts={})
#  
#         with_connection do |connection|
#      
#           database = connection.db(options[:database])
#           database[model.storage_name].update(selector, { "$set" => attributes }, opts)
#    
#         end  
#  
#       end
  
       #
       # Deletes a set of resources
       #
#       def delete(model, selector, opts={})
#  
#         with_connection do |connection|
#           database = connection.db(options[:database])
#           database[model.storage_name].remove(selector, opts)
#         end
#  
#       end         
 
       private
 
       # Build the conditions from the query conditions
       #
       def build_conditions(conditions)
         return conditions
       end
 
       # Add the fields
       def add_fields!(options, fields)
       
         if fields.length > 0
           options.store(:fields, fields) 
         end
         
       end
 
       # Add the order
       def add_order!(options, order)
         
         order_elements = []
         
         order.each do |field, order|
           order_elements.push([field, order])
         end
       
         options.store(:sort, order_elements) if order_elements.length > 0
       
       end
 
       # Add the limit and offset to the options
       def add_limit_offset!(options, limit, offset)
         if limit
           options.store(:limit, limit)
         end
         
         if limit and offset > 0
           options.store(:skip, offset)
         end
       end
 
       # @api private
       
       # with_connection
       #
       def with_connection 
       
         begin      
           yield connection = open_connection  
         rescue Exception => exception 
           raise
         ensure 
           close_connection connection if connection
         end
    
       end
  
       #
       # Opens a MongoDB connection
       #
       def open_connection
     
         connection = Mongo::Connection.new(options[:host], options[:port])
         connection.add_auth(options[:database], options[:username], options[:password])
         connection.apply_saved_authentication
    
         return connection
  
       end
  
       #
       # Close a MongoDB connection
       #
       def close_connection(connection)
  
         connection.close
  
       end
    end # end MongodbAdapter
  end # end Adapters
end # end Persistence