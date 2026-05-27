
create table quickbite_db.dim_customer (
customer_id text,
signup_date text,
city text,
acquisition_channel text
);
select * from quickbite_db.dim_customer



create table quickbite_db.dim_delivery_partner (
delivery_partner_id varchar(12),
partner_name varchar(20),
city varchar(20),
vehicle_type varchar(20),
employment_type varchar(20),
avg_rating float,
is_active varchar(2)
);
select * from quickbite_db.dim_delivery_partner


create table quickbite_db.dim_menu_items (
menu_item_id varchar(30),
restaurant_id varchar(20),
item_name text,
category varchar(20),
is_veg varchar(2),
price float
);
select * from quickbite_db.dim_menu_items

create table quickbite_db.dim_restaurant (
restaurant_id varchar(20),
restaurant_name text,
city text,
cuisine_type varchar(20),
partner_type varchar(20),
avg_prep_time_min varchar(10),
is_active varchar(2)
);
select * from quickbite_db.dim_restaurant

create table quickbite_db.fact_delivery_performance (
order_id text,
actual_delivery_time_mins int,
expected_delivery_time_mins int,
distance_km float
);
select * from quickbite_db.fact_delivery_performance

create table quickbite_db.fact_order_items (
order_id text,
item_id varchar(20),
menu_item_id varchar(30),
restaurant_id varchar(20),
quantity int,
unit_price float,
item_discount float,
line_total float
);
select * from quickbite_db.fact_order_items


create table quickbite_db.fact_orders (
order_id text,
customer_id text,
restaurant_id varchar(20),
delivery_partner_id varchar(12),
order_timestamp text,
subtotal_amount float,
discount_amount float,
delivery_fee float,
total_amount float,
is_cod varchar(2),
is_cancelled varchar(2)
);
select * from quickbite_db.fact_orders




















