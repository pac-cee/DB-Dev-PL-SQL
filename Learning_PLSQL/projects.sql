-- 1. Banking System

CREATE TABLE bank_accounts (
    account_id   NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100),
    balance      NUMBER(10,2)
);

CREATE OR REPLACE PACKAGE bank_pkg IS
    PROCEDURE deposit(p_account_id IN NUMBER, p_amount IN NUMBER);
    PROCEDURE withdraw(p_account_id IN NUMBER, p_amount IN NUMBER);
    FUNCTION get_balance(p_account_id IN NUMBER) RETURN NUMBER;
END bank_pkg;
/

CREATE OR REPLACE PACKAGE BODY bank_pkg IS
    PROCEDURE deposit(p_account_id IN NUMBER, p_amount IN NUMBER) IS
    BEGIN
        UPDATE bank_accounts
        SET balance = balance + p_amount
        WHERE account_id = p_account_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Account not found');
        END IF;
    END deposit;
    
    PROCEDURE withdraw(p_account_id IN NUMBER, p_amount IN NUMBER) IS
    BEGIN
        UPDATE bank_accounts
        SET balance = balance - p_amount
        WHERE account_id = p_account_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Account not found');
        ELSIF balance < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Insufficient funds');
        END IF;
    END withdraw;
    
    FUNCTION get_balance(p_account_id IN NUMBER) RETURN NUMBER IS
        v_balance NUMBER(10,2);
    BEGIN
        SELECT balance
        INTO v_balance
        FROM bank_accounts
        WHERE account_id = p_account_id;
        
        IF v_balance IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Account not found');
        END IF;
        
        RETURN v_balance;
    END get_balance;
END bank_pkg;
/

-- 2. Online Shopping Cart

CREATE TABLE products (
    product_id   NUMBER PRIMARY KEY,
    name         VARCHAR2(100),
    price        NUMBER(10,2)
);

CREATE TABLE customers (
    customer_id  NUMBER PRIMARY KEY,
    name         VARCHAR2(100),
    email        VARCHAR2(100)
);

CREATE TABLE orders (
    order_id     NUMBER PRIMARY KEY,
    customer_id  NUMBER,
    product_id   NUMBER,
    quantity     NUMBER,
    order_date   DATE
);

CREATE OR REPLACE PACKAGE shopping_cart_pkg IS
    PROCEDURE add_product_to_cart(p_customer_id IN NUMBER, p_product_id IN NUMBER, p_quantity IN NUMBER);
    PROCEDURE remove_product_from_cart(p_customer_id IN NUMBER, p_product_id IN NUMBER);
    FUNCTION get_cart_total(p_customer_id IN NUMBER) RETURN NUMBER;
END shopping_cart_pkg;
/

CREATE OR REPLACE PACKAGE BODY shopping_cart_pkg IS
    PROCEDURE add_product_to_cart(p_customer_id IN NUMBER, p_product_id IN NUMBER, p_quantity IN NUMBER) IS
        v_product_price NUMBER(10,2);
    BEGIN
        SELECT price
        INTO v_product_price
        FROM products
        WHERE product_id = p_product_id;
        
        INSERT INTO orders (customer_id, product_id, quantity, order_date)
        VALUES (p_customer_id, p_product_id, p_quantity, SYSDATE);
        
        UPDATE customers
        SET orders = orders + (v_product_price * p_quantity)
        WHERE customer_id = p_customer_id;
    END add_product_to_cart;
    
    PROCEDURE remove_product_from_cart(p_customer_id IN NUMBER, p_product_id IN NUMBER) IS
        v_product_price NUMBER(10,2);
    BEGIN
        SELECT price
        INTO v_product_price
        FROM products
        WHERE product_id = p_product_id;
        
        DELETE FROM orders
        WHERE customer_id = p_customer_id
        AND product_id = p_product_id;
        
        UPDATE customers
        SET orders = orders - (v_product_price * p_quantity)
        WHERE customer_id = p_customer_id;
    END remove_product_from_cart;
    
    FUNCTION get_cart_total(p_customer_id IN NUMBER) RETURN NUMBER IS
        v_total NUMBER(10,2);
    BEGIN
        SELECT SUM(price * quantity)
        INTO v_total
        FROM orders
        WHERE customer_id = p_customer_id;
        
        RETURN v_total;
    END get_cart_total;
END shopping_cart_pkg;
/

-- 3. Hotel Reservation System

CREATE TABLE hotels (
    hotel_id     NUMBER PRIMARY KEY,
    name         VARCHAR2(100),
    address      VARCHAR2(200)
);

CREATE TABLE rooms (
    room_id      NUMBER PRIMARY KEY,
    hotel_id     NUMBER,
    type         VARCHAR2(50),
    rate         NUMBER(10,2)
);

CREATE TABLE reservations (
    reservation_id NUMBER PRIMARY KEY,
    hotel_id      NUMBER,
    room_id       NUMBER,
    checkin_date  DATE,
    checkout_date DATE,
    guest_name    VARCHAR2(100)
);

CREATE OR REPLACE PACKAGE hotel_reservation_pkg IS
    PROCEDURE book_room(p_hotel_id IN NUMBER, p_room_id IN NUMBER, p_checkin_date IN DATE, p_checkout_date IN DATE, p_guest_name IN VARCHAR2);
    FUNCTION get_room_rate(p_room_id IN NUMBER) RETURN NUMBER;
END hotel_reservation_pkg;
/

CREATE OR REPLACE PACKAGE BODY hotel_reservation_pkg IS
    PROCEDURE book_room(p_hotel_id IN NUMBER, p_room_id IN NUMBER, p_checkin_date IN DATE, p_checkout_date IN DATE, p_guest_name IN VARCHAR2) IS
    BEGIN
        INSERT INTO reservations (hotel_id, room_id, checkin_date, checkout_date, guest_name)
        VALUES (p_hotel_id, p_room_id, p_checkin_date, p_checkout_date, p_guest_name);
    END book_room;
    
    FUNCTION get_room_rate(p_room_id IN NUMBER) RETURN NUMBER IS
        v_rate NUMBER(10,2);
    BEGIN
        SELECT rate
        INTO v_rate
        FROM rooms
        WHERE room_id = p_room_id;
        
        RETURN v_rate;
    END get_room_rate;
END hotel_reservation_pkg;
/

-- 4. Online Survey System

CREATE TABLE surveys (
    survey_id    NUMBER PRIMARY KEY,
    title        VARCHAR2(100),
    description  VARCHAR2(200)
);

CREATE TABLE questions (
    question_id  NUMBER PRIMARY KEY,
    survey_id    NUMBER,
    question     VARCHAR2(200)
);

CREATE TABLE answers (
    answer_id    NUMBER PRIMARY KEY,
    question_id  NUMBER,
    answer       VARCHAR2(200)
);

CREATE OR REPLACE PACKAGE survey_pkg IS
    PROCEDURE add_question(p_survey_id IN NUMBER, p_question IN VARCHAR2);
    PROCEDURE add_answer(p_question_id IN NUMBER, p_answer IN VARCHAR2);
END survey_pkg;
/

CREATE OR REPLACE PACKAGE BODY survey_pkg IS
    PROCEDURE add_question(p_survey_id IN NUMBER, p_question IN VARCHAR2) IS
    BEGIN
        INSERT INTO questions (survey_id, question)
        VALUES (p_survey_id, p_question);
    END add_question;
    
    PROCEDURE add_answer(p_question_id IN NUMBER, p_answer IN VARCHAR2) IS
    BEGIN
        INSERT INTO answers (question_id, answer)
        VALUES (p_question_id, p_answer);
    END add_answer;
END survey_pkg;
/
