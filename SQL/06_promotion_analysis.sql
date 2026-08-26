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
