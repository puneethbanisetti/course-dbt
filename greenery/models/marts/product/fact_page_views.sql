{{
  config(
    materialized='table'
  )
}}

SELECT 
    events.event_id,
    events.session_id,
    events.user_id,
    events.created_at,
    events.event_type,
    events.order_id,
    order_items.product_id,
    products.name as product_name,
    products.price as product_price,
    order_items.quantity as order_product_quantity
FROM {{ ref('stg_events') }} events
left join {{ ref('stg_order_items') }} order_items
on order_items.order_id = events.order_id or order_items.product_id = events.product_id
left join {{ ref('stg_products') }} products
on order_items.product_id = products.product_id