################## Day3 ################


#1)	Show customer number, customer name, state and credit limit from customers table for below conditions. Sort the results by highest to lowest values of creditLimit.

#	State should not contain null values
#	credit limit should be between 50000 and 100000

select customerNumber, customerName, state, creditLimit 
from customers where state is not null and creditLimit between 50000 and 100000
order by creditLimit desc ;

#2)	Show the unique productline values containing the word cars at the end from products table.

select distinct productLine 
from productlines 
where productLine 
like "%cars";

############## Day4 ###############

#1)	Show the orderNumber, status and comments from orders table for shipped status only. 
#If some comments are having null values then show them as “-“.

select orderNumber, status, ifnull(comments, '-') as 'comments' from orders where status='Shipped'; 

###2)	Select employee number, first name, job title and job title abbreviation from employees table based on following conditions.
#If job title is one among the below conditions, then job title abbreviation column should show below forms.
#●	President then “P”
#●	Sales Manager / Sale Manager then “SM”
#●	Sales Rep then “SR”
#●	Containing VP word then “VP”

select employeeNumber, firstName, jobTitle,
case
	when jobTitle = 'President' then 'P'
    when jobTitle like 'Sales Manager%' or jobTitle like 'Sale Manager%' then 'SM'
    when jobTitle = 'Sales Rep' then 'SR'
    when jobTitle like '%VP%' then 'VP'
		else jobTitle
end as job_title_abbreviation
from employees;

##### Day 5:

#1)	For every year, find the minimum amount value from payments table.

select year(paymentDate) as Year, min(amount) as minimum_amount
from payments
group by Year
order by Year;

#2)	For every year and every quarter, find the unique customers and total orders from orders table. 
#Make sure to show the quarter as Q1,Q2 etc.

select year(orderDate) as Year, 
concat("Q",quarter(orderDate)) as Quarter, 
count(distinct customerNumber) as Unique_Customers,
count(*) as Total_orders
from orders
group by Year, Quarter;

#3)	Show the formatted amount in thousands unit (e.g. 500K, 465K etc.) for every month (e.g. Jan, Feb etc.) 
#with filter on total amount as 500000 to 1000000. Sort the output by total amount in descending mode. 
#[ Refer. Payments Table]

select monthname(paymentDate) as month,
    concat(format(sum(amount) / 1000, 0), 'K') as formatted_amount
from payments 
group by month
having sum(amount) between 500000 and 1000000
order by sum(amount) desc;

#Day 7
#1)	Show employee number, Sales Person (combination of first and last names of employees), 
#unique customers for each employee number and sort the data by highest to lowest unique customers.
#Tables: Employees, Customers

select emp.employeeNumber as employee_number, 
concat(emp.firstName, ' ' ,emp.lastName) as sales_person, 
count(distinct cus.customerNumber) as unique_customers 
from employees emp
join customers cus on emp.employeeNumber=cus.salesRepEmployeeNumber
group by employee_number
order by unique_customers desc;

#2)	Show total quantities, total quantities in stock, left over quantities for each product and each customer. 
#Sort the data by customer number.
#Tables: Customers, Orders, Orderdetails, Products

select cus.customerNumber, cus.customerName, prod.productCode, prod.productName,
sum(ordet.quantityOrdered) as Total_ordered_quantity,
prod.quantityInStock, (prod.quantityInStock-sum(ordet.quantityOrdered)) as left_over_stock
from customers cus 
join orders ord 
on cus.customerNumber=ord.customerNumber
join orderdetails ordet
on ord.orderNumber=ordet.orderNumber
join products prod
on prod.productCode=ordet.productCode
group by cus.customerNumber, cus.customerName, prod.productCode, prod.productName,prod.quantityInStock
order by cus.customerNumber;


####### Day 10 #############

#Create the view products status. Show year wise total products sold. Also find the percentage of total 
#value for each year. The output should look as shown in below figure.

create or replace view products_status as
with totalvaluecte as (
    select
        year(o.orderdate) as year,
        count(od.ordernumber) as totalproductssold,
        sum(od.quantityordered * od.priceeach) as totalvalue
    from
        orders o
    join
        orderdetails od on o.ordernumber = od.ordernumber
    group by
        year
)

select
    year,
    concat(totalproductssold," ","(",   
    concat(
        round((totalvalue / (select sum(totalvalue) from totalvaluecte)) * 100, 0),
        '%'),
        ")") as value
from
    totalvaluecte
    order by totalproductssold desc;

select*from products_status;

################### Day 12 ##################

#1)	Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. 
#Format the YoY values in no decimals and show in % sign.

select
  year(orderDate) as orderYear,
  monthname(orderDate) as orderMonth,
  count(*) as orderCount,
  concat(
    round((count(*) - lag(count(*)) over (partition by year(orderDate) order by month(orderDate))) / 
    lag(count(*)) over (partition by year(orderDate) order by month(orderDate)) * 100),
    '%'
  ) as YoYPercentageChange
from
  orders
group by
  orderYear,
  orderMonth,  -- Include this line to fix the error
  month(orderDate)
order by
  orderYear,
  month(orderDate);

#2)	Create the table emp_udf with below fields.

#●	Emp_ID
#●	Name
#●	DOB
#Add the data as shown in below query.
#INSERT INTO Emp_UDF(Name, DOB)
#VALUES ("Piyush", "1990-03-30"), ("Aman", "1992-08-15"), ("Meena", "1998-07-28"), ("Ketan", "2000-11-21"), ("Sanjay", "1995-05-21");

#Create a user defined function calculate_age which returns the age in years and months 
#(e.g. 30 years 5 months) by accepting DOB column as a parameter.

drop table emp_udf;
create table emp_udf (
    Emp_ID int auto_increment primary key,
    Name varchar(50),
    DOB date
);

INSERT INTO emp_udf (Name, DOB)
VALUES
    ('Piyush', '1990-03-30'),
    ('Aman', '1992-08-15'),
    ('Meena', '1998-07-28'),
    ('Ketan', '2000-11-21'),
    ('Sanjay', '1995-05-21');

delimiter //
create function calculate_age(dob date)
returns varchar(50)
deterministic
begin
    declare age_years int;
    declare age_months int;
    declare result varchar(50);
    
    set age_years = timestampdiff(year, dob, curdate());

    set age_months = timestampdiff(month, dob, curdate()) % 12;

    set result = concat(age_years, ' years ', age_months, ' months');

    return result;
end //
delimiter ;

select emp_id, name, dob, calculate_age(DOB) as Age from emp_UDF;


######################### Day 13 #############################

#1)	Display the customer numbers and customer names from customers table who have not placed any orders 
#using subquery

#Table: Customers, Orders

select customerNumber, customerName from customers
where not exists (
    select 1
    from orders
    where customers.customerNumber = orders.customerNumber
);


#2)	Write a full outer join between customers and orders using union and get the customer number, 
#customer name, count of orders for every customer.
#Table: Customers, Orders

select cus.customerNumber, cus.customerName, count(ord.orderNumber) as Count_of_orders
from customers cus 
left join orders ord on cus.customerNumber=ord.customerNumber
group by cus.customerNumber, cus.customerName
union
select cus.customerNumber, cus.customerName, count(ord.orderNumber) as Count_of_orders
from customers cus 
right join orders ord on cus.customerNumber=ord.customerNumber
group by cus.customerNumber, cus.customerName;

#3)	Show the second highest quantity ordered value for each order number.
#Table: Orderdetails

with rankedOrderDetails as(
select orderNumber, quantityOrdered,
dense_rank() over(partition by orderNumber order by quantityOrdered desc) as Quantity_Rank
from orderdetails
)
select orderNumber, quantityOrdered
from rankedOrderDetails 
where Quantity_Rank=2;

#4)	For each order number count the number of products and then find the min and max of the values 
#among count of orders.
#Table: Orderdetails

with ProductsCountCTE as (
select orderNumber, count(productCode) as productCount
from orderdetails
group by orderNumber
)
select max(productCount), min(productCount) 
from ProductsCountCTE;

#5)	Find out how many product lines are there for which the buy price value is greater 
#than the average of buy price value. Show the output as product line and its count.

select productLine, count(productLine) as Total
from products
where buyprice > 
(select avg(buyprice) from products as subquery 
where subquery.productLine = products.productLine)
group by productLine;





