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

