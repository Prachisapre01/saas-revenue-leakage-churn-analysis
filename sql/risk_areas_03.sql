-- risk areas 3.o objective 
-- churn rate 
-- churn rates by plan/country/industry
--maximum churn reason 
--downgrade rate by plan_tier
--avg subscription duration 
--avg support ticket by churned vs retained users 
-- mrr lost by plans 
--------------------------------------------

select * from ravenstock_acct;
--1. churn rate analysis 
-------------------------
select 
round(
100.0* count(distinct account_id)filter(where churn_flag = true)
/ count(distinct account_id)) as churn_rate
from ravenstock_acct;

-- by country
select 
country, 
count(distinct account_id) as total_users,
count(churn_flag)filter(where churn_flag = true) as churned_users,
round(
100.0* count(account_id)filter(where churn_flag = true)
/count(*),2) as country_churn_rate
from ravenstock_acct
group by country
order by country_churn_rate desc;

-- by industry
select 
industry, 
count(*) as total_users,
count(churn_flag)filter(where churn_flag = true) as churned_users,
round(
100.0*count(account_id)filter(where churn_flag = true)
/count(*),2) as industry_churn_rate
from ravenstock_acct
group by industry
order by industry_churn_rate desc;


--by plans 
select 
plan_tier, 
count(*) as total_users,
count(churn_flag)filter(where churn_flag = true) as churned_users,
round(
100.0*count(account_id)filter(where churn_flag = true)
/count(*),2) as churn_rate
from ravenstock_acct
group by plan_tier
order by churn_rate desc;


select * from raven_churn_event;
--2. maximum churn reason 
select 
reason_code,
count(reason_code) as churn_max_reason
from raven_churn_event
group by reason_code
order by churn_max_reason desc;


--3. downgrade rate by plan_tier
select 
plan_tier,
round(
100.0* count(*)filter(where downgrade_flag = true)
/count(*),2) as contraction_tev_rate
from ravenstock_subscriptions 
where is_trial = false
group by plan_tier 
order by contraction_tev_rate desc;


-- 4.subscription duration 
select plan_tier,
round(
avg(end_date - start_date),2) as avg_subs_duration
from ravenstock_subscriptions
where end_date is not null
group by plan_tier
order by avg_subs_duration desc;


--5. avg ticket per user (churned vs retained users) 
select 
a.churn_flag,
round(
count(t.ticket_id)*1.0 / count(distinct a.account_id),2)
as avg_tickets_per_user
from ravenstock_acct a
left join raven_support_tickets t
on t.account_id = a.account_id
group by a.churn_flag;

--6. mrr lost by plans 
select plan_tier,
sum(mrr_amount)filter(where churn_flag = true) as churn_mrr_lost,
sum(mrr_amount)filter(where downgrade_flag = true) as downgrade_mrr_lost
from ravenstock_subscriptions
group by plan_tier;

