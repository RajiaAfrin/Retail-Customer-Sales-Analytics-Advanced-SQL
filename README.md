# 🛒 Retail Customer & Sales Analytics | Advanced SQL

## 📌 Project Overview

This project analyzes retail transaction data using **PostgreSQL** to understand revenue performance, product concentration, customer behavior, churn risk, and coupon usage.

The goal was not only to answer individual business questions, but to follow a complete analytics workflow:

**Data Modeling & Validation → Business Analysis → Customer Segmentation → Churn Analysis → Promotion Analysis → Business Recommendations**

The project demonstrates both **SQL technical skills** and the ability to translate business problems into meaningful analytical questions.

---

## 🎯 Business Problem

The retailer needs to better understand:

* What is driving revenue?
* Which departments and products contribute the most to sales?
* Is revenue concentrated among a small number of products?
* Who are the highest-value customers?
* Which customer segments generate the most revenue?
* Which customers show potential churn signals?
* Do coupon redeemers demonstrate different spending behavior?

The analysis aims to support better decisions around **customer retention, product prioritization, promotions, and revenue growth**.

---

# 📂 Dataset

The project uses retail data across the following tables:

| Table              | Description                                                                             |
| ------------------ | --------------------------------------------------------------------------------------- |
| `transaction_data` | Customer purchases, quantities, sales, discounts, baskets, stores, and time information |
| `product`          | Product, department, brand, manufacturer, and commodity information                     |
| `hh_demographic`   | Household demographic information                                                       |
| `campaign_desc`    | Campaign descriptions and campaign periods                                              |
| `campaign_table`   | Households associated with campaigns                                                    |
| `coupon`           | Coupon, product, and campaign relationships                                             |
| `coupon_redempt`   | Coupon redemption activity by households                                                |
| `causal_data`      | Product/store promotional activity, including displays and mailers                      |

---

# 🛠️ Tools & Technologies

* **PostgreSQL**
* **pgAdmin**
* SQL
* GitHub

### Key SQL Skills Demonstrated

* Database modeling
* Primary Keys & Foreign Keys
* Data validation
* `JOIN`
* `LEFT JOIN`
* `GROUP BY`
* `HAVING`
* Aggregate functions
* `CASE`
* `CTEs`
* Window Functions
* `LAG()`
* `RANK()`
* `NTILE()`
* `PARTITION BY`
* Running totals
* Cumulative percentages
* `NULLIF()`
* `TRIM()`
* `ABS()`
* Root-cause investigation

---

# Phase 0: Database Modeling & Data Validation

Before starting the business analysis, the data was validated to ensure the database structure and relationships were reliable.

### Validation steps included:

* Creating tables with appropriate data types
* Checking row counts after data loading
* Checking duplicate records
* Checking `NULL` values
* Identifying valid primary keys
* Creating composite primary keys where required
* Validating relationships before creating foreign keys

### Example Relationships

```text
transaction_data.product_id → product.product_id

coupon.product_id → product.product_id

coupon.campaign → campaign_desc.campaign

campaign_table.campaign → campaign_desc.campaign

coupon_redempt.campaign → campaign_desc.campaign

causal_data.product_id → product.product_id
```

### Key Takeaway

> Data validation was completed before analysis to reduce the risk of misleading results caused by duplicates, missing values, or invalid relationships.

---

# 📊 Business Questions & Analysis

## Phase 1: Business Health Analysis

### 1. Which departments generate the highest revenue?

Identified the departments contributing the most sales revenue.

### 2. Which departments have the highest transaction volume?

Used `COUNT(DISTINCT basket_id)` to avoid overcounting transactions containing multiple products.

### 3. Which departments generate the highest average revenue per transaction?

Calculated:

```text
Total Department Revenue ÷ Unique Transactions
```

### 4. Which departments sell the most units?

Analyzed product demand using total quantity sold.

### 5. Which departments receive the highest total discounts?

Combined retail, coupon, and coupon-match discounts to measure total discount activity.

### 6. Which departments receive the highest average discount per transaction?

Compared discount levels relative to transaction volume.

### 7. Which departments have the largest average basket size?

Calculated:

```text
Total Quantity Sold ÷ Unique Transactions
```

### 8. Which departments have the highest average selling price per unit?

Calculated:

```text
Total Sales Value ÷ Total Quantity
```

### Root-Cause Investigation

During this analysis, a **division-by-zero error** occurred.

Instead of simply suppressing the error, the underlying data was investigated by checking:

* Departments with zero total quantity
* `NULL` department values
* Empty department values
* Whitespace-only department values

The issue was addressed using `TRIM()` to identify invalid text values and `NULLIF()` to safely handle zero denominators.

> **This investigation followed a Problem → Investigation → Root Cause → Solution approach.**

---

# Phase 2: Revenue & Product Analysis

## 9. How is revenue changing over time?

Analyzed weekly revenue trends using:

* Previous-period revenue
* Revenue change
* Growth analysis
* Running cumulative revenue

### Advanced SQL Used

```sql
LAG()
SUM() OVER()
```

---

## 10. Which products contribute to approximately 80% of total revenue?

A Pareto analysis was performed by:

1. Calculating revenue per product
2. Ranking products by revenue
3. Calculating cumulative revenue
4. Calculating cumulative revenue percentage

### Key Finding

**11,863 out of 92,339 products, approximately 12.85%, generated around 80% of total revenue.**

### Business Implication

Revenue is highly concentrated among a relatively small group of products. These products should be prioritized for:

* Inventory availability
* Replenishment
* Merchandising
* Pricing monitoring

---

# Phase 3: Customer Analytics

## 11. Who are the highest-value customers?

Customers were ranked based on total revenue generated.

Demographic data was also joined to explore characteristics of high-value customers where demographic information was available.

### Advanced SQL Used

```sql
RANK() OVER()
```

### Limitation

Some high-value customers had missing demographic information, so demographic conclusions should be interpreted cautiously.

---

## 12. How can customers be segmented using RFM analysis?

Customers were segmented using:

### Recency

How recently the customer made a purchase.

### Frequency

How often the customer purchased.

### Monetary

How much the customer spent.

Customer scores were created using:

```sql
NTILE(5)
```

Customers were classified into:

* VIP Customers
* Loyal Customers
* At Risk Customers
* Regular Customers

### Advanced SQL Used

```sql
CTEs
NTILE()
CASE
COUNT(DISTINCT)
SUM()
MAX()
```

---

## 13. Which RFM segments contribute the most revenue?

### Results

| Customer Segment  | Total Customers | Total Revenue | Revenue Contribution |
| ----------------- | --------------: | ------------: | -------------------: |
| VIP Customers     |             512 | $3,676,507.17 |               45.63% |
| Loyal Customers   |             643 | $2,209,733.46 |               27.42% |
| Regular Customers |           1,183 | $1,485,549.51 |               18.44% |
| At Risk Customers |             162 |   $685,672.94 |                8.51% |

### Key Finding

**VIP and Loyal Customers together generated approximately 73.05% of total revenue.**

### Business Recommendation

* **VIP Customers:** Prioritize retention and personalized rewards.
* **Loyal Customers:** Encourage progression toward VIP status.
* **At Risk Customers:** Use targeted win-back campaigns.
* **Regular Customers:** Use scalable, lower-cost engagement strategies.

---

## 14. Which customers show potential churn signals?

The initial churn approach was improved to account for differences in individual customer purchasing behavior.

Instead of applying the same inactivity threshold to every customer, the analysis calculated:

```text
Purchase Gap Ratio =
Days Since Last Purchase
÷
Customer's Average Days Between Purchases
```

This compares a customer's current inactivity with their **own normal purchasing rhythm**.

### Example

A customer who normally purchases every 2 days but has been inactive for 200 days represents a much stronger churn signal than a customer who normally purchases every 300 days.

### Advanced SQL Used

```sql
LAG()
PARTITION BY
CTEs
CROSS JOIN
CASE
NULLIF()
```

### Business Recommendation

Customers whose inactivity is significantly longer than their normal purchasing pattern can be prioritized for:

* Win-back campaigns
* Personalized offers
* Relevant coupons
* Retention incentives

---

# Phase 4: Promotion Analysis

## 15. Do coupon redeemers spend more than non-redeemers?

Customers were classified into:

* Coupon Redeemers
* Non-Redeemers

### Results

| Customer Group  | Total Customers | Avg. Revenue per Customer | Total Revenue |
| --------------- | --------------: | ------------------------: | ------------: |
| Coupon Redeemer |             434 |                 $6,615.33 | $2,871,051.51 |
| Non-Redeemer    |           2,066 |                 $2,510.36 | $5,186,411.57 |

### Key Finding

Coupon redeemers spent approximately **2.63× more per customer on average** than non-redeemers.

### Important Interpretation

This result shows an **association, not causation**.

It cannot be concluded that coupons caused customers to spend more because high-value customers may already be more likely to redeem coupons.

A controlled experiment or stronger before-and-after analysis would be required to measure the true causal impact of coupons.

---

# 📈 Key Business Insights

### 1. Revenue is highly concentrated among a small group of products

Approximately **12.85% of products generated around 80% of total revenue**.

### 2. High-value customers are critical to the business

VIP Customers alone generated **45.63% of total revenue**.

### 3. VIP and Loyal Customers drive most revenue

Together, they contributed approximately **73.05% of total revenue**.

### 4. Churn risk should be measured relative to individual behavior

Using a customer's normal purchase rhythm provides a more meaningful churn signal than applying one fixed inactivity threshold to everyone.

### 5. Coupon redeemers are higher-value customers

Coupon redeemers spent approximately **2.63× more per customer on average**, although the analysis does not establish causation.

---

# 💡 Business Recommendations

### Customer Retention

Prioritize VIP Customers with personalized rewards and retention strategies.

### Customer Development

Target Loyal Customers with relevant offers to encourage progression toward VIP status.

### Win-Back Strategy

Focus retention efforts on customers whose current inactivity is significantly longer than their normal purchasing behavior.

### Product Strategy

Prioritize high-revenue products for:

* Inventory management
* Replenishment
* Merchandising
* Pricing monitoring

### Promotion Strategy

Further evaluate promotions using controlled or before-and-after analysis before concluding that coupon usage directly increases spending.

---

# ⚠️ Project Limitations

### 1. Product cost data was unavailable

The dataset did not include product cost information.

Therefore, this project analyzes:

* Revenue
* Sales
* Discounts

But cannot calculate:

* True profit
* Gross margin
* Profit margin

---

### 2. Coupon analysis does not prove causality

Coupon redeemers spent more, but the analysis cannot confirm that coupons caused the higher spending.

---

### 3. Churn is a proxy

The dataset does not explicitly identify whether a customer has churned.

Therefore, the project identifies **potential churn risk based on unusual inactivity**.

---

### 4. RFM segments depend on chosen scoring rules

The RFM analysis uses `NTILE(5)` and selected segmentation thresholds. Different businesses may define VIP, Loyal, and At-Risk customers differently.

---

### 5. Some demographic information is missing

Not every customer has complete demographic information, limiting demographic conclusions.

---

### 6. Dataset time limitations

Churn and recency are calculated relative to the latest date available in the dataset. Customer activity after the dataset ends is not available.

---

# 🧠 Key Learning Outcomes

Through this project, I practiced how to:

* Translate business problems into SQL questions
* Validate data before analysis
* Design primary and foreign key relationships
* Understand data grain before aggregation
* Avoid overcounting transactions
* Investigate unexpected query results
* Perform root-cause analysis
* Use CTEs to structure complex queries
* Apply advanced SQL window functions
* Build RFM customer segments
* Analyze revenue concentration using Pareto analysis
* Identify potential churn based on behavioral patterns
* Interpret analytical results carefully
* Distinguish correlation from causation
* Convert SQL findings into actionable business recommendations

