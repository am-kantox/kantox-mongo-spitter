module Kantox
  module Mongo
    module Spitter
      class GenericSpitter
        include MongoMapper::Document

        def self.inherited child
          TracePoint.new(:end) do |tp|
            if tp.self.name == "#{child}"
              tp.self.const_get('FIELDS').each do |name, type|
                type = String if type == Time
                tp.self.class_eval "key :#{name}, #{type}"
              end

              class << tp.self
                def yo
                  self.delete_all # clean up the collection
                  ActiveRecord::Base.connection.execute(const_get('SQL')).map do |r|
                    new.tap do |tld|
                      const_get('FIELDS').each.with_index do |f, idx|
                        tld.send "#{f.first}=", (f.last == Time) ? r[idx].strftime('%Y-%m-%dT%H:%M:%S.%3N%z') : r[idx]
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
