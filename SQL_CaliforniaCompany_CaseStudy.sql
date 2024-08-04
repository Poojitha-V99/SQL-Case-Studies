
/************************ California Company Case Study *****************************/

--import Data set
Select * from Customer
Select * from Department

--Convert data type
update Customer 
set EID = cast(EID as int)

update Department 
set Dept_ID = cast(Dept_ID as int)

--Count data in dataset
Select COUNT(*) from Customer as TotalCount
Select COUNT(*) from Department as TotalCount

--Analysis
--Write the query to Select first letter of First and Lastname in Upper case and all other in Lower case.
update Customer
set FirstName = Upper(left(FirstName,1))+Lower(substring(FirstName,2, len(FirstName))),
    LastName = Upper(left(LastName,1))+Lower(substring(LastName, 2, len(LastName)))  

Select * from Customer 


-- Find out the Employees which are not assigned to any dept and are on Bench
select Count(*) from Customer
where Department is Null           

select EID, FirstName, LastName from Customer 
where Department = 'Bench' 
order by EID

--Write a query to give the output - Dept ID, Dept Name and the count of the employees working in them. Make sure to cover 
--all the departments even if employees are not assigned in them 
Select d.Dept_ID, d.Dept_Name, Count(Distinct c.EID) as Count_Emp_Each_Dept from Customer c
join Department d
on d.Dept_Name = c.Department
group by d.Dept_ID, d.Dept_Name
order by Dept_ID 

--Find out how many duplicate employees we have based on their same first name and Lastnames - Use Row Number 
WITH EmployeeDuplicates AS (
    SELECT ROW_NUMBER() OVER (PARTITION BY FirstName,LastName ORDER BY EID) AS rn,FirstName,LastName
    FROM Customer
)
SELECT FirstName,LastName, COUNT(*) AS duplicate_count
FROM EmployeeDuplicates
WHERE 
    rn > 1
GROUP BY FirstName,LastName
HAVING COUNT(*) > 1;

--Write a query that calculates 2 additional fields - Month of Joining and Year of Joining along with the columns of the Customer Table
Select *, month(JoiningDate) as Month_Of_Joining, Year(JoiningDate) as Year_Of_Joining from Customer

--Write an optimal query to give the count of the employees where the name starts with - 'AS' 
--and which has 'SAP' in between of the name anywhere
select  count(EID) from Customer

select * from Customer                          --output as 46 employee data
where (FirstName LIKE 'AS%' or LastName LIKE 'AS%')
    or (FirstName LIKE '%SAP%' or LastName LIKE '%SAP%') 
	
--Find the count of employees which joined in the range of May 2003 to June 2009
select count(*) as CountOfEmployees from Customer
where JoiningDate Between '2003-05-01 00:00:00.000' and '2009-06-30 00:00:00.000'

--Find all the records where the Lastname Or Email is Null and Replace it by ‘No record Found’ – Prefer Coalesce
select * from customer
where Lastname is null and Email is null
------
select *, COALESCE(Lastname, 'no record found') AS Lastname,COALESCE(Email, 'no record found') AS Email
from Customer

--Write a query to find the number of Joining’s Year and Month wise and order them by lowest to highest numbers 
select year(JoiningDate) as JOININGYEARS, Month(JoiningDate) as JOININGMONTH, count(*) as NO_OFJOINING
from Customer
group by year(JoiningDate), Month(JoiningDate) 
order by JOININGYEARS, JOININGMONTH, NO_OFJOINING

--Delete the duplicate entries from the table using CTE and Row Number 
WITH CTE_DuplicateRecords AS (
    SELECT 
        EID,FirstName,LastName, -- Assuming EID is the primary key
        ROW_NUMBER() OVER (PARTITION BY FirstName,LastName ORDER BY EID DESC) AS rn
    FROM Customer
)
DELETE FROM CTE_DuplicateRecords
WHERE rn > 1;

exec CTE_DuplicateRecords 

-- Write a query to find all the departments in a company , their average salary per employee in that dept and their total salary for 
--the employees falling under that dept

select  EID, Department,  avg(Salary) as AVG_SALARY, Sum(Salary)  as TotalSalary
from Customer
group by Department, EID

--Find the Minimum and Maximum salary per department wise? Confirm your result with the data.
select   Department, min(Salary) as Min_SALARY, Max(Salary) as Max_SALARY
from Customer
group by Department
-- select EID, Department, Salary from Customer       * to check salary every emp has same salary as dept wise*

--Create a stored procedure that takes Input parameter as a date range and returns the data with the EmployeeID , Firstname , Salary ,
--DepartmentID and Joining Date --> from oldest to newest.

create procedure Temp_Cus 
as
select * into #TempCustomerDate
from (select EID, FirstName, LastName, d.Dept_ID, Salary, JoiningDate
from Customer c
join Department d
on d.Dept_Name = c.Department
group by EID, FirstName, LastName, d.Dept_ID, Salary, JoiningDate

) as [SomeAlias]	 

Select * from #TempCustomerDate
exec Temp_Cus

-- Update all the Male employees with Female and Female with Male in one update query
update Customer
set gender = CASE 
when gender ='F' then 'M'
when gender = 'M' then 'F'
else gender
end

select * from Customer ---to check

--Write a query to Update the Department Name in Customer Table with Department ID in Department Table
-- Begin a transaction
BEGIN TRANSACTION;

-- Update operation (for demonstration purposes)
Update Customer 
set Customer.Department = Department.Dept_ID
from Customer
join Department on Customer.Department = Department.Dept_Name

-- Check the updates
SELECT * FROM Customer;

-- Rollback the transaction if needed
ROLLBACK TRANSACTION;

-- Verify that the data is reverted
SELECT * FROM Customer;








