-- Create the customers table
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20),
    address VARCHAR2(200),
    city VARCHAR2(50),
    state VARCHAR2(2),
    zip_code VARCHAR2(10),
    registration_date DATE DEFAULT SYSDATE,
    credit_limit NUMBER(10,2),
    status VARCHAR2(10) CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- Create a sequence for customer_id
CREATE SEQUENCE customer_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Insert sample customer data
INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, 
    address, city, state, zip_code, credit_limit, status
) VALUES (
    customer_seq.NEXTVAL, 'John', 'Smith', 'john.smith@email.com', '555-0101',
    '123 Main St', 'Boston', 'MA', '02108', 5000.00, 'ACTIVE'
);

INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, 
    address, city, state, zip_code, credit_limit, status
) VALUES (
    customer_seq.NEXTVAL, 'Mary', 'Johnson', 'mary.j@email.com', '555-0102',
    '456 Oak Ave', 'New York', 'NY', '10001', 7500.00, 'ACTIVE'
);

INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, 
    address, city, state, zip_code, credit_limit, status
) VALUES (
    customer_seq.NEXTVAL, 'Robert', 'Williams', 'rwilliams@email.com', '555-0103',
    '789 Pine Rd', 'Chicago', 'IL', '60601', 3000.00, 'ACTIVE'
);

-- Verify the data
SELECT * FROM customers;