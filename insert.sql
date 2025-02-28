-- Municipality, Bibus, Bibuseros and Routes

-- good: 14 rows
INSERT INTO Bibus (license_plate, last_itv, next_itv)
    SELECT DISTINCT 
        MIN(PLATE), 
        MAX(TO_DATE(LAST_ITV, 'dd.mm.yyyy//HH24:MI:SS')), 
        MIN(TO_DATE(NEXT_ITV, 'dd.mm.yyyy'))
    FROM FSDB.BUSSTOPS
    WHERE plate IS NOT NULL AND last_itv IS NOT NULL AND next_itv IS NOT NULL
    GROUP BY PLATE
;

-- good: 13 rows
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

-- good: 1365 rows
INSERT INTO Municipalities SELECT DISTINCT town, province, to_number(population) FROM fsdb.busstops;
 
-- good: 150 rows
INSERT INTO Routes
    SELECT DISTINCT 
        ROUTE_ID,
        TO_DATE(STOPDATE, 'dd-mm-yyyy'),
        PLATE,
        LIB_PASSPORT
    FROM FSDB.BUSSTOPS
;

-- good: 1365 rows
INSERT INTO Stops 
    SELECT DISTINCT 
        TOWN,
        PROVINCE,
        ADDRESS
    FROM FSDB.BUSSTOPS
;

-- good: 1365 rows
INSERT INTO dL_Route_Stops 
    SELECT DISTINCT 
        ROUTE_ID,
        TOWN,
        PROVINCE,
        ADDRESS,
        ROW_NUMBER() OVER (PARTITION BY ROUTE_ID ORDER BY STOPTIME) AS SEQ_ORDER,
        TO_DATE(STOPTIME, 'HH24:MI:SS') AS STOPTIME
    FROM FSDB.BUSSTOPS
;


--- Users and Sanctions --------------------------------------------------------------------------------------------


-- good: 2439 rows
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
            TO_DATE(LOANS.BIRTHDATE, 'dd-mm-yyyy') AS BIRTHDATE,
            TO_NUMBER(LOANS.PHONE) AS PHONE,
            LOANS.TOWN,
            BUSSTOPS.PROVINCE,
            LOANS.ADDRESS,
            LOANS.EMAIL,
            TO_DATE(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
            TO_DATE(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN,
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

-- good: 333 rows
-- 353 LIBRARIES (1: FROM USERS WITH BIBLIOTECA IN NAME) AND 353 (2: FROM BUSSTOPS WITH HAS_LIBRARY='Y')
-- 1. THERE ARE 20 LIBRARIES THAT DOESNT HAVE A REGISTERED TOWN IN DB.
-- 2. THERE ARE 20 LIBRARIES THAT DOESNT CIF/PASSPORT.
-- IN BOTH CASES WE INSERT ONLY 333 LIBRARIES 
INSERT INTO Libraries (CIF, NAME, MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS, EMAIL, phone_number)
    SELECT DISTINCT 
        LOANS.PASSPORT,
        LOANS.NAME,
        BUSSTOPS.TOWN,
        BUSSTOPS.PROVINCE,
        BUSSTOPS.ADDRESS,
        LOANS.EMAIL,
        LOANS.PHONE
    FROM FSDB.BUSSTOPS BUSSTOPS
    LEFT JOIN FSDB.LOANS LOANS
    ON BUSSTOPS.TOWN=LOANS.TOWN
    WHERE BUSSTOPS.TOWN IN (SELECT NAME FROM MUNICIPALITIES) 
        AND BUSSTOPS.HAS_LIBRARY='Y'
        AND LOANS.PASSPORT IS NOT NULL;

-- 181435 rows
-- works flawlessly and divinely
INSERT INTO Books
    SELECT DISTINCT 
        T1.TITLE, 
        T1.MAIN_AUTHOR, 
        T2.NEW_LANG,
        T1.NEW_TOPIC,
        T1.NEW_CONTENT
    FROM(
        (SELECT DISTINCT 
            TITLE,
            MAIN_AUTHOR,
            LISTAGG(TRIM(TOPIC), ',') within group (order by TOPIC) AS NEW_TOPIC,
            NEW_CONTENT 
        FROM(
            SELECT DISTINCT
	              TITLE,
	              MAIN_AUTHOR,
	              TOPIC,
                MAX(CONTENT_NOTES) AS NEW_CONTENT 
            FROM FSDB.ACERVUS GROUP BY TITLE, MAIN_AUTHOR,TOPIC
            )
        GROUP BY TITLE, MAIN_AUTHOR, NEW_CONTENT
        ) T1 
        JOIN 
        (SELECT DISTINCT 
	          TITLE,
	          MAIN_AUTHOR,
	          LISTAGG(TRIM(ORIGINAL_LANGUAGE), ',') within group (order by ORIGINAL_LANGUAGE) AS NEW_LANG
        FROM(
            SELECT DISTINCT
                TITLE,
                MAIN_AUTHOR,
                ORIGINAL_LANGUAGE
            FROM FSDB.ACERVUS)
        GROUP BY TITLE, MAIN_AUTHOR
        ) T2 
        ON T1.TITLE=T2.TITLE AND T1.MAIN_AUTHOR=T2.MAIN_AUTHOR
    )
;



-- easy: 1433 rows
INSERT INTO Awards SELECT DISTINCT AWARDS, TITLE, MAIN_AUTHOR FROM FSDB.ACERVUS WHERE AWARDS IS NOT NULL;

-- xdd : 205729 rows 
INSERT INTO Contributors
    SELECT DISTINCT *
    FROM (
        (
            SELECT DISTINCT
                OTHER_AUTHORS,
                TITLE,
                MAIN_AUTHOR
            FROM FSDB.ACERVUS
            WHERE OTHER_AUTHORS IS NOT NULL
        )
        UNION (
            SELECT DISTINCT
                MENTION_AUTHORS,
                TITLE,
                MAIN_AUTHOR
            FROM FSDB.ACERVUS
            WHERE MENTION_AUTHORS IS NOT NULL
        )
    )
;

-- : 6578 rows 
INSERT INTO AlternativeTitles SELECT DISTINCT ALT_TITLE, TITLE, MAIN_AUTHOR FROM FSDB.ACERVUS WHERE ALT_TITLE IS NOT NULL;


-- : 176 rows 
-- We don't check with main language because there is no row where main_language = other_languages
INSERT INTO AdditionalLanguages SELECT DISTINCT OTHER_LANGUAGES, TITLE, MAIN_AUTHOR FROM FSDB.ACERVUS WHERE OTHER_LANGUAGES IS NOT NULL;


-- : 240465 rows 
INSERT INTO Editions 
    SELECT DISTINCT
        FILTRO.ISBN,
        ACERVUS.TITLE,
        ACERVUS.MAIN_AUTHOR,
        ACERVUS.EDITION,
        ACERVUS.PUBLISHER,
        ACERVUS.EXTENSION,
        ACERVUS.SERIES,
        NULL,
        ACERVUS.PUB_PLACE,
        TO_DATE(ACERVUS.PUB_DATE, 'yyyy') AS date_of_publication,
        ACERVUS.COPYRIGHT,
        ACERVUS.DIMENSIONS,
        ACERVUS.PHYSICAL_FEATURES,
        ACERVUS.ATTACHED_MATERIALS,
        ACERVUS.NOTES,
        ACERVUS.NATIONAL_LIB_ID,
        ACERVUS.URL
    FROM FSDB.ACERVUS ACERVUS
    INNER JOIN (
        SELECT DISTINCT 
            ISBN, 
            COUNT(NATIONAL_LIB_ID)
        FROM (SELECT DISTINCT ISBN, NATIONAL_LIB_ID FROM FSDB.ACERVUS)
        GROUP BY ISBN
        HAVING COUNT(NATIONAL_LIB_ID) < 2
    ) FILTRO
    ON ACERVUS.ISBN = FILTRO.ISBN
;

-- good: 241236 rows 
INSERT INTO Copies
    SELECT DISTINCT
        SIGNATURE, 
        ISBN,
        NULL,           -- condition
        NULL            -- deregistration_date
    FROM FSDB.ACERVUS
    WHERE SIGNATURE IS NOT NULL AND ISBN IN (SELECT ISBN FROM EDITIONS)
;


-- Loans and Comments --------------------------------------------------------------------------------------------


-- : 4037 rows 
-- not verified to work (needs insertion of copy first)
INSERT INTO UserLoans
    SELECT DISTINCT
        TO_NUMBER(USER_ID) AS USER_ID,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE USER_ID IN (SELECT USER_ID FROM USERS)
        AND SIGNATURE IN (SELECT SIGNATURE FROM COPIES)
;

-- good : 21178 rows 
INSERT INTO LibraryLoans
    SELECT DISTINCT
        PASSPORT,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE PASSPORT IN (SELECT CIF FROM LIBRARIES)
        AND SIGNATURE IN (SELECT SIGNATURE FROM COPIES)
;

-- good : 938 rows 
INSERT INTO Comments
    SELECT DISTINCT
        UL.COPY,
        UL.START_DATE,
        UL.RETURN_DATE,
        L.POST,
        TO_DATE(L.POST_DATE, 'dd/mm/yyyy HH24:MI:SS') AS POST_DATE,
        TO_NUMBER(L.LIKES) AS LIKES,
        TO_NUMBER(L.DISLIKES) AS DISLIKES
    FROM USERLOANS UL
    LEFT JOIN FSDB.LOANS L
    ON UL.COPY = L.SIGNATURE AND UL.START_DATE = TO_DATE(L.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS')
    WHERE UL.START_DATE IS NOT NULL AND L.POST IS NOT NULL
;