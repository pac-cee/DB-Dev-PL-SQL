# PL/SQL Basic Blocks

## Introduction to PL/SQL Blocks

A PL/SQL block is the basic unit of a PL/SQL program. Every PL/SQL program consists of blocks that can be nested within each other.

### Block Structure

```sql
DECLARE
    -- Declaration section (Optional)
    -- Variables, cursors, user-defined types
BEGIN
    -- Executable section (Mandatory)
    -- PL/SQL statements
EXCEPTION
    -- Exception section (Optional)
    -- Error handling
END;
/
```

## Types of Blocks

1. **Anonymous Blocks**
   - Not stored in the database
   - Executed at runtime
   - Cannot be reused

2. **Named Blocks**
   - Procedures
   - Functions
   - Packages
   - Triggers

## Examples

### 1. Simple Anonymous Block
```sql
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello, World!');
END;
/
```

### 2. Block with Declarations
```sql
DECLARE
    v_message VARCHAR2(100) := 'Welcome to PL/SQL!';
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/
```

### 3. Block with Exception Handling
```sql
DECLARE
    v_result NUMBER;
BEGIN
    v_result := 10/0;  -- This will raise an exception
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Cannot divide by zero!');
END;
/
```

## Practice Exercises

1. Create a simple anonymous block that prints "I am learning PL/SQL"
2. Create a block that declares two numbers and prints their sum
3. Create a block that handles both ZERO_DIVIDE and VALUE_ERROR exceptions

## Solutions

### Exercise 1
```sql
BEGIN
    DBMS_OUTPUT.PUT_LINE('I am learning PL/SQL');
END;
/
```

### Exercise 2
```sql
DECLARE
    v_num1 NUMBER := 10;
    v_num2 NUMBER := 20;
    v_sum  NUMBER;
BEGIN
    v_sum := v_num1 + v_num2;
    DBMS_OUTPUT.PUT_LINE('The sum is: ' || v_sum);
END;
/
```

### Exercise 3
```sql
DECLARE
    v_result NUMBER;
BEGIN
    v_result := 10/0;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Cannot divide by zero!');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid number operation!');
END;
/
```

## Key Points to Remember

1. Every PL/SQL block must have a BEGIN and END
2. The DECLARE section is optional
3. The EXCEPTION section is optional
4. Statements within blocks must end with a semicolon (;)
5. The entire block must be terminated with a forward slash (/) when executing in SQL*Plus or SQL Developer

## Next Steps

Once you're comfortable with basic blocks:
1. Practice creating different types of blocks
2. Experiment with nested blocks
3. Move on to Variables and Data Types in the next section 