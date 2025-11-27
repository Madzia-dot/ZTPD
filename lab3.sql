-- zadanie 1
CREATE TABLE dokumenty (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

-- zadanie 2
DECLARE
    v_text  VARCHAR2(100) := 'Oto tekst. ';
    v_clob  CLOB;
BEGIN
    DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

    FOR i IN 1..10000 LOOP
        DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_text), v_text);
    END LOOP;

    INSERT INTO dokumenty (id, dokument) VALUES (1, v_clob);

    COMMIT;

    DBMS_LOB.FREETEMPORARY(v_clob);
END;
/
SELECT id, DBMS_LOB.GETLENGTH(dokument) AS dlugosc
FROM dokumenty;


-- zadanie 3
--a) 
SELECT * 
FROM dokumenty;

--b) 
SELECT UPPER(dokument) AS dokument_wielkie_litery
FROM dokumenty;

--c) 
SELECT LENGTH(dokument) AS rozmiar_length
FROM dokumenty;

--d)
SELECT DBMS_LOB.GETLENGTH(dokument) AS rozmiar_dbms_lob
FROM dokumenty;

--e)
SELECT SUBSTR(dokument, 5, 1000) AS fragment_substr
FROM dokumenty;

--f)
DECLARE
    v_dokument CLOB;
    v_fragment VARCHAR2(1000);
BEGIN
    -- Pobranie CLOB do zmiennej
    SELECT dokument INTO v_dokument
    FROM dokumenty
    WHERE id = 1;

    -- Odczyt fragmentu do zmiennej
    v_fragment := DBMS_LOB.SUBSTR(v_dokument, 1000, 5);

    -- Wyświetlenie fragmentu
    DBMS_OUTPUT.PUT_LINE(v_fragment);
END;
/

-- zadanie 4
INSERT INTO dokumenty (id, dokument)
VALUES (2, EMPTY_CLOB());

-- zadanie 5
INSERT INTO dokumenty (id, dokument)
VALUES (3, NULL);

COMMIT;

-- zadanie 6
--a) 
SELECT id, dokument
FROM dokumenty;

--b) 
SELECT id, UPPER(dokument) AS dokument_upper
FROM dokumenty;

--c)
SELECT id, LENGTH(dokument) AS dlugosc
FROM dokumenty;

--d)
SELECT id, DBMS_LOB.GETLENGTH(dokument) AS lob_length
FROM dokumenty;

--e)
SELECT id, SUBSTR(dokument, 5, 1000) AS fragment
FROM dokumenty;

--f)
SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) AS fragment
FROM dokumenty;

-- zadanie 7
DECLARE
    -- 1) 
    v_bfile   BFILE := BFILENAME('TPD_DIR', 'dokument.txt');

    -- 2) 
    v_clob    CLOB;

    v_dest_offset   INTEGER := 1;
    v_src_offset    INTEGER := 1;
    v_lang_ctx      INTEGER := 0;
    v_warning       INTEGER;
BEGIN
    SELECT dokument
    INTO v_clob
    FROM dokumenty
    WHERE id = 2
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);

    -- 3)
    DBMS_LOB.LOADCLOBFROMFILE(
        dest_lob      => v_clob,
        src_bfile     => v_bfile,
        amount        => DBMS_LOB.GETLENGTH(v_bfile), 
        dest_offset   => v_dest_offset,
        src_offset    => v_src_offset,
        bfile_csid    => 0,     
        lang_context  => v_lang_ctx,
        warning       => v_warning
    );

    DBMS_LOB.FILECLOSE(v_bfile);

    -- 4) 
    COMMIT;

    -- 5) 
    DBMS_OUTPUT.PUT_LINE('Kopiowanie zakończone. Kod ostrzeżenia = ' || v_warning);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- zadanie 8
UPDATE dokumenty
SET dokument = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'))
WHERE id = 3;

COMMIT;

-- zadanie 9
SELECT * FROM dokumenty;

-- zadanie 10
SELECT id,
       LENGTH(dokument) AS size_chars,
       DBMS_LOB.getlength(dokument) AS size_bytes
FROM dokumenty;

-- zadanie 11
DROP TABLE dokumenty;

-- zadanie 12

CREATE OR REPLACE PROCEDURE clob_censor(
    p_clob   IN OUT CLOB,
    p_phrase IN     VARCHAR2
) AS
    pos        PLS_INTEGER := 1;
    phrase_len PLS_INTEGER := LENGTH(p_phrase);
    dots       VARCHAR2(32767);
BEGIN
    IF p_clob IS NULL OR p_phrase IS NULL OR phrase_len = 0 THEN
        RETURN;
    END IF;

    dots := RPAD('.', phrase_len, '.');

    LOOP
        pos := INSTR(p_clob, p_phrase, pos);

        EXIT WHEN pos = 0;  

        DBMS_LOB.WRITE(
            lob_loc => p_clob,
            amount  => phrase_len,
            offset  => pos,
            buffer  => dots
        );

        pos := pos + phrase_len;
    END LOOP;
END;
/

-- zadanie 13
CREATE TABLE biographies_copy AS
SELECT * FROM ztpd.biographies;

SELECT * FROM biographies_copy
WHERE person = 'Jara Cimrman';

DECLARE
    v_bio CLOB;
BEGIN
    SELECT bio INTO v_bio
    FROM biographies_copy
    WHERE person = 'Jara Cimrman'
    FOR UPDATE;

    CLOB_CENSOR(v_bio, 'Cimrman');

    UPDATE biographies_copy
    SET bio = v_bio
    WHERE person = 'Jara Cimrman';

    COMMIT;
END;
/
SELECT bio FROM biographies_copy
WHERE person = 'Jara Cimrman';

-- zadanie 14
DROP TABLE biographies_copy;




