-- MySQL Connection Configuration
DELIMITER //

-- Create a procedure to establish connection
CREATE PROCEDURE establish_connection()
BEGIN
    SET @connection_host = 'localhost';
    SET @connection_port = 3306;
    SET @connection_user = 'root';
    SET @connection_pass = 'Euqificap12.';
END //

-- Create a procedure to use or create a database
CREATE PROCEDURE use_or_create_database(IN db_name VARCHAR(64))
BEGIN
    -- Create database if it doesn't exist
    SET @create_db = CONCAT('CREATE DATABASE IF NOT EXISTS ', db_name);
    PREPARE stmt FROM @create_db;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Use the database
    SET @use_db = CONCAT('USE ', db_name);
    PREPARE stmt FROM @use_db;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

-- Example usage:
-- CALL establish_connection();
-- CALL use_or_create_database('your_database_name');