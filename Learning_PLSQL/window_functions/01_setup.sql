-- Common setup for all database systems (Oracle, PostgreSQL, MySQL)

-- Create a sample employees table
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    department VARCHAR2(50),
    salary NUMBER,
    hire_date DATE
);

-- Create a sales table
CREATE TABLE sales (
    sale_id NUMBER PRIMARY KEY,
    emp_id NUMBER,
    sale_date DATE,
    sale_amount NUMBER,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Sample data for employees
INSERT INTO employees VALUES (1, 'John', 'Doe', 'Sales', 60000, DATE '2020-01-15');
INSERT INTO employees VALUES (2, 'Jane', 'Smith', 'Sales', 65000, DATE '2019-06-20');
INSERT INTO employees VALUES (3, 'Bob', 'Johnson', 'HR', 55000, DATE '2021-03-10');
INSERT INTO employees VALUES (4, 'Alice', 'Williams', 'Sales', 62000, DATE '2020-08-30');
INSERT INTO employees VALUES (5, 'Charlie', 'Brown', 'IT', 70000, DATE '2018-12-01');
INSERT INTO employees VALUES (6, 'Diana', 'Ross', 'IT', 72000, DATE '2019-04-15');
INSERT INTO employees VALUES (7, 'Edward', 'Miller', 'HR', 58000, DATE '2021-07-22');
INSERT INTO employees VALUES (8, 'Fiona', 'Garcia', 'Sales', 63000, DATE '2020-11-05');

-- Sample data for sales
INSERT INTO sales VALUES (1, 1, DATE '2023-01-15', 5000);
INSERT INTO sales VALUES (2, 2, DATE '2023-01-16', 6200);
INSERT INTO sales VALUES (3, 1, DATE '2023-01-17', 4300);
INSERT INTO sales VALUES (4, 4, DATE '2023-01-18', 7100);
INSERT INTO sales VALUES (5, 8, DATE '2023-01-19', 3900);
INSERT INTO sales VALUES (6, 2, DATE '2023-01-20', 5600);
INSERT INTO sales VALUES (7, 1, DATE '2023-01-21', 4800);
INSERT INTO sales VALUES (8, 4, DATE '2023-01-22', 6700);

COMMIT;