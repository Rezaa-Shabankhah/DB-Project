USE airline_management;

INSERT INTO Aircraft_Model (model_name, manufacturer, typical_capacity, max_range_km, fuel_efficiency) VALUES
('Boeing 737-800', 'Boeing', 180, 5765, 2.5),
('Airbus A320', 'Airbus', 150, 6150, 2.3),
('Boeing 777-300ER', 'Boeing', 320, 13649, 3.2),
('Airbus A330-300', 'Airbus', 295, 11750, 2.8),
('Boeing 737-700', 'Boeing', 140, 6038, 2.4);

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

INSERT INTO Airport (airport_code, airport_name, city, country, timezone) VALUES
('IKA', 'Imam Khomeini International Airport', 'Tehran', 'Iran', 'Asia/Tehran'),
('THR', 'Mehrabad International Airport', 'Tehran', 'Iran', 'Asia/Tehran'),
('SYZ', 'Shiraz Shahid Dastgheib International Airport', 'Shiraz', 'Iran', 'Asia/Tehran'),
('IFN', 'Isfahan Shahid Beheshti International Airport', 'Isfahan', 'Iran', 'Asia/Tehran'),
('MHD', 'Mashhad Shahid Hashemi Nejad International Airport', 'Mashhad', 'Iran', 'Asia/Tehran'),
('TBZ', 'Tabriz International Airport', 'Tabriz', 'Iran', 'Asia/Tehran'),
('KER', 'Kerman Airport', 'Kerman', 'Iran', 'Asia/Tehran'),
('BND', 'Bandar Abbas International Airport', 'Bandar Abbas', 'Iran', 'Asia/Tehran'),
('AWZ', 'Ahvaz Jundishapur Airport', 'Ahvaz', 'Iran', 'Asia/Tehran'),
('KIH', 'Kish International Airport', 'Kish', 'Iran', 'Asia/Tehran');

INSERT INTO Control_Tower (airport_id, tower_code, radar_range_km, operational_status, last_maintenance) VALUES
(1, 'IKA-TWR', 250, 'Active', '2024-12-15'),
(2, 'THR-TWR', 200, 'Active', '2024-11-20'),
(3, 'SYZ-TWR', 180, 'Active', '2024-10-10'),
(4, 'IFN-TWR', 160, 'Active', '2024-09-25'),
(5, 'MHD-TWR', 220, 'Active', '2024-12-01');

INSERT INTO Airplane (aircraft_model_id, tail_number, capacity, manufacture_date, status) VALUES
(1, 'EP-IBB', 180, '2018-05-15', 'Active'),
(2, 'EP-IBC', 150, '2019-03-22', 'Active'),
(3, 'EP-IBD', 320, '2020-07-10', 'Active'),
(4, 'EP-IBE', 295, '2017-11-08', 'Active'),
(5, 'EP-IBF', 140, '2021-01-18', 'Active');

INSERT INTO Route (origin_airport_id, destination_airport_id, distance_km, estimated_duration_minutes, route_code) VALUES
(1, 3, 925, 85, 'IKA-SYZ'),
(2, 4, 420, 60, 'THR-IFN'),
(1, 5, 850, 90, 'IKA-MHD'),
(3, 6, 1200, 110, 'SYZ-TBZ'),
(4, 10, 780, 95, 'IFN-KIH');

INSERT INTO Passenger (person_id, customer_points, membership_level, registration_date) VALUES
(1, 2500, 'Silver', '2023-01-15'),
(2, 100, 'Bronze', '2024-12-01'),
(3, 0, 'Bronze', '2025-01-10'),
(4, 890, 'Bronze', '2023-06-20'),
(5, 1650, 'Bronze', '2023-08-12'),
(6, 4200, 'Gold', '2022-03-10'),
(7, 750, 'Bronze', '2024-02-28'),
(8, 2100, 'Silver', '2023-11-05'),
(9, 1800, 'Bronze', '2024-01-20'),
(10, 920, 'Bronze', '2024-05-15');

INSERT INTO Travel_Companion (passenger_id, companion_person_id, relationship_type) VALUES
(1, 2, 'Friend'),
(1, 4, 'Colleague'),
(4, 1, 'Colleague'),
(4, 8, 'Spouse'),
(9, 10, 'Friend');

INSERT INTO Flight_Crew (person_id, flight_experience_hours, certification_level, hire_date) VALUES
(11, 1500, 'Senior', '2020-03-15'),
(12, 4200, 'Captain', '2018-07-20'),
(13, 6500, 'Captain', '2015-01-10'),
(14, 4100, 'Captain', '2017-09-05'),
(15, 900, 'Junior', '2022-11-12');

INSERT INTO Employee (person_id, employee_id, work_experience_months, salary, manager_id, airport_id, tower_id, department, hire_date) VALUES
(16, 'EMP001', 48, 75000.00, NULL, NULL, 1, 'Operations', '2021-01-15'),
(17, 'EMP002', 36, 55000.00, 16, 1, NULL, 'Operations', '2021-07-20'),
(18, 'EMP003', 24, 45000.00, 16, 1, NULL, 'Maintenance', '2022-06-10'),
(19, 'EMP004', 60, 85000.00, NULL, 4, NULL, 'Administration', '2019-08-15'),
(20, 'EMP005', 42, 65000.00, 19, NULL, 5, 'Operations', '2020-12-05');

INSERT INTO Flight (flight_number, route_id, airplane_id, departure_time, arrival_time, replacement_flight_id, status, base_price) VALUES
('IR101', 1, 1, '2025-07-24 08:30:00', '2025-07-24 09:55:00', 5, 'Scheduled', 2500000),
('IR202', 2, 2, '2025-07-24 14:15:00', '2025-07-24 15:15:00', NULL, 'Scheduled', 1800000),
('IR303', 3, 3, '2025-07-24 19:45:00', '2025-07-24 21:15:00', NULL, 'Scheduled', 4000000),
('IR404', 4, 4, '2025-07-25 06:20:00', '2025-07-25 08:10:00', NULL, 'Scheduled', 2100000),
('IR505', 5, 5, '2025-07-25 16:10:00', '2025-07-25 17:45:00', NULL, 'Scheduled', 1700000);

INSERT INTO Ticket (flight_id, passenger_id, seat_number, price, ticket_class, booking_status) VALUES
(1, 1, '12A', 2800000, 'Economy', 'Confirmed'),
(1, 2, '12B', 2800000, 'Economy', 'Confirmed'),
(1, 3, '15C', 2500000, 'Economy', 'Confirmed'),
(2, 4, '8A', 1900000, 'Economy', 'Confirmed'),
(2, 5, '8B', 1900000, 'Economy', 'Confirmed'),
(2, 6, '22F', 1650000, 'Economy', 'Confirmed'),
(3, 7, '5A', 4200000, 'Business', 'Confirmed'),
(3, 8, '5B', 4200000, 'Business', 'Confirmed'),
(3, 9, '18D', 3800000, 'Economy', 'Confirmed'),
(4, 10, '11A', 2200000, 'Economy', 'Confirmed'),
(4, 1, '11B', 2200000, 'Economy', 'Confirmed'),
(4, 3, '20C', 2000000, 'Economy', 'Confirmed'),
(5, 2, '9A', 1800000, 'Economy', 'Confirmed'),
(5, 4, '9B', 1800000, 'Economy', 'Confirmed'),
(5, 6, '14E', 1650000, 'Economy', 'Confirmed');

INSERT INTO Crew_Assignment (flight_id, crew_id, assignment_date, role, assignment_status) VALUES
(1, 11, '2025-07-23', 'Pilot', 'Confirmed'),
(1, 12, '2025-07-23', 'Co-Pilot', 'Confirmed'),
(2, 13, '2025-07-23', 'Pilot', 'Confirmed'),
(2, 14, '2025-07-23', 'Flight Attendant', 'Confirmed'),
(3, 15, '2025-07-23', 'Flight Attendant', 'Confirmed'),
(3, 11, '2025-07-23', 'Flight Attendant', 'Confirmed'),
(4, 12, '2025-07-24', 'Pilot', 'Confirmed'),
(4, 13, '2025-07-24', 'Co-Pilot', 'Confirmed'),
(5, 14, '2025-07-24', 'Pilot', 'Confirmed'),
(5, 15, '2025-07-24', 'Flight Attendant', 'Confirmed');

INSERT INTO Flight_Supervision (flight_id, airport_id, tower_id, supervision_type) VALUES
(1, 1, 1, 'Departure'),
(1, 3, 3, 'Arrival'),
(2, 2, 2, 'Departure'),
(2, 4, 4, 'Arrival'),
(3, 1, 1, 'Departure'),
(3, 5, 5, 'Arrival'),
(4, 3, 3, 'Departure'),
(4, 6, NULL, 'Arrival'),
(5, 4, 4, 'Departure'),
(5, 10, NULL, 'Arrival');
