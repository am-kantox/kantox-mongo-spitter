require_relative 'generic_sucker'

module Kantox
  module Mongo
    module Spitter
      class TradeLimitResult < GenericSucker
        FIELDS = {
          company: Integer
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
              converter: ->(val){ (val * 100).to_i }
            }
          }
        }

        def self.yo
          TARGET[:map].map do |remote, local|
            require 'pry'
            binding.pry
            query = case_when_sql remote
            query = "UPDATE `#{TARGET[:table]}` SET `#{local[:field]}` = #{query}"
            binding.pry
            ActiveRecord::Base.connection.execute query
            binding.pry
          end
        end

        def self.case_when_sql field
          [
            "CASE `#{TARGET[:id][:remote]}`",
            all.map do |row|
              id = row.public_send TARGET[:id][:remote]
              val = row.public_send field
              val = TARGET[:map][field][:converter].call(val) if TARGET[:map][field][:converter]
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
