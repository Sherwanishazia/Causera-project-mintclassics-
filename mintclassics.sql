Use mintclassics;

-- 1. a) Check the total Inventory
SELECT 
    sum(p.quantityInStock) as Inventory
FROM
    products AS p
        LEFT JOIN
    warehouses AS w ON p.warehouseCode = w.warehouseCode;
 
-- 1. b) Check where are most items stored and which warehouse can be eliminated 
SELECT 
    p.productLine,
    p.warehouseCode,
    w.warehouseName,
    SUM(p.quantityInStock) AS stocks
FROM
    products AS p
        JOIN
    warehouses AS w ON p.warehouseCode = w.warehouseCode
GROUP BY p.productLine , p.warehouseCode , w.warehouseName;


-- 1. c) Examine the top-selling product.
SELECT 
    p.productLine,
    p.warehouseCode,
    w.warehouseName,
    SUM(o.priceEach * o.quantityOrdered) AS sales
FROM
    orderdetails AS o
        JOIN
    products AS p ON o.productCode = p.productCode
        JOIN
    warehouses AS w ON p.warehouseCode = w.warehouseCode
GROUP BY p.ProductLine , p.warehouseCode
ORDER BY sales;

-- 2.Determine important factors that may influence inventory reorganization/reduction.
-- Check the inventory and sales status for the warehouses 
-- This query is combination of above two query 
--  This shows the most sold products are (Classic Cars, Vinatge Cars, motorcycles) and South warehouse has lowest inventory. 
SELECT 
    stock.productLine,
    stock.warehouseCode,
    stock.warehouseName,
    stock.stocks,
    sales.sales
FROM
    (SELECT 
        p.productLine,
            p.warehouseCode,
            w.warehouseName,
            SUM(p.quantityInStock) AS stocks
    FROM
        products AS p
    JOIN warehouses AS w ON p.warehouseCode = w.warehouseCode
    GROUP BY p.productLine , p.warehouseCode , w.warehouseName) AS stock
        JOIN
    (SELECT 
        p.productLine,
            p.warehouseCode,
            w.warehouseName,
            SUM(o.priceEach * o.quantityOrdered) AS sales
    FROM
        orderdetails AS o
    JOIN products AS p ON o.productCode = p.productCode
    JOIN warehouses AS w ON p.warehouseCode = w.warehouseCode
    GROUP BY p.productLine , p.warehouseCode , w.warehouseName) AS sales ON stock.productLine = sales.productLine
        AND stock.warehouseCode = sales.warehouseCode
ORDER BY sales DESC;

-- Check the orders details to find the orders in south warehouse 
SELECT 
    p.productLine,
    o.orderNumber,
    orderLineNumber,
    o.quantityOrdered,
    orders.status
FROM
    products AS p
        JOIN
    orderdetails AS o ON o.productCode = p.productCode
        JOIN
    orders ON o.orderNumber = orders.orderNumber
WHERE
    p.warehouseCode = 'd';

 
-- Before reorganising the warehouse need to check the orders which are still in "In Process" state at south warehouse  
 SELECT 
    p.productLine,
    o.orderLineNumber,
    o.quantityOrdered,
    orders.*
FROM
    products AS p
        JOIN
    orderdetails AS o ON o.productCode = p.productCode
        JOIN
    orders ON o.orderNumber = orders.orderNumber
WHERE
    p.warehouseCode = 'd'
    AND orders.status = 'In Process';

