-- Create a table for attendance:
CREATE TABLE student_attendance (
    student_id       NUMBER,
    attendance_date  DATE,
    status           VARCHAR2(20)
);


-- Create a procedure to insert attendance records:
CREATE OR REPLACE PROCEDURE record_attendance(
    p_student_id        IN  NUMBER,
    p_attendance_date   IN  DATE,
    p_status            IN  VARCHAR2,
    p_message           OUT VARCHAR2
) 
IS
    -- 1) Declare a user-defined exception:
    attendance_already_recorded EXCEPTION;
    
    -- 2) Variable to check if record exists:
    v_count  NUMBER := 0;
BEGIN
    -- Check if the record already exists for the same student and date
    SELECT COUNT(*)
      INTO v_count
      FROM student_attendance
     WHERE student_id = p_student_id
       AND attendance_date = p_attendance_date;
       
    IF v_count > 0 THEN
        -- Raise user-defined exception if attendance exists
        RAISE attendance_already_recorded;
    ELSE
        -- Insert new attendance record
        INSERT INTO student_attendance (student_id, attendance_date, status)
        VALUES (p_student_id, p_attendance_date, p_status);
        
        -- Return success message
        p_message := 'Attendance recorded successfully for student ID ' 
                     || p_student_id 
                     || ' on ' 
                     || TO_CHAR(p_attendance_date, 'DD-MON-YYYY');
    END IF;
    
EXCEPTION
    WHEN attendance_already_recorded THEN
        p_message := 'Error: Attendance has already been recorded for student ID ' 
                     || p_student_id 
                     || ' on ' 
                     || TO_CHAR(p_attendance_date, 'DD-MON-YYYY');
                     
    WHEN OTHERS THEN
        -- Catch-all for any other errors
        p_message := 'An unexpected error occurred: ' || SQLERRM;
END record_attendance;
/



-- Test Scenario 1: New record (should succeed)
DECLARE
    v_message VARCHAR2(200);
BEGIN
    record_attendance(
        p_student_id      => 12345,
        p_attendance_date => DATE '2025-03-18',
        p_status          => 'Present',
        p_message         => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/

-- Test Scenario 2: Duplicate record (should raise the user-defined exception)
DECLARE
    v_message VARCHAR2(200);
BEGIN
    record_attendance(
        p_student_id      => 12345,
        p_attendance_date => DATE '2025-03-18',
        p_status          => 'Absent',  -- or any status
        p_message         => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/


/*
Here are some practice questions to challenge your ability to create procedures, handle exceptions, 
and work with different parameter types in PL/SQL:

---

### 1. Employee Insertion with Duplicate Check

**Task:**  
Create a procedure named `add_employee` that inserts a new employee record into an `employees` table. The 
table includes columns like `employee_id`, `first_name`, `last_name`, and `hire_date`.  
**Requirements:**  
- Accept the employee details as parameters.
- Check if an employee with the given `employee_id` already exists.
- If a duplicate is found, raise a user-defined exception and return an appropriate error message via an
 OUT parameter.
- If no duplicate exists, insert the record and return a success message.

---
*/
create table employees(
    employee_id number primary key,
    first_name varchar2(50),
    last_name varchar2(50),
    hire_date date
);

create or replace procedure add_employee(
    p_employee_id in number,
    p_first_name in varchar2,
    p_last_name in varchar2,
    p_hire_date in date,
    p_message out varchar2
) as
    employee_already_exists exception;
    PRAGMA EXCEPTION_INIT(employee_already_exists, -1); -- Initialize the exception
    v_count number := 0;
begin
    -- Check if the employee already exists
    SELECT COUNT(*)
      INTO v_count
      FROM employees
     WHERE employee_id = p_employee_id;

    IF v_count > 0 THEN
        -- Raise user-defined exception if employee exists
        RAISE employee_already_exists;
    ELSE
        -- Insert new employee record
        INSERT INTO employees (employee_id, first_name, last_name, hire_date)
        VALUES (p_employee_id, p_first_name, p_last_name, p_hire_date);
        
        -- Return success message
        p_message := 'Employee added successfully with ID ' || p_employee_id;
    END IF;
    
EXCEPTION
    WHEN employee_already_exists THEN
        p_message := 'Error: Employee with ID ' || p_employee_id || ' already exists.';
        
    WHEN OTHERS THEN
        -- Catch-all for any other errors
        p_message := 'An unexpected error occurred: ' || SQLERRM;
END add_employee;
/

-- Test Scenario 1: New employee record (should succeed)
DECLARE
    v_message VARCHAR2(200);
BEGIN
    add_employee(
        p_employee_id => 1001,
        p_first_name => 'John',
        p_last_name => 'Doe',
        p_hire_date => DATE '2025-03-18',
        p_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
-- Test Scenario 2: Duplicate employee record (should raise the user-defined exception)
DECLARE
    v_message VARCHAR2(200);
BEGIN
    add_employee(
        p_employee_id => 1001,
        p_first_name => 'Jane',
        p_last_name => 'Smith',
        p_hire_date => DATE '2025-03-18',
        p_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
    
    -- Test Scenario 3: New employee record (should succeed)
    add_employee(
        p_employee_id => 1002,
        p_first_name => 'Alice',
        p_last_name => 'Johnson',
        p_hire_date => DATE '2025-03-19',
        p_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/*
### 2. Safe Division

**Task:**  
Develop a procedure called `safe_division` that takes two numbers (dividend and divisor) and returns the result in an OUT parameter.  
**Requirements:**  
- Check if the divisor is zero.  
- If it is zero, raise a custom exception (or use built-in exception handling) to avoid division by zero and return a descriptive error message.
- Otherwise, perform the division and return the result.

---
*/
create or replace procedure safe_division(
    p_dividend in number,
    p_divisor in number,
    p_result out number,
    p_message out varchar2
) as
    division_by_zero exception;
    pragma exception_init(division_by_zero, -1);
begin
    -- Check if the divisor is zero
    IF p_divisor = 0 THEN
        RAISE division_by_zero;
    ELSE
        -- Perform the division
        p_result := p_dividend / p_divisor;
        p_message := 'Division successful: ' || p_result;
    END IF;
    
EXCEPTION
    WHEN division_by_zero THEN
        p_message := 'Error: Division by zero is not allowed.';
    WHEN OTHERS THEN
        p_message := 'An unexpected error occurred: ' || SQLERRM;
END safe_division;
/*
### 3. Update Employee Salary

**Task:**  
Write a procedure named `update_salary` that updates the salary of an employee in an `employees` table.  
**Requirements:**  
- Accept an employee ID and a new salary as inputs.
- Check if the employee exists.
- If the employee does not exist, raise a user-defined exception and provide an error message.
- If the employee exists, update the salary and return a confirmation message via an OUT parameter.

---

### 4. Student Grade Calculator

**Task:**  
Create a procedure called `calculate_grade` that calculates and returns a student's letter grade based on their numeric score.  
**Requirements:**  
- Accept a numeric score as an input parameter.
- Determine the letter grade based on defined thresholds (e.g., A for 90-100, B for 80-89, etc.).
- Return the letter grade as an OUT parameter.
- Handle any cases where the score might be out of the expected range.

---

### 5. Dynamic Table Creation

**Task:**  
Design a procedure named `create_table_if_missing` that checks if a table (e.g., `temp_data`) exists and creates it if it doesn’t.  
**Requirements:**  
- Use dynamic SQL (`EXECUTE IMMEDIATE`) to perform the check and create the table.
- Handle exceptions if the table creation fails, returning an appropriate message via an OUT parameter.
- Ensure that your procedure does not raise an error if the table already exists.

---

### Tips for Attempting These Questions:
- **Parameter Modes:** Use IN parameters for inputs and OUT parameters for returning messages or results.
- **Exception Handling:** Utilize `EXCEPTION` blocks to capture and handle both user-defined and system exceptions.
- **Testing:** Write anonymous PL/SQL blocks to test each procedure after creating them.
- **Comments:** Add comments in your code to explain your logic, which is good practice for clarity and maintenance.

Try implementing these one by one, and if you have any questions or run into issues, feel free to ask for guidance or clarification!




Below are several advanced PL/SQL topics with carefully crafted questions along with complete, worked‐out solutions. These exercises will help you gain practical experience in writing functions, using cursors and collections, creating packages, performing bulk operations, and designing triggers.

---

## 1. Recursive Function for Factorial Calculation

**Question:**  
Write a PL/SQL function named `get_factorial` that calculates the factorial of a positive integer using recursion. The function should return the factorial value. If a non-positive value is passed, return 1.

**Solution:**

```sql
CREATE OR REPLACE FUNCTION get_factorial (
    n IN NUMBER
) RETURN NUMBER
IS
BEGIN
    IF n <= 1 THEN
        RETURN 1;
    ELSE
        RETURN n * get_factorial(n - 1);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL; -- In case of an unexpected error
END get_factorial;
/
```

**Explanation:**  
- The function checks if `n` is less than or equal to 1, returning 1 in that case.  
- Otherwise, it recursively calls itself with `n - 1`.  
- An exception handler returns `NULL` if any error occurs.

**Testing the Function:**

```sql
DECLARE
    v_result NUMBER;
BEGIN
    v_result := get_factorial(5);
    DBMS_OUTPUT.PUT_LINE('Factorial of 5 is: ' || v_result);
END;
/
```

---

## 2. Using Implicit Cursors to List Employees

**Question:**  
Write an anonymous PL/SQL block that uses an implicit cursor to retrieve and display all rows from an `employees` table (assume the table has columns: `employee_id`, `first_name`, and `last_name`).

**Solution:**

```sql
DECLARE
    -- Variables to hold each column's data
    v_employee_id employees.employee_id%TYPE;
    v_first_name  employees.first_name%TYPE;
    v_last_name   employees.last_name%TYPE;
BEGIN
    FOR rec IN (SELECT employee_id, first_name, last_name FROM employees) LOOP
        v_employee_id := rec.employee_id;
        v_first_name  := rec.first_name;
        v_last_name   := rec.last_name;
        
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_employee_id ||
                             ', Name: ' || v_first_name || ' ' || v_last_name);
    END LOOP;
END;
/
```

**Explanation:**  
- An implicit cursor FOR loop is used to iterate through the query result.  
- Each record is printed using `DBMS_OUTPUT.PUT_LINE`.

---

## 3. Creating a Package for Employee Management

**Question:**  
Create a PL/SQL package named `emp_pkg` that includes two procedures:  
- `add_emp` for inserting an employee record into the `employees` table.  
- `raise_salary` for increasing an employee’s salary by a specified percentage.  
Assume the `employees` table contains `employee_id`, `first_name`, `last_name`, and `salary` columns.

**Solution:**

### Package Specification

```sql
CREATE OR REPLACE PACKAGE emp_pkg AS
    PROCEDURE add_emp(
        p_employee_id IN NUMBER,
        p_first_name  IN VARCHAR2,
        p_last_name   IN VARCHAR2,
        p_salary      IN NUMBER,
        p_message     OUT VARCHAR2
    );

    PROCEDURE raise_salary(
        p_employee_id IN NUMBER,
        p_percentage  IN NUMBER,
        p_message     OUT VARCHAR2
    );
END emp_pkg;
/
```

### Package Body

```sql
CREATE OR REPLACE PACKAGE BODY emp_pkg AS

    PROCEDURE add_emp(
        p_employee_id IN NUMBER,
        p_first_name  IN VARCHAR2,
        p_last_name   IN VARCHAR2,
        p_salary      IN NUMBER,
        p_message     OUT VARCHAR2
    ) IS
        duplicate_emp EXCEPTION;
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM employees
        WHERE employee_id = p_employee_id;
        
        IF v_count > 0 THEN
            RAISE duplicate_emp;
        ELSE
            INSERT INTO employees (employee_id, first_name, last_name, salary)
            VALUES (p_employee_id, p_first_name, p_last_name, p_salary);
            p_message := 'Employee added successfully.';
        END IF;
        
    EXCEPTION
        WHEN duplicate_emp THEN
            p_message := 'Error: Employee with ID ' || p_employee_id || ' already exists.';
        WHEN OTHERS THEN
            p_message := 'Unexpected error: ' || SQLERRM;
    END add_emp;
    
    PROCEDURE raise_salary(
        p_employee_id IN NUMBER,
        p_percentage  IN NUMBER,
        p_message     OUT VARCHAR2
    ) IS
        v_current_salary employees.salary%TYPE;
    BEGIN
        SELECT salary INTO v_current_salary
        FROM employees
        WHERE employee_id = p_employee_id;
        
        UPDATE employees
        SET salary = v_current_salary * (1 + p_percentage / 100)
        WHERE employee_id = p_employee_id;
        
        p_message := 'Salary increased by ' || p_percentage || '% for employee ID ' || p_employee_id;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_message := 'Error: Employee with ID ' || p_employee_id || ' not found.';
        WHEN OTHERS THEN
            p_message := 'Unexpected error: ' || SQLERRM;
    END raise_salary;
    
END emp_pkg;
/
```

**Explanation:**  
- The package specification declares the two procedures.  
- The body implements them with error checking:  
  - `add_emp` prevents duplicate insertions.  
  - `raise_salary` retrieves the current salary and updates it by a percentage.  
- Both procedures use an OUT parameter (`p_message`) to return status messages.

---

## 4. Bulk Processing Using Collections and FORALL

**Question:**  
Write a procedure named `bulk_update_salary` that accepts a collection (array) of employee IDs and a percentage increase. Use bulk processing (i.e., `FORALL`) to update the salary of all listed employees. Report how many records were updated.

**Solution:**

```sql
-- First, define a collection type at the schema level (or inside a package)
CREATE OR REPLACE TYPE num_array AS TABLE OF NUMBER;
/

CREATE OR REPLACE PROCEDURE bulk_update_salary(
    p_emp_ids   IN num_array,
    p_percentage IN NUMBER,
    p_updated_count OUT NUMBER
)
IS
BEGIN
    -- Use FORALL to update salaries in bulk
    FORALL i IN INDICES OF p_emp_ids
        UPDATE employees
        SET salary = salary * (1 + p_percentage / 100)
        WHERE employee_id = p_emp_ids(i);
    
    -- Get the count of affected rows
    p_updated_count := SQL%ROWCOUNT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_updated_count := -1; -- Indicate an error occurred
END bulk_update_salary;
/
```

**Explanation:**  
- A collection type (`num_array`) is created to hold numbers (employee IDs).  
- The procedure uses `FORALL` for bulk updates to improve performance when updating multiple rows.  
- `SQL%ROWCOUNT` returns the total number of rows updated.  
- An exception handler sets `p_updated_count` to -1 to indicate an error.

**Testing the Procedure:**

```sql
DECLARE
    v_emp_ids num_array := num_array(1001, 1002, 1003);
    v_count   NUMBER;
BEGIN
    bulk_update_salary(v_emp_ids, 10, v_count);
    DBMS_OUTPUT.PUT_LINE('Number of employees updated: ' || v_count);
END;
/
```

---

## 5. Trigger for Logging Employee Updates

**Question:**  
Create a trigger named `emp_salary_log_trg` on the `employees` table. The trigger should fire after any update on the salary column. Insert a log record into an `emp_salary_log` table capturing the employee ID, old salary, new salary, and the update date.

**Solution:**

### Step 1: Create the Log Table

```sql
CREATE TABLE emp_salary_log (
    log_id       NUMBER GENERATED BY DEFAULT AS IDENTITY,
    employee_id  NUMBER,
    old_salary   NUMBER,
    new_salary   NUMBER,
    update_date  DATE DEFAULT SYSDATE
);
```

### Step 2: Create the Trigger

```sql
CREATE OR REPLACE TRIGGER emp_salary_log_trg
AFTER UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    INSERT INTO emp_salary_log (employee_id, old_salary, new_salary, update_date)
    VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary, SYSDATE);
END;
/
```

**Explanation:**  
- The trigger is defined to fire after any update to the `salary` column of the `employees` table.  
- The `:OLD` and `:NEW` qualifiers capture the values before and after the update, respectively.  
- A record is inserted into `emp_salary_log` for every salary update.

**Testing the Trigger:**

```sql
-- Update an employee’s salary to test the trigger
UPDATE employees
SET salary = salary * 1.05
WHERE employee_id = 1001;

-- Verify the log entry:
SELECT * FROM emp_salary_log WHERE employee_id = 1001;
```

---

### Final Notes

- **Practice & Experimentation:**  
  Work through these examples, modifying them to fit your own schema or business rules. Experiment with error handling and edge cases to deepen your understanding.

- **Best Practices:**  
  Include proper exception handling, use meaningful messages, and test each block in a controlled environment.

By exploring these diverse PL/SQL concepts—functions, cursors, packages, bulk processing, and triggers—you will build a solid foundation for writing robust and efficient database applications. Happy coding!



Below is a comprehensive set of questions designed to cover a wide range of PL/SQL concepts. These questions span from basic procedure and function creation to more advanced topics such as packages, dynamic SQL, bulk processing, cursors, collections, exception handling, recursion, and triggers. Use these challenges to test and extend your understanding of PL/SQL.

---

### 1. Basic Procedure with Exception Handling
**Question:**  
Create a procedure named `insert_product` that inserts a new product record into a table named `products` (with columns like `product_id`, `product_name`, and `price`).  
- The procedure should accept the product details as parameters.  
- It should check for a duplicate `product_id` and, if found, raise a user-defined exception with an appropriate error message via an OUT parameter.  
- Otherwise, it should insert the record and return a success message.

---

### 2. Procedure with Boolean Logic and Conversion
**Question:**  
Develop a procedure named `record_attendance` that accepts a student’s ID, attendance date, and a Boolean parameter indicating presence.  
- Internally, convert the Boolean to a character value (e.g., `'P'` for present, `'A'` for absent) before inserting the record into an `attendance` table.  
- Provide appropriate exception handling if the record already exists or if there is any error during insertion.

---

### 3. Recursive Function for Calculations
**Question:**  
Write a recursive function called `compute_factorial` that calculates the factorial of a given positive integer.  
- The function should return `1` if the input is less than or equal to 1, and otherwise return the factorial result.  
- Add error handling to manage unexpected inputs or errors.

---

### 4. Using Implicit Cursors for Data Retrieval
**Question:**  
Write an anonymous PL/SQL block that uses an implicit cursor to retrieve all rows from an `employees` table (assume columns like `employee_id`, `first_name`, `last_name`, and `department`).  
- For each record retrieved, display the employee's details using `DBMS_OUTPUT.PUT_LINE`.

---

### 5. Package Creation for Business Logic
**Question:**  
Create a PL/SQL package named `hr_pkg` that includes:  
- A procedure `hire_employee` that inserts a new employee record into an `employees` table, ensuring no duplicate employee IDs.  
- A function `calculate_bonus` that accepts an employee ID and returns the bonus amount based on the employee’s current salary.  
- Include proper exception handling in both the package specification and body.

---

### 6. Bulk Processing with Collections and FORALL
**Question:**  
Write a procedure called `bulk_update_prices` that accepts a collection of product IDs and a percentage change.  
- Use a collection type (e.g., a nested table of numbers) to store the product IDs.  
- Use the `FORALL` construct to update the prices of all listed products in the `products` table.  
- Return the number of records updated via an OUT parameter.

---

### 7. Dynamic SQL and Metadata Querying
**Question:**  
Create a procedure named `create_table_if_missing` that takes a table name as a parameter.  
- The procedure should check if the specified table exists in the schema using dynamic SQL.  
- If the table does not exist, create it with a simple structure (for example, two columns: `id` and `data`).  
- Ensure proper exception handling so that no errors are raised if the table already exists.

---

### 8. Exception Handling and Logging in a Trigger
**Question:**  
Design a trigger called `log_employee_deletions` on the `employees` table that fires after a deletion.  
- The trigger should insert a log record into an `employee_deletion_log` table capturing the deleted `employee_id`, the deletion timestamp, and a custom message.  
- Ensure that any errors during logging are handled gracefully.

---

### 9. Combining Cursors with Collections
**Question:**  
Write a procedure named `collect_department_employees` that accepts a department name and returns a collection of employee names working in that department.  
- Define a collection type (for example, a nested table of VARCHAR2).  
- Use an explicit cursor to loop through the `employees` table and populate the collection.  
- Finally, output the employee names via a loop that iterates over the collection.

---

### 10. Advanced Exception Handling in Nested Blocks
**Question:**  
Develop an anonymous PL/SQL block that demonstrates nested exception handling.  
- The block should simulate two operations: a division (which could lead to a divide-by-zero error) and an update to a table (which might fail if the record is missing).  
- Use nested `BEGIN...EXCEPTION...END;` blocks to handle errors at different levels, and output distinct messages for each error case.

---

These questions cover a broad spectrum of PL/SQL capabilities. As you attempt each one, remember to:
- Define clear parameter modes (IN, OUT, IN OUT) as needed.
- Use proper exception handling to manage both expected and unexpected errors.
- Test your procedures and functions with anonymous PL/SQL blocks.
- Consider edge cases and validate inputs to make your code robust.

Happy coding and exploration of PL/SQL!



*/