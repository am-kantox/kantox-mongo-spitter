module Kantox
  module Mongo
    module Spitter
      class GenericTable
        include MongoMapper::Document

        def self.inherited child
          TracePoint.new(:end) do |tp|
            if tp.self.name == "#{child}"
              tp.self.const_get('FIELDS').each do |name, type|
                tp.self.class_eval "key :#{name}, #{type}"
              end

              class << tp.self
                def yo
                  ActiveRecord::Base.connection.execute(const_get('SQL')).map do |r|
                    new.tap do |tld|
                      const_get('FIELDS').keys.each.with_index do |f, idx|
                        tld.send "#{f}=", r[idx]
                      end
                      tld.save
                    end
                  end
                end
              end
            end
          end.enable
        end
      end
    end
  end
end
