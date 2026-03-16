-- objective
--retained revenue, expansion, contraction and churned mrr 
-- mrr rate by plans 
-- net revenue retention(nrr)
-- grr(gross revenue retention)
-- mom mrr growth percent 
-------------------------------------
select * from ravenstock_subscriptions;

select min(start_date), max(start_date)
from ravenstock_subscriptions;

--retained revenue, expansion, contraction and churned mrr 
select 
	sum(mrr_amount)filter(where churn_flag = false) as retained_rev,
	sum(mrr_amount)filter(where upgrade_flag = true) as expansion_rev,
	sum(mrr_amount)filter(where downgrade_flag = true) as contraction_rev,
	sum(mrr_amount)filter(where churn_flag = true) as churned_rev
from ravenstock_subscriptions;

-- mrr rate by plans 
select 
	plan_tier,
	sum(mrr_amount) as total_mrr_byplan,
round(
100.0 * sum(mrr_amount) 
/sum(sum(mrr_amount)) over() ,2) as mrr_rate_by_plan
from ravenstock_subscriptions
where is_trial = false
group by plan_tier
order by mrr_rate_by_plan desc;

-- net revenue retention(nrr)
with b1 as (
select 
	sum(mrr_amount) as starting_mrr_2024
	from ravenstock_subscriptions
	where is_trial = false 
	and start_date < '2024-01-01'
	and (end_date is null or end_date >= '2024-01-01')
),
 b2 as (
select 
	sum(mrr_amount) as ending_mrr_2024
	from ravenstock_subscriptions
	where is_trial = false 
	and start_date < '2024-01-01'
	and (end_date is null or end_date >= '2024-12-31')
)
select starting_mrr_2024,ending_mrr_2024,
round(
ending_mrr_2024*100.0/starting_mrr_2024,2) as total_nrr
from b1,b2;


-- grr(gross revenue retention)

with t1 as (
select 
	sum(mrr_amount) as starting_mrr_2024,
	sum(mrr_amount)filter(where churn_flag = true) as churned_rev,
	sum(mrr_amount)filter(where downgrade_flag = true) as contraction_rev
from ravenstock_subscriptions
	where is_trial = false 
	and start_date < '2024-01-01'
	and (end_date is null or end_date >= '2024-01-01')
)
select 
starting_mrr_2024,
churned_rev, contraction_rev,
round(
100*(starting_mrr_2024- churned_rev- contraction_rev)
/starting_mrr_2024,2) as grr_rate
from t1
;


-- mom mrr growth percent 

with base as (
select 
	date_trunc('month', start_date) as month,
	sum(mrr_amount) as total_mrr
	from ravenstock_subscriptions
	group by month
)
select
	month,
	total_mrr,
round(
	(total_mrr-lag(total_mrr) over (order by month)) *100.0
/lag(total_mrr) over (order by month)) as mom_mrr_growth_pcnt
from base
order by 1,2;

