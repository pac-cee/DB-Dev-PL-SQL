-- =============================================
-- COMPREHENSIVE WINDOW FUNCTIONS GUIDE
-- =============================================

-- =============================================
-- 1. BASIC WINDOW FUNCTION SYNTAX
-- =============================================
/*
General syntax:
function_name() OVER (
    [PARTITION BY column1, column2, ...]
    [ORDER BY column3, column4, ...]
    [frame_clause]
)

Where:
- function_name is the window function (like SUM, AVG, ROW_NUMBER, etc.)
- PARTITION BY divides the result set into partitions
- ORDER BY defines the logical order of rows within each partition
- frame_clause defines which rows to include in the window frame
*/

-- =============================================
-- 2. COMMON WINDOW FUNCTIONS
-- =============================================

-- ROW_NUMBER(): Assigning Sequential Numbers
-- Finding top 3 customers by purchase amount in each region
SELECT 
    region,
    customer_name,
    purchase_amount,
    ranking
FROM (
    SELECT 
        region,
        customer_name,
        purchase_amount,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY purchase_amount DESC) AS ranking
    FROM sales
) ranked_sales
WHERE ranking <= 3
ORDER BY region, ranking;

-- RANK() and DENSE_RANK(): Handling Ties
-- Comparing different ranking functions
SELECT 
    department,
    employee_name,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank
FROM employees
ORDER BY department, salary DESC;

-- NTILE(): Dividing Data into Equal Groups
-- Dividing products into price quartiles
SELECT 
    product_name,
    category,
    price,
    NTILE(4) OVER (PARTITION BY category ORDER BY price) AS price_quartile
FROM products
ORDER BY category, price;

-- LAG() and LEAD(): Accessing Previous and Next Rows
-- Calculating month-over-month sales growth
SELECT 
    sales_date,
    region,
    monthly_sales,
    LAG(monthly_sales) OVER (PARTITION BY region ORDER BY sales_date) AS previous_month_sales,
    monthly_sales - LAG(monthly_sales) OVER (PARTITION BY region ORDER BY sales_date) AS absolute_change,
    CASE 
        WHEN LAG(monthly_sales) OVER (PARTITION BY region ORDER BY sales_date) = 0 THEN NULL
        ELSE ROUND((monthly_sales - LAG(monthly_sales) OVER (PARTITION BY region ORDER BY sales_date)) * 100.0 / 
             LAG(monthly_sales) OVER (PARTITION BY region ORDER BY sales_date), 2)
    END AS percentage_change
FROM monthly_sales
ORDER BY region, sales_date;

-- FIRST_VALUE() and LAST_VALUE(): Getting First and Last Values
-- Comparing stock prices to daily opening and closing prices
SELECT 
    trading_date,
    stock_symbol,
    price_time,
    stock_price,
    FIRST_VALUE(stock_price) OVER (PARTITION BY stock_symbol, trading_date ORDER BY price_time) AS opening_price,
    LAST_VALUE(stock_price) OVER (
        PARTITION BY stock_symbol, trading_date 
        ORDER BY price_time
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS closing_price,
    stock_price - FIRST_VALUE(stock_price) OVER (PARTITION BY stock_symbol, trading_date ORDER BY price_time) AS change_from_opening
FROM stock_prices
ORDER BY stock_symbol, trading_date, price_time;

-- =============================================
-- 3. AGGREGATE WINDOW FUNCTIONS
-- =============================================

-- Sales analytics with running totals and moving averages
SELECT 
    sales_date,
    product_category,
    daily_sales,
    -- Running total of sales
    SUM(daily_sales) OVER (PARTITION BY product_category ORDER BY sales_date) AS running_total,
    -- Percentage of total sales
    ROUND(daily_sales * 100.0 / SUM(daily_sales) OVER (PARTITION BY product_category), 2) AS pct_of_category_total,
    -- 7-day moving average
    AVG(daily_sales) OVER (
        PARTITION BY product_category 
        ORDER BY sales_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day
FROM daily_sales
ORDER BY product_category, sales_date;

-- =============================================
-- 4. FRAME CLAUSES FOR ADVANCED ANALYSIS
-- =============================================

-- Analyzing customer purchase patterns with different frame clauses
SELECT 
    purchase_date,
    customer_id,
    purchase_amount,
    -- Running total (all previous rows + current row)
    SUM(purchase_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY purchase_date
        ROWS UNBOUNDED PRECEDING
    ) AS lifetime_value,
    -- Previous 30 days of purchases
    SUM(purchase_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY purchase_date
        RANGE BETWEEN INTERVAL '30' DAY PRECEDING AND CURRENT ROW
    ) AS last_30days_purchases,
    -- Average of 3 purchases before and after current purchase
    AVG(purchase_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY purchase_date
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) AS purchase_trend
FROM customer_purchases
ORDER BY customer_id, purchase_date;

-- =============================================
-- 5. PRACTICAL BUSINESS APPLICATIONS
-- =============================================

-- Detecting potentially fraudulent transactions
SELECT 
    transaction_id,
    customer_id,
    transaction_date,
    transaction_amount,
    AVG(transaction_amount) OVER (PARTITION BY customer_id) AS avg_transaction,
    STDDEV(transaction_amount) OVER (PARTITION BY customer_id) AS stddev_transaction,
    (transaction_amount - AVG(transaction_amount) OVER (PARTITION BY customer_id)) / 
        CASE 
            WHEN STDDEV(transaction_amount) OVER (PARTITION BY customer_id) = 0 THEN 1 
            ELSE STDDEV(transaction_amount) OVER (PARTITION BY customer_id) 
        END AS z_score
FROM transactions
ORDER BY ABS(
    (transaction_amount - AVG(transaction_amount) OVER (PARTITION BY customer_id)) / 
        CASE 
            WHEN STDDEV(transaction_amount) OVER (PARTITION BY customer_id) = 0 THEN 1 
            ELSE STDDEV(transaction_amount) OVER (PARTITION BY customer_id) 
        END
) DESC;

-- Finding products frequently purchased together
WITH product_pairs AS (
    SELECT 
        o1.order_id,
        o1.product_id AS product1,
        o2.product_id AS product2,
        p1.product_name AS product1_name,
        p2.product_name AS product2_name
    FROM order_items o1
    JOIN order_items o2 ON o1.order_id = o2.order_id AND o1.product_id < o2.product_id
    JOIN products p1 ON o1.product_id = p1.product_id
    JOIN products p2 ON o2.product_id = p2.product_id
)
SELECT 
    product1,
    product2,
    product1_name,
    product2_name,
    COUNT(*) AS pair_frequency,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS pair_rank
FROM product_pairs
GROUP BY product1, product2, product1_name, product2_name
ORDER BY pair_frequency DESC;

-- Segmenting customers based on purchase behavior
WITH customer_metrics AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(order_total) AS total_spent,
        MAX(order_date) AS last_purchase_date,
        DATEDIFF(day, MAX(order_date), CURRENT_DATE) AS days_since_last_purchase,
        AVG(order_total) AS avg_order_value
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    order_count,
    total_spent,
    last_purchase_date,
    days_since_last_purchase,
    avg_order_value,
    NTILE(4) OVER (ORDER BY order_count) AS frequency_quartile,
    NTILE(4) OVER (ORDER BY total_spent) AS monetary_quartile,
    NTILE(4) OVER (ORDER BY days_since_last_purchase DESC) AS recency_quartile,
    CONCAT(
        NTILE(4) OVER (ORDER BY days_since_last_purchase DESC),
        NTILE(4) OVER (ORDER BY order_count),
        NTILE(4) OVER (ORDER BY total_spent)
    ) AS rfm_segment
FROM customer_metrics
ORDER BY rfm_segment;

-- =============================================
-- 6. PERFORMANCE CONSIDERATIONS
-- =============================================
/*
Window functions can be resource-intensive. Here are some tips:

1. Limit partitions: Large partitions require more memory
2. Use appropriate frame clauses: Limit the frame size when possible
3. Consider materialized views: For frequently used window calculations
4. Index wisely: Ensure columns used in PARTITION BY and ORDER BY are indexed
*/

-- =============================================
-- 7. DATABASE-SPECIFIC IMPLEMENTATIONS
-- =============================================
/*
While the SQL standard defines window functions, implementations vary across database systems:

- SQL Server: Excellent support for all window functions
- PostgreSQL: Robust implementation with all standard functions
- Oracle: Strong support with some unique functions
- MySQL: Added window functions in version 8.0
- SQLite: Limited support added in version 3.25.0

Always check your specific database documentation for syntax variations and optimizations.
*/