Use Northwind
Go

--Use Northwind database. All questions are based on assumptions described by the Database Diagram sent to you yesterday. 
--When inserting, make up info if necessary. Write query for each step. Do not use IDE. BE CAREFUL WHEN DELETING DATA OR DROPPING TABLE.

--1.  Create a view named ¡°view_product_order_[your_last_name]¡±, list all products and total ordered quantity for that product.

Drop View If Exists view_product_order_Cui 

Create View view_product_order_Cui As
Select P.ProductName, SUM(O.Quantity) AS 'Total Ordered Quantity'
From Products P Left Join [Order Details] O On O.ProductID=P.ProductID
Group By P.ProductName

Select * From view_product_order_Cui

--2.  Create a stored procedure ¡°sp_product_order_quantity_[your_last_name]¡± that accept product id as an input and total quantities of order as output parameter.

Drop Proc If Exists sp_product_order_quantity_Cui

Create Proc sp_product_order_quantity_Cui
@ProductID int
As
Begin
	Declare @OrderCount as Int
	Select @OrderCount=COUNT(OrderID)From [Order Details]Where ProductID=@ProductID AND OrderID is Not Null
	Return @OrderCount
END

Declare @Product_id Int
Declare @Order_Count Int
Set @Product_id=1 -- Input Product ID Here. 
EXEC @Order_Count=sp_product_order_quantity_Cui @Product_id
Print 'Product '+convert(varchar,@Product_id)+' has a total quantity of orders = '+convert(varchar,@Order_Count)


--3.  Create a stored procedure ¡°sp_product_order_city_[your_last_name]¡± that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.

Drop Proc If Exists sp_product_order_city_Cui

Create Proc sp_product_order_city_Cui
@ProductName Varchar(30)
As
Begin
	Select Top 5 Q.ShipCity AS 'Top 5 Cities', SUM(O.Quantity) AS 'Total Quantity Ordered'
	From Products P
	Left Join [Order Details] O On P.ProductID=O.ProductID
	Left Join Orders Q On O.OrderID=Q.OrderID
	Where P.ProductName=@ProductName AND Q.OrderID is NOT NULL
	Group By ShipCity
	Order By SUM(O.Quantity) DESC
END

Declare @Product_Name Varchar(30)
Set @Product_Name='Manjimup Dried Apples' -- Input Product Name Here. 
EXEC sp_product_order_city_Cui @Product_Name


--4.  Create 2 new tables ¡°people_your_last_name¡± ¡°city_your_last_name¡±. 
--City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
--People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. 
--Remove city of Seattle. 
--If there was anyone from Seattle, put them into a new city ¡°Madison¡±. 
--Create a view ¡°Packers_your_name¡± lists all people from Green Bay. 
--If any error occurred, no changes should be made to DB. 
--(after test) Drop both tables and view.

Create Table city_Cui(
	Id int Primary Key,
	City Varchar(30)
)

Create Table people_Cui(
	Id Int Primary Key,
	Name Varchar(30),
	City int Foreign Key References city_Cui(Id)
)

Insert Into city_Cui Values(1,'Seattle')
Insert Into city_Cui Values(2,'Green Bay')
Insert Into people_Cui Values(1,'Aaron Rodgers',2)
Insert Into people_Cui Values(2,'Russell Wilson',1)
Insert Into people_Cui Values(3,'Jody Nelson',2)

Insert Into city_Cui Values(3,'Madison')

Update people_Cui  Set City=3
Where people_Cui.City=1

Delete From city_Cui where City='Seattle'

Select * From city_Cui
Select * From people_Cui

Create View Packers_Cui As
Select Name
From people_Cui
Where City=2

Select * From Packers_Cui


Drop View If Exists Packers_Cui

Drop Table If Exists people_Cui
Drop Table If Exists city_Cui

--5.  Create a stored procedure ¡°sp_birthday_employees_[you_last_name]¡± that creates a new table ¡°birthday_employees_your_last_name¡± and fill it with all employees that have a birthday on Feb. 
--(Make a screen shot) 
--drop the table. 
--Employee table should not be affected.

Drop Table If Exists birthday_employees_Cui
Drop Proc If Exists sp_birthday_employees_Cui

Create Proc sp_birthday_employees_Cui
As
Begin
	Select * into birthday_employees_Cui From Employees Where Month(BirthDate)=2 
End

Exec sp_birthday_employees_Cui
Select * From birthday_employees_Cui

Drop Table If Exists birthday_employees_Cui

--6.  How do you make sure two tables have the same data?

-- Use EXCEPT clause. If the result using EXCEPT clause leads to less rows than original table, then we can be sure that the two tables have the same data. 