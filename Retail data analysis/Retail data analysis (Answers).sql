--------------------------------------Data Preparation & Understanding-----------------------------------------------
--Q1--Begin
(select COUNT(*) from Customer) union all
(select COUNT(*) from Transactions) union all
(select COUNT(*) from prod_cat_info)
--Q1--End

--Q2--Begin
select COUNT(transaction_id)[No of Returns]
from Transactions
where Qty<0
--Q2--End

--Q3--Begin
--Q3--End

--Q4--Begin
select MIN(tran_date)[Start],MAX(tran_date)[End],
DATEDIFF(d,MIN(tran_date),MAX(tran_date))[Days],
DATEDIFF(m,MIN(tran_date),MAX(tran_date))[Months],
DATEDIFF(yyyy,MIN(tran_date),MAX(tran_date))[Years]
from Transactions
--Q4--End

--Q5--Begin
select prod_cat
from prod_cat_info
where prod_subcat='DIY'
--Q5--End

---------------------------------------------Data Analysis----------------------------------------------------------
--Q1--Begin
select top 1 Store_type, COUNT(transaction_id)[No of Transaction]
from Transactions
group by Store_type
order by [No of Transaction] desc
--Q1--End

--Q2--Begin
select Customer='Male', count(gender)[No of Customers]
from Customer
where Gender='M'
union all
select Customer='Female', count(gender)[No of Customers]
from Customer
where Gender='F'
--Q2--End

--Q3--Begin
select top 1 city_code, COUNT(customer_Id)[No of customers]
from Customer
group by city_code
order by [No of customers] desc
--Q3--End

--Q4--Begin
select count(prod_subcat)[sub cateogory]
from prod_cat_info
where prod_cat='Books'
--Q4--End

--Q5--Begin
select max(Qty)[Max quantity]
from Transactions
--Q5--End

--Q6--Begin
select sum(t.total_amt-t.Tax)[Net Total Revenue]
from Transactions[t]
inner join prod_cat_info[p] on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
where p.prod_cat in('Electronics','Books') and t.Qty>0
--Q6--End

--Q7--Begin
select count(cust_id)[No of Customers] from (select cust_id,count(transaction_id)[Transactions]
from Transactions
where Qty>=0
group by cust_id
having count(transaction_id)>10) [j]
/*
  Although subqueries are more commonly placed in a WHERE clause, they can also form part of the FROM clause.
  Such subqueries are commonly called derived tables.
  If a subquery is used in this way, you must also use an AS clause to name the result of the subquery
*/
--Q7--End

--Q8--Begin
select sum(t.total_amt)[Combined Revenue]
from Transactions[t]
inner join prod_cat_info[p] on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
where p.prod_cat in ('Electronics','Clothing') and t.Store_type='Flagship Store' and t.Qty>0
--Q8--End

--Q9--Begin
select p.prod_subcat,SUM(t.Qty*t.Rate)[Total Revenue from Male customer]
from prod_cat_info[p]
inner join Transactions[t] on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
inner join Customer[c] on t.cust_id=c.customer_Id
where p.prod_cat='Electronics' and c.Gender='M' and t.Qty>0
group by p.prod_subcat
--Q9--End

--Q10--Begin
--Percentage of Sales
select top 5 p.prod_subcat,(sum(t.total_amt)/(select sum(total_amt)[total amount]
from Transactions
where Qty>0))*100 [Sales Percent] 
from prod_cat_info[p]
inner join Transactions[t] on p.prod_sub_cat_code=t.prod_subcat_code and p.prod_cat_code=t.prod_cat_code
where t.Qty>0
group by p.prod_subcat
order by [Sales Percent] desc

--Percentage of Returns
select p.prod_subcat,(sum(t.total_amt)/(select sum(total_amt)[total amount]
from Transactions
where Qty<0))*100 [return Percent] 
from prod_cat_info[p]
inner join Transactions[t] on p.prod_sub_cat_code=t.prod_subcat_code and p.prod_cat_code=t.prod_cat_code
where t.Qty<0
group by p.prod_subcat
order by [return Percent] desc
--Q10--End

--Q11--Begin
select sum([Net Revenue])[Net Revenue] from (select c.customer_Id,c.DOB,DATEDIFF(year,c.DOB,max(t.tran_date))-
case
	when DATEADD(year,DATEDIFF(year,c.DOB,max(t.tran_date)),c.DOB)>max(t.tran_date) then 1
	else 0
end [Age],
sum(t.total_amt-t.Tax)[Net Revenue]
from Customer[c]
inner join Transactions[t] on c.customer_Id=t.cust_id
where t.Qty>0
group by c.customer_Id,c.DOB,t.tran_date
having DATEDIFF(year,c.DOB,max(t.tran_date)) between 25 and 35 and t.tran_date>=DATEADD(day,-30,(select max(t.tran_date) from Transactions[t])))[j]
--Q11--End

--Q12--Begin
select top 1 p.prod_cat,sum(t.total_amt)[Return Value]
from prod_cat_info[p]
inner join Transactions[t] on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
where t.Qty<0 and t.tran_date>DATEADD(month,-3,(select max(t.tran_date) from Transactions[t]))
group by p.prod_cat
order by [Return Value] desc
--Q12--End

--Q13--Begin
select top 1 Store_type,sum(total_amt)[Max Sales],sum(Qty)[Max Quantity]
from Transactions
where Qty>0
group by Store_type
order by [Max Sales] desc,[Max Quantity] desc
--Q13--End

--Q14--Begin
select p.prod_cat,avg(t.total_amt)[Avg Revenue],(select avg(total_amt) from Transactions where Qty>0)[Overall average]
from prod_cat_info[p]
inner join Transactions[t] on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
where t.Qty>0
group by p.prod_cat
having avg(t.total_amt)>(select avg(total_amt) from Transactions where Qty>0)
--Q14--End

--Q15--Begin
select p.prod_cat,p.prod_subcat,avg(t.Qty*t.Rate)[Avg Revenue],sum(t.Qty*t.Rate)[Total Revenue]
from prod_cat_info[p]
inner join Transactions[t] on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
where t.Qty>0 and p.prod_cat not in('Bags')
group by p.prod_cat,p.prod_subcat
order by p.prod_cat
--Q15--End

----------------------------------------------------------------------------------------------------------------------