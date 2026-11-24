# Six-Degrees-of-Delivery-
Business Analytics &amp; AI Final Project — UTSA Fall 2026
## Data load

The data comes from the course Olist PostgreSQL database. The query is in
[`sql/olist_analysis_data.sql`](sql/olist_analysis_data.sql).

The query returns one row per delivered order, using the most recently
answered review. It keeps orders with both delivery dates and a recorded
freight value for every item. Reviews with 1–2 stars are coded as
`negative_review = 1`. Reviews with 3–5 stars are coded as `0`.

The current query was verified in DBeaver. It returns 95,824 unique orders,
including 12,272 with a negative review (12.8%).