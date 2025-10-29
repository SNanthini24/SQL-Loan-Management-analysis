SQL Loan Management System Analysis

📊 Overview

This project analyzes loan and customer data using SQL to uncover insights about customer behavior, loan distribution, and repayment performance.
It simulates how data analysts work in the banking and finance sector.

🛠 Tools & Technologies

Database: MySQL

Skills Used: SELECT, JOIN, GROUP BY, HAVING, ORDER BY, TRIGGERS, STORED PROCEDURES

Dataset: Synthetic dataset (CSV files with 500+ records of customers, loans, and regions)

🧩 Steps Performed

Imported datasets into MySQL database

Cleaned and joined tables (customer, income, loan status, region)

Analyzed:

Loan approval rates by region and type

Customer income distribution

High-risk (default) loan patterns

Gender & region-wise repayment trends

Created stored procedures and triggers for data integrity

Exported visual outputs for reporting

📈 Insights

Most loan defaults occur in low-income groups (< ₹40,000/month)

Home loans have the lowest default rate

The North region shows highest loan approval percentage

Customer retention is higher in regions with good income consistency

 💻 Sample SQL Queries
```sql
-- 1. View all customer income data
SELECT * FROM customer_income;

-- 2. Customer criteria based on applicant income and monthly interest
CREATE TABLE customer_criteria AS
SELECT *,
    CASE
        WHEN ApplicantIncome > 15000 THEN 'Grade A'
        WHEN ApplicantIncome > 9000 THEN 'Grade B'
        WHEN ApplicantIncome > 5000 THEN 'Middle class customer'
        ELSE 'Low class customer'
    END AS Income_Status,
    CASE
        WHEN ApplicantIncome < 5000 AND Property_Area='Rural' THEN 3.0
        WHEN ApplicantIncome < 5000 AND Property_Area='SemiRural' THEN 3.5
        WHEN ApplicantIncome < 5000 AND Property_Area='Urban' THEN 5.0
        WHEN ApplicantIncome < 5000 AND Property_Area='SemiUrban' THEN 2.5
        ELSE 7.0
    END AS Monthly_Interest
FROM customer_income;

SELECT * FROM customer_criteria;

-- 3. Monthly and annual interest calculation using JOIN
CREATE TABLE customer_interest_analysis AS
SELECT cc.Loan_ID,
       ls.LoanAmount,
       ROUND(ls.LoanAmount * cc.Monthly_Interest) AS Monthly_Interest_Amt,
       ROUND(ls.LoanAmount * cc.Monthly_Interest * 12) AS Annual_Interest_Amt
FROM customer_criteria cc
JOIN loan_status ls ON ls.Loan_ID = cc.Loan_ID;

SELECT * FROM customer_interest_analysis;
SELECT * FROM loan_status;

-- 4. Loan status update using TRIGGER
CREATE TABLE loan_status_import (
    Loan_ID TEXT,
    Customer_id TEXT,
    LoanAmount TEXT,
    Loan_Amount_Term INT,
    Cibil_Score INT
);

DELIMITER $$
CREATE TRIGGER loan_amt_trig
BEFORE INSERT ON loan_status_import
FOR EACH ROW 
BEGIN
    IF NEW.LoanAmount IS NULL THEN
        SET NEW.LoanAmount = 'Loan Still Processing';
    END IF;
END;
$$
DELIMITER ;
```
🚀 Key Learnings

Practical SQL data analysis workflow

Importance of data cleaning before analysis

Building reusable queries and stored procedures

Translating SQL results into business insights

🧠 Future Enhancements

Connect SQL database to Power BI / Tableau for visualization

Build a Python-based dashboard (pandas + matplotlib)

Add data validation test cases for cleaner ETL pipeline

🪪 Author

Nanthini S
📧 nanthinisakthini@gmail.com





