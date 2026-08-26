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

