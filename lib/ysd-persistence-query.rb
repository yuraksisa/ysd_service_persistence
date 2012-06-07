module Persistence
  #
  # Represents a model query against a repository
  #
  class Query
    include Persistence::Support::Properties
    
    # The query repository
    attr_reader :repository
    
    # The query model
    attr_reader :model
    
    # The query fields
    attr_reader :fields
    
    # The query conditions
    attr_reader :conditions
    
    # The query order
    attr_reader :order
    
    # The query limit
    attr_reader :limit
    
    # The query offset
    attr_reader :offset
    
    #
    # @param [Repository] repository
    # @param [Model] model
    # @param [Hash] options
    #   {:fields=>[:type,:language,:title], :conditions=>{:language=>'es',:type=>'page'}, :order=>[[:title,:asc]], :limit=>1}
    #
    def initialize(repository, model, options={})
    
      @repository = repository
      @model = model

      options = process_hash(options)

      @fields = options[:fields]?(options[:fields].dup.freeze):[]
      @conditions = options[:conditions]?(options[:conditions].dup.freeze):{}   
      @order = options[:order]?(options[:order].dup.freeze):[] 
      @limit = options[:limit]
      @offset = options[:offset] || 0
    
    end
    
    # @param [Array] records
    #   the records to filter
    #
    def filter_records(records)
          
      records = match_records(records) if conditions
      records = sort_records(records) if order 
      records = limit_records(records) if limit and limit > 0
      records = select_fields(records) if fields and fields.length > 0
      
      records
    
    end
    
    private
    
    # Select the choosen fields
    # 
    # @param [Array] records
    #  records to match
    #
    # @return [Array] 
    #
    def select_fields(records) 

      records.each do |record|
            
        record[:metadata].delete_if do |key,value| 
          not (fields.map{|element| element.to_sym}).index(key.to_sym) 
        end
                     
      end
      
    end
    
    # Return the records which match the conditions
    #
    # @param [Array] records
    #  records to match
    #
    # @return [Array]
    #  matched records
    #
    def match_records(records)
      
      records.select do |record|
        
        return_value = true
        
        conditions.each do |key, value|
        
          if value.kind_of?(Array)
            if record[:metadata][key.to_sym].kind_of?(Array)
              if (record[:metadata][key.to_sym] & value).length == 0
                return_value = false
                break
              end
            else 
              if value.index(record[:metadata][key.to_sym]).nil?
                return_value = false
                break
              end
            end
          else 
            if record[:metadata][key.to_sym].kind_of?(Array)
              puts "record : #{record[:metadata][:categories].to_json} key: #{key.to_sym} value:#{value} #{value.class.name}"
              if record[:metadata][key.to_sym].index(value).nil?
                return_value = false
                break
              end
            else    
              if record[:metadata][key.to_sym] != value
                return_value = false
                break
              end
            end
          end
          
        end
    
        return_value
        
      end
          
    end
    
    # Sort the records
    # 
    # @param [Array]
    #   records to sort
    #
    # @return [Array]
    #   sorted records
    #
    def sort_records(records)
    
      records.sort do |x,y| 
        
        value = 0
         
        order.each do |order_element|
        
          if x[:metadata][order_element.first] == y[:metadata][order_element.first]
            next
          else
            value = (order_element.last == :asc)? x[:metadata][order_element.first] <=> y[:metadata][order_element.first] : y[:metadata][order_element.first] <=> x[:metadata][order_element.first]
            break
          end
                  
        end 
        
        value
    
      end
    
    end
    
    # Limit the records (take a subset)
    #
    #
    def limit_records(records)
    
      records.slice(offset, limit)
    
    end
    
  
  end # end Query
end # end Persistence