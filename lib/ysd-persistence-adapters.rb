module Persistence
  module Adapters
    def self.new(repository_name, options)
      adapter_class(options[:adapter]).new(repository_name, options)
    end
    
    class << self
      
      private
    
      # return the adapter class constant
      #  
      # adapter_class('mongodb') => Persistence::Adapters::MongodbAdapter
      #
      def adapter_class(name)
        class_name = (name.downcase.capitalize<<'Adapter').to_sym
        load_adapter(name) unless const_defined?(class_name)
        const_get(class_name)
      end
    
      # require the adapter library
      #
      def load_adapter(name)
        require "ysd-persistence-#{name}-adapter"
      end
    end
     
  end
end