{{
  config(
    materialized='table'
  )
}}

SELECT 
    orders.ORDER_ID,
    orders.USER_ID,
    users.name as user_name,
    orders.PROMO_ID,
    orders.ADDRESS_ID,
    orders.CREATED_AT,
    orders.ORDER_COST,
    orders.SHIPPING_COST,
    case when orders.promo_id is null then 0 else promos.discount end as discount,
	  orders.ORDER_TOTAL,
	  orders.TRACKING_ID,
	  orders.SHIPPING_SERVICE,
	  orders.ESTIMATED_DELIVERY_AT,
	  orders.DELIVERED_AT,
	  orders.STATUS
FROM {{ ref('stg_orders') }} orders
left join {{ ref('stg_users') }} users
on orders.user_id = users.user_id
left join {{ ref('stg_promos') }} promos
on orders.promo_id = promos.promo_id