INSERT INTO product_rating(rating, rating_count)
SELECT DISTINCT 
	CAST(sd.rating AS DECIMAL),
	CAST(sd.rating_count AS INTEGER)
FROM sales_data AS sd
WHERE sd.rating IS NOT NULL 
AND sd.rating != '';

INSERT INTO product_category(category)
SELECT DISTINCT 
	CAST(sd.category AS VARCHAR)
FROM sales_data AS sd;

INSERT INTO products(amazon_product_id, product_name, about_product, category_sk, rating_sk)
SELECT DISTINCT 
	CAST(sd.product_id AS VARCHAR), 
	sd.product_name, 
	sd.about_product, 
	pc.category_sk, 
	pr.rating_sk
FROM sales_data AS sd
INNER JOIN product_category AS pc
ON sd.category = pc.category
INNER JOIN product_rating AS pr
ON CAST(sd.rating AS DECIMAL) = CAST(pr.rating AS DECIMAL)
AND CAST(sd.rating_count AS INTEGER) = CAST(pr.rating_count AS INTEGER)
WHERE sd.rating IS NOT NULL 
AND sd.rating != '';

INSERT INTO product_links(product_sk, product_link, img_link)
SELECT DISTINCT 
	p.product_sk, 
	sd.product_link, 
	sd.img_link
FROM sales_data AS sd
INNER JOIN products AS p
ON sd.product_id = p.amazon_product_id;

INSERT INTO product_listing(discounted_price, discount_percentage, actual_price, product_sk)
SELECT DISTINCT 
	CAST(sd.discounted_price AS DECIMAL), 
	CAST(sd.discount_percentage AS SMALLINT), 
	CAST(sd.actual_price AS DECIMAL), 
	p.product_sk
FROM sales_data AS sd
INNER JOIN products AS p
ON sd.product_id = p.amazon_product_id;

INSERT INTO users(amazon_user_id, user_name)
SELECT DISTINCT 
	CAST(sd.user_id AS VARCHAR), 
	CAST(sd.user_name AS VARCHAR)
FROM sales_data AS sd;

INSERT INTO reviews(user_sk, listing_sk, amazon_review_id, review_title, review_content)
SELECT DISTINCT 
	u.user_sk, 
	pl.listing_sk, 
	CAST(sd.review_id AS VARCHAR), 
	sd.review_title, 
	sd.review_content
FROM sales_data AS sd
INNER JOIN users AS u
ON sd.user_id = u.amazon_user_id
INNER JOIN products AS p 
ON sd.product_id = p.amazon_product_id
INNER JOIN product_listing AS pl 
ON p.product_sk = pl.product_sk
AND CAST(sd.discounted_price AS DECIMAL) = CAST(pl.discounted_price AS DECIMAL)
AND CAST(sd.discount_percentage AS SMALLINT) = CAST(pl.discount_percentage AS SMALLINT)
AND CAST(sd.actual_price AS DECIMAL) = CAST(pl.actual_price AS DECIMAL);