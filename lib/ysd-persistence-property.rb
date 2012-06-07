module Persistence
  # 
  # A model property
  #
  class Property
  
    attr_reader :name
    attr_reader :instance_variable_name
    attr_reader :reader_visibility
    attr_reader :writer_visibility
    
    def initialize(model, name, options)
      @model = model
      @name = name
      @instance_variable_name = "@#{@name}".freeze
      @options = options
      
      determine_visibility
    end
  
    # Determine the property visibility
    def determine_visibility
      
      default_accessor = @options.fetch(:accesosor, :public)
      
      @reader_visibility = @options.fetch(:reader, default_accessor)
      @writer_visibility = @options.fetch(:writer, default_accessor)
       
    end
  
  end
end  
