Design decisions to move from initial_concept to erd_2NF to erd_final:
This document outlines the key decisions made during the design of the database schema, to move from the initial model to a normalised structure.


1. Moving from initial_concept to erd_2nf: 

a. Decision: Using Surrogate Keys rather natural keys

Initial thought: The source data provides natural keys like product_id and review_id that could potentially be used as primary keys (PKs).

Final decision: All primary keys will be system generated surrogate keys (e.g. product_sk, user_sk).

Reasoning: Natural keys from an external dataset are outside of my control and it is unclear who has control of these natural keys from the dataset (e.g. is the product_id assigned through amazon and is it guaranteed that this ID wont change?). Relying on these natural keys would make my database fragile. Therefore, I decided to use a surrogate key, as it is guaranteed to be unique, stable, and permanent.


b. Decision: Remove ambiguity from natural key names

Initial thought: The original column names like product_id could be confusing once surrogate keys are introduced.

Final decision: A new naming convention was adopted to remove all ambiguity.

Surrogate keys (PKs): Will use "_sk" within their name (e.g. product_sk, listing_sk).

Natural keys: The original identifiers from the source data will be renamed with "amazon_" ahead of their name to clearly indiciate their origin (e.g., amazon_product_id, amazon_review_id).

Reasoning: This convention makes it immediately clear what the function of each key is. product_sk is for internal database joins, while amazon_product_id is for tracing a record back to the original CSV file.


2. Moving from erd_2nf to erd_final:

Initial review: After creating erd_2NF, I compared the schema to the normalised form requirements. The rule for 3NF states that every non-key attribute must depend only on the primary key, and not on any other non-key attribute (i.e. there must be no transitive dependencies). I indentified that my schema did not satisfy these requirements, with several tables containing transitive dependencies. 

Decision: Refine the schema to comply with 3NF by resolving all transitive dependencies.

This was achieved through the following key changes:

a. Decision: Separate product attributes from listing attributes

Reasoning: The product_listings table in the 2NF design violated 3NF. It contained attributes like product_name that did not depend on the primary key (listing_sk), but rather on the amazon_product_id within that table. This created a transitive dependency: listing_sk → amazon_product_id → product_name.

Final actions:

A new products table was created to store the core information unique to a product (e.g. amazon_product_id, product_name, about_product). This ensures these attributes depend only on the new product_sk.

The product_listings table was then refined to hold only attributes that are direct facts about a specific listing, such as discounted_price and actual_price.

Consequently, the category_sk foreign key was moved from product_listings to the new products table, as a category is an attribute of the product itself, not the individual listing.


b. Decision: Isolate rating and links

Reasoning: Further querying revealed that some attributes were not facts about an individual review or listing, but about the product as a whole. For example, rating and rating_count represented the overall score for a product, not a single user's rating from one review. Similarly, the product and image links were attributes of the products.

Final Actions:

The rating and rating_count were moved from the reviews table to a new product_ratings table, linked directly to the products table via rating_sk.

The img_link and product_link were moved to their own product_links table, and linked via product_sk, to separate the link data from core product attributes.

These changes ensure that every column in every table is a fact about "the key, the whole key, and nothing but the key," to achieve compliance with 3NF.

