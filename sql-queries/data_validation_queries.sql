-- Validating the data for logical errors


-- Prices:

-- Confirming that there are no instances of discounted_price being higher than actual_price
SELECT discounted_price, actual_price
FROM product_listing
WHERE discounted_price > actual_price;

-- Confirming that there are no instances of the price being NULL
SELECT discounted_price, actual_price
FROM product_listing
WHERE discounted_price IS NULL OR actual_price IS NULL;

-- Confirming that there are no instances of discount_percentage being less than 0 or greater than 100
SELECT discount_percentage
FROM product_listing
WHERE discount_percentage < 0 OR discount_percentage > 100;

-- Checkng if the discount_percentage is correctly recorded
SELECT listing_sk, actual_price, discounted_price, discount_percentage, ROUND((actual_price - discounted_price) / actual_price * 100, 0) AS calc_dis_perc
FROM product_listing
WHERE ROUND((actual_price - discounted_price) / actual_price * 100, 0) != discount_percentage;

-- Updating the discount_percentage column rows which had rounding errors
-- Note: these 22 rows had the percentage either 1% too high or low, which seems consistant with a rounding error rather than the
-- percentage being correct and perhaps the price being recorded incorrectly. Therefore it was decided to amend the recorded discount_percentage
UPDATE product_listing
SET discount_percentage = ROUND((actual_price - discounted_price) / actual_price * 100, 0)
WHERE ROUND((actual_price - discounted_price) / actual_price * 100, 0) != discount_percentage;

-- Confirming that discount_percentage is now recorded correctly
SELECT listing_sk, discount_percentage
FROM product_listing
WHERE ROUND((actual_price - discounted_price) / actual_price * 100, 0) != discount_percentage;


-- Product:

-- Confirming that there are no instances of a product rating of less than 0 or where a produce has a rating count of 0 or below
SELECT *
FROM product_rating
WHERE rating < 0 OR rating_count <= 0;

-- Checking if there are any instances where a product rating or rating_count is NULL
-- This revealed that there were two records which had a rating_count of NULL
-- These records did have a rating, which would suggest this was an error in the recording process
-- as the rating_count must have been known to calculate the average rating, and this was omitted from the two records in error
-- Decision: rating_count will be left as NULL for these records and they will be filtered out in VIEWS that use rating_count for querying 
SELECT *
FROM product_rating
WHERE rating_count IS NULL OR rating IS NULL;

-- Confirming that there are no instances of a product_name being NULL
SELECT product_sk, product_name
FROM products
WHERE product_name IS NULL;


-- Confirming all foreign keys have matching primary key records:

-- products -> product_links
SELECT pl.product_sk
FROM product_links AS pl
LEFT JOIN products AS p
USING (product_sk)
WHERE p.product_sk IS NULL;

-- products -> product_listing
SELECT pl.product_sk
FROM product_listing AS pl
LEFT JOIN products AS p
USING (product_sk)
WHERE p.product_sk IS NULL;

-- product_rating -> products
SELECT p.rating_sk
FROM products AS p
LEFT JOIN product_rating AS pr
USING (rating_sk)
WHERE pr.rating_sk IS NULL;

-- product_category -> products
SELECT p.category_sk
FROM products AS p
LEFT JOIN product_category AS pc
USING (category_sk)
WHERE pc.category_sk IS NULL;

-- product_listing -> reviews
SELECT r.listing_sk
FROM reviews AS r
LEFT JOIN product_listing AS pl
USING (listing_sk)
WHERE pl.listing_sk IS NULL;

-- users -> reviews
SELECT r.user_sk
FROM reviews AS r
LEFT JOIN users AS u
USING (user_sk)
WHERE u.user_sk IS NULL;



