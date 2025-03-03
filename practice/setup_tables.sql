-- Create sequence for employee IDs
CREATE SEQUENCE emp_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create departments table
CREATE TABLE departments (
    department_id   NUMBER PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL,
    location       VARCHAR2(50),
    manager_id     NUMBER
);

-- Create employees table
CREATE TABLE employees (
    employee_id    NUMBER PRIMARY KEY,
    first_name     VARCHAR2(50) NOT NULL,
    last_name      VARCHAR2(50) NOT NULL,
    email          VARCHAR2(100) UNIQUE,
    hire_date      DATE DEFAULT SYSDATE,
    department_id  NUMBER REFERENCES departments(department_id),
    job_title      VARCHAR2(50),
    salary         NUMBER(10,2),
    manager_id     NUMBER REFERENCES employees(employee_id)
);

-- Create performance_ratings table
CREATE TABLE performance_ratings (
    rating_id      NUMBER PRIMARY KEY,
    employee_id    NUMBER REFERENCES employees(employee_id),
    rating_date    DATE DEFAULT SYSDATE,
    rating         CHAR(1) CHECK (rating IN ('A','B','C','D')),
    comments       VARCHAR2(1000)
);

-- Create salary_history table
CREATE TABLE salary_history (
    history_id     NUMBER PRIMARY KEY,
    employee_id    NUMBER REFERENCES employees(employee_id),
    change_date    DATE DEFAULT SYSDATE,
    old_salary     NUMBER(10,2),
    new_salary     NUMBER(10,2),
    reason         VARCHAR2(200)
);

-- Insert some sample departments
INSERT INTO departments (department_id, department_name, location)
VALUES (10, 'IT', 'New York');

INSERT INTO departments (department_id, department_name, location)
VALUES (20, 'HR', 'Chicago');

INSERT INTO departments (department_id, department_name, location)
VALUES (30, 'Finance', 'Boston');

COMMIT; 