-- The order_total should always be higher than the order_cost
select
    order_id
from {{ ref('fact_orders' )}}
where (order_cost + shipping_cost - discount) > order_total