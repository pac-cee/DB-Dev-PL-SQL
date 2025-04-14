-- Utility Functions for Bus Booking System
-- Created: April 14, 2025

CREATE OR REPLACE PACKAGE booking_utils AS
    -- Get revenue by route
    FUNCTION get_route_revenue(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR;

    -- Get bus utilization report
    FUNCTION get_bus_utilization(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR;

    -- Get popular routes
    FUNCTION get_popular_routes(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR;

    -- Check bus availability
    FUNCTION is_bus_available(
        p_bus_id IN NUMBER,
        p_date IN DATE
    ) RETURN BOOLEAN;
END booking_utils;
/

CREATE OR REPLACE PACKAGE BODY booking_utils AS
    -- Implementation of get_route_revenue
    FUNCTION get_route_revenue(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR IS
        v_result_set SYS_REFCURSOR;
    BEGIN
        OPEN v_result_set FOR
            SELECT 
                r.origin,
                r.destination,
                COUNT(b.booking_id) as total_bookings,
                SUM(CASE WHEN b.payment_status = 'PAID' THEN r.base_fare ELSE 0 END) as total_revenue
            FROM routes r
            LEFT JOIN schedules s ON r.route_id = s.route_id
            LEFT JOIN bookings b ON s.schedule_id = b.schedule_id
            WHERE TRUNC(s.departure_time) BETWEEN p_start_date AND p_end_date
            GROUP BY r.origin, r.destination
            ORDER BY total_revenue DESC;

        RETURN v_result_set;
    END get_route_revenue;

    -- Implementation of get_bus_utilization
    FUNCTION get_bus_utilization(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR IS
        v_result_set SYS_REFCURSOR;
    BEGIN
        OPEN v_result_set FOR
            SELECT 
                b.bus_id,
                b.bus_type,
                b.seating_capacity,
                COUNT(DISTINCT s.schedule_id) as total_trips,
                COUNT(bk.booking_id) as total_bookings,
                ROUND(COUNT(bk.booking_id) / (COUNT(DISTINCT s.schedule_id) * b.seating_capacity) * 100, 2) as utilization_percentage
            FROM buses b
            LEFT JOIN schedules s ON b.bus_id = s.bus_id
            LEFT JOIN bookings bk ON s.schedule_id = bk.schedule_id
            WHERE TRUNC(s.departure_time) BETWEEN p_start_date AND p_end_date
            GROUP BY b.bus_id, b.bus_type, b.seating_capacity
            ORDER BY utilization_percentage DESC;

        RETURN v_result_set;
    END get_bus_utilization;

    -- Implementation of get_popular_routes
    FUNCTION get_popular_routes(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR IS
        v_result_set SYS_REFCURSOR;
    BEGIN
        OPEN v_result_set FOR
            SELECT 
                r.origin,
                r.destination,
                COUNT(b.booking_id) as total_bookings,
                COUNT(DISTINCT s.schedule_id) as total_schedules,
                ROUND(COUNT(b.booking_id) / COUNT(DISTINCT s.schedule_id), 2) as avg_bookings_per_schedule
            FROM routes r
            LEFT JOIN schedules s ON r.route_id = s.route_id
            LEFT JOIN bookings b ON s.schedule_id = b.schedule_id
            WHERE TRUNC(s.departure_time) BETWEEN p_start_date AND p_end_date
            GROUP BY r.origin, r.destination
            ORDER BY total_bookings DESC;

        RETURN v_result_set;
    END get_popular_routes;

    -- Implementation of is_bus_available
    FUNCTION is_bus_available(
        p_bus_id IN NUMBER,
        p_date IN DATE
    ) RETURN BOOLEAN IS
        v_schedule_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_schedule_count
        FROM schedules
        WHERE bus_id = p_bus_id
        AND TRUNC(departure_time) = TRUNC(p_date);

        RETURN v_schedule_count = 0;
    END is_bus_available;
END booking_utils;
/

-- Create some helper views for reporting
CREATE OR REPLACE VIEW daily_booking_summary AS
SELECT 
    TRUNC(s.departure_time) as travel_date,
    r.origin,
    r.destination,
    COUNT(b.booking_id) as total_bookings,
    SUM(CASE WHEN b.payment_status = 'PAID' THEN 1 ELSE 0 END) as paid_bookings,
    SUM(CASE WHEN b.payment_status = 'PENDING' THEN 1 ELSE 0 END) as pending_bookings,
    SUM(CASE WHEN b.payment_status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled_bookings
FROM schedules s
JOIN routes r ON s.route_id = r.route_id
LEFT JOIN bookings b ON s.schedule_id = b.schedule_id
GROUP BY TRUNC(s.departure_time), r.origin, r.destination;

-- View for bus performance metrics
CREATE OR REPLACE VIEW bus_performance_metrics AS
SELECT 
    b.bus_id,
    b.bus_type,
    b.service_route,
    COUNT(DISTINCT s.schedule_id) as total_trips,
    COUNT(bk.booking_id) as total_bookings,
    ROUND(COUNT(bk.booking_id) / NULLIF(COUNT(DISTINCT s.schedule_id), 0), 2) as avg_bookings_per_trip,
    ROUND(SUM(CASE WHEN bk.payment_status = 'CANCELLED' THEN 1 ELSE 0 END) / 
          NULLIF(COUNT(bk.booking_id), 0) * 100, 2) as cancellation_rate
FROM buses b
LEFT JOIN schedules s ON b.bus_id = s.bus_id
LEFT JOIN bookings bk ON s.schedule_id = bk.schedule_id
GROUP BY b.bus_id, b.bus_type, b.service_route;