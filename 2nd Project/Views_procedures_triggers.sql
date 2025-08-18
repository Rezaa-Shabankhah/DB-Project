USE airline_management;

CREATE VIEW passenger_flight_summary AS
SELECT 
    p.person_id,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    pas.customer_points,
    pas.membership_level,
    COUNT(t.ticket_id) AS total_flights,
    SUM(t.price) AS total_spending,
    AVG(t.price) AS average_ticket_price,
    MIN(f.departure_time) AS first_flight_date,
    MAX(f.departure_time) AS last_flight_date
FROM Person p
JOIN Passenger pas ON p.person_id = pas.person_id
LEFT JOIN Ticket t ON pas.person_id = t.passenger_id
LEFT JOIN Flight f ON t.flight_id = f.flight_id
GROUP BY p.person_id, p.first_name, p.last_name, pas.customer_points, pas.membership_level;


CREATE VIEW flight_operations_dashboard AS
SELECT 
    f.flight_id,
    f.flight_number,
    f.status,
    f.departure_time,
    f.arrival_time,
    CONCAT(orig_airport.airport_code, ' → ', dest_airport.airport_code) AS route,
    CONCAT(orig_airport.city, ' → ', dest_airport.city) AS cities,
    r.distance_km,
    a.tail_number,
    am.model_name AS aircraft_model,
    a.capacity,
    COUNT(t.ticket_id) AS tickets_sold,
    (COUNT(t.ticket_id) * 100.0 / a.capacity) AS occupancy_rate,
    SUM(t.price) AS total_revenue,
    COUNT(ca.crew_id) AS crew_count
FROM Flight f
JOIN Route r ON f.route_id = r.route_id
JOIN Airport orig_airport ON r.origin_airport_id = orig_airport.airport_id
JOIN Airport dest_airport ON r.destination_airport_id = dest_airport.airport_id
JOIN Airplane a ON f.airplane_id = a.airplane_id
JOIN Aircraft_Model am ON a.aircraft_model_id = am.model_id
LEFT JOIN Ticket t ON f.flight_id = t.flight_id AND t.booking_status = 'Confirmed'
LEFT JOIN Crew_Assignment ca ON f.flight_id = ca.flight_id AND ca.assignment_status = 'Confirmed'
GROUP BY f.flight_id, f.flight_number, f.status, f.departure_time, f.arrival_time,
         orig_airport.airport_code, dest_airport.airport_code, orig_airport.city, dest_airport.city,
         r.distance_km, a.tail_number, am.model_name, a.capacity;


DELIMITER //

CREATE PROCEDURE BookFlightTicket(
    IN p_flight_id INT,
    IN p_passenger_id INT,
    IN p_ticket_class VARCHAR(20),
    OUT p_ticket_id INT,
    OUT p_seat_number VARCHAR(10),
    OUT p_final_price DECIMAL(10,2),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_customer_points INT;
    DECLARE v_membership_level VARCHAR(20);
    DECLARE v_class_multiplier DECIMAL(3,2);
    DECLARE v_discount_rate DECIMAL(3,2) DEFAULT 0;
    DECLARE v_next_seat VARCHAR(10);
    DECLARE v_capacity INT;
    DECLARE v_tickets_sold INT;
    DECLARE v_flight_status VARCHAR(20);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Error: Transaction failed';
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    SELECT f.base_price, f.status, a.capacity
    INTO v_base_price, v_flight_status, v_capacity
    FROM Flight f
    JOIN Airplane a ON f.airplane_id = a.airplane_id
    WHERE f.flight_id = p_flight_id;
    
    IF v_flight_status NOT IN ('Scheduled', 'Boarding') THEN
        SET p_status_message = CONCAT('Flight not available for booking. Status: ', v_flight_status);
        ROLLBACK;
        LEAVE proc_label;
    END IF;
    
    SELECT customer_points, membership_level
    INTO v_customer_points, v_membership_level
    FROM Passenger
    WHERE person_id = p_passenger_id;
    
    SELECT COUNT(*)
    INTO v_tickets_sold
    FROM Ticket
    WHERE flight_id = p_flight_id AND booking_status = 'Confirmed';
    
    IF v_tickets_sold >= v_capacity THEN
        SET p_status_message = 'Flight is fully booked';
        ROLLBACK;
        LEAVE proc_label;
    END IF;
    
    CASE p_ticket_class
        WHEN 'Economy' THEN SET v_class_multiplier = 1.0;
        WHEN 'Business' THEN SET v_class_multiplier = 1.5;
        WHEN 'First' THEN SET v_class_multiplier = 2.0;
        ELSE SET v_class_multiplier = 1.0;
    END CASE;
    
    CASE v_membership_level
        WHEN 'Bronze' THEN SET v_discount_rate = 0;
        WHEN 'Silver' THEN SET v_discount_rate = 0.05;
        WHEN 'Gold' THEN SET v_discount_rate = 0.10;
        WHEN 'Platinum' THEN SET v_discount_rate = 0.15;
    END CASE;
    
    SET p_final_price = v_base_price * v_class_multiplier * (1 - v_discount_rate);
    
    SET v_next_seat = CONCAT(LPAD(v_tickets_sold + 1, 2, '0'), 
                           CHAR(65 + (v_tickets_sold % 6))); -- A-F
    SET p_seat_number = v_next_seat;
    
    INSERT INTO Ticket (flight_id, passenger_id, seat_number, price, ticket_class, booking_status)
    VALUES (p_flight_id, p_passenger_id, p_seat_number, p_final_price, p_ticket_class, 'Confirmed');
    
    SET p_ticket_id = LAST_INSERT_ID();
    
    UPDATE Passenger 
    SET customer_points = customer_points + FLOOR(p_final_price / 1000)
    WHERE person_id = p_passenger_id;
    
    SET p_status_message = 'Ticket booked successfully';
    COMMIT;
    
END//

DELIMITER ;



DELIMITER //

CREATE TRIGGER update_membership_level
    AFTER UPDATE ON Passenger
    FOR EACH ROW
BEGIN
    DECLARE new_level VARCHAR(20);
    
    IF NEW.customer_points >= 10000 THEN
        SET new_level = 'Platinum';
    ELSEIF NEW.customer_points >= 5000 THEN
        SET new_level = 'Gold';
    ELSEIF NEW.customer_points >= 2000 THEN
        SET new_level = 'Silver';
    ELSE
        SET new_level = 'Bronze';
    END IF;
    
    IF new_level != NEW.membership_level THEN
        UPDATE Passenger 
        SET membership_level = new_level 
        WHERE person_id = NEW.person_id;
    END IF;
END//

DELIMITER ;
