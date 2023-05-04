{{
  config(
    materialized='table'
  )
}}

with cte1 as ( {{ conversion_rate_by_field('product_name') }} )

select product_name, conversion_rate
from cte1