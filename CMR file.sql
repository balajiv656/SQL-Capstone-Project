create database CMR;

use CMR;

select * from customerdetails;

-- 1.What is the distribution of account balance across different regions?

select GeographyLocation,sum(Balance) as account_balance from customerdetails
group by GeographyLocation;


-- 2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

select Surname as Customer ,round(EstimatedSalary,0)  from customerdetails
where month(BankDOJ) in (10,11,12)
order by EstimatedSalary desc
limit 5;

-- 3.Calculate the average number of products used by customers who have a credit card. (SQL)

select Surname,avg(NumOfProducts)
from customerdetails
where HasCrCard=1
group by Surname;

-- 5.Compare the average credit score of customers who have exited and those who remain. (SQL)

select ExitCategory,avg(CreditScore) as average_credit_score
from customerdetails
group by ExitCategory;

-- 6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)

select GenderCategory,ActiveCategory,count(CustomerId) as count_of_customer ,avg(EstimatedSalary) as average_estimated_salary
from customerdetails
where IsActiveMember=1
group by GenderCategory,ActiveCategory
order by average_estimated_salary desc;


-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

select case when CreditScore between 350 and 450 then '350-450'
when CreditScore between 450 and 550 then '450-550'
when CreditScore between 550 and 650 then '550-650'
when CreditScore between 650 and 750 then '650-750'
else '750-850' end as Segment,count(CustomerId) as exit_rate
from customerdetails 
where Exited=1
group by Segment
order by exit_rate desc;

-- 8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

select GeographyLocation,count(CustomerId) as number_of_active_customers
from customerdetails
where Tenure>5 and IsActiveMember=1
group by GeographyLocation
order by number_of_active_customers desc;

-- 9.What is the impact of having a credit card on customer churn, based on the available data?

select ExitCategory,count(CustomerId) as no_of_customer
from customerdetails
where HasCrCard=1
group by ExitCategory;


-- 10.For customers who have exited, what is the most common number of products they had used?

select NumOfProducts,count(CustomerId) as no_of_customers from customerdetails
where Exited=1
group by NumOfProducts;


-- 11.Examine the trend of customer exits over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

select year(BankDOJ) as years, Count(CustomerId) as Exited_customer
from customerdetails
where Exited =1
group by years
order by years desc;

-- 12.Analyze the relationship between the number of products and the account balance for customers who have exited. 

select NumOfProducts,sum(balance) as account_balance
from customerdetails
where Exited=1
group by NumOfProducts
order by account_balance desc;

-- 15.Using SQL, write a query to find out the gender wise average income of male and female in each geography id. Also rank the gender according to the average value. (SQL)

with CTE as (
select GeographyLocation,GenderCategory,avg(EstimatedSalary) as average_income
from customerdetails
group by GeographyLocation,GenderCategory
)
select dense_rank() over(order by average_income desc) Ranks,GeographyLocation,GenderCategory,average_income
from CTE;

-- 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select case
when age between 18 and 30 then '18-30'
when age between 30 and 50 then '30-50'
else '50+' end as age_bracket,avg(Tenure) as average_tenure
from customerdetails
where Exited=1
group by age_bracket;

-- 19.Rank each bucket of credit score as per the number of customers who have churned the bank.
with Bucket_rank as (
select case when CreditScore between 350 and 450 then '350-450'
when CreditScore between 450 and 550 then '450-550'
when CreditScore between 550 and 650 then '550-650'
when CreditScore between 650 and 750 then '650-750'
else '750-850' end as Segment,count(CustomerId) as exit_rate
from customerdetails 
where Exited=1
group by Segment
)
select dense_rank() over(order by exit_rate desc),Segment,exit_rate
from Bucket_rank;

-- 20.According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets who have lesser than average number of credit cards per bucket.

select case
when age between 18 and 30 then '18-30'
when age between 31 and 50 then '30-50'
else '50+' end as age_bracket,COUNT(HasCrCard) count_of_age_bracket
from customerdetails
where HasCrCard=1 
group by age_bracket
having count_of_age_bracket<(select avg(counts)  average
							from (select count(customerId) counts
								from customerDetails
                                where HasCrCard=1) a) ;
                                
 select age_bracket,avg(counts) as average
from (select case
when age between 18 and 30 then '18-30'
when age between 30 and 50 then '30-50'
else '50+' end as age_bracket,count(customerId) counts
from customerDetails
where HasCrCard=1
group by age_bracket) a
group by age_bracket;


-- 21. Rank the Locations as per the number of people who have churned the bank and average balance of the learners.
with Geography_balance as (
select GeographyLocation,avg(balance) as average_balance,count(CustomerId) as Exited_customer
from customerdetails
where Exited=1
group by GeographyLocation
)
select dense_rank() over(order by Exited_customer desc) as Ranks,GeographyLocation,average_balance,Exited_customer
from Geography_balance


