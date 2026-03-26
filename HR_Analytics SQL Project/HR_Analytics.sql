CREATE TABLE employees (
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT PRIMARY KEY,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(5),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

COPY employees
FROM 'D:/archive/HR_Analytics.csv'
DELIMITER ','
CSV HEADER;

-- 1. Top 5 longest-tenured employees
-- Question: Who are the employees with the longest tenure in the company?
SELECT EmployeeNumber, Department, JobRole, YearsAtCompany
FROM employees
ORDER BY YearsAtCompany DESC
LIMIT 5;

-- 2. Attrition rate per department
-- Question: Which department has the highest attrition rate?
SELECT Department,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate
FROM employees
GROUP BY Department
ORDER BY attrition_rate DESC;

-- 3. Average monthly income per job role
-- Question: What is the average salary for each job role?
SELECT JobRole, ROUND(AVG(MonthlyIncome),2) AS avg_income
FROM employees
GROUP BY JobRole
ORDER BY avg_income DESC;

-- 4. Salary distribution by education level
-- Question: How do salaries vary by education level?
SELECT Education,
       ROUND(AVG(MonthlyIncome),2) AS avg_income,
       MIN(MonthlyIncome) AS min_income,
       MAX(MonthlyIncome) AS max_income
FROM employees
GROUP BY Education
ORDER BY avg_income DESC;

-- 5. Attrition rate by age group
-- Question: Which age group has the highest attrition?
SELECT CASE 
           WHEN Age < 30 THEN 'Under 30'
           WHEN Age BETWEEN 30 AND 40 THEN '30-40'
           WHEN Age BETWEEN 41 AND 50 THEN '41-50'
           ELSE '51+' 
       END AS age_group,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate
FROM employees
GROUP BY age_group
ORDER BY attrition_rate DESC;

-- 6. Average years at company by department
-- Question: Which department has the longest average tenure?
SELECT Department, ROUND(AVG(YearsAtCompany),2) AS avg_years
FROM employees
GROUP BY Department
ORDER BY avg_years DESC;

-- 7. Promotion frequency
-- Question: How often do employees get promoted in each job role?
SELECT JobRole, ROUND(AVG(YearsSinceLastPromotion),2) AS avg_years_since_promotion
FROM employees
GROUP BY JobRole
ORDER BY avg_years_since_promotion ASC;

-- 8. Overtime vs attrition
-- Question: Does working overtime increase attrition?
SELECT OverTime,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate
FROM employees
GROUP BY OverTime;

-- 9. Relationship satisfaction vs attrition
-- Question: Does relationship satisfaction affect attrition?
SELECT RelationshipSatisfaction,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS attrition_rate
FROM employees
GROUP BY RelationshipSatisfaction
ORDER BY RelationshipSatisfaction;

-- 10. Work-life balance scores by department
-- Question: Which department has the best work-life balance?
SELECT Department, ROUND(AVG(WorkLifeBalance),2) AS avg_worklife_balance
FROM employees
GROUP BY Department
ORDER BY avg_worklife_balance DESC;

-- 11. Employees with above-average salary in their department
-- Question: Who earns more than their department’s average salary?
WITH dept_avg AS (
    SELECT Department, AVG(MonthlyIncome) AS avg_income
    FROM employees
    GROUP BY Department
)
SELECT e.EmployeeNumber, e.Department, e.JobRole, e.MonthlyIncome
FROM employees e
JOIN dept_avg d ON e.Department = d.Department
WHERE e.MonthlyIncome > d.avg_income
ORDER BY e.Department, e.MonthlyIncome DESC;

-- 12. Attrition by department compared to company average
-- Question: How does each department’s attrition compare to the company average?
WITH dept_attrition AS (
    SELECT Department,
           SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
           COUNT(*) AS total_count
    FROM employees
    GROUP BY Department
)
SELECT Department,
       ROUND(100.0 * left_count / total_count,2) AS dept_attrition_rate,
       ROUND(AVG(100.0 * left_count / total_count) OVER (),2) AS company_avg_attrition
FROM dept_attrition;

-- 13. Rank employees by salary within their department
-- Question: Who are the top earners in each department?
SELECT EmployeeNumber, Department, JobRole, MonthlyIncome,
       RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS salary_rank
FROM employees
ORDER BY Department, salary_rank;

-- 14. Average tenure by marital status and attrition
-- Question: Does marital status affect tenure and attrition?
SELECT MaritalStatus, Attrition, ROUND(AVG(YearsAtCompany),2) AS avg_tenure
FROM employees
GROUP BY MaritalStatus, Attrition
ORDER BY MaritalStatus, Attrition;

-- 15. Employees promoted more than once
-- Question: Which employees had multiple promotions?
SELECT EmployeeNumber, YearsSinceLastPromotion, YearsAtCompany
FROM employees
WHERE YearsSinceLastPromotion < YearsAtCompany - 2
ORDER BY YearsAtCompany DESC;
