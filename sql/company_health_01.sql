--total customer and retained customers
--customer count by referral source(organic vs paid mix)
--total mrr and avg mrr 
--mrr monthly trend 
--mom signup growth percent 
--total churned customer, logo and paid churn rate 
--------------------
select * from ravenstock_acct;

--1. total customer and retained customers 
select 
count(distinct account_id) as total_cust,
count(distinct account_id)filter(where churn_flag = true) as churned_cust,
count(distinct account_id)filter(where churn_flag = false)
as retained_cust
from ravenstock_acct;


--2. customer count by referral source(organic vs paid mix)
select referral_source,
count(distinct account_id) as customer_count
from ravenstock_acct
group by referral_source
order by customer_count desc;


-- subscription table 
------------------------
select * from ravenstock_subscriptions;

--3. total mrr and avg mrr 
select sum(mrr_amount) as total_mrr,
round(
avg(mrr_amount),2) as avg_mrr
from ravenstock_subscriptions;


--4. mrr monthly trend 
select 
	date_trunc('month', start_date) as month,
	sum(mrr_amount) as monthly_mrr
	from ravenstock_subscriptions
group by month
order by month;


--5. mom signup growth percent 
with base as (
select 
	date_trunc('month', start_date) as month,
	count(account_id) as total_signups
	from ravenstock_subscriptions
	group by month
)
select
	month,
	total_signups,
	(total_signups-lag(total_signups) over (order by month))* 100
/lag(total_signups) over (order by month) as mom_signup_growth_pcnt
from base
order by 1,2;



--6. total churned customer, logo and paid churn rate 
select
count(distinct account_id )filter(where churn_flag = true)as churned_users,
ROUND(
100.0*count(distinct account_id)filter(where churn_flag = true)
/count(distinct account_id),2) as logo_churn_rate
from ravenstock_acct;

--revenue churn rate 
select 
round(
100.0*sum(mrr_amount)filter(where churn_flag = true)
/sum(mrr_amount),2) as logo_churn_rate
from ravenstock_subscriptions;

