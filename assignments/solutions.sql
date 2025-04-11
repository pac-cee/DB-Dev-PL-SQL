/*I'll help you complete the assignment on SQL Window Functions from pages 26-31 of your lecture document. The assignment requires working with window functions like LAG(), LEAD(), RANK(), DENSE_RANK(), ROW_NUMBER(), and aggregate functions on a dataset of your choice.

# SQL Window Functions Assignment Solution

Let's create a comprehensive solution that addresses all the requirements. First, I'll create a sample dataset, and then I'll write all the required queries with clear explanations.

## Dataset Creation

Let's create a sales dataset for an electronics retail company with regional data:

```sql
-- Create the sales table
CREATE TABLE electronics_sales (
    sale_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    category VARCHAR2(50),
    region VARCHAR2(50),
    sale_date DATE,
    quantity NUMBER,
    unit_price NUMBER,
    total_amount NUMBER
);

-- Insert sample data
INSERT INTO electronics_sales VALUES (1, 'iPhone 14 Pro', 'Smartphones', 'North', TO_DATE('2023-01-05', 'YYYY-MM-DD'), 10, 999, 9990);
INSERT INTO electronics_sales VALUES (2, 'Samsung Galaxy S23', 'Smartphones', 'South', TO_DATE('2023-01-10', 'YYYY-MM-DD'), 8, 899, 7192);
INSERT INTO electronics_sales VALUES (3, 'MacBook Pro', 'Laptops', 'East', TO_DATE('2023-01-15', 'YYYY-MM-DD'), 5, 1499, 7495);
INSERT INTO electronics_sales VALUES (4, 'Dell XPS 13', 'Laptops', 'West', TO_DATE('2023-01-20', 'YYYY-MM-DD'), 4, 1299, 5196);
INSERT INTO electronics_sales VALUES (5, 'iPad Air', 'Tablets', 'North', TO_DATE('2023-01-25', 'YYYY-MM-DD'), 12, 599, 7188);
INSERT INTO electronics_sales VALUES (6, 'Samsung Tab S8', 'Tablets', 'South', TO_DATE('2023-02-05', 'YYYY-MM-DD'), 7, 649, 4543);
INSERT INTO electronics_sales VALUES (7, 'Sony PlayStation 5', 'Gaming', 'East', TO_DATE('2023-02-10', 'YYYY-MM-DD'), 6, 499, 2994);
INSERT INTO electronics_sales VALUES (8, 'Xbox Series X', 'Gaming', 'West', TO_DATE('2023-02-15', 'YYYY-MM-DD'), 5, 499, 2495);
INSERT INTO electronics_sales VALUES (9, 'AirPods Pro', 'Audio', 'North', TO_DATE('2023-02-20', 'YYYY-MM-DD'), 20, 249, 4980);
INSERT INTO electronics_sales VALUES (10, 'Bose QC45', 'Audio', 'South', TO_DATE('2023-02-25', 'YYYY-MM-DD'), 9, 329, 2961);
INSERT INTO electronics_sales VALUES (11, 'iPhone 13', 'Smartphones', 'East', TO_DATE('2023-03-05', 'YYYY-MM-DD'), 12, 799, 9588);
INSERT INTO electronics_sales VALUES (12, 'Google Pixel 7', 'Smartphones', 'West', TO_DATE('2023-03-10', 'YYYY-MM-DD'), 6, 599, 3594);
INSERT INTO electronics_sales VALUES (13, 'HP Spectre', 'Laptops', 'North', TO_DATE('2023-03-15', 'YYYY-MM-DD'), 3, 1399, 4197);
INSERT INTO electronics_sales VALUES (14, 'Lenovo ThinkPad', 'Laptops', 'South', TO_DATE('2023-03-20', 'YYYY-MM-DD'), 5, 1199, 5995);
INSERT INTO electronics_sales VALUES (15, 'Samsung Galaxy S22', 'Smartphones', 'East', TO_DATE('2023-03-25', 'YYYY-MM-DD'), 7, 749, 5243);
INSERT INTO electronics_sales VALUES (16, 'Asus ROG Phone', 'Smartphones', 'West', TO_DATE('2023-04-05', 'YYYY-MM-DD'), 4, 899, 3596);
INSERT INTO electronics_sales VALUES (17, 'Microsoft Surface', 'Laptops', 'North', TO_DATE('2023-04-10', 'YYYY-MM-DD'), 6, 1299, 7794);
INSERT INTO electronics_sales VALUES (18, 'MacBook Air', 'Laptops', 'South', TO_DATE('2023-04-15', 'YYYY-MM-DD'), 8, 1199, 9592);
INSERT INTO electronics_sales VALUES (19, 'Samsung Galaxy Tab A', 'Tablets', 'East', TO_DATE('2023-04-20', 'YYYY-MM-DD'), 10, 349, 3490);
INSERT INTO electronics_sales VALUES (20, 'Amazon Fire', 'Tablets', 'West', TO_DATE('2023-04-25', 'YYYY-MM-DD'), 15, 149, 2235);
```

Now, let's address each query requirement:

## 1. Compare Values with Previous or Next Records

For this task, I'll compare the total sales amount with previous and next records using LAG() and LEAD() functions:

```sql
SELECT 
    sale_id,
    product_name,
    category,
    region,
    sale_date,
    total_amount,
    LAG(total_amount) OVER (ORDER BY sale_date) AS previous_amount,
    LEAD(total_amount) OVER (ORDER BY sale_date) AS next_amount,
    CASE 
        WHEN total_amount > LAG(total_amount) OVER (ORDER BY sale_date) THEN 'HIGHER'
        WHEN total_amount < LAG(total_amount) OVER (ORDER BY sale_date) THEN 'LOWER'
        WHEN total_amount = LAG(total_amount) OVER (ORDER BY sale_date) THEN 'EQUAL'
        ELSE 'FIRST RECORD'
    END AS comparison_with_previous,
    CASE 
        WHEN total_amount > LEAD(total_amount) OVER (ORDER BY sale_date) THEN 'HIGHER'
        WHEN total_amount < LEAD(total_amount) OVER (ORDER BY sale_date) THEN 'LOWER'
        WHEN total_amount = LEAD(total_amount) OVER (ORDER BY sale_date) THEN 'EQUAL'
        ELSE 'LAST RECORD'
    END AS comparison_with_next
FROM 
    electronics_sales
ORDER BY 
    sale_date;
```

**Explanation:**
- This query uses LAG() and LEAD() to access the previous and next record's total_amount values.
- For each record, we compare the current total_amount with the previous and next values.
- The CASE statements determine if the current amount is HIGHER, LOWER, or EQUAL compared to previous/next records.
- If there's no previous record (first row), it shows 'FIRST RECORD'. If there's no next record (last row), it shows 'LAST RECORD'.
- The data is ordered by sale_date to maintain chronological comparison.

## 2. Ranking Data within a Category

For this task, I'll rank products within each category by their total sales amount using both RANK() and DENSE_RANK():

```sql
SELECT 
    sale_id,
    product_name,
    category,
    total_amount,
    RANK() OVER (PARTITION BY category ORDER BY total_amount DESC) AS rank_in_category,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY total_amount DESC) AS dense_rank_in_category
FROM 
    electronics_sales
ORDER BY 
    category, 
    total_amount DESC;
```

**Explanation:**
- This query partitions the data by category and orders each partition by total_amount in descending order.
- RANK() assigns a unique rank to each row within the partition, with gaps in the ranking sequence when there are ties.
- DENSE_RANK() assigns a unique rank to each row within the partition, without gaps in the ranking sequence when there are ties.
- For example, if two products have the same total_amount, RANK() might assign ranks 1, 1, 3, 4, while DENSE_RANK() would assign 1, 1, 2, 3.
- This makes DENSE_RANK() more suitable when you want consecutive rankings without gaps.

## 3. Identifying Top Records

For this task, I'll fetch the top 3 products with highest sales in each category:

```sql
WITH ranked_products AS (
    SELECT 
        sale_id,
        product_name,
        category,
        region,
        total_amount,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY total_amount DESC) AS product_rank
    FROM 
        electronics_sales
)
SELECT 
    sale_id,
    product_name,
    category,
    region,
    total_amount,
    product_rank
FROM 
    ranked_products
WHERE 
    product_rank <= 3
ORDER BY 
    category, 
    product_rank;
```

**Explanation:**
- I use a Common Table Expression (CTE) to first rank the products within each category by total_amount in descending order.
- DENSE_RANK() is used to handle potential ties properly (if two products have the same total_amount, they get the same rank).
- The outer query filters to keep only records with rank <= 3, which gives us the top 3 products in each category.
- This approach handles duplicate sales amounts appropriately by giving them the same rank but still counting them towards our top 3.

## 4. Finding the Earliest Records

For this task, I'll retrieve the first 2 sales transactions from each region based on sale_date:

```sql
WITH ranked_sales AS (
    SELECT 
        sale_id,
        product_name,
        category,
        region,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY sale_date) AS sale_sequence
    FROM 
        electronics_sales
)
SELECT 
    sale_id,
    product_name,
    category,
    region,
    sale_date,
    total_amount,
    sale_sequence
FROM 
    ranked_sales
WHERE 
    sale_sequence <= 2
ORDER BY 
    region, 
    sale_date;
```

**Explanation:**
- I use ROW_NUMBER() to assign a sequence number to each sale within each region, ordered by sale_date.
- Unlike RANK() or DENSE_RANK(), ROW_NUMBER() guarantees unique values (no ties) which is perfect for selecting exactly 2 records.
- The outer query filters to keep only records with sale_sequence <= 2, giving us exactly the first 2 sales from each region.
- This is useful for identifying initial trends or early customer behaviors by region.

## 5. Aggregation with Window Functions

For this task, I'll calculate both category-specific maximums and the overall maximum total amount:

```sql
SELECT 
    sale_id,
    product_name,
    category,
    region,
    total_amount,
    MAX(total_amount) OVER (PARTITION BY category) AS category_max_amount,
    MAX(total_amount) OVER () AS overall_max_amount,
    ROUND((total_amount / MAX(total_amount) OVER (PARTITION BY category)) * 100, 2) AS percent_of_category_max,
    ROUND((total_amount / MAX(total_amount) OVER ()) * 100, 2) AS percent_of_overall_max
FROM 
    electronics_sales
ORDER BY 
    category, 
    total_amount DESC;
```

**Explanation:**
- This query shows each individual sale alongside aggregated values for context.
- MAX(total_amount) OVER (PARTITION BY category) calculates the maximum total_amount within each category.
- MAX(total_amount) OVER () calculates the maximum total_amount across the entire dataset.
- The percentage calculations show how each sale compares to its category maximum and the overall maximum.
- This type of analysis helps identify top performers both within categories and globally.
- Using PARTITION BY differentiates between category-level calculations and overall calculations.

## Real-Life Applications of Window Functions

Window functions have numerous practical applications in business analytics:

1. **Sales Performance Analysis**:
   - Compare sales against previous periods to identify trends
   - Rank sales representatives within regions to recognize top performers
   - Calculate running totals to monitor progress toward quotas

2. **Financial Analysis**:
   - Track stock price movements compared to previous trading days
   - Calculate moving averages for smoothing out short-term fluctuations
   - Rank investments by returns within portfolio categories

3. **Customer Behavior Analysis**:
   - Identify top spending customers by segment
   - Calculate customer retention rates over consecutive time periods
   - Analyze purchase frequency patterns with time comparisons

4. **Supply Chain Management**:
   - Track inventory levels against previous periods
   - Rank suppliers by delivery performance within product categories
   - Identify earliest and latest deliveries to optimize logistics

5. **Human Resources**:
   - Compare employee performance metrics to department averages
   - Rank employees by metric while accounting for department differences
   - Track salary progression over time relative to company averages

These window functions enable sophisticated analytics without complex self-joins or subqueries, making the code more readable and maintainable while improving performance.

---

This complete solution addresses all the requirements in the assignment. All queries are thoroughly explained with their purpose and benefits. The window functions showcase different analytical capabilities that would be valuable in real business scenarios. To complete your GitHub submission, you would include these SQL scripts along with a README.md containing these explanations and any relevant screenshots of the query results.