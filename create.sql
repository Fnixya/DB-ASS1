DROP TABLE Bibus;
DROP TABLE Bibusero;
DROP TABLE Route;

CREATE TABLE Bibus(
    license_plate VARCHAR(16) PRIMARY KEY,
    status VARCHAR(16) NOT NULL,     -- available, under_inspection, in_service 
    last_itv DATE NOT NULL,
    next_itv DATE,
);

CREATE TABLE Bibusero(
    passport VARCHAR(9) PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    surname1 VARCHAR(64) NOT NULL,
    surname2 VARCHAR(64),
    phone_number VARCHAR(16),
    address
    email VARCHAR(50),
    constract_start_date DATE NOT NULL,
    constract_end_date DATE,    
    -- birthdate DATE,
);

CREATE TABLE Route (
    route_id VARCHAR(5) PRIMARY KEY,
    date DATE,
    license_plate VARCHAR(16),
    passport VARCHAR(9),    
    CONSTRAINT fk_bibus FOREIGN KEY (license_plate) REFERENCES Bibus(license_plate),
    CONSTRAINT fk_bibusero FOREIGN KEY (passport) REFERENCES Bibusero(passport),
);