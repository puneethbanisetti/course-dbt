-- The order_total should be a sum of order_cost and shipping_cost. If not, we're missing out on some additional costs
-- We're keeping this test exclusive from the order_total_less_than_order_cost test in order because that's probably a data issue and we don't want to account that in here
select
    order_id
from {{ ref('fact_orders' )}}
where ((order_cost + shipping_cost - discount) != order_total) and (order_total > (order_cost + shipping_cost - discount))