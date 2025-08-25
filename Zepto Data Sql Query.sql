drop table if exists zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

--data exploration
COPY zepto (category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, outOfStock, quantity
)
FROM 'E:\SQl\zepto_v2.csv'
DELIMITER','
CSV HEADER;

--count of rows
select count(*) from zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

--null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

--product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

--data cleaning

--products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto;

--data analysis

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

--Q2.What are the Products with High MRP but Out of Stock

SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;

--Q3.Calculate Estimated Revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;




--Business problems questions 


--Q1. Inventory Valuation: What is the Total Value of All Stock?

/*Business Problem: For financial reporting and business health assessment, 
the company needs to know the total value of its current inventory. 
We can calculate this based on both the Maximum Retail Price (MRP) 
and the actual discounted selling price.*/


SELECT
    SUM(mrp * availableQuantity) AS total_inventory_value_at_mrp,
    SUM(discountedSellingPrice * availableQuantity) AS total_inventory_value_at_selling_price,
    SUM((mrp - discountedSellingPrice) * availableQuantity) AS total_potential_discount_value
FROM
    zepto
WHERE
    outOfStock = FALSE;


-- Q2. Overstock analysis Which In-Stock Products are Most Heavily Stocked?

/* Business Problem: Holding too much of a single product (overstocking) ties up capital 
and warehouse space. Identifying the most heavily stocked items can help the inventory 
team decide whether to run promotions or adjust future orders.  */


SELECT
    name,
    category,
    availableQuantity
FROM
    zepto
WHERE
    outOfStock = FALSE
ORDER BY
    availableQuantity DESC
LIMIT 15;

--Q3. Category Diversity: Which Categories Offer the Most Variety of Products?

/* Business Problem: Understanding which categories have the widest range of unique 
products is key to marketing and customer acquisition. A category with high variety 
might be a key differentiator for the business. */


SELECT
    category,
    COUNT(DISTINCT name) AS unique_product_count
FROM
    zepto
GROUP BY
    category
ORDER BY
    unique_product_count DESC;


--Q4. Price Point Analysis: How are Products Distributed Across Price Ranges?

/* Business Problem: To understand customer purchasing power and optimize pricing 
strategy, it's useful to see how many products fall into different price buckets 
(e.g., budget, mid-range, premium).*/


SELECT
    price_range,
    COUNT(sku_id) AS number_of_products
FROM (
    SELECT
        sku_id,
        CASE
            WHEN discountedSellingPrice < 50 THEN '1. Budget (Under ₹50)'
            WHEN discountedSellingPrice BETWEEN 50 AND 150 THEN '2. Standard (₹50 - ₹150)'
            WHEN discountedSellingPrice BETWEEN 151 AND 400 THEN '3. Premium (₹151 - ₹400)'
            ELSE '4. Super Premium (Over ₹400)'
        END AS price_range
    FROM zepto
) AS price_analysis
GROUP BY
    price_range
ORDER BY
    price_range;


--Q5. Discount Strategy: Which Categories Rely Most on Products Without Discounts?

/* Business Problem: Some categories might sell well without any discounts 
(e.g., essentials like milk or salt). Identifying these categories helps the 
pricing team understand where discounts are less critical for driving sales.*/


SELECT
    category,
    COUNT(sku_id) AS zero_discount_product_count
FROM
    zepto
WHERE
    discountPercent = 0
GROUP BY
    category
ORDER BY
    zero_discount_product_count DESC
LIMIT 10;


Q6. Stock Availability vs. Discount: Are Discounted Items More Likely to be Out of Stock?

/* Business Problem: This analysis helps determine if promotions are effective. If discounted 
items are frequently out of stock, it could mean the discounts are successfully driving high 
demand. Conversely, if non-discounted items are out of stock, it might indicate a supply chain 
issue for essential goods. */


SELECT
    CASE WHEN discountPercent > 0 THEN 'Discounted' ELSE 'Not Discounted' END AS discount_status,
    COUNT(*) AS total_products,
    SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END) AS out_of_stock_count,
    ROUND((SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS out_of_stock_percentage
FROM
    zepto
GROUP BY
    discount_status;

--Q6. Unpacking "Packs": Identify Products Sold in Multiples

/* Business Problem: The product `name` often contains clues about packaging 
(e.g., "Pack of 2", "Multipack"). Identifying these items helps in analyzing 
bundle strategies and their performance. */


SELECT
    name,
    category,
    mrp
FROM
    zepto
WHERE
    name ILIKE '%Pack of%' OR name ILIKE '%Multipack%' OR name ILIKE '%Combo%';


--Q1. Price Range Within Categories: What is the Price Spread in Each Category?

/*Business Problem:** Understanding the price spread (the difference between the cheapest 
and most expensive item) within a category helps determine its market positioning. A wide 
spread suggests the category caters to both budget and premium customers.*/

**SQL Query:**
This query calculates the minimum, maximum, and range of prices for each product category.

```sql
SELECT
    category,
    MIN(discountedSellingPrice) AS min_price,
    MAX(discountedSellingPrice) AS max_price,
    (MAX(discountedSellingPrice) - MIN(discountedSellingPrice)) AS price_spread
FROM
    zepto
GROUP BY
    category
ORDER BY
    price_spread DESC;
