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

