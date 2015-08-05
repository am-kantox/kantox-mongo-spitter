require 'mongo_mapper'

require 'kantox/mongo/spitter/version'
require 'kantox/mongo/spitter/generic_spitter'
require 'kantox/mongo/spitter/generic_sucker'

require 'kantox/mongo/spitter/trade_limit_data'

module Kantox
  module Mongo
    module Spitter
      DB_NAME = "kantox_rm"

      INSTANCES = {
        spitters: [TradeLimitData],
        suckers:  []
      }

      def instances lazy = false
        lazy ?  INSTANCES :
                @instances ||=
                  ObjectSpace.each_object(Class).inject({spitters: [], suckers: []}) do |memo, k|
                    if k < GenericSpitter
                      memo[:spitters] << k
                    elsif k < GenericSucker
                      memo[:suckers] << k
                    end
                    memo
                  end
      end

      def spit database = nil
        MongoMapper.database = (database || DB_NAME) % { datestamp: Time.now.strftime('%Y%m%d_%H%M') }
        instances[:spitters].map &:yo
      end

      def suck database = nil
        MongoMapper.database = (database || DB_NAME) % { datestamp: Time.now.strftime('%Y%m%d_%H%M') }
        instances[:suckers].map &:yo
      end

      module_function :instances, :spit, :suck
    end
  end
end
