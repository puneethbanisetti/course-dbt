{{
  config(
    materialized='table'
  )
}}

SELECT 
    USER_ID,
    NAME,
    EMAIL,
    PHONE_NUMBER,
    CREATED_AT,
    UPDATED_AT,
    ADDRESS_ID
FROM {{ ref('stg_users') }}