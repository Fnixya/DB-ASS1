INSERT INTO Bibus VALUES();
-- LIB_PASSPORT CHAR(20)
-- LIB_EMAIL CHAR(100)
-- LIB_FULLNAME CHAR(80)
-- LIB_BIRTHDATE CHAR(10)
-- LIB_PHONE CHAR(9)
-- LIB_ADDRESS

INSERT INTO Bibusero VALUES();
INSERT INTO Municipality SELECT town, province, to_number(population) FROM fsdb.busstops;
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
