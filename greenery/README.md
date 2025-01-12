# Analytics engineering with dbt - Greenery - WEEK 4

## Snapshots
### I was late with my Week 3 submission and I happened to capture the changes made for Week 4 with my Week 3 submission. This led to me missing the changes that happened in Week 3. I jumped straight from Week 2 to Week 4.

## How are our users moving through the product funnel?
### Our greenery project's product funnel starts with the page view sessions. The "add to cart" conversion is about 80.8%, "checkout" conversion is about 62.45% and "package shipped" conversion is about 57.96%.
```sql
select count(distinct session_id) as overall_sessions,
count(distinct case when event_type = 'page_view' then session_id else null end) as page_view_sessions,
count(distinct case when event_type = 'add_to_cart' then session_id else null end) as add_to_cart_sessions,
count(distinct case when event_type = 'checkout' then session_id else null end) as checkout_sessions,
count(distinct case when event_type = 'package_shipped' then session_id else null end) as package_shipped_sessions
from dev_db.dbt_puneethbgv1996gmailcom.fact_page_views
```

## Which steps in the funnel have largest drop off points?
### I would believe we need to analyze the drop-off points starting from "add to cart" rather than "page view". strictly going by the numbers the highest drop off point is from "add to cart" to "checkout" where there is a 18.35% drop but I would be more concerned about the 4.49% drop from "checkout" to "package shipped". If my assumption about every package_shipped event getting logged in our events data is correct, this means that for these 4.49% of the sessions, the users never received their orders. We need to fix this issue before worrying about the drops higher up in the product funnel.

## Pitching the value of dbt to my organization
### My pitch would revolve around having a well structured and documented data modeling processes across use-cases through dbt. And also, how this helps in easily identifying any downstream implications from a potential change in a particular data model. Most importantly, dbt enables data devlopers to be more aware of how data is flowing through the system and help more informed choices.



# Analytics engineering with dbt - Greenery - WEEK 3

## What is our overall conversion rate?
### 62.45%

```sql
select count(distinct case when event_type = 'checkout' then session_id else null end)/count(distinct session_id) as conversion_rate
from dev_db.dbt_puneethbgv1996gmailcom.fact_page_views
```

## What is our conversion rate by product?
### These are the top 3 - String of pearls: 60.93%; Arrow Head: 55.55%; Cactus: 54.54%
```sql
select product_name, count(distinct case when event_type = 'checkout' then session_id else null end)/count(distinct session_id) as conversion_rate
from dev_db.dbt_puneethbgv1996gmailcom.fact_page_views
group by 1
order by 2 desc
```

## Inventory change from week 2 to week 3
### Philodendron, Bamboo, ZZ Plant, Monstera



# Analytics engineering with dbt - Greenery - WEEK 2

## What is our user repeat rate?
### 79.83%
```sql
select count(distinct case when purchases >= 2 then user_id else null end)/count(distinct user_id) as repeat_rate from
(select user_id, count(distinct order_id) as purchases
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
group by 1)
```

## What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?
### One obvious indicator would be to check whether the orders are being delivered on time. We have some data issues here where either the delivered_at or estimated_delivery_at is null for a significant number of records. But for ones where we have these dates available, we can check the % of orders that are being delivered on time for the repeat users and compare the same with the non-repeat users.
```sql
---REPEAT USERS
with repeat_users as
(select user_id from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
qualify count(distinct order_id) over(partition by user_id) >= 2)

select count(case when delivered_at <= estimated_delivery_at then order_id else null end)/count(order_id)
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
where delivered_at is not null and estimated_delivery_at is not null and user_id in (select user_id from repeat_users)
```
### 40.15%
```sql
---NON-REPEAT USERS
with repeat_users as
(select user_id from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
qualify count(distinct order_id) over(partition by user_id) >= 2)

select count(case when delivered_at <= estimated_delivery_at then order_id else null end)/count(order_id)
from dev_db.dbt_puneethbgv1996gmailcom.stg_orders
where delivered_at is not null and estimated_delivery_at is not null and user_id not in (select user_id from repeat_users)
```
### 31.81%
### This probably isn't a signifcant difference but we can probably add more detail to this analyses by considering the recency of when a particular started purchasing with us using the created_at field in the USERS table. It might not be right on our part to expect a user who just joined us last week to already make more than 2 purchases with us. So, we can probably consider the users who've been with us for more than a year and then segregate them into repeat/non-repeat users and perform the above analysis on this subset of data.

## PRODUCT MARTS

### One model was created in the product marts - fact_page_views. This model was created to help analysts answer a couple of important questions. Firstly, to understand the no. of page views by product. Also, to check which segment of products such as high-end, mid-end, lower-end generates most conversion through the product price field.

## TESTS

### Two tests were included both on the fact_orders model. First test is to check where order_total is less than the sum of order_cost and shipping_cost which should not be the case unless we have some hidden discounts. Second test is to check for cases where order_total is more than sum of order_cost and shipping_cost in which case there are some additional costs that we're probably missing to capture.

#### Both these tests failed. But when we dig into the data, nothing seems wrong. My hunch is that there is some floating point precision issue that might be causing this issue. In order to avoid this, we can probably reach out to the engineering team to figure out if there is some issue with the source data pipelines. This test can also be confirmed by running the following SQL on the raw data. This is not the exact test case but it outputs some records with this precision issue.
```sql
select *
from raw..orders
where ((order_cost + shipping_cost) != order_total) and promo_id is null
```

## Which products had their inventory change from week 1 to week 2? 
### Monstera, Philodendron, Pothos, String of pearls had their inventory change from Week 1 to Week 2
```sql
select distinct prd.name
from dev_db.dbt_puneethbgv1996gmailcom.inventory_snapshot inv
left join dev_db.dbt_puneethbgv1996gmailcom.stg_products prd
on inv.product_id = prd.product_id
qualify count(distinct dbt_scd_id) over(partition by inv.product_id) > 1
```



# Analytics engineering with dbt - Greenery - WEEK 1

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