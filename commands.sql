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
(SELECT COUNT(*), USER_ID, ADDRESS FROM 
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
GROUP BY USER_ID, ADDRESS
having COUNT(*) > 1);

SELECT COUNT(*), MUNICIPALITY_PROVINCE FROM STOPS 
GROUP BY MUNICIPALITY_PROVINCE
HAVING COUNT(*) > 1;

SELECT USER_ID, ADDRESS FROM 
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
WHERE ROWNUM < 10;