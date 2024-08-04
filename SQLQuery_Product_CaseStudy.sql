/*---------------------- Case Study -------------------------------------*/--Main Syntax: DISTINCT - No Duplication, OFFSET, FETCH - Display particular, INTO - Copy of existingtable, DELECT, UPDATE(SET), -- while using UPDATE-Use BEGIN and ROLLBACK to revert the updated data--same table can use 'join', ALTER TABLE(ADD) -for NewCol, Duplication - Using Having for count, COALESCE - To replace values or Null
-- Import data setsSelect * from dbo.CustomerSelect * from dbo.OrderItemSelect * from dbo.OrdersSelect * from dbo.ProductSelect * from dbo.Supplier--List all the customersSelect * from dbo.CustomerSelect count(cast(Id as int)) as TotalCustomer from Customer    --total customer in dataselect  DISTINCT Country,  City , count(City) over(partition by City) as CityCount from Customer    -- List the first name, last name, and city of all customersSelect FirstName, LastName, City from Customer--List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because filtering value is case sensitive in Redshift.Select Id,FirstName, LastName, Country, City from dbo.Customer cwhere c.Country = 'Sweden' --Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.Select * into Supplier_Copy
FROM dbo.Supplierupdate Supplier_Copyset City = 'Sydney'where CompanyName Like 'p%' --Create a copy of Products table and Delete all products with unit price higher than $50.select * into ProductCopyFROM dbo.Product         Select * from ProductCopyDelete ProductCopywhere UnitPrice >50Select * from ProductCopy--List the number of customers in each countryselect Country, count(*) as number_of_customerfrom dbo.Customergroup by Country--List the number of customers in each country sorted high to lowselect Country, count(*) as number_of_customerfrom dbo.Customergroup by Countryorder by number_of_customer desc-- List the total amount for items ordered by each customerselect  cast (Id as int) as Id , OrderNumber, sum(TotalAmount) as TotalAmountfrom dbo.Orders group by Id,OrderNumber--List the number of customers in each country. Only include countries with more than 10 customers.select  Country, Count(*) as NO_OF_CUSTfrom dbo.Customergroup by  CountryHaving Count(*) >10-- List the number of customers in each country, except the USA, sorted high to low. Only include countries with 9 or more customersselect  Country, Count(*) as NO_OF_CUSTfrom dbo.Customerwhere Country <> 'USA'group by  CountryHaving Count(*) >= 9 order by Country Desc--List all customers whose first name or last name contains "ill".select  Id, FirstName, LastName from dbo.Customerwhere FirstName LIKE '%ill%' or LastName LIKE '%ill%'group by Id, FirstName, LastName Select * from Customer--List all customers whose average of their total order amount is between $1000 and $1200.Limit your output to 5 resultsSelect Top 5 cast(Id as int) as Id, Avg(TotalAmount) as Avg_Totalamountfrom dbo.Orderswhere Totalamount between 1000 and 1200group by Id, TotalAmountorder by TotalAmount desc-- List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then by company name in reverse order.select Id, CompanyName, Countryfrom dbo.Supplierwhere Country IN('USA','Japan','Germany')order by Country , CompanyName DESC--Show all orders, sorted by total amount (the largest amount first), within each year.select OrderNumber, Year(OrderDate) as Year, sum(TotalAmount) TOTALAMOUNTFrom dbo.Ordersgroup by OrderNumber,Year(OrderDate), TotalAmountorder by Year(OrderDate) DESC,TotalAmount DESCselect * from dbo.Orders
--Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to discontinue products over $25.
--Write a query to relfelct this. Do this in the copy of the Product table. DO NOT perform the update operation in the Product table.SELECT * INTO Product_Copy
FROM ProductSelect * from Product
UPDATE Product_Copy
SET IsDiscontinued = 1
WHERE UnitPrice > 25SELECT * FROM Product_Copy                     

--List top 10 most expensive products
Select Top 10 ProductName, UnitPrice
from dbo.Product 
group by ProductName, UnitPrice 
order by UnitPrice DESC 

select * from Product

-- Get all but the 10 most expensive products sorted by price
Select * from Product
where Id not in 
(Select Top 10 Id
from dbo.Product 
order by UnitPrice DESC )
order by UnitPrice DESC

-- Get the 10th to 15th most expensive products sorted by price
Select * from Product
order by UnitPrice DESC
offset 9 rows fetch next 6 rows only

--Write a query to get the number of supplier countries. Do not count duplicate values
select count(DISTINCT Country) as number_of_supplier_countries 
from Supplier

--Find the total sales cost in each month of the year 2013
Select Month(OrderDate) as Month_2013, sum(TotalAmount) as salescost  
from Orders
where year(OrderDate) = 2013
group by Month(OrderDate)
order by Month(OrderDate)

--List all products with names that start with 'Ca'.
select ProductName
from Product
group by ProductName
Having ProductName Like 'Ca%'
--or
select ProductName
from Product
where ProductName Like 'Ca%'

-- List all products that start with 'Cha' or 'Chan' and have one more character.
select ProductName
from Product
where ProductName Like 'Cha%' or ProductName Like 'Chan%'

--Your manager notices there are some suppliers without fax numbers. He seeks your help to get a list of suppliers with remark 
--as "No fax number" for suppliers who do not have fax numbers (fax numbers might be null or blank).Also, Fax number should be 
--displayed for customer with fax numbers.

select Id, CompanyName,
case 
 when Fax is null or Fax = ' ' then 'No Fax Number'
 else Fax
 end as FaxRemark
from Supplier
where Fax is null or Fax = ' '

-- List all orders, their orderDates with product names, quantities, and prices.
select OrderDate, ProductName, Quantity, I.UnitPrice
from Orders O
join OrderItem I on I.OrderId = O.Id
join Product P on P.ID = I.ProductId
order by OrderDate DESC

--. List all customers who have not placed any Orders.
select * from Customer C
left join Orders O 
on O.CustomerId = C.Id
where O.CustomerId is Null

select Count(Distinct CustomerId) from Orders   -- to check diff 
select Count(Distinct Id) from Customer

-- List suppliers that have no customers in their country, and customers that have no suppliers in their country, and customers 
--and suppliers that are from the same country.
 -- Suppliers with no customers in their country
--SELECT 
--    'Supplier with No Customers' AS RecordType,
--    s.CompanyName AS CompanyName,
--    s.Country
--FROM 
--    Supplier s
--WHERE 
--    NOT EXISTS (
--        SELECT C.Id
--        FROM Customer c
--        WHERE c.Country = s.Country
--    )
--UNION ALL
---- Customers with no suppliers in their country
--SELECT 
--    'Customer with No Suppliers' AS RecordType,
    c.FirstName,
	c.LastName,
    c.Country
FROM 
    Customer c
WHERE 
    NOT EXISTS (
        SELECT CompanyName
        FROM Supplier s
        WHERE s.Country = c.Country
    )
UNION ALL
-- Customers and suppliers from the same country
SELECT DISTINCT
    'Customer and Supplier from Same Country' AS RecordType,
    s.CompanyName AS ComapanyName,
    c.FirstName,
	c.LastName,
    s.Country
FROM 
    Supplier s
JOIN 
    Customer c ON s.Country = c.Country;


--Match customers that are from the same city and country. That is you are asked to give a list of customers that are from same country 
--and city. Display firstname, lastname, city and country of such customers.
Select  C.FirstName as FirstName1 , C.LastName as LastName1, C2.FirstName AS FirstName2, C2.LastName AS LastName2, C.Country,C.City
from Customer C
join Customer C2
on C2.City = C.City and C2.Country = C.Country
where C.Id>C2.Id
order by Country, City 

----List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a supplier and 'Customer' if he is a
----customer accordingly. Also, do not display firstname and lastname as twoi fields; Display Full name of customer or supplier.

--select C.Id, CompanyName as ContactName, CONCAT(C.FirstName,' ',C.LastName) as ContactName, C.Country, C.City, 'Supplier' as Type, 'Customer' AS Type
--from Supplier S
--join Customer C
--on C.Country=S.Country

--. Create a copy of orders table. In this copy table, now add a column city of type varchar(40).Update this city column using the city --info in customers table.SELECT *
INTO orders_copy
FROM Orders;
ALTER TABLE orders_copy
ADD city VARCHAR(40);
UPDATE o
SET o.city = c.City
FROM orders_copy o
JOIN Customer c ON o.Id = c.Id

select * from orders_copy

--Suppose you would like to see the last OrderID and the OrderDate for this last order that was shipped to 'Paris'. Along with that 
--information, say you would also like to see the OrderDate for the last order shipped regardless of the Shipping City. In addition to 
--this, you would also like to calculate the difference in days between these two OrderDates that you get. Write a single query 
--which performs this.(Hint: make use of max (columnname) function to get the last order date and the output is a single row output.)
WITH LastOrderParis AS (
    SELECT o.Id, OrderDate
    FROM Orders o
	join Customer c on c.Id =o.Id
    WHERE c.City = 'Paris'
    ORDER BY o.Id,OrderDate DESC
),
LastOrderAnyCity AS (
    SELECT OrderDate
    FROM Orders o
	join Customer c on c.Id =o.Id
    ORDER BY OrderDate DESC
)
SELECT
    (SELECT TOP 1 Id FROM LastOrderParis) AS LastOrderIDParis,
    (SELECT TOP 1 OrderDate FROM LastOrderParis) AS LastOrderDateParis,
    (SELECT TOP 1 OrderDate FROM LastOrderAnyCity) AS LastOrderDateAnyCity,
    DATEDIFF(DAY, 
        (SELECT TOP 1 OrderDate FROM LastOrderParis), 
        (SELECT TOP 1 OrderDate FROM LastOrderAnyCity)
    ) AS DifferenceInDays


--Find those customer countries who do not have suppliers. This might help you provide better delivery time to customers by adding suppliers 
--to these countires. Use SubQueries
-- Find customer countries that do not have suppliers
select distinct Country
from Customer 
where Country not in(
select Country
from Supplier
)

/* Suppose a company would like to do some targeted marketing where it would contact customers in the country with the fewest number 
of orders. It is hoped that this targeted marketing will increase the overall sales in the targeted country. You are asked to write a query 
to get all details of such customers from top 5 countries with fewest numbers of orders. Use Subquerie
Get customers from the top 5 countries with the fewest orders*/

--SELECT *
--FROM Orders o
--WHERE Id Not IN (
    SELECT TOP 5 c.Country,c.Id
    FROM Customer c
    JOIN Orders o ON O.Id = c.Id
    GROUP BY c.Country, c.Id
    ORDER BY COUNT(c.Id) ASC
--)
/*select top 5 c.Country, c.Id
from Customer c

where Id  in (select CustomerId
        from Orders
		)
		group by Id,Country */

/* Let's say you want report of all distinct "OrderIDs" where the customer did not purchase more than 10% of the average quantity sold
for a given product. This way you could review these orders, and possibly contact the customers, to help determine if there was a reason for 
the low quantity order. Write a query to report such orderIDs.*/

-- Report of all distinct OrderIDs where the customer purchased less than 10% of the average quantity sold for a product
--SELECT DISTINCT o.Id
--FROM Orders o
--JOIN (
--    SELECT ProductId, AVG(Quantity) AS avg_quantity
--    FROM OrderItem oi
--    GROUP BY ProductId
--) avg_product
--ON ProductId = avg_product.ProductId
--WHERE oi.Quantity < 0.1 * avg_product.avg_quantity;


--SELECT DISTINCT o.Id
--FROM Orders o
--where (
--    SELECT oi.ProductId, AVG(Quantity) AS avg_quantity
--    FROM OrderItem oi
--	WHERE oi.Quantity < 0.1 
--    ) 
--	GROUP BY oi.Quantity
--ON ProductId = avg_product.ProductId
--WHERE oi.Quantity < 0.1 * avg_product.avg_quantity;

--Find Customers whose total orderitem amount is greater than 7500$ for the year 2013. The total order item amount for 1 order for a 
--customer is calculated using the formula UnitPrice * Quantity * (1 - Discount). DO NOT consider the total amount column from 
--'Order' table to calculate the total orderItem for a customer

select o.CustomerId, year(OrderDate) as Year
from Orders o
join OrderItem oi
on oi.OrderId = o.Id
where Year(OrderDate) = 2013  
group  by o.CustomerId,year(OrderDate)
having sum(oi.UnitPrice *oi.Quantity * (1 - oi.Discount))>7500

--Display the top two customers, based on the total dollar amount associated with their orders, per country. The dollar amount 
--is calculated as OI.unitprice * OI.Quantity * (1 -OI.Discount). You might want to perform a query like this so you can reward 
--these customers,since they buy the most per country. 
select top 2 o.CustomerId, c.FirstName, C.LastName, c.Country
from Orders o
join OrderItem oi on oi.OrderId = o.Id 
join Customer c on c.Id = o.Id
group  by o.CustomerId, c.FirstName, C.LastName, c.Country
order by sum(oi.UnitPrice *oi.Quantity * (1 - oi.Discount)) DESC

-- Create a View of Products whose unit price is above average Price.
CREATE VIEW averagePrice
AS
(SELECT ProductId, UnitPrice
FROM OrderItem
WHERE UnitPrice > (
    SELECT AVG(UnitPrice)
    FROM OrderItem
))

Select * from averagePrice

--Write a store procedure that performs the following action:Check if Product_copy table (this is a copy of Product table) is present.
--If table exists, the procedure should drop this table first and recreated.Add a column Supplier_name in this copy table. 
--Update this column with that of 'CompanyName' column from Supplier tab.

CREATE PROCEDURE ManageProduct AS
BEGIN
    IF OBJECT_ID('Product_Copy', 'U') IS NOT NULL
    BEGIN
        DROP TABLE Product_Copy;
    END
  SELECT *                                   --recreate product copy
    INTO Product_copy
    FROM Product;
	ALTER TABLE Product_Copy
    ADD Supplier_name NVARCHAR(255);
 UPDATE pc
    SET pc.Supplier_name = s.CompanyName
    FROM Product_copy pc
    JOIN Supplier s ON pc.SupplierId = s.Id;
END;

EXEC ManageProduct


