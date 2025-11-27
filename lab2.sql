-- zadanie 1
CREATE TABLE movies AS
SELECT *
FROM ZTPD.MOVIES;

-- zadanie 2
DESCRIBE movies;

-- zadanie 3
SELECT id, title
FROM movies
WHERE cover IS NULL;

-- zadanie 4
SELECT id,
       title,
       DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NOT NULL;

-- zadanie 5
SELECT id,
       title,
       CASE 
           WHEN cover IS NOT NULL THEN DBMS_LOB.GETLENGTH(cover)
           ELSE NULL
       END AS filesize
FROM movies;

-- zadanie 6
SELECT directory_name,
       directory_path
FROM all_directories
WHERE directory_name = 'TPD_DIR';

-- zadanie 7
UPDATE movies
SET cover = EMPTY_BLOB(),
    mime_type = 'image/jpeg'
WHERE id = 66;

COMMIT;

-- zadanie 8
SELECT id,
       title,
       CASE 
           WHEN cover IS NOT NULL THEN DBMS_LOB.GETLENGTH(cover)
           ELSE NULL
       END AS filesize
FROM movies
WHERE id IN (65, 66);

-- zadanie 9
DECLARE
    src_file  BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
    dest_blob BLOB;
BEGIN
    SELECT cover
    INTO dest_blob
    FROM movies
    WHERE id = 66
    FOR UPDATE;

    DBMS_LOB.OPEN(src_file, DBMS_LOB.LOB_READONLY);
    
    DBMS_LOB.LOADFROMFILE(dest_blob, src_file, DBMS_LOB.GETLENGTH(src_file));

    DBMS_LOB.CLOSE(src_file);

    COMMIT;
END;
/

-- zadanie 10
CREATE TABLE temp_covers (
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);

-- zadanie 11
INSERT INTO temp_covers (movie_id, image, mime_type)
VALUES (
    65,
    BFILENAME('TPD_DIR', 'eagles.jpg'),  -- plik z katalogu serwera
    'image/jpeg'
);


COMMIT;

-- zadanie 12
SELECT movie_id, 
       DBMS_LOB.getlength(image) AS filesize
FROM temp_covers
WHERE movie_id = 65;

-- zadanie 13
DECLARE
    v_bfile   BFILE;
    v_blob    BLOB;
    v_mime    VARCHAR2(50);
BEGIN
    SELECT image, mime_type
    INTO v_bfile, v_mime
    FROM temp_covers
    WHERE movie_id = 65;

    UPDATE movies
    SET cover = EMPTY_BLOB()
    WHERE id = 65
    RETURNING cover INTO v_blob;

    DBMS_LOB.fileopen(v_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.loadfromfile(v_blob, v_bfile, DBMS_LOB.getlength(v_bfile));
    DBMS_LOB.fileclose(v_bfile);

    COMMIT;
END;
/

-- zadanie 14 
SELECT id AS movie_id,
       DBMS_LOB.getlength(cover) AS filesize
FROM movies
WHERE id IN (65, 66);

-- zadanie 15
DROP TABLE movies CASCADE CONSTRAINTS;

