# Comprehensive PL/SQL Concepts Guide

This guide is designed to help you not only ace your quiz but also become proficient in PL/SQL for real-world database development and administration. Each section covers:
- In-depth explanations
- Syntax and structure
- Real-world best practices
- Advanced tips
- Practical code examples
- Common pitfalls and troubleshooting

**Covered Topics:**
- Windows Functions
- Cursors
- Functions
- Triggers
- Packages

---

## 1. Windows Functions (Analytic Functions)

### What Are Windows Functions?
Windows (analytic) functions allow you to perform calculations across rows that are related to the current row, without collapsing the result set like GROUP BY. They are powerful for analytics, reporting, and complex data analysis.

### Syntax
```sql
function_name([arguments]) OVER (
    [PARTITION BY expr_list]
    [ORDER BY expr_list]
    [ROWS | RANGE window_frame]
)
```

- **PARTITION BY**: Divides the result set into partitions to which the function is applied.
- **ORDER BY**: Defines the logical order of rows within each partition.
- **ROWS | RANGE**: Specifies the window frame (e.g., current row, preceding/following rows).

### Common Analytic Functions
- `ROW_NUMBER()`: Assigns a unique number to each row.
- `RANK()`, `DENSE_RANK()`: Ranking rows based on a value.
- `SUM()`, `AVG()`, `COUNT()`: Aggregates over a window.
- `LEAD()`, `LAG()`: Access data from subsequent or previous rows.

### Real-World Example
**Find the top 3 earners in each department:**
```sql
SELECT department_id, employee_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_salary_rank
FROM employees
WHERE dept_salary_rank <= 3;
```

**Calculate running totals:**
```sql
SELECT employee_id, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS running_total
FROM employees;
```

### Best Practices
- Use window functions for analytics, not for transactional logic.
- Use PARTITION BY to avoid mixing unrelated groups.
- Always specify ORDER BY for predictable results.
- Use window frames for moving averages or cumulative sums.

### Common Pitfalls
- Using window functions in WHERE clause (not allowed; use in SELECT or ORDER BY).
- Not understanding default window frame (can lead to unexpected results).
- Performance: Large partitions can be slow; index your ORDER BY columns.

### Troubleshooting
- If results look strange, check your PARTITION BY and ORDER BY logic.
- Use explicit window frames for clarity.

### Advanced Tip
You can combine multiple window functions in one SELECT for powerful analytics!

### Advanced Examples

**Moving Average Calculation**
```sql
SELECT 
  employee_id, 
  hire_date, 
  salary,
  AVG(salary) OVER (ORDER BY hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_salary
FROM employees;
```
*Calculates the average salary for the current and previous two hires.*

**Difference Between Current and Previous Row**
```sql
SELECT 
  employee_id, 
  salary,
  salary - LAG(salary, 1, 0) OVER (ORDER BY salary) AS diff_from_prev
FROM employees;
```
*Shows the difference in salary from the previous row.*

### Practice Exercises
1. Write a query to assign a unique row number to each employee within their department, ordered by salary descending.
2. Calculate the cumulative sum of salaries for all employees, ordered by hire date.
3. For each employee, display their salary and the average salary of their department (using a window function).

---

## 2. Cursors

### What Are Cursors?
A cursor is a pointer to the context area in memory where a SQL statement’s result set is stored. Cursors allow you to process query results row by row, which is useful for complex logic that can’t be handled by set-based SQL alone.

### Types of Cursors
- **Implicit Cursor**: Automatically created by Oracle for single SQL statements (e.g., SELECT INTO, DML).
- **Explicit Cursor**: Declared and controlled by the programmer for multi-row queries.
- **Cursor FOR LOOP**: Simplifies explicit cursor usage by handling open/fetch/close automatically.

### Explicit Cursor Lifecycle
1. **Declare**: Define the cursor and its query.
2. **Open**: Execute the query and populate the result set.
3. **Fetch**: Retrieve rows one at a time.
4. **Close**: Release resources.

### Example: Explicit Cursor
```sql
DECLARE
  CURSOR emp_cur IS SELECT employee_id, salary FROM employees;
  emp_id employees.employee_id%TYPE;
  emp_sal employees.salary%TYPE;
BEGIN
  OPEN emp_cur;
  LOOP
    FETCH emp_cur INTO emp_id, emp_sal;
    EXIT WHEN emp_cur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID: ' || emp_id || ' Salary: ' || emp_sal);
  END LOOP;
  CLOSE emp_cur;
END;
```

### Example: Cursor FOR LOOP
```sql
BEGIN
  FOR rec IN (SELECT employee_id, salary FROM employees) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || rec.employee_id || ' Salary: ' || rec.salary);
  END LOOP;
END;
```

### Real-World Uses
- Batch processing (e.g., updating many rows with complex logic)
- Row-by-row validation or transformation
- Generating reports

### Best Practices
- Prefer set-based operations when possible (faster and more efficient).
- Always close explicit cursors to avoid memory leaks.
- Use `%FOUND`, `%NOTFOUND`, `%ROWCOUNT`, `%ISOPEN` for cursor status.
- Use cursor FOR LOOP for simpler code and automatic management.

### Common Pitfalls
- Not closing cursors (memory/resource leaks).
- Fetching after the last row (raises NO_DATA_FOUND).
- Using cursors for simple logic that could be done with a single SQL statement.

### Advanced Tip
You can pass parameters to cursors for dynamic queries:
```sql
CURSOR emp_cur (dept_id NUMBER) IS
  SELECT * FROM employees WHERE department_id = dept_id;
```

### Advanced Example: Parameterized Cursor
```sql
DECLARE
  CURSOR emp_cur (dept_id NUMBER) IS
    SELECT employee_id, salary FROM employees WHERE department_id = dept_id;
BEGIN
  FOR rec IN emp_cur(10) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || rec.employee_id || ' Salary: ' || rec.salary);
  END LOOP;
END;
```

### Practice Exercises
1. Write a cursor to loop through all employees and give a 5% bonus to those with a salary below the company average.
2. Use a cursor to copy selected data from one table to another, applying a transformation (e.g., uppercase names).
3. Create a cursor that takes a parameter for department and prints all employee names in that department.

---

## 3. Functions (User-Defined)

### What Are PL/SQL Functions?
A function is a named PL/SQL block that performs a task and returns a single value. Functions can be called from SQL, PL/SQL, or other functions/procedures.

### Syntax
```sql
CREATE OR REPLACE FUNCTION function_name (
    [parameter1 datatype [, parameter2 datatype ...]]
) RETURN datatype IS
    -- variable declarations
BEGIN
    -- function logic
    RETURN value;
END function_name;
```

- **IN parameters**: Default, pass values in.
- **OUT/IN OUT**: Only for PL/SQL, not SQL-callable functions.

### Example: Simple Function
```sql
CREATE OR REPLACE FUNCTION get_bonus (salary NUMBER)
RETURN NUMBER IS
BEGIN
    RETURN salary * 0.10;
END;
```

### Example: Function with Validation
```sql
CREATE OR REPLACE FUNCTION safe_divide(a NUMBER, b NUMBER)
RETURN NUMBER IS
BEGIN
    IF b = 0 THEN
        RETURN NULL;
    ELSE
        RETURN a / b;
    END IF;
END;
```

### Calling Functions
- From SQL: `SELECT get_bonus(salary) FROM employees;`
- From PL/SQL: `v_bonus := get_bonus(v_salary);`

### Real-World Uses
- Business calculations (tax, commission, discount)
- Data validation
- String or date manipulation

### Best Practices
- Keep functions single-purpose and side-effect free.
- Avoid DML (INSERT/UPDATE/DELETE) in SQL-callable functions.
- Always handle NULLs and edge cases.
- Document input/output and exceptions.

### Common Pitfalls
- Missing or incorrect RETURN statement.
- Using DML in functions called from SQL (causes runtime errors).
- Not handling exceptions (use EXCEPTION block if needed).

### Troubleshooting
- If a function fails in SQL, check for DML or unhandled exceptions.
- Use `%TYPE` and `%ROWTYPE` for variable declarations to match table columns.

### Advanced Tip
Functions can be overloaded (same name, different parameters) in packages.

### Advanced Example: Function with Exception Handling
```sql
CREATE OR REPLACE FUNCTION get_commission(sales NUMBER)
RETURN NUMBER IS
  commission NUMBER;
BEGIN
  IF sales < 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Sales cannot be negative');
  END IF;
  commission := sales * 0.05;
  RETURN commission;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;
```

### Practice Exercises
1. Write a function that returns the number of days between two dates.
2. Create a function to validate an email address format (return 1 for valid, 0 for invalid).
3. Write a function that, given an employee ID, returns their manager’s name.

---

## 4. Triggers

### What Are Triggers?
A trigger is a stored PL/SQL block that automatically executes in response to specific events on a table or view, such as INSERT, UPDATE, or DELETE. Triggers are used for auditing, enforcing business rules, and maintaining data integrity.

### Types of Triggers
- **Row-level**: Fires once for each row affected (`FOR EACH ROW`).
- **Statement-level**: Fires once per SQL statement.
- **BEFORE/AFTER**: Specifies whether the trigger fires before or after the event.

### Syntax
```sql
CREATE OR REPLACE TRIGGER trigger_name
    {BEFORE | AFTER | INSTEAD OF} {INSERT | UPDATE | DELETE}
    ON table_name
    [FOR EACH ROW]
DECLARE
    -- variable declarations
BEGIN
    -- trigger logic
END trigger_name;
```

### Example: Audit Trigger
```sql
CREATE OR REPLACE TRIGGER audit_salary
AFTER UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salary_audit(emp_id, old_salary, new_salary)
    VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary);
END;
```

### Example: Enforce Business Rule
```sql
CREATE OR REPLACE TRIGGER prevent_negative_salary
BEFORE UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary cannot be negative');
    END IF;
END;
```

### Real-World Uses
- Auditing changes (who changed what and when)
- Enforcing business rules (e.g., salary cannot decrease)
- Maintaining derived or summary data

### Best Practices
- Keep triggers simple and efficient (avoid slow queries).
- Avoid using triggers for complex business logic.
- Never use COMMIT or ROLLBACK in triggers (causes errors).
- Document trigger purpose and behavior.

### Common Pitfalls
- Mutating table error (trigger modifies the table it’s triggered on).
- Unintended recursion (trigger fires itself repeatedly).
- Performance issues if triggers do too much work.

### Troubleshooting
- Use `RAISE_APPLICATION_ERROR` for custom errors.
- Use `:NEW` and `:OLD` to access new/old row values.
- Test triggers thoroughly—unexpected side effects can be hard to debug.

### Advanced Tip
Use compound triggers for complex scenarios (introduced in Oracle 11g+).

### Advanced Example: Compound Trigger (Oracle 11g+)
```sql
CREATE OR REPLACE TRIGGER audit_changes
FOR UPDATE ON employees
COMPOUND TRIGGER
  BEFORE STATEMENT IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Update started');
  END BEFORE STATEMENT;
  AFTER EACH ROW IS
  BEGIN
    INSERT INTO audit_log VALUES (:OLD.employee_id, :NEW.salary, SYSDATE);
  END AFTER EACH ROW;
END audit_changes;
```

### Practice Exercises
1. Write a trigger to prevent deletion of employees who are department managers.
2. Create a trigger to automatically update a “last_modified” timestamp column on row updates.
3. Write a trigger to log any salary changes to an audit table.

---

## 5. Packages

### What Are Packages?
A package is a schema object that groups logically related PL/SQL types, variables, constants, exceptions, procedures, and functions. Packages promote modularity, reusability, and encapsulation.

### Structure
- **Package Specification**: Declares public types, variables, constants, exceptions, procedures, and functions.
- **Package Body**: Implements the procedures and functions declared in the spec. Can also have private items.

### Syntax
```sql
-- Specification
CREATE OR REPLACE PACKAGE pkg_name IS
    PROCEDURE proc1;
    FUNCTION func1 RETURN NUMBER;
    -- Public variables/constants
END pkg_name;
/
-- Body
CREATE OR REPLACE PACKAGE BODY pkg_name IS
    PROCEDURE proc1 IS BEGIN NULL; END;
    FUNCTION func1 RETURN NUMBER IS BEGIN RETURN 1; END;
    -- Private procedures/functions
END pkg_name;
/
```

### Example: Utility Package
```sql
CREATE OR REPLACE PACKAGE math_utils IS
    FUNCTION add(a NUMBER, b NUMBER) RETURN NUMBER;
    FUNCTION factorial(n NUMBER) RETURN NUMBER;
END math_utils;
/
CREATE OR REPLACE PACKAGE BODY math_utils IS
    FUNCTION add(a NUMBER, b NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN a + b;
    END;
    FUNCTION factorial(n NUMBER) RETURN NUMBER IS
        result NUMBER := 1;
    BEGIN
        FOR i IN 1..n LOOP
            result := result * i;
        END LOOP;
        RETURN result;
    END;
END math_utils;
/
```

### Real-World Uses
- Grouping related business logic
- Sharing global variables/constants across sessions
- Encapsulating utility functions

### Best Practices
- Use packages to organize code for maintainability.
- Only expose what’s necessary in the specification.
- Use package variables for session-level state (with caution).
- Document all public procedures/functions.

### Common Pitfalls
- Spec and body mismatch (missing or extra procedures/functions).
- Forgetting to end statements with semicolons.
- Overusing package variables (can lead to unexpected state).

### Troubleshooting
- If a procedure/function is not visible, check if it’s declared in the spec.
- Use `DBMS_OUTPUT.PUT_LINE` for debugging inside package bodies.

### Advanced Tip
Packages support overloading (same name, different parameters) and can have initialization sections (run once per session).

### Advanced Example: Package with Initialization and Overloading
```sql
CREATE OR REPLACE PACKAGE session_pkg IS
  session_start DATE;
  PROCEDURE log_event(event VARCHAR2);
  FUNCTION get_session_duration RETURN NUMBER;
  FUNCTION calc_area(radius NUMBER) RETURN NUMBER;
  FUNCTION calc_area(length NUMBER, width NUMBER) RETURN NUMBER;
END session_pkg;
/
CREATE OR REPLACE PACKAGE BODY session_pkg IS
  PROCEDURE log_event(event VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Event: ' || event);
  END;
  FUNCTION get_session_duration RETURN NUMBER IS
  BEGIN
    RETURN SYSDATE - session_start;
  END;
  FUNCTION calc_area(radius NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN 3.14159 * radius * radius;
  END;
  FUNCTION calc_area(length NUMBER, width NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN length * width;
  END;
  BEGIN
    session_start := SYSDATE; -- Initialization
  END session_pkg;
/
```

### Practice Exercises
1. Create a package for employee utilities: functions for getting full name, years of service, and a procedure to promote an employee.
2. Write a package that manages application-level error logging.
3. Implement a package with overloaded functions for different types of calculations.

---

## Quick Reference Table

| Topic           | Key Syntax/Concepts                           | Common Pitfalls               |
|-----------------|-----------------------------------------------|-------------------------------|
| Windows Funcs   | `OVER (PARTITION BY ... ORDER BY ...)`        | Missing OVER, wrong clause    |
| Cursors         | DECLARE, OPEN, FETCH, CLOSE                   | Not closing, fetch after end  |
| Functions       | RETURN, parameters, DML in SQL-callable funcs | Missing RETURN, DML in SQL    |
| Triggers        | BEFORE/AFTER, :NEW/:OLD, no commit/rollback   | Mutating table, transaction   |
| Packages        | Spec & Body, session vars, modularity         | Spec/body mismatch, semicolon |

---

## Real-World Tips for Mastery

- **Practice regularly**: Build your own sample tables, triggers, functions, and packages.
- **Read Oracle documentation**: It’s thorough and full of examples.
- **Debug with DBMS_OUTPUT**: Print variable values to trace execution.
- **Keep code modular**: Use packages and functions to organize logic.
- **Handle exceptions**: Always anticipate and handle possible errors.
- **Optimize for performance**: Use set-based logic when possible, and index columns used in analytic functions.
- **Document everything**: Comments help you and your team understand and maintain code.

**Keep exploring!** PL/SQL is a powerful language—mastering it opens doors to advanced database applications and performance tuning.

---

**Tip:** Use this guide as a reference for both exams and real-world projects. Good luck, and keep learning!
