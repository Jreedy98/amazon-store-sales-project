CREATE TABLE product_category (
	category_sk SERIAL PRIMARY KEY,
	category VARCHAR (255)
);
CREATE TABLE users (
	user_sk SERIAL PRIMARY KEY,
	amazon_user_id VARCHAR(300),
	user_name VARCHAR (255)
);
CREATE TABLE product_rating (
	rating_sk SERIAL PRIMARY KEY,
	rating DECIMAL(2,1),
	rating_count INTEGER
);
CREATE TABLE products (
	product_sk SERIAL PRIMARY KEY,
	amazon_product_id VARCHAR(100),
	product_name TEXT,
	about_product TEXT,
	category_sk INTEGER,
	rating_sk INTEGER,
	FOREIGN KEY (category_sk) REFERENCES product_category(category_sk), 
	FOREIGN KEY (rating_sk) REFERENCES product_rating(rating_sk)
);
CREATE TABLE product_links (
	links_sk SERIAL PRIMARY KEY,
	product_sk INTEGER,
	product_link TEXT,
	img_link TEXT,
	FOREIGN KEY (product_sk) REFERENCES products(product_sk)
);
CREATE TABLE product_listing (
	listing_sk SERIAL PRIMARY KEY,
	discounted_price DECIMAL(6,2),
	discount_percentage SMALLINT,
	actual_price DECIMAL(6,2),
	product_sk INTEGER,
	FOREIGN KEY (product_sk) REFERENCES products(product_sk)
);
CREATE TABLE reviews (
	review_sk SERIAL PRIMARY KEY,
	user_sk INTEGER,
	listing_sk INTEGER,
	amazon_review_id VARCHAR(300),
	review_title TEXT,
	review_content TEXT,
	FOREIGN KEY (user_sk) REFERENCES users(user_sk),
	FOREIGN KEY (listing_sk) REFERENCES product_listing(listing_sk)
);