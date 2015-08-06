module Kantox
  module Mongo
    module Spitter
      class GenericSucker
        def self.inherited child
          child.send :include, MongoMapper::Document

          TracePoint.new(:end) do |tp|
            if tp.self.name == "#{child}"
              tp.self.const_get('FIELDS').each do |name, type|
                tp.self.class_eval "key :#{name}, #{type}"
              end

              class << tp.self
                # def yo
                # end
              end
            end
          end.enable
        end
      end
    end
  end
end
