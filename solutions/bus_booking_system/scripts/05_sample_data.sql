-- Sample Data for Smart Bus Booking System
-- Created: April 14, 2025

-- Insert Bus Terminals
INSERT INTO bus_terminals (terminal_id, location, operating_hours, contact_info) VALUES
(terminal_seq.NEXTVAL, 'Kigali Central Terminal', '04:00-23:00', '+250789123456');
INSERT INTO bus_terminals (terminal_id, location, operating_hours, contact_info) VALUES
(terminal_seq.NEXTVAL, 'Huye Bus Station', '05:00-22:00', '+250789123457');
INSERT INTO bus_terminals (terminal_id, location, operating_hours, contact_info) VALUES
(terminal_seq.NEXTVAL, 'Musanze Terminal', '05:00-21:00', '+250789123458');
INSERT INTO bus_terminals (terminal_id, location, operating_hours, contact_info) VALUES
(terminal_seq.NEXTVAL, 'Rubavu Bus Park', '06:00-22:00', '+250789123459');

-- Insert Buses
INSERT INTO buses (bus_id, terminal_id, seating_capacity, service_route, bus_type) VALUES
(bus_seq.NEXTVAL, 1, 45, 'Kigali-Huye', 'LUXURY');
INSERT INTO buses (bus_id, terminal_id, seating_capacity, service_route, bus_type) VALUES
(bus_seq.NEXTVAL, 1, 50, 'Kigali-Musanze', 'STANDARD');
INSERT INTO buses (bus_id, terminal_id, seating_capacity, service_route, bus_type) VALUES
(bus_seq.NEXTVAL, 1, 45, 'Kigali-Rubavu', 'LUXURY');
INSERT INTO buses (bus_id, terminal_id, seating_capacity, service_route, bus_type) VALUES
(bus_seq.NEXTVAL, 2, 50, 'Huye-Kigali', 'STANDARD');

-- Insert Routes
INSERT INTO routes (route_id, origin, destination, base_fare) VALUES
(route_seq.NEXTVAL, 'Kigali', 'Huye', 5000);
INSERT INTO routes (route_id, origin, destination, base_fare) VALUES
(route_seq.NEXTVAL, 'Huye', 'Kigali', 5000);
INSERT INTO routes (route_id, origin, destination, base_fare) VALUES
(route_seq.NEXTVAL, 'Kigali', 'Musanze', 4000);
INSERT INTO routes (route_id, origin, destination, base_fare) VALUES
(route_seq.NEXTVAL, 'Musanze', 'Kigali', 4000);
INSERT INTO routes (route_id, origin, destination, base_fare) VALUES
(route_seq.NEXTVAL, 'Kigali', 'Rubavu', 6000);
INSERT INTO routes (route_id, origin, destination, base_fare) VALUES
(route_seq.NEXTVAL, 'Rubavu', 'Kigali', 6000);

-- Insert Sample Schedules (for next 7 days)
DECLARE
    v_current_date DATE := TRUNC(SYSDATE);
    v_route_id NUMBER;
    v_bus_id NUMBER;
BEGIN
    -- For each route
    FOR route IN (SELECT route_id, origin FROM routes) LOOP
        -- For next 7 days
        FOR i IN 0..6 LOOP
            -- Morning schedule
            INSERT INTO schedules (
                schedule_id,
                route_id,
                bus_id,
                departure_time,
                arrival_time,
                frequency
            ) VALUES (
                schedule_seq.NEXTVAL,
                route.route_id,
                CASE 
                    WHEN route.origin = 'Kigali' THEN 1
                    WHEN route.origin = 'Huye' THEN 4
                    WHEN route.origin = 'Musanze' THEN 2
                    ELSE 3
                END,
                TIMESTAMP '2025-04-14 07:00:00' + i,
                TIMESTAMP '2025-04-14 10:00:00' + i,
                'DAILY'
            );

            -- Afternoon schedule
            INSERT INTO schedules (
                schedule_id,
                route_id,
                bus_id,
                departure_time,
                arrival_time,
                frequency
            ) VALUES (
                schedule_seq.NEXTVAL,
                route.route_id,
                CASE 
                    WHEN route.origin = 'Kigali' THEN 1
                    WHEN route.origin = 'Huye' THEN 4
                    WHEN route.origin = 'Musanze' THEN 2
                    ELSE 3
                END,
                TIMESTAMP '2025-04-14 14:00:00' + i,
                TIMESTAMP '2025-04-14 17:00:00' + i,
                'DAILY'
            );
        END LOOP;
    END LOOP;
END;
/

-- Insert Sample Users
INSERT INTO users (user_id, first_name, last_name, email, phone_number, created_date) VALUES
(user_seq.NEXTVAL, 'John', 'Doe', 'john.doe@email.com', '+250781234567', SYSDATE);
INSERT INTO users (user_id, first_name, last_name, email, phone_number, created_date) VALUES
(user_seq.NEXTVAL, 'Jane', 'Smith', 'jane.smith@email.com', '+250782345678', SYSDATE);
INSERT INTO users (user_id, first_name, last_name, email, phone_number, created_date) VALUES
(user_seq.NEXTVAL, 'Robert', 'Johnson', 'robert.j@email.com', '+250783456789', SYSDATE);

-- Insert Sample Bookings
DECLARE
    v_schedule_id NUMBER;
    v_user_id NUMBER;
BEGIN
    -- Get first schedule ID
    SELECT MIN(schedule_id) INTO v_schedule_id FROM schedules;
    
    -- Get first user ID
    SELECT MIN(user_id) INTO v_user_id FROM users;
    
    -- Create some sample bookings
    INSERT INTO bookings (
        booking_id,
        user_id,
        schedule_id,
        seat_number,
        booking_date,
        payment_status
    ) VALUES (
        booking_seq.NEXTVAL,
        v_user_id,
        v_schedule_id,
        1,
        SYSTIMESTAMP,
        'PAID'
    );
    
    INSERT INTO bookings (
        booking_id,
        user_id,
        schedule_id,
        seat_number,
        booking_date,
        payment_status
    ) VALUES (
        booking_seq.NEXTVAL,
        v_user_id + 1,
        v_schedule_id,
        2,
        SYSTIMESTAMP,
        'PENDING'
    );
END;
/

COMMIT;