
use final_project;

select * from walmartdataset;

----- 1 -----

WITH monthly AS (
  SELECT Branch,
         DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS month,
         SUM(Total) AS sales
  FROM walmartdataset
  GROUP BY Branch, month
),
growth AS (
  SELECT Branch,
         month,
         sales,
         LAG(sales) OVER (PARTITION BY Branch ORDER BY month) AS prev_sales
  FROM monthly
)
SELECT Branch,
       ROUND(AVG((sales - prev_sales) / NULLIF(prev_sales, 0) * 100), 2) AS avg_growth
FROM growth
WHERE prev_sales IS NOT NULL
GROUP BY Branch
ORDER BY avg_growth DESC
LIMIT 1;

----- 2 ----

WITH profits AS (
  SELECT
    Branch,
    `Product line`,
    SUM(`gross income`) AS total_profit
  FROM walmartdataset
  GROUP BY Branch, `Product line`
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY Branch ORDER BY total_profit DESC) AS rnk
  FROM profits
)
SELECT Branch, `Product line`, total_profit
FROM ranked
WHERE rnk = 1;

----- 3 ------

SELECT 
  CASE
    WHEN total_spending < 100 THEN 'Low'
    WHEN total_spending BETWEEN 100 AND 500 THEN 'Medium'
    WHEN total_spending > 500 THEN 'High'
  END AS spending_segment,
  COUNT(DISTINCT `Customer ID`) AS number_of_customers,
  AVG(total_spending) AS avg_spending,
  MAX(total_spending) AS max_spending,
  MIN(total_spending) AS min_spending
FROM (
  SELECT `Customer ID`, SUM(`Total`) AS total_spending
  FROM walmartdataset
  GROUP BY `Customer ID`
) AS customer_spending
GROUP BY spending_segment
ORDER BY spending_segment;

----- 4 ------

SELECT 
  w.`Invoice ID`,
  w.Branch,
  w.City,
  w.`Product line`,
  w.Total,
  p.avg_sale,
  p.std_dev,
  CASE 
    WHEN w.Total > p.avg_sale + 2 * p.std_dev THEN 'High Anomaly'
    WHEN w.Total < p.avg_sale - 2 * p.std_dev THEN 'Low Anomaly'
    ELSE NULL
  END AS anomaly_type
FROM walmartdataset w
JOIN (
    SELECT 
      `Product line`,
      AVG(Total) AS avg_sale,
      STDDEV(Total) AS std_dev
    FROM walmartdataset
    GROUP BY `Product line`
) p
ON w.`Product line` = p.`Product line`
WHERE w.Total > p.avg_sale + 2 * p.std_dev
   OR w.Total < p.avg_sale - 2 * p.std_dev;

----- 5 ----

SELECT City, Payment, total_transactions
FROM (
    SELECT 
        City,
        Payment,
        COUNT(*) AS total_transactions,
        RANK() OVER (PARTITION BY City ORDER BY COUNT(*) DESC) AS rnk
    FROM walmartdataset
    GROUP BY City, Payment
) AS ranked
WHERE rnk = 1;

----- 6 ------

SELECT 
  DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS Month,
  Gender,
  SUM(Total) AS Total_Sales
FROM walmartdataset
GROUP BY Month, Gender
ORDER BY Month, Gender;

----- 7 -----
 
SELECT 
  `Customer type`,
  `Product line`,
  COUNT(*) AS total_transactions
FROM walmartdataset
GROUP BY `Customer type`, `Product line`
ORDER BY `Customer type`, total_transactions DESC;

----- 8 ------

SELECT DISTINCT
  w1.`Customer ID`,
  w1.`Invoice ID` AS first_purchase,
  w2.`Invoice ID` AS repeat_purchase,
  w1.Date AS first_purchase_date,
  w2.Date AS repeat_purchase_date
FROM walmartdataset w1
JOIN walmartdataset w2
  ON w1.`Customer ID` = w2.`Customer ID`
  AND DATEDIFF(STR_TO_DATE(w2.Date, '%d-%m-%Y'), STR_TO_DATE(w1.Date, '%d-%m-%Y')) BETWEEN 1 AND 30
  AND w1.`Invoice ID` != w2.`Invoice ID`
ORDER BY w1.`Customer ID`, w1.Date;

----- 9 -----

SELECT 
  `Customer ID`,
  SUM(Total) AS total_sales
FROM walmartdataset
GROUP BY `Customer ID`
ORDER BY total_sales DESC
LIMIT 5;

----- 10 -----

SELECT 
  DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y')) AS Day_of_Week,
  SUM(Total) AS total_sales
FROM walmartdataset
GROUP BY Day_of_Week
ORDER BY total_sales DESC;



