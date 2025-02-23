DROP TABLE Municipality;
DROP TABLE Library;
DROP TABLE Bibus;
DROP TABLE Bibusero;
DROP TABLE Route;
DROP TABLE Stops;
DROP TABLE dL_Route_Stops;
DROP TABLE Users;
DROP TABLE Sanctions;
DROP TABLE Books;
DROP TABLE Contributors;
DROP TABLE AlternativeTitle;
DROP TABLE Awards;
DROP TABLE Edition;
DROP TABLE AdditionalLanguage;
DROP TABLE Copy;
DROP TABLE LibraryLoans;
DROP TABLE UserLoans;
DROP TABLE Comment;


-- Municipality and Library --------------------------------------------------


CREATE TABLE Municipality (
    name VARCHAR(64),
    province VARCHAR(64),
    population NUMBER,
    PRIMARY KEY (name, province)
);

CREATE TABLE Library (
    cif VARCHAR(64) PRIMARY KEY,
    name VARCHAR(64),
    date_of_foundation DATE,
    municipality_name VARCHAR(64),
    municipality_province VARCHAR(64),
    CONSTRAINT fk_municipality FOREIGN KEY (municipality_name, municipality_province) REFERENCES Municipality(name, province)
);


-- Bibus and Routes ----------------------------------------------------------


CREATE TABLE Bibus(
    license_plate VARCHAR(16) PRIMARY KEY,
    status VARCHAR(16) NOT NULL,     -- available, under_inspection, in_service 
    last_itv DATE NOT NULL,
    next_itv DATE
);

CREATE TABLE Bibusero(
    passport VARCHAR(9) PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    surname1 VARCHAR(64) NOT NULL,
    surname2 VARCHAR(64),
    phone_number VARCHAR(16),
    address VARCHAR(100),
    email VARCHAR(50),
    constract_start_date DATE NOT NULL,
    constract_end_date DATE    
    -- birthdate DATE
);

CREATE TABLE Route (
    route_id VARCHAR(5) PRIMARY KEY,
    date DATE NOT NULL,
    bibus VARCHAR(16),
    bibusero VARCHAR(9),    
    CONSTRAINT fk_bibus FOREIGN KEY (bibus) REFERENCES Bibus(license_plate),
    CONSTRAINT fk_bibusero FOREIGN KEY (passport) REFERENCES Bibusero(passport)
);

CREATE TABLE Stops (
    municipality_name VARCHAR(64),
    municipality_province VARCHAR(64),
    address VARCHAR(64),
    PRIMARY KEY (municipality_name, municipality_province, address),
    CONSTRAINT fk_municipality FOREIGN KEY (municipality_name, municipality_province) REFERENCES Municipality(name, province)
);

CREATE TABLE dL_Route_Stops (
    route_id VARCHAR(5),
    municipality_name VARCHAR(64),
    municipality_province VARCHAR(64),
    address VARCHAR(64),
    seq_order NUMBER,
    stop_time TIME,
    PRIMARY KEY (route_id, municipality_name, municipality_province, address),    
    CONSTRAINT fk_stop FOREIGN KEY (municipality_name, municipality_province, address) REFERENCES Stops(municipality_name, municipality_province, address),
    CONSTRAINT fk_route FOREIGN KEY (route_id) REFERENCES Route(route_id)
);


-- Books, Users and Loans ----------------------------------------------------


CREATE TABLE Users (
    user_id NUMBER PRIMARY KEY,
    name VARCHAR(64),
    surname1 VARCHAR(64) NOT NULL,
    surname2 VARCHAR(64),
    passport VARCHAR(9) UNIQUE,
    birthdate DATE,
    phone_number VARCHAR(16),
    municipality_name VARCHAR(64),
    municipality_province VARCHAR(64),
    address VARCHAR(64),
    email VARCHAR(50),
    CONSTRAINT fk_municipality FOREIGN KEY (municipality_name, municipality_province) REFERENCES Municipality(name, province)
);

CREATE TABLE Sanctions (
    user_id VARCHAR(5),
    date DATE,
    duration NUMBER,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Books (
    title VARCHAR(200),
    main_author VARCHAR(100),
    country_of_publication VARCHAR(100),
    original_language VARCHAR(100), 
    date_of_publication DATE, 
    topic VARCHAR(100),
    subject VARCHAR(100),
    content_notes VARCHAR(100),
    copyright VARCHAR(100), 
    number_of_publications NUMBER,
    PRIMARY KEY (title, main_author)
);

CREATE TABLE Contributors (
    author VARCHAR(100),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (author, book_title, book_author),
    CONSTRAINT fk_book FOREIGN KEY (book_title, book_author) REFERENCES Books(title, main_author)
);

CREATE TABLE AlternativeTitle (
    title VARCHAR(200),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (title, book_title, book_author),
    CONSTRAINT fk_book FOREIGN KEY (book_title, book_author) REFERENCES Books(title, main_author)
);

CREATE TABLE Awards (
    name VARCHAR(200),
    book_title VARCHAR(200),
    book_author VARCHAR(100),
    PRIMARY KEY (name, book_title, book_author),
    CONSTRAINT fk_book FOREIGN KEY (book_title, book_author) REFERENCES Books(title, main_author)
);

CREATE TABLE Edition (
    isbn VARCHAR(20) PRIMARY KEY, 
    book VARCHAR(200), 
    edition VARCHAR(200), 
    publisher VARCHAR(200), 
    length VARCHAR(200), 
    series VARCHAR(200), 
    legal deposit VARCHAR(200), 
    place_of_publication VARCHAR(200), 
    dimensions VARCHAR(200), 		
    physical_features VARCHAR(200), 
    ancillary VARCHAR(200), 
    notes VARCHAR(200), 
    national_library_id NUMBER UNIQUE,
    URL VARCHAR(200) UNIQUE,
    CONSTRAINT fk_book FOREIGN KEY (book_title, book_author) REFERENCES Books(title, main_author)
);

CREATE TABLE AdditionalLanguage (
    edition VARCHAR(20),
    language VARCHAR(200),
    PRIMARY KEY (isbn, language),
    CONSTRAINT fk_edition FOREIGN KEY (edition) REFERENCES Edition(isbn)
);

CREATE TABLE Copy (
    signature VARCHAR(5) PRIMARY KEY, 
    edition VARCHAR(20) NOT NULL, 
    condition VARCHAR(200), 
    comments VARCHAR(200), 
    deregistration_date VARCHAR(200),
    CONSTRAINT fk_edition FOREIGN KEY (edition) REFERENCES Edition(isbn)
);

CREATE TABLE LibraryLoans (
    library VARCHAR(200),
    copy VARCHAR(200),
    start_date VARCHAR(100),
    return_date VARCHAR(100),
    PRIMARY KEY (copy, start_date),
    CONSTRAINT fk_library FOREIGN KEY (library) REFERENCES Library(cif),
    CONSTRAINT fk_copy FOREIGN KEY (copy) REFERENCES Copy(signature)
);

CREATE TABLE UserLoans (
    user VARCHAR(200),
    copy VARCHAR(200),
    start_date VARCHAR(100),
    return_date VARCHAR(100),
    PRIMARY KEY (copy, start_date),
    CONSTRAINT fk_user FOREIGN KEY (user) REFERENCES User(user_id),
    CONSTRAINT fk_copy FOREIGN KEY (copy) REFERENCES Copy(signature)
);

CREATE TABLE Comments (
    loan_copy VARCHAR(200),
    loan_date DATE,
    post VARCHAR(200),
    post_date DATE,
    likes NUMBER,
    dislikes NUMBER,
    PRIMARY KEY (loan_copy, loan_date),
    CONSTRAINT fk_loan FOREIGN KEY (loan_copy, loan_date) REFERENCES UserLoans(copy, start_date)
);
