-- good
INSERT INTO Bibus (license_plate, last_itv, next_itv)
    SELECT DISTINCT 
        MIN(PLATE), 
        MAX(TO_TIMESTAMP(LAST_ITV, 'dd.mm.yyyy//HH24:MI:SS')), 
        MIN(TO_DATE(NEXT_ITV, 'dd.mm.yyyy'))
    FROM FSDB.BUSSTOPS
    WHERE plate IS NOT NULL AND last_itv IS NOT NULL AND next_itv IS NOT NULL
    GROUP BY PLATE
;

-- good
INSERT INTO Bibuseros (passport, fullname, phone_number, address, email, contract_start_date, contract_end_date, birthdate)
    SELECT DISTINCT 
        LIB_PASSPORT,
        LIB_FULLNAME,
        TO_NUMBER(LIB_PHONE),
        LIB_ADDRESS,
        LIB_EMAIL,
        TO_DATE(CONT_START, 'dd.mm.yyyy'),
        TO_DATE(CONT_END, 'dd.mm.yyyy'),
        CASE
            WHEN VALIDATE_CONVERSION(LIB_BIRTHDATE AS DATE, 'dd-mm-yyyy') = 1 THEN
                TO_DATE(LIB_BIRTHDATE, 'dd-mm-yyyy')
            ELSE
                NULL
        END AS LIB_BIRTHDATE
    FROM FSDB.BUSSTOPS
;

-- good
INSERT INTO Municipalities SELECT DISTINCT town, province, to_number(population) FROM fsdb.busstops;

-- good
INSERT INTO Routes 
    SELECT DISTINCT 
        ROUTE_ID,
        TO_DATE(STOPDATE, 'dd-mm-yyyy'),
        PLATE,
        LIB_PASSPORT
    FROM FSDB.BUSSTOPS
;

-- good
INSERT INTO Stops 
    SELECT DISTINCT 
        TOWN,
        PROVINCE,
        ADDRESS
    FROM FSDB.BUSSTOPS
;

-- good, i think
INSERT INTO dL_Route_Stops 
    SELECT DISTINCT 
        ROUTE_ID,
        TOWN,
        PROVINCE,
        ADDRESS,
        ROW_NUMBER() OVER (PARTITION BY ROUTE_ID ORDER BY STOPTIME) AS SEQ_ORDER,
        TO_TIMESTAMP(STOPTIME, 'HH24:MI:SS') AS STOPTIME
    FROM FSDB.BUSSTOPS
;

-- Books, Users and Loans ----------------------------------------------------

INSERT INTO Libraries VALUES();

-- users have duplicated addresses
-- unique constraint error
-- should we make address a separate relation?
INSERT INTO Users
    SELECT DISTINCT
        TO_NUMBER(FSDB.LOANS.USER_ID),
        FSDB.LOANS.NAME, 
        FSDB.LOANS.SURNAME1, 
        FSDB.LOANS.SURNAME2,
        FSDB.LOANS.PASSPORT, 
        CASE
            WHEN VALIDATE_CONVERSION(FSDB.LOANS.BIRTHDATE AS DATE, 'dd-mm-yyyy') = 1 THEN
                TO_DATE(FSDB.LOANS.BIRTHDATE, 'dd-mm-yyyy')
            ELSE
                NULL
            END AS 
        BIRTHDATE,
        TO_NUMBER(FSDB.LOANS.PHONE),
        FSDB.LOANS.TOWN,
        MUNICIPALITIES.PROVINCE,
        FSDB.LOANS.ADDRESS,
        FSDB.LOANS.EMAIL
    FROM FSDB.LOANS
    JOIN MUNICIPALITIES
    ON FSDB.LOANS.TOWN = MUNICIPALITIES.NAME
;

-- doesnt work
INSERT INTO Books 
    SELECT DISTINCT
        TITLE, 
        MAIN_AUTHOR,
        PUB_COUNTRY,
        ORIGINAL_LANGUAGE,
        TO_DATE(PUB_DATE, 'yyyy'),
        TOPIC,
        CONTENT_NOTES,
        COPYRIGHT
    FROM FSDB.ACERVUS;

INSERT INTO Awards VALUES();

INSERT INTO Contributors VALUES();
INSERT INTO AlternativeTitle VALUES();


INSERT INTO Edition VALUES();

INSERT INTO Sanctions VALUES();

-- not working
INSERT INTO Copies 
    SELECT 
        SIGNATURE, 
        ISBN,
        condition,
        COMMENTS,
        -- deregistration_date
    FROM FSDB.ACERVUS
    WHERE SIGNATURE IS NOT NULL AND ISBN IS NOT NULL AND COMMENTS IS NOT NULL
;

-- need edition
INSERT INTO AdditionalLanguage VALUES();

INSERT INTO UserLoans VALUES();
INSERT INTO LibraryLoans VALUES();

INSERT INTO Comments VALUES();
