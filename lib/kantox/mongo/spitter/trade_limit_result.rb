require_relative 'generic_sucker'

module Kantox
  module Mongo
    module Spitter
      class TradeLimitResult < GenericSucker
        FIELDS = {
          company: Integer,
          predicted_trade_limit: Float
        }

        TARGET = {
          table: :profiles,
          id: {
            local: :id,
            remote: :company
          },
          map: {
            predicted_trade_limit: {
              field: :market_trade_limit_cents_prediction,
              converter: ->(val){ val.to_i }
            }
          }
        }

        def self.yo
          TARGET[:map].map do |remote, local|
            query = case_when_sql remote
            query = "UPDATE `#{TARGET[:table]}` SET `#{local[:field]}` = #{query}"
            ActiveRecord::Base.connection.execute query
          end
        end

        def self.case_when_sql field
          [
            "CASE `#{TARGET[:id][:local]}`",
            all.map do |row|
              id = row.public_send TARGET[:id][:remote]
              val = row.public_send field
              # check if converter is Symbol => call it on val
              val = case TARGET[:map][field][:converter]
                    when String, Symbol then val.public_send TARGET[:map][field][:converter]
                    when Proc then TARGET[:map][field][:converter].call(val)
                    else val
                    end
              val = "'#{val}'" unless val.is_a?(Numeric)  # Date??
              "\tWHEN '#{id}' THEN #{val}"
            end,
            "ELSE `#{TARGET[:map][field][:field]}`",
            'END'
          ].join $/
        end
      end
    end
  end
end
