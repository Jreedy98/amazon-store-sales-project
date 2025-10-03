COPY sales_data(
	product_id, 
	product_name, 
	category, 
	discounted_price, 
	actual_price, 
	discount_percentage,
	rating,
	rating_count,
	about_product,
	user_id,
	user_name,
	review_id,
	review_title,
	review_content,
	img_link,
	product_link
)  
FROM 'C:\Users\jakes\OneDrive\Desktop\Github\Data\Amazon sales\amazon.csv'
DELIMITER ','
CSV HEADER;