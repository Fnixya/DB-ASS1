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

-- Siro
select name from municipalities where name LIKE '%Valverde%';

-- SEE HOW MANY USERS ARE LIBRARIES
SELECT NAME FROM USERS WHERE INSTR(NAME, 'Biblioteca') > 0;














-- TOTAL NUMBER OF LOANS: 26844
SELECT COUNT(*) FROM (
    SELECT DISTINCT
        TO_NUMBER(USER_ID) AS USER_ID,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
);
-- TOTAL NUMBER OF USER LOANS: 4044
SELECT COUNT(*) FROM (
    SELECT DISTINCT
        TO_NUMBER(USER_ID) AS USER_ID,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE USER_ID IN (SELECT USER_ID FROM USERS)
);
-- TOTAL NUMBER OF LIBRARY LOANS: 21214
SELECT COUNT(*) FROM (
    SELECT DISTINCT
        PASSPORT,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE PASSPORT IN (SELECT CIF FROM LIBRARIES)
);
-- LOST DATA: 1586
SELECT COUNT(*) FROM (
    SELECT DISTINCT
        USER_ID
        PASSPORT,
        SIGNATURE,
        TO_TIMESTAMP(LOANS.DATE_TIME, 'dd/mm/yyyy HH24:MI:SS') AS DATE_TIME,
        TO_TIMESTAMP(LOANS.RETURN, 'dd/mm/yyyy HH24:MI:SS') AS RETURN
    FROM FSDB.LOANS
    WHERE PASSPORT NOT IN (SELECT CIF FROM LIBRARIES)
        AND USER_ID NOT IN (SELECT USER_ID FROM USERS)
);



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