{{
  config(
    materialized='table'
  )
}}

SELECT 
    PRODUCT_ID,
    NAME,
    PRICE,
    INVENTORY
FROM {{ ref('stg_products') }}