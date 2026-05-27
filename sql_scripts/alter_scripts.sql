set search_path to quickbite_db;
select * from fact_orders
ALTER TABLE fact_orders
ALTER COLUMN order_timestamp
TYPE TIMESTAMP
USING TO_TIMESTAMP(order_timestamp, 'YYYY-MM-DD HH24:MI');
select * from fact_orders

alter table fact_orders
add column month int
generated always as (extract (month from order_timestamp)) stored;
ALTER TABLE fact_orders
RENAME COLUMN month TO month_num;
select distinct month_num from fact_orders

