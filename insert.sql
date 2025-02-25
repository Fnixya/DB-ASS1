INSERT INTO Bibus (license_plate, last_itv, next_itv)
    SELECT DISTINCT 
        MIN(PLATE), 
        MAX(TO_TIMESTAMP(LAST_ITV, 'dd.mm.yyyy//HH24:MI:SS')), 
        MIN(TO_DATE(NEXT_ITV, 'dd.mm.yyyy'))
    FROM FSDB.BUSSTOPS
    WHERE plate IS NOT NULL AND last_itv IS NOT NULL AND next_itv IS NOT NULL
    GROUP BY PLATE
;

-- not verified to work
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

INSERT INTO Municipalities SELECT DISTINCT town, province, to_number(population) FROM fsdb.busstops;

INSERT INTO Books 
    SELECT DISTINCT
        TITLE, 
        MAIN_AUTHOR,
        PUB_COUNTRY,
        ORIGINAL_LANGUAGE,
        TO_DATE(PUB_DATE, 'dd.mm.yyyy'),
        TOPIC,
        CONTENT_NOTES,
        COPYRIGHT
    FROM FSDB.ACERVUS;

INSERT INTO Routes 
    SELECT DISTINCT 
        ROUTE_ID,
        TO_DATE(STOPDATE, 'dd-mm-yyyy'),
        LIB_PASSPORT,
        PLATE
    FROM FSDB.BUSSTOPS
;

INSERT INTO Stops 
    SELECT DISTINCT 
        STOP_ID,
        TOWN,
        PROVINCE,
        ROUTE_ID
;


INSERT INTO Libraries VALUES();
INSERT INTO Users VALUES();
INSERT INTO Awards VALUES();
INSERT INTO Contributors VALUES();
INSERT INTO AlternativeTitle VALUES();
INSERT INTO Edition VALUES();

INSERT INTO Sanctions VALUES();
INSERT INTO dL_Route_Stops VALUES();
INSERT INTO Copy VALUES();

-- need edition
INSERT INTO AdditionalLanguage VALUES();

INSERT INTO UserLoans VALUES();
INSERT INTO LibraryLoans VALUES();

INSERT INTO Comments VALUES();
