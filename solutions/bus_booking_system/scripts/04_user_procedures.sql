-- User Management Procedures
-- Created: April 14, 2025

CREATE OR REPLACE PACKAGE user_mgmt AS
    -- Register new user
    PROCEDURE register_user(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_user_id OUT NUMBER
    );

    -- Update user details
    PROCEDURE update_user(
        p_user_id IN NUMBER,
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_phone_number IN VARCHAR2
    );

    -- Get user booking history
    FUNCTION get_user_bookings(
        p_user_id IN NUMBER
    ) RETURN SYS_REFCURSOR;

    -- Delete user account
    PROCEDURE delete_user(
        p_user_id IN NUMBER
    );
END user_mgmt;
/

CREATE OR REPLACE PACKAGE BODY user_mgmt AS
    -- Implementation of register_user
    PROCEDURE register_user(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_user_id OUT NUMBER
    ) IS
    BEGIN
        -- Check if email already exists
        SELECT COUNT(*)
        INTO v_count
        FROM users
        WHERE email = p_email;

        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Email already registered');
        END IF;

        -- Create new user
        SELECT user_seq.NEXTVAL INTO p_user_id FROM DUAL;
        
        INSERT INTO users (
            user_id,
            first_name,
            last_name,
            email,
            phone_number,
            created_date
        ) VALUES (
            p_user_id,
            p_first_name,
            p_last_name,
            p_email,
            p_phone_number,
            SYSDATE
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END register_user;

    -- Implementation of update_user
    PROCEDURE update_user(
        p_user_id IN NUMBER,
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_phone_number IN VARCHAR2
    ) IS
    BEGIN
        UPDATE users
        SET first_name = NVL(p_first_name, first_name),
            last_name = NVL(p_last_name, last_name),
            phone_number = NVL(p_phone_number, phone_number)
        WHERE user_id = p_user_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'User not found');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_user;

    -- Implementation of get_user_bookings
    FUNCTION get_user_bookings(
        p_user_id IN NUMBER
    ) RETURN SYS_REFCURSOR IS
        v_result_set SYS_REFCURSOR;
    BEGIN
        OPEN v_result_set FOR
            SELECT b.booking_id,
                   r.origin,
                   r.destination,
                   s.departure_time,
                   s.arrival_time,
                   b.seat_number,
                   b.payment_status,
                   r.base_fare
            FROM bookings b
            JOIN schedules s ON b.schedule_id = s.schedule_id
            JOIN routes r ON s.route_id = r.route_id
            WHERE b.user_id = p_user_id
            ORDER BY s.departure_time DESC;

        RETURN v_result_set;
    END get_user_bookings;

    -- Implementation of delete_user
    PROCEDURE delete_user(
        p_user_id IN NUMBER
    ) IS
        v_booking_count NUMBER;
    BEGIN
        -- Check for active bookings
        SELECT COUNT(*)
        INTO v_booking_count
        FROM bookings
        WHERE user_id = p_user_id
        AND payment_status = 'PAID'
        AND schedule_id IN (
            SELECT schedule_id 
            FROM schedules 
            WHERE departure_time > SYSTIMESTAMP
        );

        IF v_booking_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Cannot delete user with active bookings');
        END IF;

        -- Delete user
        DELETE FROM users
        WHERE user_id = p_user_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'User not found');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_user;
END user_mgmt;
/