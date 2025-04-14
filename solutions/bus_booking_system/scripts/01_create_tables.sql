-- Create tables for Smart Bus Booking System
-- Created: April 14, 2025

-- Users table
CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    created_date DATE DEFAULT SYSDATE
);

-- Bus Terminals table
CREATE TABLE bus_terminals (
    terminal_id NUMBER PRIMARY KEY,
    location VARCHAR2(100) NOT NULL,
    operating_hours VARCHAR2(50) NOT NULL,
    contact_info VARCHAR2(100) NOT NULL
);

-- Buses table
CREATE TABLE buses (
    bus_id NUMBER PRIMARY KEY,
    terminal_id NUMBER,
    seating_capacity NUMBER NOT NULL,
    service_route VARCHAR2(100) NOT NULL,
    bus_type VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_terminal FOREIGN KEY (terminal_id) REFERENCES bus_terminals(terminal_id)
);

-- Routes table
CREATE TABLE routes (
    route_id NUMBER PRIMARY KEY,
    origin VARCHAR2(100) NOT NULL,
    destination VARCHAR2(100) NOT NULL,
    base_fare NUMBER(10,2) NOT NULL
);

-- Schedules table
CREATE TABLE schedules (
    schedule_id NUMBER PRIMARY KEY,
    route_id NUMBER,
    bus_id NUMBER,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    frequency VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_route FOREIGN KEY (route_id) REFERENCES routes(route_id),
    CONSTRAINT fk_bus FOREIGN KEY (bus_id) REFERENCES buses(bus_id)
);

-- Bookings table
CREATE TABLE bookings (
    booking_id NUMBER PRIMARY KEY,
    user_id NUMBER,
    schedule_id NUMBER,
    seat_number NUMBER NOT NULL,
    booking_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    payment_status VARCHAR2(20) DEFAULT 'PENDING',
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_schedule FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id),
    CONSTRAINT ck_payment_status CHECK (payment_status IN ('PENDING', 'PAID', 'CANCELLED'))
);

-- Create sequences for primary keys
CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE terminal_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE bus_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE route_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE schedule_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE booking_seq START WITH 1 INCREMENT BY 1;