-- Creating a VIEW for the weighted average rating to be used in future queries 
CREATE VIEW weighted_average_ratings AS
WITH rating_calcs AS(
	SELECT 
	CAST(percentile_cont(0.75) WITHIN GROUP (ORDER BY rating_count) AS DECIMAL) AS top25_perc_rating_count,
	AVG(rating) AS mean_rating
	FROM product_rating
	WHERE rating_count IS NOT NULL
)
SELECT
	pr.rating_sk,
	ROUND(((pr.rating * pr.rating_count) + (rc.mean_rating * rc.top25_perc_rating_count)) / ((pr.rating_count + rc.top25_perc_rating_count)), 1) AS weighted_average_rating
FROM product_rating AS pr
CROSS JOIN rating_calcs AS rc
WHERE rating_count IS NOT NULL;

-- Creating a VIEW to compare relationship between price point and rating metrics
DROP VIEW price_point_rating_analysis;
CREATE VIEW price_point_rating_analysis AS
SELECT
	CASE
		WHEN pl.discounted_price BETWEEN 0 AND 20 THEN '£0.01 - £20.00'
		WHEN pl.discounted_price BETWEEN 20.01 AND 40 THEN '£20.01 - £40.00'
		WHEN pl.discounted_price BETWEEN 40.01 AND 60 THEN '£40.01 - £60.00'
		WHEN pl.discounted_price BETWEEN 60.01 AND 80 THEN '£60.01 - £80.00'
		WHEN pl.discounted_price BETWEEN 80.01 AND 100 THEN '£80.01 - £100.00'
		WHEN pl.discounted_price > 100 THEN 'In excess of £100.00'
	END AS price_points,
	ROUND(AVG(war.weighted_average_rating), 2) AS avg_weighted_rating,
	SUM(pr.rating_count) AS total_votes,
	ROUND(AVG(pr.rating), 2) AS avg_rating
FROM product_listing AS pl
LEFT JOIN products AS p
USING (product_sk)
LEFT JOIN weighted_average_ratings AS war
ON p.rating_sk = war.rating_sk
LEFT JOIN product_rating AS pr
ON p.rating_sk = pr.rating_sk
GROUP BY price_points
ORDER BY price_points ASC;

-- Creating a VIEW to compare which category of producs had the most user engagement
DROP VIEW category_engagement_analysis;
CREATE VIEW category_engagement_analysis AS
SELECT
	SPLIT_PART(c.category, '|', -1) AS category, -- shortening the category types to make it more readable in the visualisations
	COUNT(r.review_sk) AS num_written_reviews,
	SUM(pr.rating_count) AS total_rating_votes
FROM reviews AS r
LEFT JOIN product_listing AS pl
USING (listing_sk)
LEFT JOIN products AS p
ON pl.product_sk = p.product_sk
LEFT JOIN product_category AS c
ON p.category_sk = c.category_sk
LEFT JOIN product_rating AS pr
ON p.rating_sk = pr.rating_sk
GROUP BY c.category_sk
ORDER BY num_written_reviews DESC, total_rating_votes DESC
LIMIT 10;


-- Creating a VIEW to compare each category's discount to the average discount in that price bracket
DROP VIEW discount_strategy_analysis;
CREATE VIEW discount_strategy_analysis AS
WITH price_point AS(
	SELECT
		c.category,
		CASE
			WHEN pl.discounted_price BETWEEN 0 AND 20 THEN '£0.01 - £20.00'
			WHEN pl.discounted_price BETWEEN 20.01 AND 40 THEN '£20.01 - £40.00'
			WHEN pl.discounted_price BETWEEN 40.01 AND 60 THEN '£40.01 - £60.00'
			WHEN pl.discounted_price BETWEEN 60.01 AND 80 THEN '£60.01 - £80.00'
			WHEN pl.discounted_price BETWEEN 80.01 AND 100 THEN '£80.01 - £100.00'
			WHEN pl.discounted_price > 100 THEN 'In excess of £100.00'
		END AS price_bracket,
		pl.discount_percentage
	FROM product_listing AS pl
	LEFT JOIN products AS p
	USING (product_sk)
	LEFT JOIN product_category AS c
	ON p.category_sk = c.category_sk
),
avg_discounts AS(
	SELECT
		category,
		price_bracket,
		AVG(discount_percentage) AS cat_avg_discount
		FROM price_point
		GROUP BY category, price_bracket
)
SELECT
	category_avg_discount_for_bracket - avg_discount_for_bracket AS category_price_discount_dif,
	SPLIT_PART(category, '|', -1) AS category, -- shortening the category types to make it more readable in the visualisations
	price_bracket,
	category_avg_discount_for_bracket,
	avg_discount_for_bracket
FROM (
	SELECT
		category, 
		price_bracket,
		ROUND(AVG(cat_avg_discount) OVER (PARTITION BY price_bracket), 0) AS avg_discount_for_bracket,
		ROUND(cat_avg_discount, 0) AS category_avg_discount_for_bracket
	FROM avg_discounts) AS sub
WHERE ABS(category_avg_discount_for_bracket - avg_discount_for_bracket) > 10 
OR ABS(category_avg_discount_for_bracket - avg_discount_for_bracket) < -10
ORDER BY price_bracket, category;

-- Creating a VIEW of total metrics for power bi report 
DROP VIEW listing_total_metrics;
CREATE VIEW listing_total_metrics AS
SELECT
	COUNT(DISTINCT r.listing_sk) AS total_listings,
	COUNT(DISTINCT r.review_sk) AS total_reviews,
	COUNT(DISTINCT c.category_sk) AS total_categories,
	SUM(pr.rating_count) AS sum_ratings
FROM reviews AS r
LEFT JOIN product_listing AS pl
USING (listing_sk)
LEFT JOIN products AS p
ON pl.product_sk = p.product_sk
LEFT JOIN product_category AS c
ON p.category_sk = c.category_sk
LEFT JOIN product_rating AS pr
ON p.rating_sk = pr.rating_sk;




