-- Booking Management Procedures
-- Created: April 14, 2025

CREATE OR REPLACE PACKAGE booking_mgmt AS
    -- Check seat availability
    FUNCTION check_seat_availability(
        p_schedule_id IN NUMBER,
        p_seat_number IN NUMBER
    ) RETURN BOOLEAN;

    -- Create new booking
    PROCEDURE create_booking(
        p_user_id IN NUMBER,
        p_schedule_id IN NUMBER,
        p_seat_number IN NUMBER,
        p_booking_id OUT NUMBER
    );

    -- Cancel booking
    PROCEDURE cancel_booking(
        p_booking_id IN NUMBER
    );

    -- Update payment status
    PROCEDURE update_payment_status(
        p_booking_id IN NUMBER,
        p_status IN VARCHAR2
    );
END booking_mgmt;
/

CREATE OR REPLACE PACKAGE BODY booking_mgmt AS
    -- Implementation of check_seat_availability
    FUNCTION check_seat_availability(
        p_schedule_id IN NUMBER,
        p_seat_number IN NUMBER
    ) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM bookings
        WHERE schedule_id = p_schedule_id
        AND seat_number = p_seat_number
        AND payment_status != 'CANCELLED';

        RETURN v_count = 0;
    END check_seat_availability;

    -- Implementation of create_booking
    PROCEDURE create_booking(
        p_user_id IN NUMBER,
        p_schedule_id IN NUMBER,
        p_seat_number IN NUMBER,
        p_booking_id OUT NUMBER
    ) IS
    BEGIN
        -- Check if seat is available
        IF NOT check_seat_availability(p_schedule_id, p_seat_number) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Seat is already booked');
        END IF;

        -- Create new booking
        SELECT booking_seq.NEXTVAL INTO p_booking_id FROM DUAL;
        
        INSERT INTO bookings (
            booking_id,
            user_id,
            schedule_id,
            seat_number,
            booking_date,
            payment_status
        ) VALUES (
            p_booking_id,
            p_user_id,
            p_schedule_id,
            p_seat_number,
            SYSTIMESTAMP,
            'PENDING'
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_booking;

    -- Implementation of cancel_booking
    PROCEDURE cancel_booking(
        p_booking_id IN NUMBER
    ) IS
    BEGIN
        UPDATE bookings
        SET payment_status = 'CANCELLED'
        WHERE booking_id = p_booking_id
        AND payment_status != 'CANCELLED';

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Booking not found or already cancelled');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END cancel_booking;

    -- Implementation of update_payment_status
    PROCEDURE update_payment_status(
        p_booking_id IN NUMBER,
        p_status IN VARCHAR2
    ) IS
    BEGIN
        UPDATE bookings
        SET payment_status = p_status
        WHERE booking_id = p_booking_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Booking not found');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_payment_status;
END booking_mgmt;
/