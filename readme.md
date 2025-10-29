# SQL Project: Loan Management System Analysis

## 🛠 Tools Used
- MySQL  
- SQL commands: SELECT, JOIN, GROUP BY, ORDER BY, WHERE, JOINS, TRIGGERS, STORED PROCEDURES, etc.

## 📝 Project Steps
1. Imported datasets into SQL database  
2. Performed exploratory data analysis using SQL queries  
3. Analyzed loan distribution by type, repayment behavior, and customer demographics  
4. Identified high-risk customers and repayment trends  
5. Generated insights and visualized query results  

## 💻 Sample SQL Queries
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

## 📈 Key Insights
- Full joined dataset created  
- Mismatched records identified  
- High CIBIL score customers highlighted  
- Home, office & corporate customers analyzed  

## 📂 Project Files
- `Loan_Management.sql` → SQL queries  
- `Customer_Det.csv` → Dataset  
- `Customer_income.csv` → Dataset  
- `Region_info.csv` → Dataset  
- `Loan_status.csv` → Dataset  
- `country_state.csv` → Dataset  
- `images/` → Screenshots of query results  

## 🖼 Screenshots
output1.png  
output2.png  
output3.png  
output4.png
output5.png


