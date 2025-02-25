SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER='FSDB308';

SELECT PASSPORT, phone_number, BIRTHDATE FROM BIBUSEROS;


SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY ROUTE_ID) AS row_index, 
    ROUTE_ID,
    TOWN,
    ADDRESS,
    TO_TIMESTAMP(STOPTIME, 'HH24:MI:SS') AS STOPTIME
FROM FSDB.BUSSTOPS
GROUP BY ROUTE_ID, TOWN, ADDRESS, STOPTIME
ORDER BY STOPTIME ASC;

SELECT COUNT(*), ROUTE_ID, STOPDATE FROM FSDB.BUSSTOPS  
    GROUP BY ROUTE_ID, STOPDATE; 

SELECT COUNT(*), ROUTE_ID, STOP_TIME FROM dL_Route_Stops WHERE ROWNUM < 10 GROUP BY ROUTE_ID, STOP_TIME;
SELECT COUNT(MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS), MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS FROM dL_Route_Stops where count(MUNICIPALITY_NAME, MUNICIPALITY_PROVINCE, ADDRESS) > 1



SELECT COUNT(*) FROM
(SELECT COUNT(*), USER_ID, NAME FROM 
    (
    SELECT DISTINCT
        FSDB.LOANS.USER_ID,
        FSDB.LOANS.NAME, 
        FSDB.LOANS.SURNAME1, 
        FSDB.LOANS.SURNAME2,
        FSDB.LOANS.PASSPORT, 
        CASE
            WHEN VALIDATE_CONVERSION(FSDB.LOANS.BIRTHDATE AS DATE, 'dd-mm-yyyy') = 1 THEN
                TO_DATE(FSDB.LOANS.BIRTHDATE, 'dd-mm-yyyy')
            ELSE
                NULL
        END AS BIRTHDATE,
        FSDB.LOANS.PHONE,
        FSDB.LOANS.TOWN,
        MUNICIPALITIES.PROVINCE,
        FSDB.LOANS.ADDRESS,
        FSDB.LOANS.EMAIL
    FROM FSDB.LOANS
    JOIN MUNICIPALITIES
    ON FSDB.LOANS.TOWN = MUNICIPALITIES.NAME
)
WHERE USER_ID IS NOT NULL
GROUP BY USER_ID, NAME
having COUNT(*) > 1);

SELECT COUNT(*), MUNICIPALITY_PROVINCE FROM STOPS 
GROUP BY MUNICIPALITY_PROVINCE
HAVING COUNT(*) > 1;

SELECT ADDRESS, TOWN FROM 
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
            END AS 
        BIRTHDATE,
        TO_NUMBER(LOANS.PHONE),
        LOANS.TOWN,
        MUNICIPALITIES.PROVINCE,
        LOANS.ADDRESS AS ADDRESS,
        FSDB.LOANS.EMAIL
    FROM FSDB.LOANS LOANS
    JOIN MUNICIPALITIES
    ON FSDB.LOANS.TOWN = MUNICIPALITIES.NAME
    )
WHERE ROWNUM < 10
AND USER_ID=16965023;

SELECT USER_ID, SIGNATURE, DATE_TIME, RETURN, PASSPORT, TRIM(TOWN), TRIM(ADDRESS) 
FROM FSDB.LOANS
WHERE USER_ID='0016965023';

SELECT COUNT(*), RETURN 
FROM FSDB.LOANS
WHERE RETURN IS NOT NULL;

select name from municipalities where name LIKE '%Valverde%';

--- users related
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
                END AS 
            BIRTHDATE,
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
    )
    WHERE RECENCY=1
;

SELECT DISTINCT TIME_DATE, RETURN FROM FSDB.BUSSTOPS WHERE ROWNUM <= 10;