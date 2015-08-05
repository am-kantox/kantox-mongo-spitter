require_relative 'generic_sucker'

module Kantox
  module Mongo
    module Spitter
      class TradeLimitResult < GenericSucker
        TARGET = {
          table: :profiles,
          id: {
            local: :id,
            remote: :id
          },
          map: {
            prediction: :trade_limit_prediction
          }
        }

        def yo
          subsql = TARGET[:map].map do |remote, local|
            sql = case_when_sql remote
            sql = "UPDATE `#{TARGET[:table]}` SET `#{local}` = #{sql}"
            ActiveRecord::Base.connection.execute sql
          end
        end

        def self.case_when_sql field
          [
            "CASE `#{TARGET[:id][:remote]}`",
            all.map do |row|
              id = row.public_send TARGET[:id][:remote]
              val = row.public_send field
              "\tWHEN '#{id}' THEN '#{val}'"
            end,
            "ELSE `#{TARGET[:map][field]}`",
            'END'
          ].join $/
        end
      end
    end
  end
end
