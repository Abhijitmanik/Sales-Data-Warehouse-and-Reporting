
--Table 1: DimCustomers

CREATE TABLE DimCustomers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    JoinDate DATE
);


--Table 2: DimProducts

CREATE TABLE DimProducts (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10, 2)
);
--Table 3: DimSalesChannel

CREATE TABLE DimSalesChannel (
    SalesChannelID INT PRIMARY KEY,
    ChannelName VARCHAR(50)
);

--Table 4: DimTime

CREATE TABLE DimTime (
    DateKey INT PRIMARY KEY,  -- Format: YYYYMMDD
    FullDate DATE,
    Year INT,
    Month INT,
    Day INT,
    DayOfWeek VARCHAR(10)
);
--Table 5: FactSales

CREATE TABLE FactSales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    SalesChannelID INT,
    DateKey INT,
    Quantity INT,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProducts(ProductID),
    FOREIGN KEY (SalesChannelID) REFERENCES DimSalesChannel(SalesChannelID),
    FOREIGN KEY (DateKey) REFERENCES DimTime(DateKey)
);

INSERT INTO DimCustomers (CustomerID, FirstName, LastName, Email, City, State, JoinDate)
VALUES 
(1, 'John', 'Doe', 'john.doe@example.com', 'New York', 'NY', '2022-01-10'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', 'Los Angeles', 'CA', '2022-03-15'),
(3, 'Michael', 'Johnson', 'michael.j@example.com', 'Chicago', 'IL', '2022-05-20'),
(4, 'Emily', 'Davis', 'emily.d@example.com', 'Houston', 'TX', '2022-07-01'),
(5, 'Daniel', 'Brown', 'daniel.b@example.com', 'Phoenix', 'AZ', '2022-09-09');

INSERT INTO DimProducts (ProductID, ProductName, Category, UnitPrice)
VALUES
(101, 'Laptop', 'Electronics', 999.99),
(102, 'Smartphone', 'Electronics', 699.99),
(103, 'Tablet', 'Electronics', 499.99),
(104, 'Headphones', 'Accessories', 199.99),
(105, 'Wireless Charger', 'Accessories', 49.99);


INSERT INTO DimSalesChannel (SalesChannelID, ChannelName)
VALUES
(1, 'Online'),
(2, 'In-Store');

INSERT INTO DimTime (DateKey, FullDate, Year, Month, Day, DayOfWeek)
VALUES
(20230101, '2023-01-01', 2023, 1, 1, 'Sunday'),
(20230102, '2023-01-02', 2023, 1, 2, 'Monday'),
(20230103, '2023-01-03', 2023, 1, 3, 'Tuesday'),
(20230104, '2023-01-04', 2023, 1, 4, 'Wednesday'),
(20230105, '2023-01-05', 2023, 1, 5, 'Thursday');


INSERT INTO FactSales (SaleID, CustomerID, ProductID, SalesChannelID, DateKey, Quantity, TotalAmount)
VALUES
(1001, 1, 101, 1, 20230101, 1, 999.99),   -- John Doe bought 1 Laptop Online
(1002, 2, 102, 2, 20230102, 2, 1399.98),  -- Jane Smith bought 2 Smartphones In-Store
(1003, 3, 103, 1, 20230103, 1, 499.99),   -- Michael Johnson bought 1 Tablet Online
(1004, 4, 104, 2, 20230104, 3, 599.97),   -- Emily Davis bought 3 Headphones In-Store
(1005, 5, 105, 1, 20230105, 4, 199.96);   -- Daniel Brown bought 4 Wireless Chargers 


--1. Total sales by product category

SELECT P.Category, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimProducts P ON FS.ProductID = P.ProductID
GROUP BY P.Category
ORDER BY TotalSales DESC;

-- Monthly sales trend for the past year

SELECT T.Year, T.Month, SUM(FS.TotalAmount) AS MonthlySales
FROM FactSales FS
JOIN DimTime T ON FS.DateKey = T.DateKey
WHERE T.Year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY T.Year, T.Month
ORDER BY T.Year, T.Month;

--3. Top 5 customers by total spend

SELECT C.FirstName, C.LastName, SUM(FS.TotalAmount) AS TotalSpent
FROM FactSales FS
JOIN DimCustomers C ON FS.CustomerID = C.CustomerID
GROUP BY C.FirstName, C.LastName
ORDER BY TotalSpent DESC
LIMIT 5;
--4. Sales channel performance comparison (online vs in-store)

SELECT SC.ChannelName, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimSalesChannel SC ON FS.SalesChannelID = SC.SalesChannelID
GROUP BY SC.ChannelName
ORDER BY TotalSales DESC;
--5. Sales by day of the week

SELECT T.DayOfWeek, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimTime T ON FS.DateKey = T.DateKey
GROUP BY T.DayOfWeek
ORDER BY  
    CASE T.DayOfWeek
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

--6. Average order value (AOV) per sales channel

SELECT SC.ChannelName, AVG(FS.TotalAmount) AS AvgOrderValue
FROM FactSales FS
JOIN DimSalesChannel SC ON FS.SalesChannelID = SC.SalesChannelID
GROUP BY SC.ChannelName;

--7. Top-selling products by quantity

SELECT P.ProductName, SUM(FS.Quantity) AS TotalQuantitySold
FROM FactSales FS
JOIN DimProducts P ON FS.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalQuantitySold DESC
LIMIT 5;
--8. Year-over-year growth in total sales

SELECT T.Year, SUM(FS.TotalAmount) AS YearlySales,
       LAG(SUM(FS.TotalAmount), 1) OVER (ORDER BY T.Year) AS PreviousYearSales,
       (SUM(FS.TotalAmount) - LAG(SUM(FS.TotalAmount), 1) OVER (ORDER BY T.Year)) / LAG(SUM(FS.TotalAmount), 1) OVER (ORDER BY T.Year) * 100 AS YoYGrowth
FROM FactSales FS
JOIN DimTime T ON FS.DateKey = T.DateKey
GROUP BY T.Year
ORDER BY T.Year;
--9. Customer lifetime value (CLV) by customer

SELECT C.CustomerID, C.FirstName, C.LastName, SUM(FS.TotalAmount) AS CLV
FROM FactSales FS
JOIN DimCustomers C ON FS.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.FirstName, C.LastName
ORDER BY CLV DESC;
--10. Most profitable products (total revenue)

SELECT P.ProductName, SUM(FS.TotalAmount) AS TotalRevenue
FROM FactSales FS
JOIN DimProducts P ON FS.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalRevenue DESC;

--11. Average sales per day of the week

SELECT T.DayOfWeek, AVG(FS.TotalAmount) AS AvgSales
FROM FactSales FS
JOIN DimTime T ON FS.DateKey = T.DateKey
GROUP BY T.DayOfWeek
ORDER BY 
    CASE T.DayOfWeek
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

--12. Identify underperforming products (low sales)

SELECT P.ProductName, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimProducts P ON FS.ProductID = P.ProductID
GROUP BY P.ProductName
HAVING SUM(FS.TotalAmount) < 5000  -- Set a threshold for low sales
ORDER BY TotalSales ASC;
--13. Total sales by customer location (city or state)

SELECT C.City, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimCustomers C ON FS.CustomerID = C.CustomerID
GROUP BY C.City
ORDER BY TotalSales DESC;

--14. Products that have never been sold

SELECT P.ProductName
FROM DimProducts P
LEFT JOIN FactSales FS ON P.ProductID = FS.ProductID
WHERE FS.ProductID IS NULL;

--15. Sales per customer segment (grouped by total spend)

WITH CustomerSpending AS (
    SELECT FS.CustomerID, SUM(FS.TotalAmount) AS TotalSpent
    FROM FactSales FS
    GROUP BY FS.CustomerID
)
SELECT 
    CASE 
        WHEN TotalSpent < 100 THEN 'Low Spender'
        WHEN TotalSpent BETWEEN 100 AND 1000 THEN 'Medium Spender'
        ELSE 'High Spender' 
    END AS CustomerSegment,
    COUNT(CustomerID) AS CustomerCount
FROM CustomerSpending
GROUP BY CustomerSegment;

--16. Product sales by category over the last 6 months

SELECT P.Category, T.Year, T.Month, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimProducts P ON FS.ProductID = P.ProductID
JOIN DimTime T ON FS.DateKey = T.DateKey
WHERE T.FullDate >= CURRENT_DATE - INTERVAL '6 MONTHS'
GROUP BY P.Category, T.Year, T.Month
ORDER BY T.Year, T.Month, P.Category;

--17. Total sales on the busiest day of the year
SELECT T.FullDate, SUM(FS.TotalAmount) AS TotalSales
FROM FactSales FS
JOIN DimTime T ON FS.DateKey = T.DateKey
GROUP BY T.FullDate
ORDER BY TotalSales DESC
LIMIT 1;


--18. Customer retention rate

WITH FirstOrder AS (
    SELECT CustomerID, MIN(T.FullDate) AS FirstOrderDate
    FROM FactSales FS
    JOIN DimTime T ON FS.DateKey = T.DateKey
    GROUP BY CustomerID
),
RepeatOrder AS (
    SELECT CustomerID, COUNT(DISTINCT SaleID) - 1 AS RepeatOrders
    FROM FactSales FS
    JOIN DimTime T ON FS.DateKey = T.DateKey
    WHERE T.FullDate > (SELECT MIN(T.FullDate) FROM FactSales FS JOIN DimTime T ON FS.DateKey = T.DateKey)
    GROUP BY CustomerID
)
SELECT ROUND(SUM(CASE WHEN RepeatOrders > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS RetentionRate
FROM RepeatOrder;
--19. Total number of new customers per month

SELECT T.Year, T.Month, COUNT(DISTINCT FS.CustomerID) AS NewCustomers
FROM FactSales FS
JOIN DimTime T ON FS.DateKey = T.DateKey
WHERE FS.CustomerID IN (
    SELECT CustomerID
    FROM FactSales
    GROUP BY CustomerID
    HAVING MIN(DateKey) = FS.DateKey
)
GROUP BY T.Year, T.Month
ORDER BY T.Year, T.Month;
--20. Products that contribute to 80% of total sales (Pareto Analysis)

WITH ProductSales AS (
    SELECT P.ProductName, SUM(FS.TotalAmount) AS TotalSales
    FROM FactSales FS
    JOIN DimProducts P ON FS.ProductID = P.ProductID
    GROUP BY P.ProductName
),
CumulativeSales AS (
    SELECT ProductName, TotalSales, 
           SUM(TotalSales) OVER (ORDER BY TotalSales DESC) / (SELECT SUM(TotalSales) FROM ProductSales) AS CumulativeSales
    FROM ProductSales
)
SELECT ProductName, TotalSales
FROM CumulativeSales
WHERE CumulativeSales <= 0.8
ORDER BY CumulativeSales;

















