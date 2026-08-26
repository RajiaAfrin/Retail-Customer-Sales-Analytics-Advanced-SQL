--Database modeling and validat
DROP TABLE IF EXISTS transaction_data;
CREATE TABLE transaction_data (
    household_key      INTEGER,
    basket_id          BIGINT,
    day                INTEGER,
    product_id         INTEGER,
    quantity           INTEGER,
    sales_value        NUMERIC(10,2),
    store_id           INTEGER,
    retail_disc        NUMERIC(10,2),
    trans_time         INTEGER,
    week_no            INTEGER,
    coupon_disc        NUMERIC(10,2),
    coupon_match_disc  NUMERIC(10,2)
);
SELECT COUNT(*)
FROM transaction_data;

SELECT
    basket_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM transaction_data
GROUP BY
    basket_id,
    product_id
HAVING COUNT(*) > 1;
SELECT *
FROM transaction_data
WHERE basket_id IS NULL
   OR product_id IS NULL;
   
ALTER TABLE transaction_data
ADD CONSTRAINT pk_transaction_data
PRIMARY KEY (basket_id, product_id);go

DROP TABLE IF EXISTS product;

CREATE TABLE product (
    product_id            INTEGER,
    manufacturer          INTEGER,
    department            TEXT,
    brand                 TEXT,
    commodity_desc        TEXT,
    sub_commodity_desc    TEXT,
    curr_size_of_product  TEXT
);

SELECT COUNT(*)
FROM product;

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM product
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM product
WHERE product_id IS NULL;

ALTER TABLE product
ADD CONSTRAINT pk_product
PRIMARY KEY (product_id);

DROP TABLE IF EXISTS hh_demographic;

CREATE TABLE hh_demographic (
    age_desc              TEXT,
    marital_status_code   TEXT,
    income_desc           TEXT,
    homeowner_desc        TEXT,
    hh_comp_desc          TEXT,
    household_size_desc   TEXT,
    kid_category_desc     TEXT,
    household_key         INTEGER
);
SELECT COUNT(*)
FROM hh_demographic;

SELECT
    household_key,
    COUNT(*) AS duplicate_count
FROM hh_demographic
GROUP BY household_key
HAVING COUNT(*) > 1;

SELECT *
FROM hh_demographic
WHERE household_key IS NULL;

ALTER TABLE hh_demographic
ADD CONSTRAINT pk_hh_demographic
PRIMARY KEY (household_key);

DROP TABLE IF EXISTS campaign_desc;

CREATE TABLE campaign_desc (
    description TEXT,
    campaign    INTEGER,
    start_day   INTEGER,
    end_day     INTEGER
);

SELECT COUNT(*)
FROM campaign_desc;

SELECT
    campaign,
    COUNT(*) AS duplicate_count
FROM campaign_desc
GROUP BY campaign
HAVING COUNT(*) > 1;

SELECT *
FROM campaign_desc
WHERE campaign IS NULL;

ALTER TABLE campaign_desc
ADD CONSTRAINT pk_campaign_desc
PRIMARY KEY (campaign);

DROP TABLE IF EXISTS campaign_table;
CREATE TABLE campaign_table (
    description   TEXT,
    household_key INTEGER,
    campaign      INTEGER
);

SELECT COUNT(*)
FROM campaign_table;

SELECT
    household_key,
    campaign,
    COUNT(*) AS duplicate_count
FROM campaign_table
GROUP BY household_key, campaign
HAVING COUNT(*) > 1;

SELECT *
FROM campaign_table
WHERE household_key IS NULL
   OR campaign IS NULL;

ALTER TABLE campaign_table
ADD CONSTRAINT pk_campaign_table
PRIMARY KEY (household_key, campaign);

ALTER TABLE transaction_data
ADD CONSTRAINT fk_transaction_product
FOREIGN KEY (product_id)
REFERENCES product(product_id);

ALTER TABLE campaign_table
ADD CONSTRAINT fk_campaign_desc
FOREIGN KEY (campaign)
REFERENCES campaign_desc(campaign);

DROP TABLE IF EXISTS coupon;

CREATE TABLE coupon (
    coupon_upc BIGINT,
    product_id INTEGER,
    campaign INTEGER
);

SELECT COUNT(*)
FROM coupon;

SELECT
    coupon_upc,
    product_id,
    campaign,
    COUNT(*) AS duplicate_count
FROM coupon
GROUP BY
    coupon_upc,
    product_id,
    campaign
HAVING COUNT(*) > 1;

SELECT *
FROM coupon
WHERE coupon_upc = 54180010033
  AND product_id = 91572
  AND campaign = 13;
  
SELECT *
FROM coupon
WHERE coupon_upc IS NULL
   OR product_id IS NULL
   OR campaign IS NULL;
   
SELECT COUNT(*)
FROM coupon c
LEFT JOIN product p
ON c.product_id = p.product_id
WHERE p.product_id IS NULL;

ALTER TABLE coupon
ADD CONSTRAINT fk_coupon_product
FOREIGN KEY (product_id)
REFERENCES product(product_id);

SELECT COUNT(*)
FROM coupon c
LEFT JOIN campaign_desc cd
ON c.campaign = cd.campaign
WHERE cd.campaign IS NULL;

ALTER TABLE coupon
ADD CONSTRAINT fk_coupon_campaign
FOREIGN KEY (campaign)
REFERENCES campaign_desc(campaign);

DROP TABLE IF EXISTS coupon_redempt;

CREATE TABLE coupon_redempt (
    household_key INTEGER,
    day INTEGER,
    coupon_upc BIGINT,
    campaign INTEGER
);

SELECT COUNT(*)
FROM coupon_redempt;

SELECT
    household_key,
    coupon_upc,
    campaign,
    COUNT(*) AS duplicate_count
FROM coupon_redempt
GROUP BY
    household_key,
    coupon_upc,
    campaign
HAVING COUNT(*) > 1;
SELECT *
FROM coupon_redempt
WHERE household_key = 1228
  AND coupon_upc = 54900050076
  AND campaign = 18;

SELECT
    household_key,
    coupon_upc,
    campaign,
    day,
    COUNT(*) AS duplicate_count
FROM coupon_redempt
GROUP BY
    household_key,
    coupon_upc,
    campaign,
    day
HAVING COUNT(*) > 1;

ALTER TABLE coupon_redempt
ADD CONSTRAINT pk_coupon_redempt
PRIMARY KEY (household_key, coupon_upc, campaign, day);

SELECT COUNT(*)
FROM coupon_redempt cr
LEFT JOIN hh_demographic h
ON cr.household_key = h.household_key
WHERE h.household_key IS NULL;

SELECT COUNT(*)
FROM coupon_redempt cr
LEFT JOIN campaign_desc cd
ON cr.campaign = cd.campaign
WHERE cd.campaign IS NULL;

ALTER TABLE coupon_redempt
ADD CONSTRAINT fk_coupon_redempt_campaign
FOREIGN KEY (campaign)
REFERENCES campaign_desc(campaign);

DROP TABLE IF EXISTS causal_data;

CREATE TABLE causal_data (
    product_id INTEGER,
    store_id INTEGER,
    week_no INTEGER,
    display TEXT,
    mailer TEXT
);

SELECT COUNT(*)
FROM causal_data;

SELECT *
FROM causal_data
LIMIT 10;

ALTER TABLE causal_data
ADD CONSTRAINT pk_causal_data
PRIMARY KEY (product_id, store_id, week_no);

SELECT *
FROM causal_data
WHERE product_id = 27658
  AND store_id = 361
  AND week_no = 59;

ALTER TABLE causal_data
ADD CONSTRAINT pk_causal_data
PRIMARY KEY (product_id, store_id, week_no, display);

SELECT *
FROM causal_data
WHERE product_id = 262910
  AND store_id = 330
  AND week_no = 77
  AND display = '5';

SELECT
    product_id,
    store_id,
    week_no,
    display,
    mailer,
    COUNT(*) AS duplicate_count
FROM causal_data
GROUP BY
    product_id,
    store_id,
    week_no,
    display,
    mailer
HAVING COUNT(*) > 1
LIMIT 10;

SELECT *
FROM causal_data
WHERE product_id IS NULL
   OR store_id IS NULL
   OR week_no IS NULL
   OR display IS NULL
   OR mailer IS NULL
LIMIT 10;

ALTER TABLE causal_data
ADD CONSTRAINT pk_causal_data
PRIMARY KEY (
    product_id,
    store_id,
    week_no,
    display,
    mailer
);

SELECT COUNT(*)
FROM causal_data cd
LEFT JOIN product p
ON cd.product_id = p.product_id
WHERE p.product_id IS NULL;

ALTER TABLE causal_data
ADD CONSTRAINT fk_causal_data_product
FOREIGN KEY (product_id)
REFERENCES product(product_id);

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

--9. How is monthly revenue changing over time?

WITH monthly_revenue AS (

    SELECT
        week_no,
        SUM(sales_value) AS revenue
    FROM transaction_data
    GROUP BY week_no

)

SELECT
    week_no,

    ROUND(revenue,2) AS weekly_revenue,

    ROUND(
        revenue
        - LAG(revenue) OVER(
            ORDER BY week_no
        ),
        2
    ) AS revenue_change,

    ROUND(
        (
            revenue
            - LAG(revenue) OVER(
                ORDER BY week_no
            )
        )
        /
        NULLIF(
            LAG(revenue) OVER(
                ORDER BY week_no
            ),
            0
        )
        *100,
        2
    ) AS growth_percentage,

    ROUND(
        SUM(revenue) OVER(
            ORDER BY week_no
        ),
        2
    ) AS cumulative_revenue

FROM monthly_revenue
ORDER BY week_no;

--10. Which products contribute to 80% of total revenue? (Pareto Analysis)

WITH product_revenue AS (

    SELECT
        product_id,
        SUM(sales_value) AS total_revenue
    FROM transaction_data
    GROUP BY product_id

),

pareto AS (

    SELECT
        product_id,
        total_revenue,

        SUM(total_revenue) OVER(
            ORDER BY total_revenue DESC
        ) AS cumulative_revenue,

        SUM(total_revenue) OVER() AS overall_revenue

    FROM product_revenue

)

SELECT
    product_id,
    ROUND(total_revenue,2) AS total_revenue,
    ROUND(cumulative_revenue,2) AS cumulative_revenue,
    ROUND(
        cumulative_revenue
        / overall_revenue * 100,
        2
    ) AS cumulative_percentage

FROM pareto
WHERE cumulative_revenue / overall_revenue <= 0.80
ORDER BY total_revenue DESC;

--11. Who are the highest-value customers?

WITH customer_revenue AS (

    SELECT
        household_key,
        SUM(sales_value) AS total_revenue
    FROM transaction_data
    GROUP BY household_key

)

SELECT
    c.household_key,
    ROUND(c.total_revenue, 2) AS total_revenue,

    RANK() OVER(
        ORDER BY c.total_revenue DESC
    ) AS customer_rank,

    h.age_desc,
    h.income_desc,
    h.homeowner_desc,
    h.household_size_desc

FROM customer_revenue c
LEFT JOIN hh_demographic h
ON c.household_key = h.household_key

ORDER BY customer_rank
Limit 20;

--12. Build RFM Customer Segmentation

WITH customer_rfm AS (

    SELECT
        household_key,
        MAX(day) AS last_purchase_day,
        COUNT(DISTINCT basket_id) AS purchase_frequency,
        SUM(sales_value) AS monetary_value
    FROM transaction_data
    GROUP BY household_key

),

rfm_scores AS (

    SELECT
        household_key,
        last_purchase_day,
        purchase_frequency,
        ROUND(monetary_value,2) AS monetary_value,
        NTILE(5) OVER(
            ORDER BY last_purchase_day ASC
        ) AS recency_score,
        NTILE(5) OVER(
            ORDER BY purchase_frequency
        ) AS frequency_score,
        NTILE(5) OVER(
            ORDER BY monetary_value
        ) AS monetary_score
    FROM customer_rfm

)

SELECT

    household_key,
    last_purchase_day,
    purchase_frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,

    CASE

        WHEN recency_score >=4
         AND frequency_score >=4
         AND monetary_score >=4
        THEN 'VIP Customers'

        WHEN recency_score >=3
         AND frequency_score >=3
        THEN 'Loyal Customers'

        WHEN recency_score <=2
         AND frequency_score >=4

        THEN 'At Risk Customers'
        ELSE 'Regular Customers'

    END AS customer_segment

FROM rfm_scores
ORDER BY
    monetary_value DESC;

--13. Which RFM customer segments contribute the most revenue?

WITH customer_rfm AS (

    SELECT
        household_key,
        MAX(day) AS last_purchase_day,
        COUNT(DISTINCT basket_id) AS purchase_frequency,
        SUM(sales_value) AS monetary_value
    FROM transaction_data
    GROUP BY household_key

),

rfm_scores AS (

    SELECT
        household_key,
        purchase_frequency,
        monetary_value,

        NTILE(5) OVER (
            ORDER BY last_purchase_day ASC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY purchase_frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary_value
        ) AS monetary_score

    FROM customer_rfm

),

customer_segments AS (

    SELECT
        household_key,
        monetary_value,

        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
                THEN 'VIP Customers'

            WHEN recency_score >= 3
             AND frequency_score >= 3
                THEN 'Loyal Customers'

            WHEN recency_score <= 2
             AND frequency_score >= 4
                THEN 'At Risk Customers'

            ELSE 'Regular Customers'
        END AS customer_segment

    FROM rfm_scores

)

SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(monetary_value), 2) AS total_revenue,
    ROUND(
        SUM(monetary_value) * 100.0
        / SUM(SUM(monetary_value)) OVER (),
        2
    ) AS revenue_percentage

FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;

--14. Which customers show potential churn signals based on their current purchase gap?

WITH customer_purchases AS (

    --Keep one record per customer transaction
    SELECT DISTINCT
        household_key,
        basket_id,
        day
    FROM transaction_data

),

purchase_history AS (

    --Calculate the gap between each customer's consecutive purchases
    SELECT
        household_key,
        day,
        LAG(day) OVER (
            PARTITION BY household_key
            ORDER BY day
        ) AS previous_purchase_day
    FROM customer_purchases

),

customer_purchase_gaps AS (

    --Calculate each customer's normal average time between purchases
    SELECT
        household_key,
        AVG(day - previous_purchase_day) AS avg_days_between_purchases,
        MAX(day) AS last_purchase_day
    FROM purchase_history
    WHERE previous_purchase_day IS NOT NULL
    GROUP BY household_key

),

dataset_last_day AS (

    --Identify the latest day available in the dataset
    SELECT
        MAX(day) AS max_day
    FROM transaction_data

),

customer_churn_analysis AS (

    --Compare the customer's current inactivity with their normal purchase rhythm
    SELECT
        c.household_key,
        c.last_purchase_day,
        d.max_day - c.last_purchase_day AS days_since_last_purchase,
        ROUND(c.avg_days_between_purchases, 2) AS avg_days_between_purchases,
        ROUND(
            (d.max_day - c.last_purchase_day)::NUMERIC
            / NULLIF(c.avg_days_between_purchases, 0),
            2
        ) AS purchase_gap_ratio
    FROM customer_purchase_gaps c
    CROSS JOIN dataset_last_day d

)

SELECT
    household_key,
    last_purchase_day,
    days_since_last_purchase,
    avg_days_between_purchases,
    purchase_gap_ratio,

    CASE
        WHEN purchase_gap_ratio >= 3 THEN 'High Churn Risk'
        WHEN purchase_gap_ratio >= 2 THEN 'Medium Churn Risk'
        WHEN purchase_gap_ratio >= 1.5 THEN 'Low Churn Risk'
        ELSE 'Active Customer'
    END AS churn_risk

FROM customer_churn_analysis
ORDER BY purchase_gap_ratio DESC;

--15. Do coupon redeemers spend more than non-redeemers?

WITH customer_revenue AS (

    --Calculate total spending for each customer
    SELECT
        household_key,
        SUM(sales_value) AS total_revenue
    FROM transaction_data
    GROUP BY household_key

),

coupon_users AS (

    --Identify customers who redeemed at least one coupon
    SELECT DISTINCT
        household_key
    FROM coupon_redempt

),

customer_coupon_analysis AS (

    --Classify each customer based on coupon redemption
    SELECT
        cr.household_key,
        cr.total_revenue,

        CASE
            WHEN cu.household_key IS NOT NULL
                THEN 'Coupon Redeemer'
            ELSE 'Non-Redeemer'
        END AS coupon_status

    FROM customer_revenue cr
    LEFT JOIN coupon_users cu
        ON cr.household_key = cu.household_key

)

SELECT
    coupon_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(SUM(total_revenue), 2) AS total_revenue

FROM customer_coupon_analysis
GROUP BY coupon_status
ORDER BY avg_revenue_per_customer DESC;