require 'mongo' unless defined?Mongo::Connection
require 'ysd_md_system' unless defined?Model::System::Chrono

module Persistence
  module Adapters
    #
    # MongoDB adapter
    #
    class MongodbAdapter < AbstractAdapter
       include Model::System::Chrono
       
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
            
          result, duration_ms = execute_and_chrono do 
          
            with_connection do |connection|
              begin
                database = connection.db(options[:database])      
                attributes = resource.attributes.dup
                if not resource['_id']
                  attributes.merge!({'_id' => resource.key}) 
                end
                document = database[resource.model.storage_name].insert(attributes, opts.merge(:safe => true))
              rescue
                Persistence.logger.fatal('Persistence') {"ERROR INSERTING #{resource.model} #{$!}"} if Persistence.logger
                raise 
              end 
    
            end            
    
          end
          
          Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) INSERT #{resource.model}"} if Persistence.logger
      
       end
  
       #
       # Update a resource
       #
       def update(resource, opts={})
  
         id = resource['_id'] || resource.key
  
         result, duration_ms = execute_and_chrono do
           with_connection do |connection|
             begin
               database = connection.db(options[:database])
               database[resource.model.storage_name].update({'_id' => id}, resource.attributes, opts.merge(:safe => true))  
               # TODO : Analizar la respuesta de la actualizacion [Hash] ( key "n" indica el numero de operaciones)
             rescue
                Persistence.logger.fatal('Persistence') {"ERROR UPDATING #{resource.model} #{id} #{$!}"} if Persistence.logger
                raise                             
             end
           end
         end

         Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) UPDATE #{resource.model} #{id}"} if Persistence.logger      
         
         resource
      
       end
  
       # 
       # Deletes a resource
       #
       def delete(resource, opts={})
       
         id = resource['_id'] || resource.key
       
         result, duration_ms = execute_and_chrono do
           with_connection do |connection|
             begin
               database = connection.db(options[:database])
               database[resource.model.storage_name].remove({'_id' => id}, opts.merge(:safe => true))
               # TODO : Analizar la respuesta de la actualizacion [Hash] ( key "n" indica el numero de operaciones)
             rescue
                Persistence.logger.fatal('Persistence') {"ERROR DELETING #{resource.model} #{id} #{$!}"} if Persistence.logger
                raise                             
             end
           end
         end       

         Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) DELETE #{resource.model} #{resource['_id']}"} if Persistence.logger       

       end  
    
       # ---- Retrieving information methods ---------------------------------
  
       # Get a resource by its id
       #
       def get(model, id, opts={})                 
         
         result = nil
         
         result, duration_ms = execute_and_chrono do
           with_connection do |connection|
             begin
               database = connection.db(options[:database])     
               result = database[model.storage_name].find_one({:_id => id}, opts) 
             rescue
                Persistence.logger.fatal('Persistence') {"ERROR FINDING #{model} #{id} #{$!}"} if Persistence.logger
                raise                             
             end
           end           
         end

         Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) FIND ONE #{model} #{id}"} if Persistence.logger
       
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
         result, duration_ms = execute_and_chrono do 
           with_connection do |connection|
             begin
               database = connection.db(options[:database])    
               database[query.model.storage_name].find(conditions, q_options).to_a.map do |element|
                 {:path => query.model.build_path(element['_id'].to_s), :metadata => element }
               end
             rescue
                Persistence.logger.fatal('Persistence') {"ERROR QUERYING #{resource.model} #{conditions.inspect if conditions} #{$!}"} if Persistence.logger
                raise                             
             end                
           end           
         end
         
         Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) QUERY in #{query.model} #{conditions.inspect if conditions}"} if Persistence.logger       
         
         result
                     
       end
  
       # Count the number of resources that match the query
       #
       def count(query)
       
         # Build the conditions
         conditions = build_conditions(query.conditions)
         
         num_of_docs = 0
         
         num_of_docs, duration_ms = execute_and_chrono do 
           with_connection do |connection|
             begin
               database = connection.db(options[:database])
               num_of_docs = database[query.model.storage_name].count({:query => conditions})
             rescue
                Persistence.logger.fatal('Persistence') {"ERROR COUNTING #{resource.model} #{conditions.inspect if conditions} #{$!}"} if Persistence.logger
                raise              
             end
           end
         end
         
         Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) COUNTING in #{query.model} #{conditions.inspect if conditions}"} if Persistence.logger
         
         num_of_docs
       
       end
  
       private
 
       # Build the conditions from the query conditions
       #
       def build_conditions(conditions)
         
         conditions.build_mongodb if conditions
         
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
     
         connection, duration_ms = execute_and_chrono do
           
           begin
             connection = Mongo::Connection.new(options[:host], options[:port])
             connection.add_auth(options[:database], options[:username], options[:password])
             connection.apply_saved_authentication
             connection
           rescue
             Persistence.logger.fatal('Persistence') {" (#{duration_ms}) ERROR GETTING MongoDB CONNECTION"} if Persistence.logger
             raise
           end
           
         end
    
         #Persistence.logger.debug('Persistence') {" (#{'%1.5f' % duration_ms}) GETTING MongoDB CONNECTION"} if Persistence.logger
    
         connection
  
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