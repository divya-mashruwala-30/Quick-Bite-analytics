set search_path to quickbite_db;
select * from fact_orders;

query 1:- monthly orders pre crisis vs crisis

SELECT CASE
        WHEN month_num BETWEEN 1 AND 5 THEN 'Pre-Crisis (Jan–May 2025)'
        WHEN month_num BETWEEN 6 AND 9 THEN 'Crisis (Jun–Sep 2025)'
    END AS time_period,
    COUNT(order_id) AS total_orders,
    ROUND(
        COUNT(order_id) * 100.0 /
        SUM(COUNT(order_id)) OVER (),
        2
    ) AS percent_contribution
FROM fact_orders
GROUP BY time_period
ORDER BY percent_contribution desc;


Query 2:- Which top 5 city groups experienced the highest percentage decline in orders 
during the crisis period compared to the pre-crisis period? 

SELECT dr.city,
 COUNT(CASE WHEN fo.month_num BETWEEN 1 AND 5 THEN fo.order_id END)
        AS pre_crisis_orders,
 COUNT(CASE WHEN fo.month_num BETWEEN 6 AND 9 THEN fo.order_id END)
        AS crisis_orders,
ROUND((
            COUNT(CASE WHEN fo.month_num BETWEEN 1 AND 5 THEN fo.order_id END)
          - COUNT(CASE WHEN fo.month_num BETWEEN 6 AND 9 THEN fo.order_id END)
        ) * 100.0
        / NULLIF(COUNT(CASE WHEN fo.month_num BETWEEN 1 AND 5 THEN fo.order_id END), 0),
        2
    ) AS percentage_drop
FROM fact_orders fo
JOIN dim_restaurant dr
    ON fo.restaurant_id = dr.restaurant_id
GROUP BY dr.city
ORDER BY percentage_drop DESC
limit 5;

query 3:- Among restaurants with at least 50 pre-crisis orders, which top 10 high-volume 
restaurants experienced the largest percentage decline in order counts during 
the crisis period? 


with pre_crisis_orders as (
select count(case when month_num between 1 and 5 then order_id end) as pre_crisis_orders,dr.restaurant_name 
from fact_orders as fo join dim_restaurant as dr
on fo.restaurant_id=dr.restaurant_id
group by dr.restaurant_name
having count(case when month_num between 1 and 5 then order_id end) >=50
),
crisis_orders as (
select count(case when month_num between 6 and 9 then order_id end) as crisis_orders,dr.restaurant_name 
from fact_orders as fo join dim_restaurant as dr
on fo.restaurant_id=dr.restaurant_id
group by dr.restaurant_name
)
SELECT p.restaurant_name,p.pre_crisis_orders,
    COALESCE(c.crisis_orders, 0) AS crisis_orders,
    ROUND((p.pre_crisis_orders - COALESCE(c.crisis_orders, 0)) * 100.0 / p.pre_crisis_orders,2) AS percentage_decline
FROM pre_crisis_orders p
LEFT JOIN crisis_orders c
    ON p.restaurant_name = c.restaurant_name
ORDER BY percentage_decline DESC
limit 10;

query 4:- Cancellation Analysis: What is the cancellation rate trend pre-crisis vs crisis, 
and which cities are most affected? 

with order_cancellation_stats as (
select dr.city,case
        when fo.month_num between 1 and 5 then 'Pre-Crisis (Jan-May 2025)'
        when fo.month_num between 6 and 9 then 'Crisis (June-Sept 2025)'
    end AS time_period,
	COUNT(order_id) as total_orders,
	COUNT(case when fo.is_cancelled = 'Y' then order_id end) as cancelled_orders,

    ROUND(count(case when fo.is_cancelled = 'Y' then order_id end)*100.0/count(order_id),2)as cancellation_rate
from fact_orders fo join dim_restaurant dr 
on fo.restaurant_id=dr.restaurant_id
group by dr.city,time_period
order by cancellation_rate desc
),
final_cancellation_stats as (select city,time_period,total_orders,cancelled_orders,
    ROUND( cancelled_orders * 100.0 / nullif(total_orders, 0),2) AS cancellation_rate
from order_cancellation_stats
order by city,cancellation_rate desc
)
select pre.city, pre.cancellation_rate as pre_crisis_rate, crisis.cancellation_rate as crisis_rate,
ROUND(crisis.cancellation_rate - pre.cancellation_rate,2) AS cancellation_rate_increase
from final_cancellation_stats pre
join final_cancellation_stats crisis
on pre.city = crisis.city
where pre.time_period = 'Pre-Crisis (Jan-May 2025)'
and crisis.time_period = 'Crisis (June-Sept 2025)'
order by cancellation_rate_increase desc
limit 5;

Query 5:-Delivery SLA: Measure average delivery duration time across phases. 
select case
when month_num between 1 and 5 then 'Pre-Crisis (Jan-May 2025)'
when month_num between 6 and 9 then 'Crisis (June-Sept 2025)'
end as phase,
avg(actual_delivery_time_mins - expected_delivery_time_mins) as avg_delivery_duration
from fact_delivery_performance fd join fact_orders fo 
on fd.order_id=fo.order_id
group by phase
order by avg_delivery_duration desc;

Query 6: SLA compliance rate during the two phases.

select case
when month_num between 1 and 5 then 'Pre-Crisis (Jan-May 2025)'
when month_num between 6 and 9 then 'Crisis (June-Sept 2025)'
end as phase,
count(fo.order_id) as total_orders,
count(case
      when actual_delivery_time_mins <= expected_delivery_time_mins then 1
      end
    ) as sla_compliant_orders,
ROUND(count(
            case
            when actual_delivery_time_mins <= expected_delivery_time_mins
            then 1
            end
        ) * 100.0 / count(fo.order_id),
        2
    ) AS sla_compliance_rate
from fact_delivery_performance fd join fact_orders fo 
on fd.order_id=fo.order_id	
group by phase
order by sla_compliance_rate desc;

query 7:- average customer rating month by month.which months saw the drop?

select case 
when month_num=1 then 'Jan'
when month_num=2 then 'Feb'
when month_num=3 then 'Mar'
when month_num=4 then 'Apr'
when month_num=5 then 'May'
when month_num=6 then 'Jun'
when month_num=7 then 'Jul'
when month_num=8 then 'Aug'
when month_num=9 then 'Sep'
end as month_name,
ROUND(avg(fr.rating)::numeric,2) as avg_customer_rating from dim_customer dc 
join fact_ratings fr on dc.customer_id=fr.customer_id
join fact_orders fo on dc.customer_id=fo.customer_id
group by month_num

query 8:- Estimate revenue loss from pre-crisis vs crisis (based on 
subtotal, discount, and delivery fee).

select case
when month_num between 1 and 5 then 'Pre-Crisis (Jan-May 2025)'
when month_num between 6 and 9 then 'Crisis (June-Sept 2025)'
end as phase,
round(sum(total_amount)::numeric/1000000.0,2) as total_revenue_millions
from fact_orders
group by phase
order by total_revenue_millions desc;

query 9 :-Among customers who placed five or more orders before the 
crisis, determine how many stopped ordering during the crisis, and out of those, 
how many had an average rating above 4.5? 

query 9: how many customers placed five or more orders before the crisis?
with pre_crisis_loyal_customers as (select customer_id, count(order_id) as pre_order_count
    from fact_orders
    where month_num between 1 and 5
    group by customer_id
    having count(order_id) >= 5
),
crisis_customers as ( select distinct customer_id from fact_orders 
where month_num between 6 and 9
),
churned_loyal_customers as (select plc.customer_id 
from pre_crisis_loyal_customers plc
left join crisis_customers cc
on plc.customer_id = cc.customer_id
where cc.customer_id is null),
customer_avg_ratings as (
  select customer_id, avg(rating) as avg_rating
  from fact_ratings
  group by customer_id
)
select count(*) AS high_rating_churned_customers
from churned_loyal_customers clc
join customer_avg_ratings car
on clc.customer_id = car.customer_id
where car.avg_rating > 4.5;

// 58 where the loyal customers pre crisis, 49 of them churned during crisis and 
// 26 of them were highly satisfied with the ratings of grater than 4.5?

query 10:- top 5% of customers as per pre crisis money spent

WITH pre_crisis_customer_spend AS (
    SELECT
        customer_id,
        SUM(
            COALESCE(subtotal_amount, 0)
          - COALESCE(discount_amount, 0)
          + COALESCE(delivery_fee, 0)
        ) AS pre_total_spend
    FROM fact_orders
    WHERE month_num BETWEEN 1 AND 5
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        pre_total_spend,
        NTILE(20) OVER (ORDER BY pre_total_spend DESC) AS spend_bucket
    FROM pre_crisis_customer_spend
)
SELECT
    customer_id,
    ROUND(pre_total_spend::numeric, 2) AS pre_total_spend
FROM ranked_customers
WHERE spend_bucket = 1
ORDER BY pre_total_spend DESC;

query 11: Among high-value customers,
how many experienced the largest drop in order frequency during the crisis?

WITH pre_crisis_customer_spend AS (
    SELECT
    customer_id,
    SUM(COALESCE(subtotal_amount, 0)
    - COALESCE(discount_amount, 0)
    + COALESCE(delivery_fee, 0)) AS pre_total_spend,
    COUNT(order_id) AS pre_order_count
    FROM fact_orders
    WHERE month_num BETWEEN 1 AND 5
    GROUP BY customer_id
),

top_5_percent_customers AS (
    SELECT
    customer_id,
    pre_total_spend,
    pre_order_count
    FROM (
        SELECT
            customer_id,
            pre_total_spend,
            pre_order_count,
            NTILE(20) OVER (ORDER BY pre_total_spend DESC) AS spend_bucket
        FROM pre_crisis_customer_spend
    ) t
    WHERE spend_bucket = 1
),

crisis_orders_per_customer AS (
    SELECT
    customer_id,
    COUNT(order_id) AS crisis_order_count
    FROM fact_orders
    WHERE month_num BETWEEN 6 AND 9
    GROUP BY customer_id
),
order_frequency_drop as (SELECT
    t.customer_id,
    t.pre_order_count,
    COALESCE(c.crisis_order_count, 0) AS crisis_order_count,
    (t.pre_order_count - COALESCE(c.crisis_order_count, 0))
        AS order_frequency_drop
FROM top_5_percent_customers t
LEFT JOIN crisis_orders_per_customer c
    ON t.customer_id = c.customer_id
ORDER BY order_frequency_drop DESC)
select count(*) as customers_with_highest_order_drop from order_frequency_drop where crisis_order_count=0

//there are 4342 customers with high value money spent pre crisis and 
out of this 3648 customers have highest order frequency drop( 0 orders during the crisis time)

query 12:- Do longer delivery delays directly increase cancellation rates?
answer- yes as the duration of delivery delay is increasing the cancellation of orders is also increasing

select case
when fdp.actual_delivery_time_mins <= fdp.expected_delivery_time_mins
then 'On-time'
when fdp.actual_delivery_time_mins - fdp.expected_delivery_time_mins <= 10
then'Delay 0–10 min'
when fdp.actual_delivery_time_mins - fdp.expected_delivery_time_mins <= 20
then 'Delay 10–20 min'
else 'Delay 20+ min'
end as delay_bucket,
count(*) as total_orders,
ROUND(count(*) * 100.0 /sum(count(*)) over (),2) as order_distribution_pct,
ROUND(count(case when fo.is_cancelled = 'Y' then 1 end) * 100.0 / count(*), 2) as cancellation_rate
from fact_delivery_performance fdp
join fact_orders fo on fdp.order_id = fo.order_id
group by delay_bucket
order by cancellation_rate desc;

query 13:- out of this 11.10% of orders which are having delivery delay of >20 mins which is our strict
sla compliance breach and is hurting the trust factor of the company. which cities, restaurants and partners 
are key reasons for this  delivery delays?

13-a) cities contributing to 20 min + delivery delays:-

select dr.city,
count(*) as delayed_orders_20_plus,
ROUND(count(*) * 100.0 /sum(count(*)) over (),2) AS pct_of_all_20_plus_delays
FROM fact_delivery_performance fdp
JOIN fact_orders fo
    ON fdp.order_id = fo.order_id
JOIN dim_restaurant dr
    ON fo.restaurant_id = dr.restaurant_id
WHERE fdp.actual_delivery_time_mins - fdp.expected_delivery_time_mins > 20
GROUP BY dr.city
ORDER BY delayed_orders_20_plus DESC;

13-b:- which partners are responsible for 20 min+delivery delays?

select dp.partner_name,
count(*) as delayed_orders_20_plus,
ROUND(count(*) * 100.0 /sum(count(*)) over (),2) as pct_of_all_20_plus_delays
from fact_delivery_performance fdp
join fact_orders fo
on fdp.order_id = fo.order_id
join dim_delivery_partner dp
on fo.delivery_partner_id = dp.delivery_partner_id
where fdp.actual_delivery_time_mins - fdp.expected_delivery_time_mins > 20
group by dp.partner_name
order by delayed_orders_20_plus desc;


select dr.restaurant_name,dr.city,
count(*) as delayed_orders_20_plus
from fact_delivery_performance fdp
join fact_orders fo
on fdp.order_id = fo.order_id
join dim_restaurant dr
on fo.restaurant_id = dr.restaurant_id
where fdp.actual_delivery_time_mins - fdp.expected_delivery_time_mins > 20
group by dr.restaurant_name, dr.city
ORDER BY delayed_orders_20_plus desc


query 14:- Which cities experienced the worst delivery & cancellation performance during crisis?
select dr.city,
ROUND(avg(fdp.actual_delivery_time_mins), 2) as avg_delivery_time,
ROUND(count(case when fo.is_cancelled = 'Y' then 1 end) * 100.0 /count(*), 2) as cancellation_rate
from fact_orders fo
join fact_delivery_performance fdp on fo.order_id = fdp.order_id
join dim_restaurant dr on fo.restaurant_id = dr.restaurant_id
where fo.month_num between 6 and 9
group by dr.city
order by cancellation_rate desc;


query 15:-sentiment bucket analysis

select
case
when sentiment_score < 0.4 then 'Negative'
when sentiment_score < 0.5 then 'Neutral'
when sentiment_score < 0.7 then 'Positive'
else 'Very Positive'
end as sentiment_bucket,
count(*) as reviews,
round(count(*)*100/sum(count(*))over()::numeric) as review_percentage	
from fact_ratings
group by sentiment_bucket;





























































































