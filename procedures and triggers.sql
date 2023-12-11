##########Day 11 #####################

#1)	Create a stored procedure GetCustomerLevel which takes input as customer number and gives the output as 
#either Platinum, Gold or Silver as per below criteria.

#`	Table: Customers

#●	Platinum: creditLimit > 100000
#●	Gold: creditLimit is between 25000 to 100000
#●	Silver: creditLimit < 25000

drop procedure getcustomerlevel;
delimiter //
create procedure GetCustomerLevel(in CustomerNumberproc int)
begin
    declare credit decimal(10,2);
    declare Customer_Level varchar(10);
    select CreditLimit into credit
    from customers
    where customerNumber = CustomerNumberproc;

    case
        when credit > 100000 then set Customer_Level = 'Platinum';
        when credit between 25000 and 100000 then set Customer_Level = 'Gold';
        else set Customer_Level = 'Silver';
    end case;

    select Customer_Level as Customer_Level;
end//
delimiter ;

call GetCustomerLevel(112);

#2)	Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, 
#country wise total amount as an output. Format the total amount to nearest thousand unit (K)
#Tables: Customers, Payments

drop procedure Get_country_payments;
delimiter //
create procedure Get_country_payments (
    in inputYear int,
    in inputCountry varchar(50)
)
begin
   select year(paymentDate) as PaymentYear, cus.country as Country, concat(format(sum(amount) / 1000, 0),'K') as TotalAmount
    from payments pay
    join customers cus on pay.customerNumber = cus.customerNumber
    where year(pay.paymentDate) = inputYear and cus.country = inputCountry
    group by year(pay.paymentDate), cus.country;
end //

call Get_country_payments(2003, 'France');



#################################### Day 14 #################################

#Create the table Emp_EH. Below are its fields.
#●	EmpID (Primary Key)
#●	EmpName
#●	EmailAddress
#Create a procedure to accept the values for the columns in Emp_EH. 
#Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.

create table Emp_EH (
EmpID int primary key,
EmpName varchar(200),
EmailAddress varchar(200)
);

delimiter //

create procedure insert_Emp_EH (
in EmpIDpr int,
in EmpNamepr varchar(200),
in EmailAddresspr varchar(200)
)

begin
		declare exit handler for sqlexception
			begin
				select "Error Occurred" as ErrorMessage;
				end;
		insert into Emp_EH(EmpID, EmpName, EmailAddress)
        values(EmpIDpr,EmpNamepr,EmailAddresspr);
	select "Employee info inserted successfully" as SuccessfulMessage;
end//
delimiter ;
		
call insert_Emp_EH(1,"Gourab Ghosh","gourabsmailbox2@gmail.com");	

select*from Emp_EH;

##################### Day 15 ########################

#Create the table Emp_BIT. Add below fields in it.
#●	Name
#●	Occupation
#●	Working_date
#●	Working_hours

#Insert the data as shown in below query.
#INSERT INTO Emp_BIT VALUES
#('Robin', 'Scientist', '2020-10-04', 12),  
#('Warner', 'Engineer', '2020-10-04', 10),  
#('Peter', 'Actor', '2020-10-04', 13),  
#('Marco', 'Doctor', '2020-10-04', 14),  
#('Brayden', 'Teacher', '2020-10-04', 12),  
#('Antonio', 'Business', '2020-10-04', 11);  
 
#Create before insert trigger to make sure any new value of Working_hours, if it is negative, 
#then it should be inserted as positive.

create table emp_BIT (
    name varchar(100),
    occupation varchar(100),
    working_date date,
    working_hours int
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

delimiter //

create trigger before_insert_emp_BIT
before insert on emp_BIT
for each row
begin
    if new.working_hours < 0 then
        set new.working_hours = abs(new.working_hours);
    end if;
end;

//

delimiter ;
 
