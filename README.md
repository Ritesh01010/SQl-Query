# Zepto Data Analysis with SQL

This repository contains a comprehensive SQL-based analysis of a product dataset from Zepto, a quick commerce company. The project explores the data, cleans it, and answers key business questions related to inventory, pricing, and category performance.

---

## 📝 Overview

The goal of this project is to leverage SQL to extract actionable insights from a real-world dataset. The entire analysis follows a structured workflow:

1.  **Database Setup:** Creating the table structure to hold the product data.
2.  **Data Loading:** Importing data from a `.csv` file into the SQL database.
3.  **Data Exploration:** Understanding the dataset's size, scope, and basic characteristics.
4.  **Data Cleaning:** Identifying and correcting inconsistencies, such as converting prices from paise to rupees and removing invalid entries.
5.  **In-Depth Analysis:** Writing complex queries to answer specific business questions and uncover strategic insights.

---

## 📂 Files in This Repository

* **`Zepto Data Sql Query.sql`**: This is the core of the project. It contains all the SQL queries used for the entire workflow, from creating the table and loading the data to performing the final, detailed analysis. The queries are commented to explain the purpose of each step.

* **`Zepto Report.pdf`**: This is a professional business report that summarizes the key findings from the SQL analysis. It translates the raw data insights into strategic recommendations for inventory management, pricing strategy, and marketing focus.

---

## ❓ Key Business Questions Answered

The analysis in the SQL file and the report addresses critical business questions, including:

* What is the total financial value of all stock on hand (at both MRP and discounted prices)?
* Which products are most heavily overstocked and may require promotional campaigns?
* Which high-value products are out of stock, representing a loss of potential revenue?
* Which product categories generate the most revenue and offer the most variety?
* How are products distributed across different price points (e.g., budget, standard, premium)?
* How effective are discount strategies at driving sales?
* Which essential products sell well without any discounts?

---

## 🛠️ Tools Used

* **Database:** PostgreSQL
* **Language:** SQL

---

## 🚀 How to Use

To replicate this analysis, you will need:

1.  A running instance of **PostgreSQL**.
2.  The dataset file `zepto_v2.csv` (Note: this dataset is not included in this repository).
3.  Clone this repository or download the files.

**Steps:**

1.  Open the **`Zepto Data Sql Query.sql`** file.
2.  **Crucially, update the file path** in the `COPY` command to point to the location of your `zepto_v2.csv` file:
    ```sql
    COPY zepto (...)
    FROM 'YOUR_LOCAL_PATH\zepto_v2.csv' -- <-- CHANGE THIS LINE
    DELIMITER ','
    CSV HEADER;
    ```
3.  Execute the entire SQL script in your preferred SQL client (like pgAdmin, DBeaver, etc.).
4.  Review the query results to see the analysis in action.
5.  For a high-level summary and strategic recommendations, read the **`Zepto Report.pdf`**.
