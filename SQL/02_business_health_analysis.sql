--Q1. Which product departments generate the highest sales revenue?

--Check for missing departments
SELECT
    t.product_id,
    p.department
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
WHERE p.department IS NULL;

--Check for negative sales values
SELECT *
FROM transaction_data
WHERE sales_value < 0;

--Calculate total revenue by department
SELECT
    p.department,
    SUM(t.sales_value) AS total_revenue
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY total_revenue DESC;

--Q2. Which product departments have the highest transaction volume?

--Calculate unique transactions handled by each department
SELECT
    p.department,
    COUNT(DISTINCT t.basket_id) AS total_transactions
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY total_transactions DESC;

--Q3. Which product departments have the highest average basket value?

SELECT
    p.department,
    ROUND(
        SUM(t.sales_value) /
        COUNT(DISTINCT t.basket_id),
        2
    ) AS avg_revenue_per_transaction
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY avg_revenue_per_transaction DESC;

--Q4. Which product departments sell the highest number of units?

SELECT
    p.department,
    SUM(t.quantity) AS total_units_sold
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY total_units_sold DESC;

--Q5. Which product departments receive the highest total discount?

SELECT
    p.department,
    ABS(
        SUM(
            t.retail_disc +
            t.coupon_disc +
            t.coupon_match_disc
        )
    ) AS total_discount
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY total_discount DESC;

--Q6. Which product departments receive the highest average discount per transaction?

SELECT
    p.department,
    ROUND(
        ABS(
            SUM(
                t.retail_disc +
                t.coupon_disc +
                t.coupon_match_disc
            )
        ) /
        COUNT(DISTINCT t.basket_id),
        2
    ) AS avg_discount_per_transaction
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY avg_discount_per_transaction DESC;

--Q7. Which product departments have the largest average basket size?

SELECT
    p.department,
    ROUND(
        SUM(t.quantity)::NUMERIC /
        COUNT(DISTINCT t.basket_id),
        2
    ) AS avg_items_per_transaction
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
GROUP BY p.department
ORDER BY avg_items_per_transaction DESC;

--8. Which product departments have the highest average selling price per unit?

--Initial analysis to calculate the average selling price per unit for each department.
SELECT
    p.department,
    ROUND(
        SUM(t.sales_value) / SUM(t.quantity)::NUMERIC,
        2
    ) AS avg_selling_price_per_unit
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
WHERE p.department NOT IN ('KIOSK-GAS', 'MISC SALES TRAN')
GROUP BY p.department
ORDER BY avg_selling_price_per_unit DESC;


--The query returned a division-by-zero error, so I checked whether any department had a total quantity of zero.
SELECT
    p.department,
    SUM(t.quantity) AS total_quantity
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
WHERE p.department NOT IN ('KIOSK-GAS', 'MISC SALES TRAN')
GROUP BY p.department
HAVING SUM(t.quantity) = 0;


--The previous query showed a blank department, so I checked whether it was NULL or an empty string.
SELECT DISTINCT department
FROM product
WHERE department IS NULL
   OR department = '';


--Since no NULL or empty department was found, I reviewed all departments to identify which one had a total quantity of zero.
SELECT
    p.department,
    SUM(t.quantity) AS total_quantity,
    COUNT(*) AS rows_count
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
WHERE p.department NOT IN ('KIOSK-GAS', 'MISC SALES TRAN')
GROUP BY p.department
ORDER BY total_quantity;


--The blank department turned out to contain only whitespace, so I verified it using TRIM().
SELECT
    DISTINCT department,
    LENGTH(department) AS length
FROM product
WHERE TRIM(department) = '';


--Final solution: exclude whitespace-only departments and prevent division-by-zero errors.
SELECT
    p.department,
    ROUND(
        SUM(t.sales_value) /
        NULLIF(SUM(t.quantity), 0)::NUMERIC,
        2
    ) AS avg_selling_price_per_unit
FROM transaction_data t
JOIN product p
ON t.product_id = p.product_id
WHERE p.department NOT IN ('KIOSK-GAS', 'MISC SALES TRAN')
  AND TRIM(p.department) <> ''
GROUP BY p.department
ORDER BY avg_selling_price_per_unit DESC;
