/*Below are sample PL/SQL solutions for each exercise from the document, with plenty of inline comments so you can follow the logic and learn good commenting practices.

─────────────────────────────
Question 1: VAT Calculation Procedure for RRA
─────────────────────────────

/*This procedure accepts a transaction amount, calculates the VAT at a fixed 18% rate, and returns both the VAT and the final amount.*/
CREATE OR REPLACE PROCEDURE Calculate_VAT (
    total_amount IN NUMBER,    -- Input: total transaction amount
    vat OUT NUMBER,            -- Output: calculated VAT amount
    final_amount OUT NUMBER    -- Output: final amount after adding VAT
) AS
    -- Define a constant for the VAT rate (18%)
    VAT_RATE CONSTANT NUMBER := 0.18;
    -- Local variable to hold the computed VAT value
    temp_vat NUMBER;
BEGIN
    -- Calculate VAT by multiplying the total amount by the VAT rate
    temp_vat := total_amount * VAT_RATE;
    
    -- Set the output parameters
    vat := temp_vat;
    final_amount := total_amount + temp_vat;
    
    -- Display the results using DBMS_OUTPUT for verification
    DBMS_OUTPUT.PUT_LINE('VAT: ' || vat || ', Final Amount: ' || final_amount);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Calculate_VAT: ' || SQLERRM);
END Calculate_VAT;
/
/*
─────────────────────────────
Question 2: Employee Bonus Calculation
─────────────────────────────

This procedure calculates a bonus based on the employee’s performance rating: 20% for ‘A’, 10% for ‘B’, and 5% for ‘C’.
*/
CREATE OR REPLACE PROCEDURE Calculate_Bonus (
    p_employee_id IN NUMBER,   -- Employee ID (for logging purposes)
    p_salary IN NUMBER,        -- Input: employee's salary
    p_rating IN CHAR,          -- Input: performance rating ('A', 'B', 'C')
    p_bonus OUT NUMBER         -- Output: calculated bonus
) AS
BEGIN
    -- Use UPPER to handle lowercase inputs and calculate bonus accordingly
    IF UPPER(p_rating) = 'A' THEN
        p_bonus := p_salary * 0.20;  -- 20% bonus for rating A
    ELSIF UPPER(p_rating) = 'B' THEN
        p_bonus := p_salary * 0.10;  -- 10% bonus for rating B
    ELSIF UPPER(p_rating) = 'C' THEN
        p_bonus := p_salary * 0.05;  -- 5% bonus for rating C
    ELSE
        -- If the rating does not match, assign a bonus of zero
        p_bonus := 0;
    END IF;
    
    -- Display bonus for the given employee
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || p_employee_id || ' Bonus: ' || p_bonus);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Calculate_Bonus: ' || SQLERRM);
END Calculate_Bonus;
/
/*
─────────────────────────────
Question 3: Customer Discount Calculation
─────────────────────────────

This procedure applies a discount based on the purchase amount:
– 10% if greater than 100,000 RWF,
– 5% if between 50,000 and 100,000 RWF,
– 0% if below 50,000 RWF.
*/
CREATE OR REPLACE PROCEDURE Calculate_Discount (
    p_purchase_amount IN NUMBER,  -- Input: total purchase amount
    p_discount OUT NUMBER,        -- Output: calculated discount amount
    p_final_amount OUT NUMBER     -- Output: final amount after discount
) AS
BEGIN
    -- Apply discount rules based on purchase amount
    IF p_purchase_amount > 100000 THEN
        p_discount := p_purchase_amount * 0.10;  -- 10% discount
    ELSIF p_purchase_amount BETWEEN 50000 AND 100000 THEN
        p_discount := p_purchase_amount * 0.05;   -- 5% discount
    ELSE
        p_discount := 0;                          -- No discount
    END IF;
    
    -- Calculate the final amount after discount
    p_final_amount := p_purchase_amount - p_discount;
    
    -- Output the results
    DBMS_OUTPUT.PUT_LINE('Discount: ' || p_discount || ', Final Amount: ' || p_final_amount);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Calculate_Discount: ' || SQLERRM);
END Calculate_Discount;
/
/*
─────────────────────────────
Question 4: Student Grade Calculation
─────────────────────────────

This procedure calculates the average of three subject marks to determine a student’s final grade.
*/
CREATE OR REPLACE PROCEDURE Calculate_Grade (
    p_math IN NUMBER,          -- Input: Math mark
    p_science IN NUMBER,       -- Input: Science mark
    p_english IN NUMBER,       -- Input: English mark
    p_final_grade OUT NUMBER   -- Output: calculated average grade
) AS
BEGIN
    -- Compute the average of the three marks
    p_final_grade := (p_math + p_science + p_english) / 3;
    
    -- Display the final grade
    DBMS_OUTPUT.PUT_LINE('Final Grade: ' || p_final_grade);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Calculate_Grade: ' || SQLERRM);
END Calculate_Grade;
/
/*
─────────────────────────────
Question 5: Product Price Update
─────────────────────────────

This procedure updates the price of a product in the products table by applying a percentage increase. (Assumes a table named PRODUCTS with columns PRODUCT_ID and PRICE.)
*/
CREATE OR REPLACE PROCEDURE Update_Product_Price (
    p_product_id IN NUMBER,          -- Input: product identifier
    p_percentage_increase IN NUMBER, -- Input: percentage increase (e.g., 15 for 15%)
    p_updated_price OUT NUMBER       -- Output: updated product price
) AS
BEGIN
    -- Update the product's price by applying the percentage increase
    UPDATE products
    SET price = price * (1 + p_percentage_increase / 100)
    WHERE product_id = p_product_id;
    
    -- Retrieve the updated price from the table
    SELECT price INTO p_updated_price 
    FROM products 
    WHERE product_id = p_product_id;
    
    -- Display the updated price
    DBMS_OUTPUT.PUT_LINE('Updated Price for Product ' || p_product_id || ': ' || p_updated_price);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No product found with ID ' || p_product_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Update_Product_Price: ' || SQLERRM);
END Update_Product_Price;
/
/*
─────────────────────────────
Question 6: Employee Salary Increment
─────────────────────────────

This procedure increments an employee’s salary based on their years of service. (Assumes an EMPLOYEES table with columns EMPLOYEE_ID and SALARY.)
*/
CREATE OR REPLACE PROCEDURE Increment_Salary (
    p_employee_id IN NUMBER,    -- Input: employee identifier
    p_years_of_service IN NUMBER,  -- Input: number of years the employee has served
    p_updated_salary OUT NUMBER -- Output: updated salary after increment
) AS
    v_increment NUMBER;         -- Local variable to hold the increment percentage
BEGIN
    -- Determine the increment rate based on years of service
    IF p_years_of_service > 10 THEN
        v_increment := 0.15;   -- 15% increment for more than 10 years
    ELSIF p_years_of_service BETWEEN 5 AND 10 THEN
        v_increment := 0.10;   -- 10% increment for 5-10 years
    ELSE
        v_increment := 0.05;   -- 5% increment for less than 5 years
    END IF;
    
    -- Update the employee's salary in the EMPLOYEES table
    UPDATE employees
    SET salary = salary * (1 + v_increment)
    WHERE employee_id = p_employee_id;
    
    -- Retrieve the updated salary
    SELECT salary INTO p_updated_salary 
    FROM employees 
    WHERE employee_id = p_employee_id;
    
    -- Output the updated salary
    DBMS_OUTPUT.PUT_LINE('Updated Salary for Employee ' || p_employee_id || ': ' || p_updated_salary);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee found with ID ' || p_employee_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Increment_Salary: ' || SQLERRM);
END Increment_Salary;
/
/*
─────────────────────────────
Question 7: Order Total Calculation
─────────────────────────────

This procedure calculates the total order cost by adding a shipping fee. A shipping fee of 5,000 RWF is applied for orders below 50,000 RWF; orders of 50,000 RWF or more get free shipping.
*/
CREATE OR REPLACE PROCEDURE Calculate_Order_Total (
    p_order_amount IN NUMBER,   -- Input: amount of the order
    p_total_cost OUT NUMBER     -- Output: total cost including shipping fee
) AS
    v_shipping_fee NUMBER;       -- Local variable for the shipping fee
BEGIN
    -- Determine shipping fee based on the order amount
    IF p_order_amount < 50000 THEN
        v_shipping_fee := 5000;
    ELSE
        v_shipping_fee := 0;
    END IF;
    
    -- Calculate the total cost
    p_total_cost := p_order_amount + v_shipping_fee;
    
    -- Display the total order cost
    DBMS_OUTPUT.PUT_LINE('Total Order Cost: ' || p_total_cost);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Calculate_Order_Total: ' || SQLERRM);
END Calculate_Order_Total;
/
/*
─────────────────────────────
Question 8: Loan Interest Calculation
─────────────────────────────

This procedure calculates simple interest based on the principal amount, interest rate, and loan duration (in years).
*/

CREATE OR REPLACE PROCEDURE Calculate_Loan_Interest (
    p_principal IN NUMBER,  -- Input: principal loan amount
    p_rate IN NUMBER,       -- Input: interest rate (as a decimal, e.g., 0.08 for 8%)
    p_duration IN NUMBER,   -- Input: loan duration in years
    p_interest OUT NUMBER   -- Output: calculated interest
) AS
BEGIN
    -- Calculate interest using the simple interest formula: Principal * Rate * Time
    p_interest := p_principal * p_rate * p_duration;
    
    -- Display the calculated interest
    DBMS_OUTPUT.PUT_LINE('Calculated Interest: ' || p_interest);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Calculate_Loan_Interest: ' || SQLERRM);
END Calculate_Loan_Interest;
/
/*
─────────────────────────────
Question 9: Customer Age Verification
─────────────────────────────

This procedure verifies whether a customer is at least 18 years old based on their date of birth.
*/
CREATE OR REPLACE PROCEDURE Verify_Age (
    p_dob IN DATE,            -- Input: customer's date of birth
    p_message OUT VARCHAR2    -- Output: eligibility message
) AS
    v_age NUMBER;             -- Local variable to hold the calculated age
BEGIN
    -- Calculate age in years using months_between and truncating the result
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    
    -- Check if the customer meets the age requirement for registration
    IF v_age >= 18 THEN
        p_message := 'Customer is eligible for registration. Age: ' || v_age;
    ELSE
        p_message := 'Customer is NOT eligible for registration. Age: ' || v_age;
    END IF;
    
    -- Display the eligibility message
    DBMS_OUTPUT.PUT_LINE(p_message);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Verify_Age: ' || SQLERRM);
END Verify_Age;
/
/*
─────────────────────────────
Question 10: Employee Retirement Eligibility
─────────────────────────────

This procedure checks if an employee is eligible for retirement (defined as age 60 or above) based on their date of birth.
*/
CREATE OR REPLACE PROCEDURE Check_Retirement_Eligibility (
    p_dob IN DATE,           -- Input: employee's date of birth
    p_message OUT VARCHAR2   -- Output: retirement eligibility message
) AS
    v_age NUMBER;            -- Local variable for employee's age
BEGIN
    -- Calculate the employee's age
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    
    -- Determine retirement eligibility based on age
    IF v_age >= 60 THEN
        p_message := 'Employee is eligible for retirement. Age: ' || v_age;
    ELSE
        p_message := 'Employee is NOT eligible for retirement. Age: ' || v_age;
    END IF;
    
    -- Output the eligibility message
    DBMS_OUTPUT.PUT_LINE(p_message);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Check_Retirement_Eligibility: ' || SQLERRM);
END Check_Retirement_Eligibility;
/
/*
─────────────────────────────
Question 11a: Fetch and Display Employee Details
─────────────────────────────

This anonymous PL/SQL block retrieves and displays details for an employee (with employee_id = 3) from the EMPLOYEES table using a record declared with %ROWTYPE.
*/
DECLARE
    -- Declare a record variable that matches the structure of the EMPLOYEES table row
    v_employee employees%ROWTYPE;
BEGIN
    -- Retrieve employee details for employee_id = 3 into the record variable
    SELECT employee_id, first_name, last_name, salary, hire_date
      INTO v_employee
      FROM employees
     WHERE employee_id = 3;
     
    -- Display the employee details using DBMS_OUTPUT.PUT_LINE
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee.employee_id);
    DBMS_OUTPUT.PUT_LINE('First Name: ' || v_employee.first_name);
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || v_employee.last_name);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_employee.salary);
    DBMS_OUTPUT.PUT_LINE('Hire Date: ' || TO_CHAR(v_employee.hire_date, 'DD-MON-YYYY'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee found with ID 3.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error fetching employee details: ' || SQLERRM);
END;
/
/*
─────────────────────────────
Question 11b: Insurance Company Eligibility Check
─────────────────────────────

This anonymous PL/SQL block calculates the age of a policyholder (using a fixed DOB of January 1, 1960) and determines if they are eligible for an insurance benefit (eligibility if age is 60 or older).
*/
DECLARE
    -- Define the policyholder's date of birth
    v_dob DATE := TO_DATE('01-JAN-1960', 'DD-MON-YYYY');
    v_age NUMBER;            -- Variable to store calculated age
    v_message VARCHAR2(100); -- Variable to store the eligibility message
BEGIN
    -- Calculate the age in years
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, v_dob) / 12);
    
    -- Check eligibility: age 60 or older qualifies
    IF v_age >= 60 THEN
        v_message := 'Eligible for insurance benefit. Age: ' || v_age;
    ELSE
        v_message := 'Not eligible for insurance benefit. Age: ' || v_age;
    END IF;
    
    -- Output the eligibility message
    DBMS_OUTPUT.PUT_LINE(v_message);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in insurance eligibility check: ' || SQLERRM);
END;
/

-- Each solution is carefully commented so that you can see what every section does—from variable declarations and calculations to error handling and output via DBMS_OUTPUT. You can adjust table names, column names, or logic as needed for your environment. Happy coding and learning PL/SQL!