INSERT INTO Bibus (license_plate, last_itv, next_itv)
    SELECT DISTINCT 
        MIN(PLATE), 
        MAX(TO_TIMESTAMP(LAST_ITV, 'dd.mm.yyyy // HH24.MI.SS')), 
        MIN(TO_DATE(NEXT_ITV, 'dd.mm.yyyy'))
    FROM FSDB.BUSSTOPS
    WHERE plate IS NOT NULL AND last_itv IS NOT NULL AND next_itv IS NOT NULL
    GROUP BY PLATE
;

-- not verified to work
INSERT INTO Bibusero (passport, fullname, phone_number, address, email, constract_start_date, constract_end_date, birthdate)
    SELECT DISTINCT 
        LIB_PASSPORT,
        LIB_FULLNAME,
        TO_NUMBER(LIB_PHONE),
        LIB_ADDRESS,
        LIB_EMAIL,
        TO_DATE(CONT_START, 'dd.mm.yyyy'),
        TO_DATE(CONT_END, 'dd.mm.yyyy'),
        TO_DATE(LIB_BIRTHDATE, 'dd-mm-yyyy')
    FROM FSDB.BUSSTOPS
;

INSERT INTO Municipality SELECT DISTINCT town, province, to_number(population) FROM fsdb.busstops;
INSERT INTO Books VALUES();

INSERT INTO Route VALUES();
INSERT INTO Stops VALUES();
INSERT INTO Library VALUES();
INSERT INTO Users VALUES();
INSERT INTO Awards VALUES();
INSERT INTO Contributors VALUES();
INSERT INTO AlternativeTitle VALUES();
INSERT INTO Edition VALUES();

INSERT INTO Sanctions VALUES();
INSERT INTO dL_Route_Stops VALUES();
INSERT INTO Copy VALUES();
INSERT INTO AdditionalLanguage VALUES();

INSERT INTO UserLoans VALUES();
INSERT INTO LibraryLoans VALUES();

INSERT INTO Comments VALUES();
