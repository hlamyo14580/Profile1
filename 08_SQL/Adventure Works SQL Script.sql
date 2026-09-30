
--- [dbo].[dim_Address]
select 
	BEA.AddressID,
	At.Name AS "AddressTypeName",
	PA.AddressLine1 AS "AddressLine", 
	PA.City,
	SP.TerritoryID, 
	ST.Name AS "TerritoryName",
	PA.StateProvinceID, 
	SP.Name As "StateProvinceName", 
	SP.StateProvinceCode,  
	SP.CountryRegionCode, 
	CR.Name As "CountryName", 
	ST.[Group] AS "Continent",
	PA.PostalCode
from Person.BusinessEntityAddress BEA
left join person.[address] PA on BEA.AddressID = PA.AddressID
left join person.AddressType AT on BEA.AddressTypeID  = AT.AddressTypeID
left join person.StateProvince SP on PA.StateProvinceID = SP.StateProvinceID
left join person.CountryRegion CR on SP.CountryRegionCode = CR.CountryRegionCode
left join sales.SalesTerritory ST on SP.TerritoryID = ST.TerritoryID

-- [dbo].[dim_Billofmaterials]
Create view dim_Billofmaterials as
SELECT [BillOfMaterialsID]
      ,[ProductAssemblyID]
      ,[ComponentID]
      ,[StartDate]
      ,[EndDate]
      ,[UnitMeasureCode]
      ,[BOMLevel]
      ,[PerAssemblyQty]
FROM Production.BillOfMaterials 

-- [dbo].[dim_Currencyrate] 
Create view dim_Currencyrate as
SELECT *
FROM [AdventureWorks2022].[Sales].[CurrencyRate]

-- [dbo].[dim_Customer]
select 
	sc.CustomerID,
	sc.PersonID,
	sc.StoreID,
	sc.TerritoryID,
	CASE WHEN pp.Title IN ('Sr.','Mr.') THEN 'Male' 
		 WHEN pp.Title IS NULL THEN 'Undefined'
		 ELSE 'Female' END AS 'Gender',
	concat(pp.FirstName,' ', pp.MiddleName,' ', pp.LastName) CustomerName,
	st.Name TerritoryName, st.CountryRegionCode,  cr.name as CountryName, st.[group] Continent,
	ss.name AS StoreName, ss.SalesPersonID,
	ea.[EmailAddress]
from sales.customer sc
left join person.person pp on sc.PersonID = pp.BusinessEntityID
left join sales.SalesTerritory st on sc.TerritoryID = st.TerritoryID
left join person.CountryRegion CR on st.CountryRegionCode = cr.CountryRegionCode
left join sales.store ss on sc.StoreID = ss.BusinessEntityID
left join person.emailaddress ea on ea.BusinessEntityID = pp.BusinessEntityID
where sc.PersonID is not null

-- [dbo].[dim_Employee]

SELECT
	   E.[BusinessEntityID] AS "Emp ID"
	  ,Concat(P.FirstName, ' ', P.MiddleName, ' ', P.LastName) AS "Emp Name"
      ,ISNULL(NULLIF([OrganizationLevel], ''), 0) AS "Org Level"
	  ,p.[PersonType] 
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
	  ,pp.[PhoneNumber]
      ,pnt.[Name] AS [PhoneNumberType]
      ,ea.[EmailAddress]
      ,p.[EmailPromotion]
	  ,a.AddressID
	  ,EmpHis.TenureYear
	  ,EmpHis.DeptChangeFrequency
	  ,EmpHis.[Emp Status]
	  ,PayHis.AllTimeChanges SalaryAllTimeChanges
	  ,PayHis.MaxPayHistory SalaryChangesFrequency
  FROM [AdventureWorks2022].[HumanResources].[Employee] e
  LEFT JOIN [Person].[Person] p on e.[BusinessEntityID] = p.[BusinessEntityID]
  LEFT JOIN [Person].[BusinessEntityAddress] bea  ON bea.[BusinessEntityID] = e.[BusinessEntityID] 
  LEFT JOIN [Person].[Address] a ON a.[AddressID] = bea.[AddressID]
  LEFT JOIN [Person].[PersonPhone] pp ON pp.BusinessEntityID = p.[BusinessEntityID]
  LEFT JOIN [Person].[PhoneNumberType] pnt ON pp.[PhoneNumberTypeID] = pnt.[PhoneNumberTypeID]
  LEFT JOIN [Person].[EmailAddress] ea ON p.[BusinessEntityID] = ea.[BusinessEntityID]
  LEFT JOIN 
  (Select distinct([Emp ID]), [TenureYear], [DeptChangeFrequency], [Emp Status] from
  [AdventureWorks2022].[dbo].[fct_EmpDeptHist] ) EmpHis ON E.[BusinessEntityID] = EmpHis.[Emp ID]
  LEFT JOIN 
  (Select distinct( [EmpID] ) EmpID, [AllTimeChanges], [MaxPayHistory]
  FROM [AdventureWorks2022].[dbo].[fct_EmpPayHist] ) PayHis ON E.[BusinessEntityID] = PayHis.EmpID

-- [dbo].[dim_Location]
Create view dim_Location as
SELECT [LocationID]
      ,[Name]
      ,[CostRate]
      ,[Availability]
  FROM [AdventureWorks2022].[Production].[Location]

--- [dbo].[dim_Product]
Create view dim_Product as
select 
	ProductID,
	PP.Name As ProductName,
	ProductNumber,
	CASE [MakeFlag] WHEN 0 THEN 'Product is Purchased' WHEN 1 THEN 'Product is manufactured in-house'
	ELSE 'Unknown' END AS "Product Make",
	CASE [FinishedGoodsFlag] WHEN 0 THEN 'Product is not a salable item'
	WHEN 1 THEN 'Product is salable' ELSE 'Unknown' END AS "FinishedGoods",
	ISNULL(Color, 'Multi') Color,
	SafetyStockLevel,
	ReorderPoint,
	StandardCost,
	ListPrice,
	Size,
	SizeUnitMeasureCode,
	pu_size.name as SizeUnitMeasure,
	WeightUnitMeasureCode,
	pu_weight.name as WeightUnitMeasure,
	Weight,
	DaysToManufacture,
	CASE [ProductLine] WHEN 'R' THEN 'Road'
	WHEN 'M' THEN 'Mountain' WHEN 'T' THEN 'Touring' WHEN 'S' THEN 'Standard'
	ELSE 'Unknown' END AS "Product Line",
	CASE [Class] WHEN 'H' THEN 'High' WHEN 'M' THEN 'Medium' WHEN 'L' THEN 'Low' ELSE 'Unknown'
	END AS "Class",
	CASE [Style] WHEN 'M' THEN 'Men' WHEN 'W' THEN 'Women' WHEN 'U' THEN 'Universal' ELSE 'Unknown'
	END AS "Style",
	ProductSubcategoryID,
	PP.ProductModelID,
	PM.Name ProductModelName,
	CAST(SellStartDate AS Date) SellStartDate,
	CAST(SellEndDate AS Date) SellEndDate
from production.Product PP
left join Production.ProductModel pm
on pp.ProductModelID = pm.ProductModelID
left join Production.UnitMeasure pu_size
on pp.SizeUnitMeasureCode = pu_size.UnitMeasureCode
left join Production.UnitMeasure pu_weight
on pp.weightUnitMeasureCode = pu_weight.UnitMeasureCode


-- [dbo].[dim_Productcategory]
Create view dim_Productcategory as
select 
	ProductCategoryID,
	Name AS ProductCategoryName
from production.ProductCategory

-- [dbo].[dim_Productsubcategory]
create view dim_Productsubcategory as
select 
	ProductSubcategoryID,
	Name AS ProductSubcategoryName,
	ProductCategoryID
from production.ProductSubcategory

--Dim_Product_Join
create view Dim_Product_Join as
select 
	ProductID,
	PP.Name As ProductName,
	ProductNumber,
	/*CASE [MakeFlag] WHEN 0 THEN 'Product is Purchased' WHEN 1 THEN 'Product is manufactured in-house'
	ELSE 'Unknown' END AS "Product Make",
	CASE [FinishedGoodsFlag] WHEN 0 THEN 'Product is not a salable item'
	WHEN 1 THEN 'Product is salable' ELSE 'Unknown' END AS "FinishedGoods",*/
	ISNULL(Color, 'Multi') Color,
	SafetyStockLevel,
	ReorderPoint,
	StandardCost,
	ListPrice,
	Size,
	SizeUnitMeasureCode,
	pu_size.name as SizeUnitMeasure,
	WeightUnitMeasureCode,
	pu_weight.name as WeightUnitMeasure,
	Weight,
	DaysToManufacture,
	/*CASE [ProductLine] WHEN 'R' THEN 'Road'
	WHEN 'M' THEN 'Mountain' WHEN 'T' THEN 'Touring' WHEN 'S' THEN 'Standard'
	ELSE 'Unknown' END AS "Product Line",
	CASE [Class] WHEN 'H' THEN 'High' WHEN 'M' THEN 'Medium' WHEN 'L' THEN 'Low' ELSE 'Unknown'
	END AS "Class",
	CASE [Style] WHEN 'M' THEN 'Men' WHEN 'W' THEN 'Women' WHEN 'U' THEN 'Universal' ELSE 'Unknown'
	END AS "Style",*/
	PS.Name as ProductSubcategoryName,
	PC.Name as ProductCategoryName,
	PP.ProductModelID,
	PM.Name ProductModelName
	/*CAST(SellStartDate AS Date) SellStartDate,
	CAST(SellEndDate AS Date) SellEndDate*/
from production.Product PP
left join Production.ProductModel pm
on pp.ProductModelID = pm.ProductModelID
left join Production.UnitMeasure pu_size
on pp.SizeUnitMeasureCode = pu_size.UnitMeasureCode
left join Production.UnitMeasure pu_weight
on pp.weightUnitMeasureCode = pu_weight.UnitMeasureCode
left Join Production.ProductSubcategory PS on PS.ProductSubcategoryID = PP.ProductSubcategoryID
left Join Production.ProductCategory PC on PS.ProductCategoryID = PC.ProductCategoryID


-- [dbo].[dim_SalesTerritory]
create view dim_SalesTerritory as
SELECT 
	[TerritoryID],
	[Name] AS "Territory Name",
	[CountryRegionCode],
	[Group] AS RegionGroup
FROM [AdventureWorks2022].[Sales].[SalesTerritory]

--- [dbo].[dim_Shift]
Create view dim_Shift as
SELECT
	   [ShiftID]
      ,[Name]
      ,[StartTime]
      ,[EndTime]
  FROM [AdventureWorks2022].[HumanResources].[Shift]

--- [dbo].[dim_Shipmethod] AS
create view dim_Shipmethod as
SELECT [ShipMethodID]
      ,[Name]
      ,[ShipBase]
      ,[ShipRate]
FROM [AdventureWorks2022].[Purchasing].[ShipMethod]

-- [dbo].[dim_SpecialOffer] as 
create view dim_SpecialOffer as
SELECT [SpecialOfferID]
      ,[Description]
      ,[DiscountPct]
      ,[Type]
      ,[Category]
      ,cast([StartDate] as date) StartDate
      ,cast([EndDate] as date) EndDate
      ,[MinQty]
      ,[MaxQty]
  FROM [AdventureWorks2022].[Sales].[SpecialOffer]

-- [dbo].[dim_SpecialOfferProduct] as 
create view dim_SpecialOfferProduct as
Select [SpecialOfferID], [ProductID]
FROM [AdventureWorks2022].[Sales].[SpecialOfferProduct]

--[dbo].[dim_Stateprovince]
create view dim_Stateprovince as
SELECT 
    sp.[StateProvinceID] 
    ,sp.[StateProvinceCode] 
    ,sp.[IsOnlyStateProvinceFlag] 
    ,sp.[Name] AS [StateProvinceName] 
    ,sp.[TerritoryID] 
    ,cr.[CountryRegionCode] 
    ,cr.[Name] AS [CountryRegionName]
FROM [Person].[StateProvince] sp 
    INNER JOIN [Person].[CountryRegion] cr 
    ON sp.[CountryRegionCode] = cr.[CountryRegionCode]

-- [dbo].[dim_Store]  
SELECT 
     s.[BusinessEntityID] AS StoreID
    ,s.[Name] AS StoreName
	,a.[AddressID]
FROM [Sales].[Store] s
    INNER JOIN [Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = s.[BusinessEntityID] 
    INNER JOIN [Person].[Address] a 
    ON a.[AddressID] = bea.[AddressID]

-- [dbo].[dim_Vendor] as
create view dim_Vendor as
SELECT V.[BusinessEntityID] AS VendorID
      ,[AccountNumber]
      ,[Name] AS VendorName
      ,[CreditRating]
      ,[PreferredVendorStatus]
      ,[ActiveFlag]
	  ,a.[AddressID]
FROM [Purchasing].[Vendor] V
INNER JOIN [Person].[BusinessEntityAddress] bea 
ON bea.[BusinessEntityID] = v.[BusinessEntityID] 
INNER JOIN [Person].[Address] a 
ON a.[AddressID] = bea.[AddressID]

-- [dbo].[fct_EmpDeptHist]
Create View fct_EmpDeptHist as
WITH DeptHist as (
SELECT  [BusinessEntityID] AS "Emp ID"
      ,EH.[DepartmentID] AS "Dept ID"
	  ,ED.[Name] AS "Section Name"
	  ,ED.[GroupName] AS "Dept Name"
      ,EH.[ShiftID]
	  ,S.[Name] AS "Shift Name"
	  ,RANK() OVER (PARTITION BY [BusinessEntityID] ORDER BY StartDate desc) "HistoryCount"
      ,[StartDate]
      ,[EndDate]
  FROM [AdventureWorks2022].[HumanResources].[EmployeeDepartmentHistory] EH
  LEFT JOIN [AdventureWorks2022].[HumanResources].[Department] ED On EH.DepartmentID = ED.DepartmentID
  LEFT JOIN [AdventureWorks2022].[HumanResources].[Shift] S ON EH.[ShiftID] = S.[ShiftID] )

, secondstep as (
Select 
	[Emp ID],
	[Dept ID],
	[Section Name],
	[Dept Name],
	ShiftID,
	[Shift Name],
	[StartDate], 
	HistoryCount,
	CASE WHEN HistoryCount  = 1 AND EndDate IS NULL THEN CAST('2014-06-30' AS Date) ELSE EndDate 
	END AS "EndDate",
	MAX(HistoryCount) OVER (PARTITION BY [Emp ID]) AS "DeptChangeFrequency"
From DeptHist )

, thirdstep as (
Select 
	[Emp ID],
	[Dept ID],
	[Section Name],
	[Dept Name],
	ShiftID,
	[Shift Name],
	StartDate,
	EndDate,
	HistoryCount,
	DeptChangeFrequency,
	MIN(StartDate) OVER (PARTITION BY [Emp ID]) "MinStartDate",
	MAX(EndDate) OVER (PARTITION BY [Emp ID]) "MaxEndDate"
From secondstep )


select 
	[Emp ID],
	[Dept ID],
	[Section Name],
	[Dept Name],
	ShiftID,
	[Shift Name],
	StartDate,
	EndDate,
	DeptChangeFrequency,
	Datediff(day,Minstartdate,MaxEndDate)/ 365.25 TenureYear,
	CASE WHEN  MaxEndDate <> '20140630' THEN 'Inactive' ELSE 'Active' END AS "Emp Status"
from thirdstep

-- [dbo].[fct_EmpPayHist] 
Create view fct_EmpPayHist as
with firststep as (
SELECT [BusinessEntityID] as "EmpID"
      ,cast([RateChangeDate] as date) RateChangeDate
      ,[Rate]
      ,[PayFrequency]
	  ,CASE PayFrequency WHEN 1 THEN 'Monthly' WHEN 2 THEN ' Biweekly'
	   ELSE 'Unknown' END AS PayFrequencyStatus
	  ,RANK() OVER (PARTITION BY [BusinessEntityID] ORDER BY RateChangeDate desc) "PayHistory"
	  ,Max(Rate) OVER (PARTITION BY [BusinessEntityID]) "MaxRate"
	  ,Min(Rate) OVER (PARTITION BY [BusinessEntityID]) "MinRate"
	  ,LEAD(Rate) OVER (PARTITION BY [BusinessEntityID] ORDER BY RateChangeDate desc)  "LeadPay"
  FROM [AdventureWorks2022].[HumanResources].[EmployeePayHistory] )

Select 
	EmpID,
	RateChangeDate,
	Rate, 
	LeadPay, 
	CASE WHEN LeadPay Is not null THEN ((Rate - LeadPay) / LeadPay) ELSE 0 END AS "PercentChange",
	((MaxRate - MinRate) / MinRate)  AS "AllTimeChanges",
	PayFrequency,
	PayFrequencyStatus, PayHistory,  
	Max(PayHistory) OVER (PARTITION BY EmpID) MaxPayHistory
From firststep

--[dbo].[fct_Inventory]
create view fct_Inventory as
SELECT [ProductID]
      ,[LocationID]
      ,[Shelf]
      ,[Bin]
      ,[Quantity]
      ,[ModifiedDate]
  FROM [AdventureWorks2022].[Production].[ProductInventory]

--[dbo].[fct_ProductbyVendor] as
Create view fct_ProductbyVendor as
SELECT [ProductID]
      ,PV.[BusinessEntityID] AS VendorID
	  ,V.Name AS VendorName
      ,[AverageLeadTime]
      ,[StandardPrice]
      ,[LastReceiptCost]
      ,CAST([LastReceiptDate] AS DATE) LastReceiptDate
      ,[MinOrderQty]
      ,[MaxOrderQty]
      ,CASE WHEN [OnOrderQty] IS NULL THEN 0 ELSE [OnOrderQty] END AS OnOrderQty
      ,PV.[UnitMeasureCode]
	  ,UM.Name AS UnitMeasureName
      ,CAST(PV.[ModifiedDate] AS DATE) ModifiedDate
FROM [Purchasing].[ProductVendor] PV
LEFT JOIN [Purchasing].[Vendor] V ON PV.BusinessEntityID = V.BusinessEntityID
LEFT JOIN [Production].[UnitMeasure] UM ON  PV.[UnitMeasureCode] = UM.[UnitMeasureCode]

-- [dbo].[fct_PurchaseOrder] as
Create view fct_PurchaseOrder as
SELECT PD.[PurchaseOrderID]
      ,PD.[PurchaseOrderDetailID]
	  ,CAST(PH.[OrderDate] AS DATE) AS OrderDate
	  ,CAST(PH.[ShipDate] AS DATE) AS ShipDate
      ,CAST(PD.[DueDate] AS DATE) AS DueDate
      ,PD.[OrderQty]
      ,PD.[ProductID]
      ,PD.[UnitPrice]
      ,PD.[LineTotal]
      ,PD.[ReceivedQty]
      ,PD.[RejectedQty]
      ,PD.[StockedQty]
	  ,PH.[RevisionNumber]
	  ,CASE PH.[Status] WHEN 1 THEN 'Pending' WHEN 2 THEN 'Approved' WHEN 3 THEN 'Rejected' WHEN 4 THEN 'Complete' ELSE 'Unknown' END AS "Status"
	  ,PH.[EmployeeID]
	  ,PH.[VendorID]
	  ,PH.[ShipMethodID]
	  ,PH.[SubTotal]
	  ,COUNT(PH.[PurchaseOrderID]) OVER(PARTITION BY PH.[PurchaseOrderID] ORDER BY PH.[PurchaseOrderID]) AS "PO LineCount"
	  ,PH.[TaxAmt]/ COUNT(PH.[PurchaseOrderID]) OVER(PARTITION BY PH.[PurchaseOrderID] ORDER BY PH.[PurchaseOrderID]) AS "TaxAmt"
	  ,PH.[Freight]/ COUNT(PH.[PurchaseOrderID]) OVER(PARTITION BY PH.[PurchaseOrderID] ORDER BY PH.[PurchaseOrderID]) AS "Freight"
FROM [Purchasing].[PurchaseOrderDetail] PD 
LEFT JOIN [Purchasing].[PurchaseOrderHeader] PH 
ON PD.PurchaseOrderID = PH.PurchaseOrderID

-- [dbo].[fct_SalesDetatils] as
Create view fct_SalesDetails as
select 
	SD.SalesOrderID, 
	SD.SalesOrderDetailID, 
	SD.ProductID,
	cast(SH.OrderDate as date) OrderDate, 
	cast(SH.ShipDate as date) ShipDate, 
	SH.CustomerID, 
	CASE WHEN SH.SalesPersonID = ' ' THEN '9999' ELSE SH.SalesPersonID END AS SalesPersonID , 
	SH.TerritoryID, 
	SH.BillToAddressID, 
	SH.ShipToAddressID, 
	SH.OnlineOrderFlag,
	SD.OrderQty, 
    SD.UnitPrice,
    SD.UnitPriceDiscount, 
	SD.UnitPrice * SD.UnitPriceDiscount AS "DiscountAmt",
	(cast(SD.OrderQty as float)/ sum(SD.OrderQty) over (partition by sd.salesorderid)) * SH.Freight AS "Line Freight Amt",
	 SD.LineTotal, 
	(SD.LineTotal/SH.SubTotal) * SH.TaxAmt AS "Line Tax Amt",
    PCH.StandardCost,
	SH.CurrencyRateID,
	SD.SpecialOfferID,
	SH.ShipMethodID
from sales.SalesOrderDetail SD
left Join sales.SalesOrderHeader SH on SD.SalesOrderID = SH.SalesOrderID
left Join 
( select 
	ProductId,
	StartDate, 
	CASE 
		dense_rank () OVer(partition by productid  order by startdate desc)  WHEN 1 THEN getdate()
		ELSE enddate ENd As "EndDate",
	StandardCost
from Production.ProductCostHistory ) PCH on Sd.ProductID = PCH.ProductID 
and SH.OrderDate between PCH.StartDate and PCH.EndDate

---[dbo].[fct_workorder] as
Create view fct_workorder as
SELECT WO.[WorkOrderID]
	  ,WOR.[OperationSequence]
      ,WO.[ProductID]
      ,[OrderQty]
      ,[StockedQty]
      ,[ScrappedQty]  --- OrderQty - StockedQty
      ,CAST(WOR.[ScheduledStartDate] AS DATE) ScheduledStartDate
      ,CAST(WOR.[ScheduledEndDate] AS DATE) ScheduledEndDate
      ,CAST(WOR.[ActualStartDate] AS DATE) ActualStartDate
      ,CAST(WOR.[ActualEndDate] AS DATE) ActualEndDate
	  ,CAST(WO.[StartDate] AS date) StartDate
	  ,CAST(WO.[EndDate] AS date) EndDate
      ,CAST(WO.[DueDate] AS DATE) DueDate
      ,WO.[ScrapReasonID]
	  ,SR.[Name] AS "ScrapReason"
	  ,ActualResourceHrs
	  ,PlannedCost
	  ,ActualCost
	  ,WOR.LocationID
	  ,LOC.Name AS LocationName
	  ,LOC.CostRate AS LocationCostRate
	  ,LOC.Availability LocationAvailability
FROM Production.WorkOrder WO
LEFT JOIN Production.WorkOrderRouting WOR ON WO.WorkOrderID = WOR.WorkOrderID
LEFT JOIN Production.ScrapReason SR ON WO.ScrapReasonID = SR.ScrapReasonID
LEFT JOIN Production.Location LOC ON WOR.LocationID = LOC.LocationID



