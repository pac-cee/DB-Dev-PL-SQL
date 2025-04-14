-- Installation Script for Smart Bus Booking System
-- Created: April 14, 2025

-- Start with a clean slate
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;
SET ECHO ON;

PROMPT Installing Smart Bus Booking System...

PROMPT Creating tables and sequences...
@@01_create_tables.sql

PROMPT Creating booking management procedures...
@@02_booking_procedures.sql

PROMPT Creating schedule management procedures...
@@03_schedule_procedures.sql

PROMPT Creating user management procedures...
@@04_user_procedures.sql

PROMPT Loading sample data...
@@05_sample_data.sql

PROMPT Creating utility functions and views...
@@06_utility_functions.sql

PROMPT Installation complete.
PROMPT 
PROMPT To verify the installation, you can run the following tests:
PROMPT 1. Select from daily_booking_summary view
PROMPT 2. Check bus_performance_metrics view
PROMPT 3. Try booking_mgmt.create_booking procedure
PROMPT 4. Query available schedules using schedule_mgmt.get_available_schedules
PROMPT
PROMPT Example usage:
PROMPT SELECT * FROM daily_booking_summary WHERE travel_date = TRUNC(SYSDATE);
PROMPT SELECT * FROM bus_performance_metrics ORDER BY total_bookings DESC;

SET ECHO OFF;
SET FEEDBACK OFF;

DECLARE
    v_count NUMBER;
BEGIN
    -- Verify tables
    SELECT COUNT(*) INTO v_count FROM user_tables 
    WHERE table_name IN ('USERS', 'BUS_TERMINALS', 'BUSES', 'ROUTES', 'SCHEDULES', 'BOOKINGS');
    
    IF v_count = 6 THEN
        DBMS_OUTPUT.PUT_LINE('Tables created successfully.');
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Not all tables were created properly.');
    END IF;
    
    -- Verify packages
    SELECT COUNT(*) INTO v_count FROM user_objects 
    WHERE object_type = 'PACKAGE' 
    AND object_name IN ('BOOKING_MGMT', 'SCHEDULE_MGMT', 'USER_MGMT', 'BOOKING_UTILS');
    
    IF v_count = 4 THEN
        DBMS_OUTPUT.PUT_LINE('Packages created successfully.');
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Not all packages were created properly.');
    END IF;
    
    -- Verify views
    SELECT COUNT(*) INTO v_count FROM user_views
    WHERE view_name IN ('DAILY_BOOKING_SUMMARY', 'BUS_PERFORMANCE_METRICS');
    
    IF v_count = 2 THEN
        DBMS_OUTPUT.PUT_LINE('Views created successfully.');
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Not all views were created properly.');
    END IF;
    
    -- Verify sample data
    SELECT COUNT(*) INTO v_count FROM users;
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Sample data loaded successfully.');
    ELSE
        RAISE_APPLICATION_ERROR(-20004, 'Sample data was not loaded properly.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Installation verification complete.');
    DBMS_OUTPUT.PUT_LINE('The Smart Bus Booking System is ready to use.');
END;
/