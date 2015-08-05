require_relative 'generic_spitter'

module Kantox
  module Mongo
    module Spitter
      # select `bid_sides`.`id` as `bid_side_id`,
      #    `profiles`.`company_name` as `company`,
      #    `profiles`.`same_day` as `same_day`,
      #    `profiles`.`created_at` as`company_created_at`,
      #    `profiles`.`annual_fx` as `annual_fx`,
      #    `profiles`.`auto_vip` as `auto_vip`,
      #    `profiles`.`market_trade_limit_cents` as `trade_limit`,
      #    `hedges`.`normalized_amount_cents` as `bought_sold`,
      #    `bid_sides`.`created_at` as `execution_date`,
      #    `clearings`.`workflow_state` as `status`
      #
      # from ((((((`bid_sides`
      #   join `bids` on ((`bids`.`id` = `bid_sides`.`bid_id`)))
      #     join `hedges` on((`hedges`.`id` = `bid_sides`.`hedge_id`)))
      #       join `hedges` `hedges_bid_sides_join` on ((`hedges_bid_sides_join`.`id` = `bid_sides`.`hedge_id`)))
      #         join `profiles` on((`profiles`.`id` = `hedges_bid_sides_join`.`company_id`)))
      #           join `hedges` `hedges_bid_sides_join_2` on((`hedges_bid_sides_join_2`.`id` = `bid_sides`.`hedge_id`)))
      #             join `clearings` on(((`clearings`.`hedge_id` = `hedges`.`id`) and (`clearings`.`type` = 'OrderClearing'))))
      # where ((`bids`.`workflow_state` = 'accepted') and
      #        (`hedges`.`workflow_state` = 'closed_to_trading') and
      #        (`profiles`.`group_id` = 3 or `profiles`.`group_id` = 8  or `profiles`.`group_id` = 9 ));
      class TradeLimitData < GenericSpitter
        SQL = %Q{ select `bid_sides`.`id` as `bid_side_id`,
            		 `profiles`.`id` as `company`,
            		 `profiles`.`same_day` as `same_day`,
            		 `profiles`.`created_at` as`company_created_at`,
            		 `profiles`.`annual_fx` as `annual_fx`,
            		 `profiles`.`auto_vip` as `auto_vip`,
            		 `profiles`.`market_trade_limit_cents` as `trade_limit`,
            		 `hedges`.`normalized_amount_cents` as `bought_sold`,
            		 `bid_sides`.`created_at` as `execution_date`,
            		 `clearings`.`workflow_state` as `status`

            		  from `bid_sides`
            			join `bids` on (`bids`.`id` = `bid_sides`.`bid_id`)
            			  join `hedges` on (`hedges`.`id` = `bid_sides`.`hedge_id`)
            				join `profiles` on (`profiles`.`id` = `hedges`.`company_id`)
            				  join `clearings` on ((`clearings`.`hedge_id` = `hedges`.`id`) and (`clearings`.`type` = 'OrderClearing'))
            		  where ((`bids`.`workflow_state` = 'accepted') and
            				 (`hedges`.`workflow_state` = 'closed_to_trading') and
            				 (`profiles`.`group_id` in (3, 8, 9) ) and
                     (`profiles`.`id` not in (212, 213) ) ) }

        FIELDS = {
          bid_side_id: Integer,
          company: Integer,
          same_day: Integer,
          company_created_at: Time,
          annual_fx: Integer,
          auto_vip: Integer,
          trade_limit: Integer,
          bought_sold: Integer,
          execution_date: Time,
          status: String
        }
      end
    end
  end
end
