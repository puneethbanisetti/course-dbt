# Analytics engineering with dbt - Greenery

## How many users do we have?
### 130 users

```sql
select count(distinct user_id) from dev_db.dbt_puneethbgv1996gmailcom.stg_users
```

## On average, how many orders do we receive per hour?
### 7.52 orders per hour on average

```sql
select avg(distinct_orders) from
(select date_trunc(hour, created_at), count(distinct order_id) as distinct_orders
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
group by 1)
```

## On average, how long does an order take from being placed to being delivered?
### 3.9 days or 93.4 hours

```sql
select avg(datediff(hour, created_at, delivered_at))
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
where delivered_at is not null
```

## How many users have only made one purchase? Two purchases? Three+ purchases?

### One purchase: 25

```sql
select count(distinct user_id) from
(select user_id
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
qualify count(distinct order_id) over(partition by user_id) = 1)
```

### Two purchases: 28

```sql
select count(distinct user_id) from
(select user_id
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
qualify count(distinct order_id) over(partition by user_id) = 2)
```

### Three+ purchases: 37

```sql
select count(distinct user_id) from
(select user_id
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
qualify count(distinct order_id) over(partition by user_id) > 3)
```


## On average, how many unique sessions do we have per hour?
### 16.32 unique sessions per hour on average

```sql
select avg(distinct_sessions) from
(select date_trunc(hour, created_at), count(distinct session_id) as distinct_sessions
from dev_db.dbt_puneethbgv1996gmailcom.stg_events
group by 1)
```