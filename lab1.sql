-- zadanie 1
CREATE OR REPLACE TYPE SAMOCHOD AS OBJECT (
    marka           VARCHAR2(20),
    model           VARCHAR2(20),
    kilometry       NUMBER,
    data_produkcji  DATE,
    cena            NUMBER(10,2)
);
/
CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES ('FIAT','BRAVA',60000,DATE '1999-11-30',25000);
INSERT INTO samochody VALUES ('FORD','MONDEO',80000,DATE '1997-05-10',45000);
INSERT INTO samochody VALUES ('MAZDA','323',12000,DATE '2000-09-22',52000);

SELECT * FROM samochody;

-- zadanie 2
CREATE TABLE wlasciciele (
    imie      VARCHAR2(100),
    nazwisko  VARCHAR2(100),
    auto      samochod
);

INSERT INTO wlasciciele VALUES ('JAN','KOWALSKI', 
    samochod('FIAT','SEICENTO',30000,DATE '2010-12-02',19500));
INSERT INTO wlasciciele VALUES ('ADAM','NOWAK',
    samochod('OPEL','ASTRA',34000,DATE '2009-06-01',33700));

SELECT * FROM wlasciciele;

-- zadanie 3
CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        years NUMBER;  
    BEGIN
        years := FLOOR(EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM DATA_PRODUKCJI));
        RETURN ROUND(CENA * POWER(0.9, years), 2);
    END wartosc;
END;

ALTER TYPE SAMOCHOD ADD MEMBER FUNCTION wartosc
    RETURN NUMBER CASCADE INCLUDING TABLE DATA;   

SELECT s.marka, s.cena, s.wartosc() FROM samochody s;

-- zadanie 4
ALTER TYPE samochod ADD
    MAP MEMBER FUNCTION porownaj RETURN NUMBER
CASCADE;

CREATE OR REPLACE TYPE BODY samochod AS

    MEMBER FUNCTION wartosc RETURN NUMBER IS
        lata NUMBER;
    BEGIN
        lata := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_produkcji);
        RETURN cena * POWER(0.9, lata);
    END;

    MAP MEMBER FUNCTION porownaj RETURN NUMBER IS
        lata NUMBER;
    BEGIN
        lata := (SYSDATE - data_produkcji) / 365;
        RETURN lata + (kilometry / 10000);
    END;

END;
/
SELECT *
FROM samochody s
ORDER BY VALUE(s);

-- zadanie 5
CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT (
    imie    VARCHAR2(50),
    nazwisko VARCHAR2(50)
);
/
ALTER TYPE SAMOCHOD ADD ATTRIBUTE wlasciciel_ref REF WLASCICIEL CASCADE;
/

CREATE TABLE WLASCICIELE2 OF WLASCICIEL;

INSERT INTO WLASCICIELE2 VALUES (NEW WLASCICIEL('Jan','Kowalski'));
INSERT INTO WLASCICIELE2 VALUES (NEW WLASCICIEL('Adam','Nowak'));
COMMIT;
INSERT INTO WLASCICIELE2 VALUES (NEW WLASCICIEL('Piotr','Wiśniewski'));
COMMIT;

UPDATE SAMOCHODY s
SET s.wlasciciel_ref = (
    SELECT REF(wlas) FROM WLASCICIELE2 wlas WHERE wlas.nazwisko='Kowalski'
)
WHERE s.marka='FIAT';

UPDATE SAMOCHODY s
SET s.wlasciciel_ref = (
    SELECT REF(wlas) FROM WLASCICIELE2 wlas WHERE wlas.nazwisko='Nowak'
)
WHERE s.marka='FORD';

UPDATE SAMOCHODY s
SET s.wlasciciel_ref = (
    SELECT REF(wlas) FROM WLASCICIELE2 wlas WHERE wlas.nazwisko='Wiśniewski'
)
WHERE s.marka='MAZDA';

SELECT s.marka, s.model, s.kilometry, s.cena, s.wlasciciel_ref
FROM SAMOCHODY s;

-- zadanie 6
DECLARE
   
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);

   
    moje_przedmioty t_przedmioty := t_przedmioty('MATEMATYKA');
BEGIN
    
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;

    
    DBMS_OUTPUT.PUT_LINE('Pełna lista przedmiotów:');
    FOR i IN moje_przedmioty.FIRST..moje_przedmioty.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;

    
    moje_przedmioty.TRIM(2);

    DBMS_OUTPUT.PUT_LINE('Po usunięciu 2 ostatnich:');
    FOR i IN moje_przedmioty.FIRST..moje_przedmioty.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;

   
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT);
    DBMS_OUTPUT.PUT_LINE('Liczba elementów: ' || moje_przedmioty.COUNT);

   
    moje_przedmioty.EXTEND;
    moje_przedmioty(moje_przedmioty.LAST) := 'DODATKOWY';

    DBMS_OUTPUT.PUT_LINE('Po dodaniu dodatkowego elementu:');
    FOR i IN moje_przedmioty.FIRST..moje_przedmioty.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;

    
    moje_przedmioty.DELETE;

    DBMS_OUTPUT.PUT_LINE('Po usunięciu wszystkich elementów:');
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT);
    DBMS_OUTPUT.PUT_LINE('Liczba elementów: ' || moje_przedmioty.COUNT);
END;
/
-- zadanie 7
DECLARE
   
    TYPE t_ksiazki IS TABLE OF VARCHAR2(50);
    
    
    moje_ksiazki t_ksiazki := t_ksiazki('Matematyka', 'Fizyka', 'Chemia');
BEGIN
   
    DBMS_OUTPUT.PUT_LINE('Początkowa lista książek:');
    FOR i IN moje_ksiazki.FIRST..moje_ksiazki.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
    
   
    moje_ksiazki.EXTEND(2);
    moje_ksiazki(moje_ksiazki.LAST-1) := 'Biologia';
    moje_ksiazki(moje_ksiazki.LAST) := 'Historia';
    
    DBMS_OUTPUT.PUT_LINE('Po dodaniu książek:');
    FOR i IN moje_ksiazki.FIRST..moje_ksiazki.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;

    
    moje_ksiazki.DELETE(2);

    DBMS_OUTPUT.PUT_LINE('Po usunięciu drugiej książki:');
    FOR i IN moje_ksiazki.FIRST..moje_ksiazki.LAST LOOP
        IF moje_ksiazki.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
        END IF;
    END LOOP;

   
    moje_ksiazki(2) := 'Geografia';

    DBMS_OUTPUT.PUT_LINE('Po wstawieniu nowej książki na miejsce 2:');
    FOR i IN moje_ksiazki.FIRST..moje_ksiazki.LAST LOOP
        IF moje_ksiazki.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Liczba elementów: ' || moje_ksiazki.COUNT);
END;
/
-- zadanie 8
DECLARE

    TYPE t_wykladowcy IS TABLE OF VARCHAR2(50);


    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN

    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';


    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;


    DBMS_OUTPUT.PUT_LINE('Początkowa lista wykładowców:');
    FOR i IN moi_wykladowcy.FIRST..moi_wykladowcy.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;

 
    moi_wykladowcy.TRIM(2);
    DBMS_OUTPUT.PUT_LINE('Po usunięciu 2 wykładowców:');
    FOR i IN moi_wykladowcy.FIRST..moi_wykladowcy.LAST LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;


    moi_wykladowcy.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Po usunięciu wykładowców 5-7:');
    FOR i IN moi_wykladowcy.FIRST..moi_wykladowcy.LAST LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;

    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';


    DBMS_OUTPUT.PUT_LINE('Ostateczna lista wykładowców:');
    FOR i IN moi_wykladowcy.FIRST..moi_wykladowcy.LAST LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Liczba elementów: ' || moi_wykladowcy.COUNT);
END;
/

-- zadanie 9
DECLARE
   
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);

   
    miesiace t_miesiace := t_miesiace();
BEGIN
   
    miesiace.EXTEND(12);
    miesiace(1)  := 'Styczeń';
    miesiace(2)  := 'Luty';
    miesiace(3)  := 'Marzec';
    miesiace(4)  := 'Kwiecień';
    miesiace(5)  := 'Maj';
    miesiace(6)  := 'Czerwiec';
    miesiace(7)  := 'Lipiec';
    miesiace(8)  := 'Sierpień';
    miesiace(9)  := 'Wrzesień';
    miesiace(10) := 'Październik';
    miesiace(11) := 'Listopad';
    miesiace(12) := 'Grudzień';

    
    DBMS_OUTPUT.PUT_LINE('Początkowa lista miesięcy:');
    FOR i IN miesiace.FIRST..miesiace.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;

   
    miesiace.DELETE(3);  
    miesiace.DELETE(7); 

   
    DBMS_OUTPUT.PUT_LINE('Lista miesięcy po usunięciu marca i lipca:');
    FOR i IN miesiace.FIRST..miesiace.LAST LOOP
        IF miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(miesiace(i));
        END IF;
    END LOOP;

    
    DBMS_OUTPUT.PUT_LINE('Liczba miesięcy po usunięciu: ' || miesiace.COUNT);
END;
/


-- zadanie 10

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT (
    nazwa VARCHAR2(50),
    kraj  VARCHAR2(30),
    jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES (
    'SOKRATES',
    'FRANCJA',
    jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI')
);

INSERT INTO stypendia VALUES (
    'ERASMUS',
    'NIEMCY',
    jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI')
);

SELECT * FROM stypendia;

SELECT s.jezyki FROM stypendia s;

UPDATE stypendia
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';


CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/


CREATE TYPE semestr AS OBJECT (
    numer NUMBER,
    egzaminy lista_egzaminow
);
/


CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;


INSERT INTO semestry VALUES (
    semestr(1, lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA'))
);

INSERT INTO semestry VALUES (
    semestr(2, lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE'))
);


SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;


SELECT * 
FROM TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=1);


INSERT INTO TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=2) 
VALUES ('METODY NUMERYCZNE');


UPDATE TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=2) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';


DELETE FROM TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=2) e
WHERE e.column_value = 'BAZY DANYCH';

-- zadanie 11
CREATE TYPE lista_produktow AS TABLE OF VARCHAR2(50);
/

CREATE TYPE zakup AS OBJECT (
    id NUMBER,
    klient VARCHAR2(50),
    koszyk_produktow lista_produktow
);
/

CREATE TABLE zakupy OF zakup
NESTED TABLE koszyk_produktow STORE AS tab_koszyk;

INSERT INTO zakupy VALUES (
    zakup(1, 'Anna Kowalska', lista_produktow('Mleko', 'Chleb', 'Masło'))
);

INSERT INTO zakupy VALUES (
    zakup(2, 'Jan Nowak', lista_produktow('Sok', 'Chleb', 'Jajka'))
);

INSERT INTO zakupy VALUES (
    zakup(3, 'Marta Wiśniewska', lista_produktow('Mleko', 'Jajka', 'Ser'))
);


SELECT z.id, z.klient, p.column_value AS produkt
FROM zakupy z, TABLE(z.koszyk_produktow) p;

DELETE FROM zakupy
WHERE id IN (
    SELECT z.id
    FROM zakupy z, TABLE(z.koszyk_produktow) p
    WHERE p.column_value = 'Chleb'
);

SELECT z.id, z.klient, p.column_value AS produkt
FROM zakupy z, TABLE(z.koszyk_produktow) p;

-- zadanie 12
CREATE TYPE instrument AS OBJECT (
    nazwa  VARCHAR2(20),
    dzwiek VARCHAR2(20),
    MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
/
CREATE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN dzwiek;
    END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
    material VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY instrument_dety AS

    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'dmucham: ' || dzwiek;
    END;

    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN glosnosc || ':' || dzwiek;
    END;

END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
    producent VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS

    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'stukam w klawisze: ' || dzwiek;
    END;

END;
/
DECLARE
    tamburyn instrument := instrument('tamburyn', 'brzdek-brzdek');
    trabka instrument_dety := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian', 'pingping', 'steinway');
BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
END;
/

-- zadanie 13
CREATE TYPE istota AS OBJECT (
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
) NOT INSTANTIABLE NOT FINAL;
/
CREATE TYPE lew UNDER istota (
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);
/

CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: ' || ofiara;
    END;
END;
/

DECLARE
    KrolLew lew := lew('LEW', 4);
BEGIN
    DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;
/

-- zadanie 14
SET SERVEROUTPUT ON;

DECLARE
    tamburyn  instrument;
    cymbalki  instrument;
    trabka    instrument_dety;
    saksofon  instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');

    
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');

   
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    saksofon := instrument_dety('saksofon','tra-taaaa','mosiezny');

    
    dbms_output.put_line('tamburyn: ' || tamburyn.graj);
    dbms_output.put_line('cymbalki: ' || cymbalki.graj);
    dbms_output.put_line('trabka: ' || trabka.graj);
    dbms_output.put_line('saksofon: ' || saksofon.graj);
END;
/
-- zadanie 15
CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty
VALUES ( instrument('tamburyn','brzdek-brzdek') );

INSERT INTO instrumenty
VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa') );

INSERT INTO instrumenty
VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );

COMMIT;

SELECT 
    i.nazwa,
    i.graj() AS dzwiek
FROM instrumenty i;

