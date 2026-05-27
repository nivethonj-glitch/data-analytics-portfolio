SELECT * FROM customer LIMIT 10
SELECT revenue 
FROM customer

--Q1 What is the total revenue 
SELECT gender , SUM(purchase_amount) as revenue
FROM customer
GROUP BY gender 

--Q2 . Which customers used a discount but still spent more than the average purchase amount?
SELECT customer_id ,purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer)

--Q3 Which are the top 5 products with the highest average review rating?
SELECT 
    item_purchased , -- or category, depending on your exact column name
    ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;

--Q4 Compare the average Purchase Amounts between Standard and Express Shipping.
SELECT shipping_type ,ROUND(AVG(purchase_amount)::numeric,2)
FROM customer
WHERE shipping_type in ('Standard','Express')
GROUP BY shipping_type

--Q5. Do subscribed customers spend more? Compare average spend and total revenue between subscribers and non-subscribers.
SELECT subscription_status ,COUNT(customer_id) as toal_customers ,ROUND(AVG(purchase_amount)::numeric, 2) as avg_spend, SUM(purchase_amount) as total_rev
FROM customer
GROUP BY subscription_status
ORDER BY total_rev , avg_spend DESC

--Q6. Which 5 products have the highest percentage of purchases with discounts applied?
SELECT 
    item_purchased,
    ROUND((COUNT(CASE WHEN discount_applied = 'Yes' THEN 1 END) * 100.0 / COUNT(*))::numeric, 2) AS discount_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

--Q7. Segment customers into New, Returning, and Loyal based on their total number of previous purchases, and show the count of each segment.
WITH customer_segments AS (
    SELECT 
        customer_id,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal' -- 5 or more
        END AS segment
    FROM customer
)
SELECT 
    segment, 
    COUNT(*) AS customer_count
FROM customer_segments
GROUP BY segment;

--Q8 What are the top 3 most purchased products within each category?
WITH RowCte as 
(SELECT category , item_purchased , COUNT(*) as purchase_count ,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(*) DESC) as rnk
FROM customer
GROUP BY category , item_purchased) 
SELECT category , item_purchased , purchase_count, rnk
FROM RowCte 

--Q9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status, COUNT(*) as cnt
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_Status


--Q10. What is the revenue contribution of each age group?
SELECT age_group,
SUM(purchase_amount) as total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc

SELECT * FROM customer









