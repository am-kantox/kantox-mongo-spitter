require 'mongo_mapper'

require 'kantox/mongo/spitter/version'
require 'kantox/mongo/spitter/generic_table'
require 'kantox/mongo/spitter/trade_limit_data'

module Kantox
  module Mongo
    module Spitter
      def tables
        @tables ||= ObjectSpace.each_object(Class).inject([]) do |memo, k|
          memo << k if k < GenericTable
          memo
        end
      end

      def yo database = nil
        MongoMapper.database = database || "kantox_mongo_#{Time.now.strftime('%Y%M%d_%H%M')}"
        tables.map &:yo
      end
      module_function :tables, :yo
    end
  end
end
