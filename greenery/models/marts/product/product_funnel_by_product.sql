{{
  config(
    materialized='table'
  )
}}

SELECT 
    product_name,
    product_price,
    count(distinct case when event_type = 'page_view' then session_id else null end) as page_view_count,
    count(distinct case when event_type = 'add_to_cart' then session_id else null end) as add_to_cart_count,
    count(distinct case when event_type = 'checkout' then session_id else null end) as checkout_count,
    count(distinct case when event_type = 'package_shipped' then session_id else null end) as package_shipped_count
FROM {{ ref('fact_page_views') }}
group by 1,2