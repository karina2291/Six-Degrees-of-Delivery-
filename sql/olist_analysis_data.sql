--Rank reviews within each order so rank 1 is the most recently
-- answered review. Use review_id if answer timestamps match.
WITH ranked_reviews AS (
SELECT
r.order_id,
r.review_score,
ROW_NUMBER() OVER (PARTITION BY r.order_id 
ORDER BY r.review_answer_timestamp DESC, r.review_id) AS review_rank
FROM olist.order_reviews AS r),
-- Summarize items before joining so each order keeps one row.
-- Compare the counts to catch any item missing a freight value.
item_totals AS (
SELECT
o.order_id,
COUNT(*) AS item_count,
SUM(o.freight_value) AS total_freight,
COUNT(o.freight_value) AS items_with_freight
FROM olist.order_items AS o
GROUP BY o.order_id
)
-- This is the outcome Michelle will model.
-- Scores of 1 or 2 are negative. Scores of 3 through 5 are 0.
SELECT
ord.order_id,
CASE
WHEN r.review_score IN (1, 2) THEN 1
ELSE 0
END AS negative_review,
-- Compare calendar dates so deliveries on the promised day are on time.
CASE
WHEN CAST(ord.order_delivered_customer_date AS date)
> CAST(ord.order_estimated_delivery_date AS date) THEN 1
ELSE 0
END AS late_delivery,
item_totals.item_count,
item_totals.total_freight
FROM olist.orders AS ord
INNER JOIN ranked_reviews AS r
ON ord.order_id = r.order_id
INNER JOIN item_totals
ON ord.order_id = item_totals.order_id
-- Keep delivered orders with a valid review and complete delivery and freight data.
WHERE r.review_rank = 1
AND r.review_score IN (1, 2, 3, 4, 5)
AND ord.order_status = 'delivered'
AND ord.order_delivered_customer_date IS NOT NULL
AND ord.order_estimated_delivery_date IS NOT NULL
AND item_totals.item_count = item_totals.items_with_freight
ORDER BY ord.order_id;