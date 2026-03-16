# Data Dictionary – Gold Layer

## Overview

The **Gold Layer** represents the **business-level data model** of the data warehouse. It is designed to support **analytics, reporting, and business intelligence use cases**.

This layer contains **dimension tables** that store descriptive attributes and **fact tables** that store measurable transactional data.

---

# 1. gold.dim_customers

### Purpose

Stores **customer information** enriched with demographic and geographic attributes.
This table is used to analyze **customer behavior, demographics, and sales performance by customer**.

### Columns

| Column Name     | Data Type    | Description                                                                          |
| --------------- | ------------ | ------------------------------------------------------------------------------------ |
| customer_key    | INT          | Surrogate key uniquely identifying each customer record in the dimension table.      |
| customer_id     | INT          | Unique numerical identifier assigned to each customer from the source system.        |
| customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer used for tracking and referencing. |
| first_name      | NVARCHAR(50) | The customer’s first name as recorded in the source system.                          |
| last_name       | NVARCHAR(50) | The customer’s last name or family name.                                             |
| country         | NVARCHAR(50) | The country of residence of the customer (e.g., USA, Australia).                     |
| marital_status  | NVARCHAR(50) | Marital status of the customer (e.g., Married, Single).                              |
| gender          | NVARCHAR(50) | Gender of the customer (e.g., Male, Female, N/A).                                    |
| birthdate       | DATE         | Date of birth of the customer in YYYY-MM-DD format.                                  |
| create_date     | DATE         | Date when the customer record was created in the system.                             |

---

# 2. gold.dim_products

### Purpose

Stores **product-related information** including category and product attributes.
This table enables analysis of **sales performance by product, category, and product line**.

### Columns

| Column Name  | Data Type     | Description                                                     |
| ------------ | ------------- | --------------------------------------------------------------- |
| product_key  | INT           | Surrogate key uniquely identifying each product record.         |
| product_id   | INT           | Unique identifier assigned to the product in the source system. |
| product_name | NVARCHAR(100) | Name of the product.                                            |
| category     | NVARCHAR(50)  | Product category grouping similar products.                     |
| subcategory  | NVARCHAR(50)  | Subdivision within the product category.                        |
| product_line | NVARCHAR(50)  | Product line classification used for business grouping.         |
| product_cost | INT           | Cost associated with manufacturing or acquiring the product.    |
| maintenance  | NVARCHAR(50)  | Indicates whether the product requires maintenance.             |
| start_date   | DATE          | Date when the product became available for sale.                |

---

# 3. gold.fact_sales

### Purpose

Stores **transactional sales data** that records product purchases made by customers.
This fact table is used for **sales analysis, revenue reporting, and performance monitoring**.

### Columns

| Column Name   | Data Type    | Description                                                     |
| ------------- | ------------ | --------------------------------------------------------------- |
| order_number  | NVARCHAR(50) | Unique identifier representing a sales order.                   |
| product_key   | INT          | Surrogate key linking the sale to the product dimension table.  |
| customer_key  | INT          | Surrogate key linking the sale to the customer dimension table. |
| order_date    | DATE         | Date when the order was placed.                                 |
| shipping_date | DATE         | Date when the order was shipped to the customer.                |
| due_date      | DATE         | Date when the payment for the order was due.                    |
| sales_amount  | INT          | Total monetary value of the sale for the order line.            |
| quantity      | INT          | Number of product units ordered.                                |
| price         | INT          | Price per unit of the product in the order.                     |

---

# Relationship Between Tables

![relation between tables](docs/integration_model.png)
The **Gold Layer follows a Star Schema design**:

* **dim_customers → fact_sales**
* **dim_products → fact_sales**

The **fact_sales table references dimension tables using surrogate keys** to enable efficient analytical queries.

---

It will make your GitHub project look **10x more professional** (like a real Data Engineer portfolio project).
