-- Schedule Management Procedures
-- Created: April 14, 2025

CREATE OR REPLACE PACKAGE schedule_mgmt AS
    -- Add new route
    PROCEDURE add_route(
        p_origin IN VARCHAR2,
        p_destination IN VARCHAR2,
        p_base_fare IN NUMBER,
        p_route_id OUT NUMBER
    );

    -- Create new schedule
    PROCEDURE create_schedule(
        p_route_id IN NUMBER,
        p_bus_id IN NUMBER,
        p_departure_time IN TIMESTAMP,
        p_arrival_time IN TIMESTAMP,
        p_frequency IN VARCHAR2,
        p_schedule_id OUT NUMBER
    );

    -- Get available schedules
    FUNCTION get_available_schedules(
        p_origin IN VARCHAR2,
        p_destination IN VARCHAR2,
        p_travel_date IN DATE
    ) RETURN SYS_REFCURSOR;

    -- Update schedule times
    PROCEDURE update_schedule_times(
        p_schedule_id IN NUMBER,
        p_new_departure IN TIMESTAMP,
        p_new_arrival IN TIMESTAMP
    );
END schedule_mgmt;
/

CREATE OR REPLACE PACKAGE BODY schedule_mgmt AS
    -- Implementation of add_route
    PROCEDURE add_route(
        p_origin IN VARCHAR2,
        p_destination IN VARCHAR2,
        p_base_fare IN NUMBER,
        p_route_id OUT NUMBER
    ) IS
    BEGIN
        SELECT route_seq.NEXTVAL INTO p_route_id FROM DUAL;
        
        INSERT INTO routes (
            route_id,
            origin,
            destination,
            base_fare
        ) VALUES (
            p_route_id,
            p_origin,
            p_destination,
            p_base_fare
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_route;

    -- Implementation of create_schedule
    PROCEDURE create_schedule(
        p_route_id IN NUMBER,
        p_bus_id IN NUMBER,
        p_departure_time IN TIMESTAMP,
        p_arrival_time IN TIMESTAMP,
        p_frequency IN VARCHAR2,
        p_schedule_id OUT NUMBER
    ) IS
    BEGIN
        SELECT schedule_seq.NEXTVAL INTO p_schedule_id FROM DUAL;
        
        INSERT INTO schedules (
            schedule_id,
            route_id,
            bus_id,
            departure_time,
            arrival_time,
            frequency
        ) VALUES (
            p_schedule_id,
            p_route_id,
            p_bus_id,
            p_departure_time,
            p_arrival_time,
            p_frequency
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_schedule;

    -- Implementation of get_available_schedules
    FUNCTION get_available_schedules(
        p_origin IN VARCHAR2,
        p_destination IN VARCHAR2,
        p_travel_date IN DATE
    ) RETURN SYS_REFCURSOR IS
        v_result_set SYS_REFCURSOR;
    BEGIN
        OPEN v_result_set FOR
            SELECT s.schedule_id,
                   r.origin,
                   r.destination,
                   s.departure_time,
                   s.arrival_time,
                   b.bus_type,
                   b.seating_capacity,
                   r.base_fare,
                   (SELECT COUNT(*) 
                    FROM bookings bk 
                    WHERE bk.schedule_id = s.schedule_id 
                    AND bk.payment_status != 'CANCELLED') as booked_seats
            FROM schedules s
            JOIN routes r ON s.route_id = r.route_id
            JOIN buses b ON s.bus_id = b.bus_id
            WHERE r.origin = p_origin
            AND r.destination = p_destination
            AND TRUNC(s.departure_time) = p_travel_date
            ORDER BY s.departure_time;

        RETURN v_result_set;
    END get_available_schedules;

    -- Implementation of update_schedule_times
    PROCEDURE update_schedule_times(
        p_schedule_id IN NUMBER,
        p_new_departure IN TIMESTAMP,
        p_new_arrival IN TIMESTAMP
    ) IS
    BEGIN
        UPDATE schedules
        SET departure_time = p_new_departure,
            arrival_time = p_new_arrival
        WHERE schedule_id = p_schedule_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Schedule not found');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_schedule_times;
END schedule_mgmt;
/