--*************************************************************************--
-- Title: Assignment06
-- Author: NickYoungkrantz
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-08-14,NickYoungkrantz,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_NickYoungkrantz')
	 Begin 
	  Alter Database [Assignment06DB_NickYoungkrantz] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_NickYoungkrantz;
	 End
	Create Database Assignment06DB_NickYoungkrantz;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_NickYoungkrantz;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/*'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'*/

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Try 1
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
    SELECT [CategoryID], [CategoryName]
    FROM dbo.Categories;
GO

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
    SELECT [EmployeeID], [EmployeeFirstName], [EmployeeLastName], [ManagerID]
    FROM dbo.Employees;
GO

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
    SELECT [InventoryID], [InventoryDate], [EmployeeID], [ProductID], [Count]
    FROM dbo.Inventories;
GO

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
    SELECT [ProductID], [ProductName], [CategoryID], [UnitPrice]
    FROM dbo.Products;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Try 1
DENY SELECT ON dbo.Categories TO PUBLIC;
GRANT SELECT ON dbo.vCategories TO PUBLIC;
GO

DENY SELECT ON dbo.Employees TO PUBLIC;
GRANT SELECT ON dbo.vEmployees TO PUBLIC;
GO

DENY SELECT ON dbo.Inventories TO PUBLIC;
GRANT SELECT ON dbo.vInventories TO PUBLIC;
GO

DENY SELECT ON dbo.Products TO PUBLIC;
GRANT SELECT ON dbo.vProducts TO PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/* Try 1 Can't use ORDER BY in VIEWs without TOP trick
CREATE VIEW ProductsByCategory
WITH SCHEMABINDING
AS
    SELECT [CategoryName], [ProductName], [UnitPrice]
    FROM vCategories JOIN vProducts
    ON Categories.CategoryID = Products.CategoryID
    ORDER BY 1, 2;
GO
*/

/*Try 2 Need to use namespace on table names
CREATE VIEW ProductsByCategory
WITH SCHEMABINDING
AS
    SELECT TOP 1000000000 [CategoryName], [ProductName], [UnitPrice]
    FROM vCategories JOIN vProducts
    ON vCategories.CategoryID = vProducts.CategoryID
    ORDER BY 1, 2;
GO
*/

--Try 3
CREATE VIEW ProductsByCategory
WITH SCHEMABINDING
AS
    SELECT TOP 1000000000 [CategoryName], [ProductName], [UnitPrice]
    FROM dbo.vCategories JOIN dbo.vProducts
        ON vCategories.CategoryID = vProducts.CategoryID
    ORDER BY 1, 2;
GO

/*
SELECT * FROM ProductsByCategory;
GO
*/

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Try 1
CREATE VIEW ProductInventoryCountsAndDates
WITH SCHEMABINDING
AS
    SELECT TOP 1000000000 [ProductName], [InventoryDate], [Count]
    FROM dbo.vProducts JOIN dbo.vInventories
        ON vProducts.ProductID = vInventories.ProductID
    ORDER BY 1, 2;
GO

/*
SELECT * FROM ProductInventoryCountsAndDates;
GO
*/

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Try 1
CREATE VIEW EmployeeInventoryDates
WITH SCHEMABINDING
AS
    SELECT DISTINCT TOP 100000 [InventoryDate], [EmployeeFirstName] + ' ' + [EmployeeLastName] AS EmployeeName
    FROM dbo.vInventories JOIN dbo.vEmployees
        ON vInventories.EmployeeID = vEmployees.EmployeeID
    ORDER BY [InventoryDate];
GO

/*
SELECT * FROM EmployeeInventoryDates;
GO
*/

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Try 1
CREATE VIEW ProductInventoriesByDateAndCategory
WITH SCHEMABINDING
AS
    SELECT TOP 1000000000 [CategoryName], [ProductName], [InventoryDate], [Count]
    FROM dbo.vCategories AS C JOIN dbo.vProducts AS P
            ON C.CategoryID = P.CategoryID
        JOIN dbo.vInventories AS I
            ON P.ProductID = I.ProductID
    ORDER BY 1, 2, 3, 4;
GO

/*
SELECT * FROM ProductInventoriesByDateAndCategory;
GO
*/

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Try 1
CREATE VIEW ProductInventoriesByDateAndCategoryAndEmployee
WITH SCHEMABINDING
AS
    SELECT TOP 100000000 [CategoryName], [ProductName], [InventoryDate], [Count],
            [EmployeeFirstName] + ' ' + [EmployeeLastName] AS [EmployeeName]
    FROM dbo.vCategories AS C JOIN dbo.vProducts AS P
            ON C.CategoryID = P.CategoryID
        JOIN dbo.vInventories AS I
            ON P.ProductID = I.ProductID
        JOIN dbo.vEmployees AS E
            ON I.EmployeeID = E.EmployeeID
    ORDER BY [InventoryDate], [CategoryName], [ProductName], [EmployeeName];
GO

/*
SELECT * FROM ProductInventoriesByDateAndCategoryAndEmployee;
GO
*/

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Try 1
CREATE VIEW ChaiAndChangInventoriesByDateAndEmployee
WITH SCHEMABINDING
AS
    SELECT TOP 1000000 [CategoryName], [ProductName], [InventoryDate], [Count],
            [EmployeeFirstName] + ' ' + [EmployeeLastName] AS [EmployeeName]
    FROM dbo.vCategories AS C JOIN dbo.vProducts AS P
            ON C.CategoryID = P.CategoryID
        JOIN dbo.vInventories AS I
            ON P.ProductID = I.ProductID
        JOIN dbo.vEmployees AS E
            ON I.EmployeeID = E.EmployeeID
    WHERE P.ProductID IN 
    (
        SELECT [ProductID]
        FROM dbo.vProducts
        WHERE [ProductName] = 'Chai' OR [ProductName] = 'Chang'
    )
    ORDER BY [InventoryDate], [CategoryName], [ProductName];
GO

/*
SELECT * FROM ChaiAndChangInventoriesByDateAndEmployee;
GO
*/

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW EmployeesByManager
WITH SCHEMABINDING
AS
    SELECT TOP 1000000 M.EmployeeFirstName + ' ' + M.EmployeeLastName AS [Manager],
            E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee]
    FROM dbo.vEmployees AS E JOIN dbo.vEmployees AS M
            ON E.ManagerID = M.EmployeeID
    ORDER BY [Manager], [Employee];
GO

/*
SELECT * FROM EmployeesByManager;
GO
*/

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

--Try 1
CREATE VIEW ProductInventoriesByCategoryAndEmployee
WITH SCHEMABINDING
AS
    SELECT TOP 1000000000
            C.[CategoryID], C.[CategoryName],
            P.[ProductID], P.[ProductName], P.[UnitPrice],
            I.[InventoryID], I.[InventoryDate], I.[Count],
            E.[EmployeeID], E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName] AS [Employee],
            M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName] AS [Manager]
    FROM dbo.vCategories AS C JOIN dbo.vProducts AS P
            ON C.[CategoryID] = P.[CategoryID]
        JOIN dbo.vInventories AS I
            ON P.[ProductID] = I.[ProductID]
        JOIN dbo.vEmployees AS E
            ON I.[EmployeeID] = E.EmployeeID
        JOIN dbo.vEmployees AS M
            ON E.[ManagerID] = M.[EmployeeID]
    ORDER BY C.[CategoryID], P.[ProductID], E.[EmployeeID]
GO

/*
SELECT * FROM ProductInventoriesByCategoryAndEmployee;
GO
*/

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[ProductsByCategory]
Select * From [dbo].[ProductInventoryCountsAndDates]
Select * From [dbo].[EmployeeInventoryDates]
Select * From [dbo].[ProductInventoriesByDateAndCategory]
Select * From [dbo].[ProductInventoriesByDateAndCategoryAndEmployee]
Select * From [dbo].[ChaiAndChangInventoriesByDateAndEmployee]
Select * From [dbo].[EmployeesByManager]
Select * From [dbo].[ProductInventoriesByCategoryAndEmployee]
/***************************************************************************************/