require 'stringio' unless defined?StringIO
require 'support/ysd-persistence-hook'
require 'ysd-persistence-support'
require 'ysd-persistence-repository'
require 'ysd-persistence-adapters'
require 'adapters/ysd-persistence-abstract-adapter'
require 'ysd-persistence-resource'
require 'ysd-persistence-model'
require 'ysd-persistence-model-property'
require 'ysd-persistence-model-hook'
require 'ysd-persistence-query'
require 'ysd-persistence-property'
require 'support/ysd-persistence-logger'
require 'logger'

require 'property/ysd-persistence-property-object'
require 'property/ysd-persistence-property-integer'
require 'property/ysd-persistence-property-datetime'
require 'property/ysd-persistence-property-string'

#
#  Configure a repository
#
# require 'ysd_persistence_content'
# Persistence.setup(:default, {:adapter=>'memory'})
#  Persistence.repository 
#
module Persistence
  
  # Setups a connection to a data-store
  #
  # @param [Symbol] name
  #   name for the context, defaults to :default
  # @param [Hash(Symbol => String)]
  #
  # Example:
  #
  # Persistence.setup
  #
  def self.setup(*args)
    adapter = args.first
    adapter = Adapters.new(*args)
    Repository.adapters[adapter.name] = adapter
  end

  # Gets a repository
  #
  def self.repository(name=nil)
        
    # Gets the repository context
    context = Repository.context
    
    current_repository = if name
      name = name.to_sym
      context.detect do |repository| repository.name == name end
    else
      name = Repository.default_name
      context.last
    end
    
    current_repository ||= Repository.new(name)
  
    if block_given?
      current_repository.scope do |*block_args| yield(*block_args) end
    else
      current_repository
    end
  
  end
  
end

# Assign the default logger
Persistence.logger= ::Logger.new($stdout)
Persistence.logger.level = Logger::FATAL
