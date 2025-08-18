DROP DATABASE IF EXISTS airline_management;
CREATE DATABASE airline_management 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE airline_management;

CREATE TABLE Person (
    person_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_person_name CHECK (LENGTH(TRIM(first_name)) > 0 AND LENGTH(TRIM(last_name)) > 0)
);

CREATE TABLE Phone (
    phone_id INT PRIMARY KEY AUTO_INCREMENT,
    person_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    phone_type ENUM('mobile', 'home', 'work') DEFAULT 'mobile',
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_phone_format CHECK (phone_number REGEXP '^\\+[0-9]{10,15}$'),
    UNIQUE KEY unique_phone (phone_number)
);

CREATE TABLE Passenger (
    person_id INT PRIMARY KEY,
    customer_points INT DEFAULT 0,
    membership_level ENUM('Bronze', 'Silver', 'Gold', 'Platinum') DEFAULT 'Bronze',
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_points CHECK (customer_points >= 0)
);

CREATE TABLE Travel_Companion (
    companion_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    companion_person_id INT NOT NULL,
    relationship_type VARCHAR(50) DEFAULT 'Friend',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (passenger_id) REFERENCES Passenger(person_id) ON DELETE CASCADE,
    FOREIGN KEY (companion_person_id) REFERENCES Passenger(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_not_self_companion CHECK (passenger_id != companion_person_id),
    UNIQUE KEY unique_companion_pair (passenger_id, companion_person_id)
);

CREATE TABLE Flight_Crew (
    person_id INT PRIMARY KEY,
    flight_experience_hours INT DEFAULT 0,
    certification_level ENUM('Junior', 'Senior', 'Captain') DEFAULT 'Junior',
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_flight_experience CHECK (flight_experience_hours >= 0)
);

CREATE TABLE Airport (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_code VARCHAR(10) UNIQUE NOT NULL,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'Iran',
    timezone VARCHAR(50) DEFAULT 'Asia/Tehran',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_airport_code CHECK (LENGTH(airport_code) >= 3)
);

CREATE TABLE Control_Tower (
    tower_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_id INT UNIQUE NOT NULL,
    tower_code VARCHAR(10) UNIQUE NOT NULL,
    radar_range_km INT DEFAULT 100,
    operational_status ENUM('Active', 'Maintenance', 'Inactive') DEFAULT 'Active',
    last_maintenance DATE,
    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id) ON DELETE CASCADE,
    CONSTRAINT chk_radar_range CHECK (radar_range_km > 0 AND radar_range_km <= 500)
);

CREATE TABLE Employee (
    person_id INT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    work_experience_months INT DEFAULT 0,
    salary DECIMAL(10,2),
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    manager_id INT,
    airport_id INT,
    tower_id INT,
    department ENUM('Operations', 'Maintenance', 'Security', 'Administration') DEFAULT 'Operations',
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES Employee(person_id) ON DELETE SET NULL,
    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id) ON DELETE SET NULL,
    FOREIGN KEY (tower_id) REFERENCES Control_Tower(tower_id) ON DELETE SET NULL,
    CONSTRAINT chk_work_experience CHECK (work_experience_months >= 0),
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT chk_not_self_manager CHECK (person_id != manager_id)
);

CREATE TABLE Aircraft_Model (
    model_id INT PRIMARY KEY AUTO_INCREMENT,
    model_name VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    typical_capacity INT NOT NULL,
    max_range_km INT NOT NULL,
    fuel_efficiency DECIMAL(5,2),
    CONSTRAINT chk_capacity CHECK (typical_capacity > 0),
    CONSTRAINT chk_range CHECK (max_range_km > 0)
);

CREATE TABLE Airplane (
    airplane_id INT PRIMARY KEY AUTO_INCREMENT,
    aircraft_model_id INT NOT NULL,
    tail_number VARCHAR(20) UNIQUE NOT NULL,
    capacity INT NOT NULL,
    manufacture_date DATE,
    last_maintenance DATE,
    status ENUM('Active', 'Maintenance', 'Retired') DEFAULT 'Active',
    FOREIGN KEY (aircraft_model_id) REFERENCES Aircraft_Model(model_id),
    CONSTRAINT chk_airplane_capacity CHECK (capacity > 0)
);

CREATE TABLE Route (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    distance_km INT NOT NULL,
    estimated_duration_minutes INT NOT NULL,
    route_code VARCHAR(20) UNIQUE NOT NULL,
    FOREIGN KEY (origin_airport_id) REFERENCES Airport(airport_id),
    FOREIGN KEY (destination_airport_id) REFERENCES Airport(airport_id),
    CONSTRAINT chk_different_airports CHECK (origin_airport_id != destination_airport_id),
    CONSTRAINT chk_distance CHECK (distance_km > 0),
    CONSTRAINT chk_duration CHECK (estimated_duration_minutes > 0)
);

CREATE TABLE Flight (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(20) UNIQUE NOT NULL,
    route_id INT NOT NULL,
    airplane_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    replacement_flight_id INT UNIQUE,
    status ENUM('Scheduled', 'Boarding', 'Departed', 'Arrived', 'Cancelled', 'Delayed') DEFAULT 'Scheduled',
    base_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (route_id) REFERENCES Route(route_id),
    FOREIGN KEY (airplane_id) REFERENCES Airplane(airplane_id),
    FOREIGN KEY (replacement_flight_id) REFERENCES Flight(flight_id) ON DELETE SET NULL,
    CONSTRAINT chk_flight_times CHECK (departure_time < arrival_time),
    CONSTRAINT chk_base_price CHECK (base_price > 0),
    CONSTRAINT chk_not_self_replacement CHECK (flight_id != replacement_flight_id)
);

CREATE TABLE Ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    ticket_class ENUM('Economy', 'Business', 'First') DEFAULT 'Economy',
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('Confirmed', 'Cancelled', 'Checked-In') DEFAULT 'Confirmed',
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES Passenger(person_id) ON DELETE CASCADE,
    UNIQUE KEY unique_seat_flight (flight_id, seat_number),
    CONSTRAINT chk_ticket_price CHECK (price > 0)
);

CREATE TABLE Crew_Assignment (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    assignment_date DATE NOT NULL,
    role ENUM('Pilot', 'Co-Pilot', 'Flight Attendant', 'Engineer') NOT NULL,
    assignment_status ENUM('Assigned', 'Confirmed', 'Completed') DEFAULT 'Assigned',
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES Flight_Crew(person_id) ON DELETE CASCADE,
    UNIQUE KEY unique_crew_flight_role (flight_id, crew_id, role)
);

CREATE TABLE Flight_Supervision (
    supervision_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    airport_id INT NOT NULL,
    tower_id INT NOT NULL,
    supervision_type ENUM('Departure', 'Arrival', 'Transit') NOT NULL,
    supervision_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id),
    FOREIGN KEY (tower_id) REFERENCES Control_Tower(tower_id),
    UNIQUE KEY unique_flight_airport_type (flight_id, airport_id, supervision_type)
);

CREATE INDEX idx_person_name ON Person(last_name, first_name);
CREATE INDEX idx_phone_person ON Phone(person_id);
CREATE INDEX idx_flight_departure ON Flight(departure_time);
CREATE INDEX idx_flight_route ON Flight(route_id);
CREATE INDEX idx_ticket_passenger ON Ticket(passenger_id);
CREATE INDEX idx_ticket_flight ON Ticket(flight_id);
CREATE INDEX idx_crew_assignment_flight ON Crew_Assignment(flight_id);
CREATE INDEX idx_employee_manager ON Employee(manager_id);
