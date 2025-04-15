-- =============================================
-- Dynamic SQL and Performance Optimization
-- =============================================

/*
Section 1: Dynamic SQL
Purpose: Execute SQL statements constructed at runtime
Benefits:
- Flexible query construction
- Reusable code
- Dynamic object names
- Runtime binding
*/

-- 1.1 Basic Dynamic SQL
-- --------------------
-- Purpose: Demonstrate simple dynamic SQL execution
-- Use Case: Generic queries with variable table names
CREATE OR REPLACE PROCEDURE dynamic_query(
    p_table_name IN VARCHAR2,
    p_where_clause IN VARCHAR2 DEFAULT NULL
) IS
    v_sql VARCHAR2(4000);
    v_columns VARCHAR2(4000);
    TYPE t_refcursor IS REF CURSOR;
    v_result_set t_refcursor;
    v_column_value VARCHAR2(4000);
BEGIN
    -- Get column list dynamically
    SELECT LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_id)
    INTO v_columns
    FROM user_tab_columns
    WHERE table_name = UPPER(p_table_name);
    
    -- Construct SQL dynamically
    v_sql := 'SELECT ' || v_columns || ' FROM ' || p_table_name;
    IF p_where_clause IS NOT NULL THEN
        v_sql := v_sql || ' WHERE ' || p_where_clause;
    END IF;
    
    -- Execute and process results
    DBMS_OUTPUT.PUT_LINE('Executing: ' || v_sql);
    
    -- Log execution plan for performance monitoring
    execute_with_plan(v_sql);
END;
/

-- 1.2 Advanced Dynamic PL/SQL
-- --------------------------
-- Purpose: Dynamic PL/SQL block execution
-- Use Case: Flexible procedure calls and business logic
CREATE OR REPLACE PROCEDURE execute_dynamic_plsql(
    p_proc_name IN VARCHAR2,
    p_params IN VARCHAR2
) IS
    v_plsql_block VARCHAR2(32767);
    v_param_list VARCHAR2(4000);
BEGIN
    -- Build parameter list
    SELECT LISTAGG(param_name || ' => ' || param_value, ', ')
    INTO v_param_list
    FROM table(parse_params(p_params));
    
    -- Construct PL/SQL block
    v_plsql_block := '
    DECLARE
        -- Runtime variable declarations
        v_start_time TIMESTAMP := SYSTIMESTAMP;
    BEGIN
        -- Execute procedure with parameters
        ' || p_proc_name || '(' || v_param_list || ');
        
        -- Log execution time
        log_execution_time(
            ''' || p_proc_name || ''',
            EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time))
        );
    END;';
    
    -- Execute dynamic PL/SQL
    EXECUTE IMMEDIATE v_plsql_block;
END;
/

/*
Section 2: Performance Optimization
Purpose: Improve execution speed and resource usage
Benefits:
- Faster query execution
- Reduced resource consumption
- Better scalability
*/

-- 2.1 Bulk Operations
-- ------------------
-- Purpose: Optimize DML operations using bulk processing
CREATE OR REPLACE PROCEDURE bulk_salary_update(
    p_department_id IN NUMBER,
    p_increase_percent IN NUMBER
) IS
    -- Types for bulk processing
    TYPE t_emp_ids IS TABLE OF employees.employee_id%TYPE;
    TYPE t_salaries IS TABLE OF employees.salary%TYPE;
    
    -- Collections for bulk operations
    v_emp_ids t_emp_ids;
    v_old_salaries t_salaries;
    v_new_salaries t_salaries;
    
    -- Constants for batch size
    c_batch_size CONSTANT PLS_INTEGER := 100;
    
    -- Performance monitoring
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    -- Bulk collect employee data
    SELECT employee_id, salary BULK COLLECT 
    INTO v_emp_ids, v_old_salaries
    FROM employees
    WHERE department_id = p_department_id;
    
    -- Calculate new salaries
    v_new_salaries := t_salaries();
    v_new_salaries.EXTEND(v_emp_ids.COUNT);
    
    -- Array processing for calculations
    FOR i IN 1..v_emp_ids.COUNT LOOP
        v_new_salaries(i) := v_old_salaries(i) * (1 + p_increase_percent/100);
    END LOOP;
    
    -- Bulk update in batches
    FOR i IN 0..TRUNC((v_emp_ids.COUNT-1)/c_batch_size) LOOP
        FORALL j IN (i*c_batch_size+1)..LEAST((i+1)*c_batch_size, v_emp_ids.COUNT)
            UPDATE employees
            SET salary = v_new_salaries(j)
            WHERE employee_id = v_emp_ids(j);
            
        -- Commit each batch
        COMMIT;
    END LOOP;
    
    -- Log performance metrics
    v_end_time := SYSTIMESTAMP;
    log_performance_metrics(
        p_procedure_name => 'bulk_salary_update',
        p_records_processed => v_emp_ids.COUNT,
        p_execution_time => EXTRACT(SECOND FROM (v_end_time - v_start_time))
    );
END;
/

-- 2.2 Result Cache
-- --------------
-- Purpose: Cache frequently accessed data
-- Use Case: Lookup tables and reference data
CREATE OR REPLACE FUNCTION get_department_budget(
    p_dept_id IN NUMBER
) RETURN NUMBER
    RESULT_CACHE RELIES_ON (departments, employees)
IS
    v_budget NUMBER;
BEGIN
    SELECT SUM(salary) INTO v_budget
    FROM employees
    WHERE department_id = p_dept_id;
    
    RETURN v_budget;
END;
/

-- 2.3 Parallel Execution
-- --------------------
-- Purpose: Utilize parallel processing for large datasets
CREATE OR REPLACE PROCEDURE parallel_data_analysis(
    p_as_of_date IN DATE
) IS
    -- Parallel hint for large table scan
    v_sql VARCHAR2(32767) := '
    INSERT /*+ PARALLEL(8) */ INTO employee_stats (
        analysis_date,
        department_id,
        emp_count,
        total_salary,
        avg_salary,
        salary_stddev
    )
    SELECT
        :1 as analysis_date,
        department_id,
        COUNT(*) as emp_count,
        SUM(salary) as total_salary,
        AVG(salary) as avg_salary,
        STDDEV(salary) as salary_stddev
    FROM employees
    GROUP BY department_id';
BEGIN
    -- Execute parallel query
    EXECUTE IMMEDIATE v_sql USING p_as_of_date;
    
    -- Update statistics
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname => USER,
        tabname => 'EMPLOYEE_STATS',
        estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
        degree => DBMS_STATS.AUTO_DEGREE
    );
END;
/

/*
Section 3: Performance Monitoring
Purpose: Track and analyze execution performance
Benefits:
- Identify bottlenecks
- Optimize resource usage
- Trend analysis
*/

-- 3.1 Execution Statistics Package
-- -----------------------------
CREATE OR REPLACE PACKAGE performance_stats IS
    -- Record execution metrics
    PROCEDURE record_execution(
        p_module_name IN VARCHAR2,
        p_execution_time IN NUMBER,
        p_rows_processed IN NUMBER,
        p_cpu_time IN NUMBER DEFAULT NULL
    );
    
    -- Get performance report
    FUNCTION get_performance_report(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR;
END performance_stats;
/

-- Implementation with detailed stats collection
CREATE OR REPLACE PACKAGE BODY performance_stats IS
    PROCEDURE record_execution(
        p_module_name IN VARCHAR2,
        p_execution_time IN NUMBER,
        p_rows_processed IN NUMBER,
        p_cpu_time IN NUMBER DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO execution_stats (
            module_name,
            execution_time,
            rows_processed,
            cpu_time,
            execution_date,
            session_id,
            instance_id
        ) VALUES (
            p_module_name,
            p_execution_time,
            p_rows_processed,
            p_cpu_time,
            SYSTIMESTAMP,
            SYS_CONTEXT('USERENV', 'SID'),
            SYS_CONTEXT('USERENV', 'INSTANCE')
        );
        
        COMMIT;
    END record_execution;
    
    FUNCTION get_performance_report(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR IS
        v_result SYS_REFCURSOR;
    BEGIN
        OPEN v_result FOR
            SELECT 
                module_name,
                COUNT(*) as execution_count,
                AVG(execution_time) as avg_execution_time,
                MAX(execution_time) as max_execution_time,
                MIN(execution_time) as min_execution_time,
                STDDEV(execution_time) as time_stddev,
                SUM(rows_processed) as total_rows_processed
            FROM execution_stats
            WHERE TRUNC(execution_date) BETWEEN p_start_date AND p_end_date
            GROUP BY module_name
            ORDER BY avg_execution_time DESC;
            
        RETURN v_result;
    END get_performance_report;
END performance_stats;
/