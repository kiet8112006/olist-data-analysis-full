# olist-data-analysis-full
## Project Workflow

This project follows a structured data analytics workflow, transforming raw transactional data into a clean analytical dataset and business insights.

### 1. Data Understanding

The first step is to understand the dataset structure and the relationships between tables.

Key tasks:

- Review dataset documentation
- Identify primary keys and foreign keys
- Understand entity relationships
- Examine the overall transaction flow

Main entities in the Olist dataset:

customers → orders → order_items → products

Additional supporting tables:

- sellers
- payments
- reviews
- geolocation
- category translation

This step ensures a clear understanding of how the data is organized before performing analysis.
### 2. Data Quality Assessment (Exploratory Data Analysis)

Before performing any analysis, the dataset was evaluated to identify potential data quality issues.

The following checks were performed for each table:

- Missing value detection
- Duplicate record detection
- Data type validation
- Range validation for numeric columns
- Distribution analysis
- Logical validation of timestamps
- Cross-table consistency checks

Examples:

- Checking missing values in each column
- Detecting duplicate primary keys
- Validating ZIP code ranges
- Verifying payment installment logic
- Checking delivery timestamps
- ### 3. Data Cleaning and Standardization

After identifying data quality issues, several cleaning and standardization steps were applied.

Cleaning actions include:

- Standardizing ZIP code prefixes to 5-digit format
- Normalizing city and state names
- Handling missing product attributes
- Flagging unmatched ZIP codes in geolocation data
- Validating logical timestamp relationships
- Identifying unusual price or freight values

These steps ensure the dataset is consistent and suitable for analytical queries.
### 4. Data Modeling

To support analytical queries and reporting, the dataset was transformed into a dimensional model.

A Star Schema was designed to simplify analysis and improve query performance.

Fact table:

- fact_order_items

Dimension tables:

- dim_customers
- dim_products
- dim_sellers
- dim_reviews
- dim_date

Supporting tables:

- geolocation
- product_category_name_translation
### 5. Exploratory Data Analysis

After cleaning and modeling the data, exploratory analysis was conducted to understand key patterns in the dataset.

Examples of analyses:

- Price distribution of products
- Payment method distribution
- Freight cost vs product price
- Review score distribution
- Customer geographic distribution
- Seller distribution by state
### 6. Business Analysis

The cleaned dataset enables analysis of several business aspects of the Olist platform.

Key analytical areas include:

- sales performance
- delivery performance
- payment behavior
- customer satisfaction
- product category popularity
