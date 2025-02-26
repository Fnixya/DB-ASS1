-- Municipality, Bibus, Bibuseros and Routes

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

-- good
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


--- Users and Sanctions --------------------------------------------------------------------------------------------


-- good
-- chooses the address ad town from the latest loan
INSERT INTO USERS
    SELECT DISTINCT
        USER_ID, NAME, SURNAME1, SURNAME2, PASSPORT, BIRTHDATE, PHONE, TOWN, PROVINCE, ADDRESS, EMAIL
    FROM
    (
        SELECT DISTINCT 
            TO_NUMBER(LOANS.USER_ID) AS USER_ID,
            LOANS.NAME, 
            LOANS.SURNAME1, 
            LOANS.SURNAME2,
            LOANS.PASSPORT, 
            CASE
                WHEN VALIDATE_CONVERSION(LOANS.BIRTHDATE AS DATE, 'dd-mm-yyyy') = 1 THEN
                    TO_DATE(LOANS.BIRTHDATE, 'dd-mm-yyyy')
                ELSE
                    NULL
            END AS BIRTHDATE,
            TO_NUMBER(LOANS.PHONE) AS PHONE,
            LOANS.TOWN,
            BUSSTOPS.PROVINCE,
            LOANS.ADDRESS,
            LOANS.EMAIL,
            TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
            TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN,
            ROW_NUMBER() OVER (PARTITION BY LOANS.USER_ID ORDER BY RETURN ASC) AS RECENCY
        FROM FSDB.LOANS LOANS
        JOIN FSDB.BUSSTOPS BUSSTOPS
        ON LOANS.TOWN = BUSSTOPS.TOWN
    )
    WHERE RECENCY=1 AND INSTR(NAME, 'Biblioteca')=0
;

-- no data about sanctions in old database
-- INSERT INTO Sanctions ....;


-- Books and Editions --------------------------------------------------------------------------------------------

-- good
-- 353 LIBRARIES (1: FROM USERS WITH BIBLIOTECA IN NAME) AND 353 (2: FROM BUSSTOPS WITH HAS_LIBRARY='Y')
-- 1. THERE ARE 20 LIBRARIES THAT DOESNT HAVE A REGISTERED TOWN IN DB.
-- 2. THERE ARE 20 LIBRARIES THAT DOESNT CIF/PASSPORT.
-- IN BOTH CASES WE INSERT ONLY 333 LIBRARIES 
INSERT INTO Libraries (CIF, NAME, MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS, EMAIL, phone_number)
    SELECT 
        DISTINCT PASSPORT, NAME, TOWN, PROVINCE, ADDRESS, EMAIL, PHONE 
    FROM 
        (
            SELECT 
                LOANS.PASSPORT,
                LOANS.NAME,
                BUSSTOPS.TOWN,
                BUSSTOPS.PROVINCE,
                BUSSTOPS.ADDRESS,
                LOANS.EMAIL,
                LOANS.PHONE
            FROM 
            (
                SELECT DISTINCT
                    TOWN,
                    PROVINCE,
                    ADDRESS
                FROM FSDB.BUSSTOPS
                WHERE HAS_LIBRARY='Y'
            ) BUSSTOPS
            LEFT JOIN FSDB.LOANS LOANS
            ON BUSSTOPS.TOWN=LOANS.TOWN
            WHERE BUSSTOPS.TOWN IS NOT NULL
        )
    WHERE TOWN IN (SELECT NAME FROM MUNICIPALITIES) AND PASSPORT IS NOT NULL
;

-- works pichi picha
INSERT INTO Books
    SELECT 
	      T1.TITLE, 
	      T1.MAIN_AUTHOR, 
	      LISTAGG(TRIM(T2.ORIGINAL_LANGUAGE), ',') within group (order by T2.ORIGINAL_LANGUAGE),
	      LISTAGG(TRIM(T1.TOPIC), ',') within group (order by T1.TOPIC), 
	      T1.NEW_CONTENT
    FROM(
        (SELECT DISTINCT 
	          TITLE, 
	          MAIN_AUTHOR, 
	          TOPIC, 
		  MAX(CONTENT_NOTES) AS NEW_CONTENT 
            FROM FSDB.ACERVUS GROUP BY TITLE, MAIN_AUTHOR,TOPIC
        ) T1 
        JOIN 
        (SELECT DISTINCT 
	          TITLE, 
	          MAIN_AUTHOR, 
		  ORIGINAL_LANGUAGE 
         FROM FSDB.ACERVUS
        ) T2 
        ON T1.TITLE=T2.TITLE AND T1.MAIN_AUTHOR=T2.MAIN_AUTHOR
    ) GROUP BY T1.TITLE, T1.MAIN_AUTHOR, T1.NEW_CONTENT 
;

-- easy
INSERT INTO Awards SELECT DISTINCT AWARDS, TITLE, MAIN_AUTHOR FROM FSDB.ACERVUS WHERE AWARDS IS NOT NULL;

INSERT INTO Contributors
    SELECT DISTINCT *
    FROM(
        (SELECT DISTINCT
            OTHER_AUTHORS,
            TITLE,
            MAIN_AUTHOR
        FROM FSDB.ACERVUS
        WHERE OTHER_AUTHORS IS NOT NULL)
        UNION
        (SELECT DISTINCT
            MENTION_AUTHORS,
            TITLE,
            MAIN_AUTHOR
        FROM FSDB.ACERVUS
        WHERE MENTION_AUTHORS IS NOT NULL)
      )
;


INSERT INTO AlternativeTitles SELECT DISTINCT ALT_TITLE, TITLE, MAIN_AUTHOR FROM FSDB.ACERVUS WHERE ALT_TITLE IS NOT NULL;

-- not verified to work
INSERT INTO Editions 
    SELECT DISTINCT 
        ISBN,
        TITLE,
        MAIN_AUTHOR,
        EDITION,
        PUBLISHER,
        EXTENSION,
        SERIES,
        NULL,
        PUB_PLACE,
        TO_DATE(PUB_DATE, 'yyyy'),
        COPYRIGHT,
        DIMENSIONS,
        PHYSICAL_FEATURES,
        ATTACHED_MATERIALS,
        NOTES,
        NATIONAL_LIB_ID,
        URL
    FROM FSDB.ACERVUS
;

-- not verified to work (needs insertion of edition first)
INSERT INTO Copies (signature, edition, condition, comments)
    SELECT DISTINCT
        SIGNATURE, 
        ISBN,
        condition,
        COMMENTS,
        -- deregistration_date
    FROM FSDB.ACERVUS
    WHERE SIGNATURE IS NOT NULL AND ISBN IS NOT NULL AND COMMENTS IS NOT NULL
;

-- need edition
INSERT INTO AdditionalLanguages VALUES();


-- Loans and Comments --------------------------------------------------------------------------------------------


-- not verified to work (needs insertion of copy first)
INSERT INTO UserLoans
    SELECT DISTINCT
        TO_NUMBER(USER_ID) AS USER_ID,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE USER_ID IN (SELECT USER_ID FROM USERS)
;

-- not verified to work (needs insertion of copy first)
INSERT INTO LibraryLoans
    SELECT DISTINCT
        PASSPORT,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE PASSPORT IN (SELECT CIF FROM LIBRARIES)
;

-- not verified to work (needs user loans first)
INSERT INTO Comments
    SELECT DISTINCT
        SIGNATURE,
        TO_DATE(DATE_TIME, 'dd-mm-yyyy'),
        TO_DATE(RETURN, 'dd-mm-yyyy'),
        POST,
        TO_DATE(POST_DATE, 'dd-mm-yyyy'),
        TO_NUMBER(LIKES),
        TO_NUMBER(DISLIKES)
    FROM FSDB.LOANS;
