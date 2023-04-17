How many users do we have? - 130

"select count(distinct user_id) from dev_db.dbt_puneethbgv1996gmailcom.stg_users"


On average, how many orders do we receive per hour? - 15.04

"select count(distinct order_id)/24 from dev_db.dbt_puneethbgv1996gmailcom.stg_orders"


On average, how long does an order take from being placed to being delivered? - 3.9 days or 93.4 hours

"select avg(datediff(hour, created_at, delivered_at)) from dev_db.dbt_puneethbgv1996gmailcom.stg_orders where delivered_at is not null"


How many users have only made one purchase? Two purchases? Three+ purchases?

One purchase: 25

"select count(distinct user_id) from (select user_id from dev_db.dbt_puneethbgv1996gmailcom.stg_orders qualify count(distinct order_id) over(partition by user_id) = 1)"

Two purchases: 28

"select count(distinct user_id) from (select user_id from dev_db.dbt_puneethbgv1996gmailcom.stg_orders qualify count(distinct order_id) over(partition by user_id) = 2)"

Three+ purchases: 37

"select count(distinct user_id) from (select user_id from dev_db.dbt_puneethbgv1996gmailcom.stg_orders qualify count(distinct order_id) over(partition by user_id) > 3)"


On average, how many unique sessions do we have per hour? - 24.08

"select count(distinct session_id)/24 from dev_db.dbt_puneethbgv1996gmailcom.stg_events"