module Persistence
  module Support
    
    module Properties 
        
      #
      #
      def process_hash(hash)

       checked_hash = {}
       hash.each do |key,value| checked_hash.store(key.to_sym,value.kind_of?(Hash)?process_hash(value):value) end
       
       checked_hash
       
      end
            
    end # ContentExtract
  end # end Support
end # end Persistence