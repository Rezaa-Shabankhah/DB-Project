DROP DATABASE IF EXISTS airline_management;
CREATE DATABASE airline_management 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE airline_management;

CREATE TABLE Person (
    person_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
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
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_points CHECK (customer_points >= 0)
);

CREATE TABLE Travel_Companion (
    passenger_id INT PRIMARY KEY,
    companion_id INT,
    FOREIGN KEY (passenger_id) REFERENCES Passenger(person_id) ON DELETE CASCADE,
    FOREIGN KEY (companion_id) REFERENCES Passenger(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_not_self_companion CHECK (passenger_id != companion_person_id),
    UNIQUE KEY unique_companion_pair (passenger_id, companion_person_id)
);

CREATE TABLE Flight_Crew (
    person_id INT PRIMARY KEY,
    flight_experience_hours INT DEFAULT 0,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_flight_experience CHECK (flight_experience_hours >= 0)
);

CREATE TABLE Airport (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_name VARCHAR(100) NOT NULL,
);

CREATE TABLE Control_Tower (
    tower_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_id INT UNIQUE NOT NULL,
    radar_range_km INT DEFAULT 100,
    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id) ON DELETE CASCADE,
    CONSTRAINT chk_radar_range CHECK (radar_range_km > 0 AND radar_range_km <= 500)
);

CREATE TABLE Employee (
    person_id INT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    work_experience_months INT DEFAULT 0,
    manager_id INT,
    airport_id INT,
    tower_id INT,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES Employee(person_id) ON DELETE SET NULL,
    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id) ON DELETE SET NULL,
    FOREIGN KEY (tower_id) REFERENCES Control_Tower(tower_id) ON DELETE SET NULL,
    CONSTRAINT chk_work_experience CHECK (work_experience_months >= 0),
    CONSTRAINT chk_not_self_manager CHECK (person_id != manager_id)
);

CREATE TABLE Airplane (
    airplane_id INT PRIMARY KEY AUTO_INCREMENT,
    capacity INT NOT NULL,
    CONSTRAINT chk_airplane_capacity CHECK (capacity > 0)
);

CREATE TABLE Route (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    FOREIGN KEY (origin_airport_id) REFERENCES Airport(airport_id),
    FOREIGN KEY (destination_airport_id) REFERENCES Airport(airport_id),
    CONSTRAINT chk_different_airports CHECK (origin_airport_id != destination_airport_id),
);

CREATE TABLE Flight (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(20) UNIQUE NOT NULL,
    route_id INT NOT NULL,
    airplane_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    replacement_flight_id INT UNIQUE,
    FOREIGN KEY (route_id) REFERENCES Route(route_id),
    FOREIGN KEY (airplane_id) REFERENCES Airplane(airplane_id),
    FOREIGN KEY (replacement_flight_id) REFERENCES Flight(flight_id) ON DELETE SET NULL,
    CONSTRAINT chk_flight_times CHECK (departure_time < arrival_time),
    CONSTRAINT chk_not_self_replacement CHECK (flight_id != replacement_flight_id)
);

CREATE TABLE Ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
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
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES Flight_Crew(person_id) ON DELETE CASCADE,
);

CREATE TABLE Flight_Supervision (
    supervision_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    airport_id INT NOT NULL,
    tower_id INT NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (airport_id) REFERENCES Airport(airport_id),
    FOREIGN KEY (tower_id) REFERENCES Control_Tower(tower_id),
);

CREATE INDEX idx_person_name ON Person(last_name, first_name);
CREATE INDEX idx_phone_person ON Phone(person_id);
CREATE INDEX idx_flight_departure ON Flight(departure_time);
CREATE INDEX idx_flight_route ON Flight(route_id);
CREATE INDEX idx_ticket_passenger ON Ticket(passenger_id);
CREATE INDEX idx_ticket_flight ON Ticket(flight_id);
CREATE INDEX idx_crew_assignment_flight ON Crew_Assignment(flight_id);
CREATE INDEX idx_employee_manager ON Employee(manager_id);
