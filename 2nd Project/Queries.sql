USE airline_management;

-- 1: Flight list ordered by soonest flight_time
SELECT flight_id, flight_time, airplane_id
FROM Flight
ORDER BY flight_time ASC;

-- 2: Flight manifest with passenger details
SELECT f.flight_id, f.flight_time, per.first_name, per.last_name, t.seat_number
FROM Flight f
JOIN Ticket t ON f.flight_id = t.flight_id
JOIN Passenger p ON t.passenger_id = p.passenger_id
JOIN Person per ON p.person_id = per.person_id
ORDER BY f.flight_time, per.last_name, per.first_name;

-- 3: Number of tickets and total revenue per flight
SELECT f.flight_id, COUNT(t.ticket_id) AS tickets_sold, SUM(t.price) AS total_revenue
FROM Flight f
LEFT JOIN Ticket t ON f.flight_id = t.flight_id
GROUP BY f.flight_id;

-- 4: Flights with more than N passengers
SELECT f.flight_id, COUNT(t.ticket_id) AS cnt
FROM Flight f
LEFT JOIN Ticket t ON f.flight_id = t.flight_id
GROUP BY f.flight_id
HAVING cnt > 2
ORDER BY cnt DESC;

-- 5: Top 5 passengers by points
SELECT p.passenger_id, per.first_name, per.last_name, p.customer_points
FROM Passenger p
JOIN Person per ON p.person_id = per.person_id
ORDER BY p.customer_points DESC
LIMIT 5;

-- 6: Crew assignments with crew member names
SELECT ca.flight_id, ca.assignment_date, per.first_name, per.last_name, fc.flight_experience
FROM Crew_Assignment ca
JOIN Flight_Crew fc ON ca.crew_id = fc.crew_id
JOIN Person per ON fc.person_id = per.person_id
ORDER BY ca.flight_id, ca.assignment_date;

-- 7: Airports with average ticket price for flights they supervise
SELECT ap.airport_id, ap.airport_name, ROUND(AVG(t.price)) AS avg_price, COUNT(t.ticket_id) AS tickets_count
FROM Airport ap
JOIN Flight_Supervision fs ON ap.airport_id = fs.airport_id
JOIN Flight f ON fs.flight_id = f.flight_id
LEFT JOIN Ticket t ON f.flight_id = t.flight_id
GROUP BY ap.airport_id, ap.airport_name
ORDER BY avg_price DESC;

-- 8: Employees and their manager names
SELECT e.employee_id, per.first_name AS employee_first, per.last_name AS employee_last,
       m.employee_id AS manager_employee_id, mp.first_name AS manager_first, mp.last_name AS manager_last
FROM Employee e
LEFT JOIN Employee m ON e.manager_id = m.employee_id
JOIN Person per ON e.person_id = per.person_id
LEFT JOIN Person mp ON m.person_id = mp.person_id
ORDER BY e.employee_id;

-- 9: Flights using airplanes over capacity threshold
SELECT f.flight_id, f.flight_time, a.airplane_id, a.capacity
FROM Flight f
JOIN Airplane a ON f.airplane_id = a.airplane_id
WHERE a.capacity > 200
ORDER BY a.capacity DESC;

-- 10: Frequent co-travel pairs
SELECT tc.passenger_id, tc.companion_id, COUNT(*) AS times_travelled_together
FROM Travel_Companion tc
GROUP BY tc.passenger_id, tc.companion_id
HAVING times_travelled_together >= 1
ORDER BY times_travelled_together DESC;
