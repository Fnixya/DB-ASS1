-- recurrent commands
SET LINESIZE 1000;
SET WRAP OFF;

SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER='FSDB308';

SELECT COUNT(*) FROM MUNICIPALITIES;

SELECT PASSPORT, phone_number, BIRTHDATE FROM BIBUSEROS;

SELECT COUNT(*), ROUTE_ID, STOPDATE FROM FSDB.BUSSTOPS  
    GROUP BY ROUTE_ID, STOPDATE; 

SELECT COUNT(*), ROUTE_ID, STOP_TIME FROM dL_Route_Stops WHERE ROWNUM < 10 GROUP BY ROUTE_ID, STOP_TIME;
SELECT COUNT(MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS), MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS FROM dL_Route_Stops where count(MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS) > 1


SELECT COUNT(*), MUNICIPALITY_PROVINCE FROM STOPS 
GROUP BY MUNICIPALITY_PROVINCE
HAVING COUNT(*) > 1;

SELECT USER_ID, SIGNATURE, DATE_TIME, RETURN, PASSPORT, TRIM(TOWN), TRIM(ADDRESS) 
FROM FSDB.LOANS
WHERE USER_ID='0016965023';

SELECT COUNT(*), RETURN 
FROM FSDB.LOANS
WHERE RETURN IS NOT NULL;

-- Check user
SELECT DISTINCT COUNT(DISTINCT TO_NUMBER(USER_ID)) FROM FSDB.LOANS WHERE USER_ID IS NOT NULL

-- CHECKS HOW MANY USERS DOWSN'T HAVE A VALID MUNICIPALITY
SELECT COUNT(DISTINCT TO_NUMBER(USER_ID)) AS ORPHAN_USERS 
    FROM FSDB.LOANS 
    WHERE USER_ID NOT IN (
        SELECT USER_ID FROM USERS
    );

SELECT DISTINCT TO_NUMBER(USER_ID) AS ORPHAN_USERS 
    FROM FSDB.LOANS 
    WHERE USER_ID NOT IN (
        SELECT USER_ID FROM USERS
    )
    AND ROWNUM < 20;


SELECT COUNT(*) FROM Users;
SELECT USER_ID FROM USERS WHERE ROWNUM < 20;
SELECT * FROM FSDB.LOANS WHERE USER_ID=1751637514;


SELECT 
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
    MUNICIPALITIES.PROVINCE,
    LOANS.ADDRESS,
    LOANS.EMAIL,
    TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
    TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN,
    ROW_NUMBER() OVER (PARTITION BY LOANS.USER_ID ORDER BY RETURN ASC) AS RECENCY
FROM FSDB.LOANS LOANS
JOIN MUNICIPALITIES
ON FSDB.LOANS.TOWN = MUNICIPALITIES.NAME
WHERE USER_ID=1751637514;

SELECT * FROM FSDB.BUSSTOPS WHERE TRIM(TOWN)='Sotochimeneas de Manteca';

-- Siro
select name from municipalities where name LIKE '%Valverde%';


SELECT COUNT(*) FROM (
    SELECT DISTINCT
        TO_NUMBER(USER_ID),
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
);

--  Biblioteca
SELECT NAME FROM FSDB.LOANS WHERE SIGNATURE IS NULL;

--  Biblioteca
SELECT COUNT(DISTINCT NAME) FROM FSDB.LOANS 
    WHERE INSTR(NAME, 'Biblioteca') > 0;
SELECT DISTINCT USER_ID, PASSPORT, NAME FROM FSDB.LOANS 
    WHERE INSTR(NAME, 'Biblioteca') > 0;


SELECT HAS_LIBRARY FROM FSDB.BUSSTOPS
    WHERE ROWNUM < 10;
SELECT COUNT(*) FROM FSDB.BUSSTOPS
    WHERE HAS_LIBRARY='Y';

--

-- 353 LIBRARIES (USERS WITH NAME LIBRARY)
-- THERE ARE 20 LIBRARIES THAT DOESNT HAVE A RREGISTERED TOWN IN DB.
-- THEN WE INSERT ONLY 333 LIBRARIES 
SELECT USER_ID, PASSPORT FROM 
(
    SELECT DISTINCT TOWN, USER_ID, PASSPORT FROM FSDB.LOANS 
    WHERE INSTR(NAME, 'Biblioteca') > 0
)
WHERE TOWN NOT IN
(
    SELECT DISTINCT TOWN FROM FSDB.BUSSTOPS
);
---- IMPORTANT !!!


-- 

SELECT 
    DISTINCT *
FROM 
    (
        SELECT 
            LOANS.USER_ID,
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
    )
WHERE TOWN IN (SELECT NAME FROM MUNICIPALITIES) AND PASSPORT IS NULL;



SELECT COUNT(SIGNATURE), SIGNATURE FROM FSDB.LOANS
GROUP BY SIGNATURE HAVING COUNT(SIGNATURE) > 1;