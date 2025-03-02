DROP TABLE Comments;
DROP TABLE UserLoans;
DROP TABLE LibraryLoans;
DROP TABLE Copies;
DROP TABLE AdditionalLanguages;
DROP TABLE Editions;
DROP TABLE Awards;
DROP TABLE AlternativeTitles;
DROP TABLE Contributors;
DROP TABLE Books;
DROP TABLE Sanctions;
DROP TABLE Users;
DROP TABLE dL_Route_Stops;
DROP TABLE Stops;
DROP TABLE Routes;
DROP TABLE Bibuseros;
DROP TABLE Bibus;
DROP TABLE Libraries;
DROP TABLE Municipalities;


-- Municipalities and Libraries --------------------------------------------------


CREATE TABLE Municipalities (
    name VARCHAR(50),
    province VARCHAR(22),
    population NUMBER DEFAULT 0 CHECK (population >= 0),
    PRIMARY KEY (name, province)
);

CREATE TABLE Libraries (
    cif VARCHAR(20) PRIMARY KEY,
    name VARCHAR(80) CHECK (name LIKE 'Biblioteca%'),
    date_of_foundation DATE,
    municipality_name VARCHAR(50),
    municipality_province VARCHAR(22),
    address VARCHAR(100),
    email VARCHAR(100),
    phone_number NUMBER CHECK (phone_number > 99999999 AND phone_number < 1000000000),
    CONSTRAINT fk_municipality_library FOREIGN KEY (municipality_name, municipality_province) 
        REFERENCES Municipalities(name, province)
        ON DELETE CASCADE
);


-- Bibus and Routes ----------------------------------------------------------


CREATE TABLE Bibus(
    license_plate VARCHAR(16) PRIMARY KEY,
    status VARCHAR(32) DEFAULT 'AVAILABLE' 
        CHECK (status IN ('AVAILABLE', 'ASSIGNED', 'TECHNICAL INSPECTION')),     -- 
    last_itv DATE NOT NULL,
    next_itv DATE NOT NULL
);

CREATE TABLE Bibuseros(
    passport VARCHAR(20) PRIMARY KEY,
    fullname VARCHAR(80) NOT NULL,
    phone_number NUMBER NOT NULL CHECK (phone_number > 99999999 AND phone_number < 1000000000),
    address VARCHAR(100),
    email VARCHAR(100) NOT NULL,
    status VARCHAR(32) DEFAULT 'AVAILABLE' 
        CHECK (status IN ('AVAILABLE', 'ASSIGNED', 'TECHNICAL INSPECTION')),     -- available, technical inspection, assigned 
    contract_start_date DATE NOT NULL,
    contract_end_date DATE,                    -- CAN BE NULL  
    birthdate DATE
);

CREATE TABLE Routes (
    route_id VARCHAR(5) PRIMARY KEY,
    day DATE NOT NULL,
    bibus VARCHAR(16),
    bibusero VARCHAR(20),    
    CONSTRAINT fk_bibus FOREIGN KEY (bibus) 
        REFERENCES Bibus(license_plate),
    CONSTRAINT fk_bibusero FOREIGN KEY (bibusero) 
        REFERENCES Bibuseros(passport)
);

CREATE TABLE Stops (
    municipality_name VARCHAR(50),
    municipality_province VARCHAR(22),
    address VARCHAR(150) NOT NULL,
    PRIMARY KEY (municipality_name, municipality_province, address),
    CONSTRAINT fk_municipality_stops FOREIGN KEY (municipality_name, municipality_province) 
        REFERENCES Municipalities(name, province)
);

CREATE TABLE dL_Route_Stops (
    route_id VARCHAR(5),
    municipality_name VARCHAR(64),
    municipality_province VARCHAR(64),
    address VARCHAR(100) NOT NULL,
    seq_order NUMBER CHECK (seq_order > 0),
    stop_time DATE,
    PRIMARY KEY (route_id, municipality_name, municipality_province, address),    
    CONSTRAINT fk_stop FOREIGN KEY (municipality_name, municipality_province, address) 
        REFERENCES Stops(municipality_name, municipality_province, address) 
        ON DELETE CASCADE,
    CONSTRAINT fk_route FOREIGN KEY (route_id) 
        REFERENCES Routes(route_id) ON DELETE CASCADE
);


-- Books, Users and Loans ----------------------------------------------------


CREATE TABLE Users (
    user_id NUMBER PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    surname1 VARCHAR(80) NOT NULL,
    surname2 VARCHAR(80),
    passport VARCHAR(20) UNIQUE,
    birthdate DATE NOT NULL,
    phone_number NUMBER NOT NULL CHECK (phone_number > 99999999 AND phone_number < 1000000000),
    municipality_name VARCHAR(50),
    municipality_province VARCHAR(22),
    address VARCHAR(150) NOT NULL,
    email VARCHAR(100),
    CONSTRAINT fk_municipality_users FOREIGN KEY (municipality_name, municipality_province) 
        REFERENCES Municipalities(name, province)
        ON DELETE SET NULL
);

CREATE TABLE Sanctions (
    user_id NUMBER,
    day DATE NOT NULL,
    duration NUMBER NOT NULL CHECK (duration >= 0),
    PRIMARY KEY (user_id, day),
    CONSTRAINT fk_user_sanctions FOREIGN KEY (user_id) 
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE Books (
    title VARCHAR(200),
    main_author VARCHAR(100),
    original_language VARCHAR(50), 
    topic VARCHAR(550),
    content_notes VARCHAR(100),
    number_of_publications NUMBER,
    PRIMARY KEY (title, main_author)
);

CREATE TABLE Contributors (
    author VARCHAR(200),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (author, book_title, book_author),
    CONSTRAINT fk_book_contributors FOREIGN KEY (book_title, book_author) 
        REFERENCES Books(title, main_author)
        ON DELETE CASCADE
);

CREATE TABLE AlternativeTitles (
    title VARCHAR(200),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (title, book_title, book_author),
    CONSTRAINT fk_book_alt_title FOREIGN KEY (book_title, book_author) 
        REFERENCES Books(title, main_author)
        ON DELETE CASCADE
);

CREATE TABLE Awards (
    name VARCHAR(200),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (name, book_title, book_author),
    CONSTRAINT fk_book_awards FOREIGN KEY (book_title, book_author) 
        REFERENCES Books(title, main_author)
        ON DELETE CASCADE
);

CREATE TABLE Editions (
    isbn VARCHAR(20) PRIMARY KEY, 
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    edition VARCHAR(50), 
    publisher VARCHAR(100), 
    extension VARCHAR(200), 
    series VARCHAR(50), 
    legal_deposit VARCHAR(200), 
    place_of_publication VARCHAR(50), 
    date_of_publication DATE,
    copyright VARCHAR(20),
    dimensions VARCHAR(50),		
    physical_features VARCHAR(200), 
    attached_materials VARCHAR(200), 
    notes VARCHAR(500),
    national_library_id VARCHAR(20) UNIQUE,
    URL VARCHAR(200),
    CONSTRAINT fk_book_edition FOREIGN KEY (book_title, book_author) 
        REFERENCES Books(title, main_author)
        ON DELETE CASCADE
);

CREATE TABLE AdditionalLanguages (
    language VARCHAR(200),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (language, book_title, book_author),
    CONSTRAINT fk_book_add_language FOREIGN KEY (book_title, book_author) 
        REFERENCES Books(title, main_author)
        ON DELETE CASCADE
);

CREATE TABLE Copies (
    signature VARCHAR(20) PRIMARY KEY, 
    edition VARCHAR(20), 
    condition VARCHAR(16)
        CHECK (condition IN ('NEW', 'GOOD', 'WORN', 'VERY USED', 'DETERIORATED')),
    -- notes VARCHAR(500), 
    deregistration_date DATE,
    CONSTRAINT fk_edition_copy FOREIGN KEY (edition) 
        REFERENCES Editions(isbn)
);

CREATE TABLE LibraryLoans (
    library VARCHAR(20),
    copy VARCHAR(20),
    start_date date,
    return_date date,
    PRIMARY KEY (copy, start_date),
    CONSTRAINT fk_library FOREIGN KEY (library) 
        REFERENCES Libraries(cif),
    CONSTRAINT fk_copy_lib_loan FOREIGN KEY (copy) 
        REFERENCES Copies(signature)
);

CREATE TABLE UserLoans (
    user_id NUMBER,
    copy VARCHAR(20),
    start_date DATE,
    return_date DATE,
    PRIMARY KEY (copy, start_date),
    CONSTRAINT fk_user_loan FOREIGN KEY (user_id) 
        REFERENCES Users(user_id),
    CONSTRAINT fk_copy_usr_loan FOREIGN KEY (copy) 
        REFERENCES Copies(signature)
);

CREATE TABLE Comments (
    loan_copy VARCHAR(20),
    loan_date DATE,
    return DATE,
    post VARCHAR(2000) NOT NULL,
    post_date DATE NOT NULL,
    likes NUMBER DEFAULT 0 CHECK (likes >= 0),
    dislikes NUMBER DEFAULT 0 CHECK (dislikes >= 0),
    PRIMARY KEY (loan_copy, loan_date),
    CONSTRAINT fk_loan FOREIGN KEY (loan_copy, loan_date) 
        REFERENCES UserLoans(copy, start_date)
        ON DELETE CASCADE
);
