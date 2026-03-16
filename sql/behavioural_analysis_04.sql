-- behavioural analysis objective

-- top 5 features with maximum usages 
-- feature adoption rate 
-- feature adoption by plan 
-- feature usage by churned vs retained users 
---------------------------------------------
-- What behaviors predict churn, expansion, or revenue leakage

SELECT * FROM raven_feature;

-- 1. top 5 most used product feature 
select 
feature_name,
sum(usage_count) as max_feature_usage
from raven_feature
group by feature_name
order by max_feature_usage desc
limit 5;

-- 2. feature adoption rate 
select 
f.feature_name,
round(
100.0*count(distinct f.subscription_id)
/ (select count(distinct subscription_id) 
         from ravenstock_subscriptions),2
) as feature_adoption_rate
from raven_feature f
group by f.feature_name
order by feature_adoption_rate desc;


-- 3. feature adoption by plan 
with total_plans as (
select 
	plan_tier,
	count(distinct subscription_id)	as total_sub
	from ravenstock_subscriptions
	group by plan_tier
	order by total_sub desc
)
select 
	f.feature_name,
	s.plan_tier,
round(
100.0*count(distinct f.subscription_id)
/total_sub,2) as feature_adop_by_plan
from raven_feature f 
join ravenstock_subscriptions s 
on f.subscription_id = s.subscription_id
join total_plans t
on t.plan_tier = s.plan_tier
group by s.plan_tier,total_sub, f.feature_name
order by feature_adop_by_plan desc;



--4. feature usage by churned vs retained users 
select 
churn_flag,
sum(usage_count) as feature_usage
from raven_feature f
join ravenstock_subscriptions r 
on f.subscription_id = r.subscription_id
group by churn_flag;

