# PL/SQL Control Structures

## 1. Conditional Statements

### IF-THEN-ELSIF-ELSE
```sql
DECLARE
    v_grade CHAR(1) := 'B';
    v_result VARCHAR2(20);
BEGIN
    IF v_grade = 'A' THEN
        v_result := 'Excellent';
    ELSIF v_grade = 'B' THEN
        v_result := 'Good';
    ELSIF v_grade = 'C' THEN
        v_result := 'Fair';
    ELSE
        v_result := 'Poor';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
END;
/
```

### CASE Statement
```sql
DECLARE
    v_grade CHAR(1) := 'B';
    v_result VARCHAR2(20);
BEGIN
    CASE v_grade
        WHEN 'A' THEN v_result := 'Excellent';
        WHEN 'B' THEN v_result := 'Good';
        WHEN 'C' THEN v_result := 'Fair';
        ELSE v_result := 'Poor';
    END CASE;
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
END;
/
```

### CASE Expression
```sql
DECLARE
    v_grade CHAR(1) := 'B';
    v_result VARCHAR2(20);
BEGIN
    v_result := CASE v_grade
        WHEN 'A' THEN 'Excellent'
        WHEN 'B' THEN 'Good'
        WHEN 'C' THEN 'Fair'
        ELSE 'Poor'
    END;
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
END;
/
```

## 2. Loop Structures

### Basic LOOP
```sql
DECLARE
    v_counter NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('Counter: ' || v_counter);
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 5;
    END LOOP;
END;
/
```

### WHILE LOOP
```sql
DECLARE
    v_counter NUMBER := 1;
BEGIN
    WHILE v_counter <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE('Counter: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;
END;
/
```

### FOR LOOP
```sql
BEGIN
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('Counter: ' || i);
    END LOOP;
END;
/
```

### Reverse FOR LOOP
```sql
BEGIN
    FOR i IN REVERSE 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('Counter: ' || i);
    END LOOP;
END;
/
```

## 3. Control Statements

### CONTINUE Statement
```sql
BEGIN
    FOR i IN 1..5 LOOP
        -- Skip even numbers
        IF MOD(i, 2) = 0 THEN
            CONTINUE;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Odd number: ' || i);
    END LOOP;
END;
/
```

### GOTO Statement
```sql
DECLARE
    v_total NUMBER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        v_total := v_total + i;
        IF v_total > 20 THEN
            GOTO end_loop;
        END IF;
    END LOOP;
    
    <<end_loop>>
    DBMS_OUTPUT.PUT_LINE('Final total: ' || v_total);
END;
/
```

## Practice Exercises

1. Write a program using IF statements to determine if a number is positive, negative, or zero
2. Create a CASE statement to convert number grades (1-5) to letter grades (A-F)
3. Write a program using each type of loop to calculate the sum of numbers from 1 to 10
4. Create a nested loop structure to create a multiplication table (1-5)

## Solutions

### Exercise 1: Number Classification
```sql
DECLARE
    v_number NUMBER := &input_number;
BEGIN
    IF v_number > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Positive number');
    ELSIF v_number < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Negative number');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zero');
    END IF;
END;
/
```

### Exercise 2: Grade Conversion
```sql
DECLARE
    v_number_grade NUMBER := &grade;
    v_letter_grade CHAR(1);
BEGIN
    v_letter_grade := CASE v_number_grade
        WHEN 5 THEN 'A'
        WHEN 4 THEN 'B'
        WHEN 3 THEN 'C'
        WHEN 2 THEN 'D'
        ELSE 'F'
    END;
    
    DBMS_OUTPUT.PUT_LINE('Letter Grade: ' || v_letter_grade);
END;
/
```

### Exercise 3: Sum Using Different Loops
```sql
DECLARE
    v_sum1 NUMBER := 0;
    v_sum2 NUMBER := 0;
    v_sum3 NUMBER := 0;
    v_counter NUMBER := 1;
BEGIN
    -- Using WHILE loop
    WHILE v_counter <= 10 LOOP
        v_sum1 := v_sum1 + v_counter;
        v_counter := v_counter + 1;
    END LOOP;
    
    -- Using FOR loop
    FOR i IN 1..10 LOOP
        v_sum2 := v_sum2 + i;
    END LOOP;
    
    -- Using basic LOOP
    v_counter := 1;
    LOOP
        v_sum3 := v_sum3 + v_counter;
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 10;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Sum using WHILE: ' || v_sum1);
    DBMS_OUTPUT.PUT_LINE('Sum using FOR: ' || v_sum2);
    DBMS_OUTPUT.PUT_LINE('Sum using basic LOOP: ' || v_sum3);
END;
/
```

### Exercise 4: Multiplication Table
```sql
BEGIN
    FOR i IN 1..5 LOOP
        FOR j IN 1..5 LOOP
            DBMS_OUTPUT.PUT_LINE(i || ' x ' || j || ' = ' || (i*j));
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('-------------------');
    END LOOP;
END;
/
```

## Key Points to Remember

1. Always use proper indentation for better code readability
2. Choose the appropriate control structure for your needs:
   - IF-THEN for simple conditions
   - CASE for multiple conditions on the same variable
   - WHILE LOOP when number of iterations is unknown
   - FOR LOOP when number of iterations is known
3. Use EXIT WHEN instead of IF-EXIT for cleaner code
4. Avoid overuse of GOTO statements
5. Consider using CONTINUE instead of nested IF statements

## Next Steps

After mastering control structures:
1. Practice combining different control structures
2. Create more complex programs using nested structures
3. Move on to SQL in PL/SQL in the next section 