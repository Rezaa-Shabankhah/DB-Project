USE airline_management;

INSERT INTO Person (first_name, last_name) VALUES
('Zahra', 'Karimi'),
('Maryam', 'Javadi'),
('Mohammad', 'Ahmadi'),
('Ali', 'Rezaei'),
('Hassan', 'Moradi'),
('Reza', 'Bagheri'),
('Samira', 'Rahimi'),
('Mehdi', 'Shariati'),
('Nasrin', 'Kazemi'),
('Amir', 'Mousavi'),
('Leila', 'Sadeghi'),
('Masoud', 'Rahmani'),
('Fateme', 'Hosseini'),
('Shahla', 'Talebi'),
('Hamid', 'Nabavi'),
('Parvin', 'Mohammadi'),
('Saeed', 'Ghorbani'),
('Mina', 'Hashemi'),
('Davood', 'Farahani'),
('Taraneh', 'Saberi');

INSERT INTO Phone (person_id, phone_number, phone_type, is_primary) VALUES
(1, '+989305564859', 'mobile', TRUE),
(1, '+989124895623', 'work', FALSE),
(2, '+989158654872', 'mobile', TRUE),
(3, '+989104085618', 'mobile', TRUE),
(3, '+989398684517', 'home', FALSE),
(4, '+989355861532', 'mobile', TRUE),
(4, '+989036548912', 'work', FALSE),
(5, '+989356899849', 'mobile', TRUE),
(6, '+989151654984', 'mobile', TRUE),
(6, '+989366849874', 'work', FALSE),
(7, '+989106846868', 'mobile', TRUE),
(8, '+989216846849', 'mobile', TRUE),
(8, '+989156849684', 'home', FALSE),
(9, '+989336849759', 'mobile', TRUE),
(10, '+989399849849', 'mobile', TRUE),
(10, '+989216849879', 'work', FALSE),
(11, '+989306849898', 'mobile', TRUE),
(12, '+989351984984', 'mobile', TRUE),
(13, '+989019849849', 'mobile', TRUE),
(13, '+989016849849', 'home', FALSE),
(14, '+989336849849', 'mobile', TRUE),
(15, '+989159849898', 'mobile', TRUE),
(15, '+989359874913', 'work', FALSE),
(16, '+989039849849', 'mobile', TRUE),
(17, '+989216846849', 'mobile', TRUE),
(18, '+989106849848', 'mobile', TRUE),
(18, '+989366849865', 'work', FALSE),
(19, '+989156849849', 'mobile', TRUE),
(20, '+989366849499', 'mobile', TRUE),
(20, '+989156684968', 'work', FALSE),
(20, '+989119874949', 'home', FALSE);

INSERT INTO Airport (airport_name) VALUES
('Imam Khomeini International Airport'),
('Mehrabad International Airport'),
('Shiraz Shahid Dastgheib International Airport'),
('Isfahan Shahid Beheshti International Airport'),
('Mashhad Shahid Hashemi Nejad International Airport'),
('Tabriz International Airport'),
('Kerman Airport'),
('Bandar Abbas International Airport'),
('Ahvaz Jundishapur Airport'),
('Kish International Airport');

INSERT INTO Control_Tower (airport_id, radar_range_km) VALUES
(1, 250),
(2, 200),
(3, 180),
(4, 160),
(5, 220);

INSERT INTO Airplane (capacity) VALUES
(180),
(150),
(320),
(295),
(140);

INSERT INTO Route (origin_airport_id, destination_airport_id) VALUES
(1, 3),
(2, 4),
(1, 5),
(3, 6),
(4, 10);

INSERT INTO Passenger (person_id, customer_points) VALUES
(1, 2500),
(2, 100),
(3, 0),
(4, 890),
(5, 1650),
(6, 4200),
(7, 750),
(8, 2100),
(9, 1800),
(10, 920);

INSERT INTO Travel_Companion (passenger_id, companion_id) VALUES
(1, 2),
(1, 4),
(4, 1),
(4, 8),
(9, 10);

INSERT INTO Flight_Crew (person_id, flight_experience_hours) VALUES
(11, 1500),
(12, 4200),
(13, 6500),
(14, 4100),
(15, 900);

INSERT INTO Employee (person_id, employee_id, work_experience_months, manager_id, airport_id, tower_id) VALUES
(16, 'EMP001', 48, NULL, NULL, 1),
(17, 'EMP002', 36, 16, 1, NULL),
(18, 'EMP003', 24, 16, 1, NULL),
(19, 'EMP004', 60, NULL, 4, NULL),
(20, 'EMP005', 42, 19, NULL, 5);

INSERT INTO Flight (flight_number, route_id, airplane_id, departure_time, arrival_time, replacement_flight_id) VALUES
('IR101', 1, 1, '2025-07-24 08:30:00', '2025-07-24 09:55:00', 5),
('IR202', 2, 2, '2025-07-24 14:15:00', '2025-07-24 15:15:00', NULL),
('IR303', 3, 3, '2025-07-24 19:45:00', '2025-07-24 21:15:00', NULL),
('IR404', 4, 4, '2025-07-25 06:20:00', '2025-07-25 08:10:00', NULL),
('IR505', 5, 5, '2025-07-25 16:10:00', '2025-07-25 17:45:00', NULL);

INSERT INTO Ticket (flight_id, passenger_id, seat_number, price) VALUES
(1, 1, '12A', 2800000),
(1, 2, '12B', 2800000),
(1, 3, '15C', 2500000),
(2, 4, '8A', 1900000),
(2, 5, '8B', 1900000),
(2, 6, '22F', 1650000),
(3, 7, '5A', 4200000),
(3, 8, '5B', 4200000),
(3, 9, '18D', 3800000),
(4, 10, '11A', 2200000),
(4, 1, '11B', 2200000),
(4, 3, '20C', 2000000),
(5, 2, '9A', 1800000),
(5, 4, '9B', 1800000),
(5, 6, '14E', 1650000);

INSERT INTO Crew_Assignment (flight_id, crew_id, assignment_date) VALUES
(1, 11, '2025-07-23'),
(1, 12, '2025-07-23'),
(2, 13, '2025-07-23'),
(2, 14, '2025-07-23'),
(3, 15, '2025-07-23'),
(3, 11, '2025-07-23'),
(4, 12, '2025-07-24'),
(4, 13, '2025-07-24'),
(5, 14, '2025-07-24'),
(5, 15, '2025-07-24');

INSERT INTO Flight_Supervision (flight_id, airport_id, tower_id) VALUES
(1, 1, 1),
(1, 3, 3),
(2, 2, 2),
(2, 4, 4),
(3, 1, 1),
(3, 5, 5),
(4, 3, 3),
(4, 6, NULL),
(5, 4, 4),
(5, 10, NULL);
