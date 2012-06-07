require 'mongo'

# Driver
# ------
# https://github.com/mongodb/mongo-ruby-driver
#
# Tutorials
# ---------
# http://api.mongodb.org/ruby/current/
# http://api.mongodb.org/ruby/current/file.TUTORIAL.html
#
# API
# ---------
# http://api.mongodb.org/ruby/current/Mongo/DB.html 
# http://api.mongodb.org/ruby/current/Mongo/Collection.html (count, drop, create_index, find, insert, update, map_reduce, save, remove) 
#
#
# HOWTO use the wrapper
# ---------------------
#
# MongoWrapper.setup(:default, { :host => 'my.host', :port => 'my.port', :database => 'my.database', :username => 'my.username', :password => 'my.password' })
#
# MongoWrapper.insert_document('articles', { '_id' => 'my-document', 'title' => 'my-document', 'author' => 'Juan', 'body' => 'text body', 'keywords' => 'un, dos, tres'})
#
#
module MongoWrapper
 
  @@repositories = {}
  
  #
  # Configure a repository to access a database
  #
  # options :
  #
  #   :host
  #   :port
  #   :database
  #   :username
  #   :password
  #
  def self.setup(repository, options)
  
    @@repositories[repository] = options
    
  end
  
  #
  # Insert a document in a collection
  #
  def self.insert_document(collection_name, document, options={})
  
    with_connection do |connection|
      
      database = connection.db(@@repositories[:default][:database])
      database[collection_name].insert(document,options)
      
    end
    
    return document
  
  end
  
  #
  # Update a document
  #
  def self.update_document(collection_name, document, options={})
  
    with_connection do |connection|
    
      database = connection.db(@@repositories[:default][:database])
      database[collection_name].update({'_id' => document['_id']}, document, options)
    
    end
    
    return document  
  
  end
  
  #
  # Update document property
  #
  def self.update_document_property(collection_name, document_id, properties_values, options={})
  
    with_connection do |connection|
      
      database = connection.db(@@repositories[:default][:database])
      database[collection_name].update({'_id' => document_id}, { "$set" => properties_values }, options)
    
    end  
  
  end
  
  #
  # Delete documents
  #
  def self.delete_documents(collection_name, selector, options={})
  
    with_connection do |connection|
    
      database = connection.db(@@repositories[:default][:database])
      database[collection_name].remove(selector, options)
    
    end
  
  end  
  
  #
  # Get a document
  #
  def self.get_document(collection_name, document_id, options={})
  
    with_connection do |connection|
    
      database = connection.db(@@repositories[:default][:database])
      document = database[collection_name].find_one( { :_id => document_id }, options )
    
    end  
  
  end
  
  #
  # Performs a block on a collection
  #
  def self.with_collection(collection_name)
  
    with_connection do |connection|
    
      database = connection.db(@@repositories[:default][:database])
      yield database[collection_name]
    
    end
    
  end    
  
  private
 
  # @api private
  
  def self.with_connection 
  
  begin      
    yield connection = open_connection  
  rescue Exception => exception 
    raise
  ensure 
    close_connection connection
  end
    
  end
  
  #
  # Opens a MongoDB connection
  #
  def self.open_connection
     
    connection = Mongo::Connection.new(@@repositories[:default][:host], @@repositories[:default][:port])
    connection.add_auth(@@repositories[:default][:database], @@repositories[:default][:username], @@repositories[:default][:password])
    connection.apply_saved_authentication
    
    return connection
  
  end
  
  #
  # Close a MongoDB connection
  #
  def self.close_connection(connection)
  
    connection.close
  
  end
   
end 
