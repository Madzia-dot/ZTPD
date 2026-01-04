-- zadanie 1
CREATE TABLE CYTATY AS SELECT * FROM ZTPD.CYTATY;
-- zadanie 2
SELECT autor, tekst
FROM CYTATY
WHERE LOWER(tekst) LIKE '%optymista%'
  AND LOWER(tekst) LIKE '%pesymista%';
  
-- zadanie 3
CREATE INDEX idx_cytaty_tekst ON CYTATY(TEKST) 
INDEXTYPE IS CTXSYS.CONTEXT;

-- zadanie 4
SELECT autor, tekst FROM CYTATY 
WHERE CONTAINS(tekst, 'optymista AND pesymista') > 0;

-- zadanie 5
SELECT autor, tekst FROM CYTATY 
WHERE CONTAINS(tekst, 'pesymista NOT optymista') > 0;

-- zadanie 6
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((optymista, pesymista), 3)') > 0;

-- zadanie 7
SELECT autor, tekst FROM CYTATY 
WHERE CONTAINS(tekst, 'NEAR((optymista, pesymista), 10)') > 0;

-- zadanie 8
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0;

-- zadanie 9
SELECT SCORE(1) AS DOPASOWANIE, AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

-- zadanie 10
SELECT SCORE(1) AS DOPASOWANIE, AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0
ORDER BY DOPASOWANIE DESC
FETCH FIRST 1 ROW ONLY;

-- zadanie 11
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'FUZZY(probelm, 70, 6, weight)', 1) > 0;

-- zadanie 12
INSERT INTO CYTATY (ID, AUTOR, TEKST) 
VALUES (100, 'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;
-- zadanie 13
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'głupcy') > 0;
-- indeks nie jest aktualizowany automatycznie po insert 
-- zadanie 14

SELECT TOKEN_TEXT FROM DR$IDX_CYTATY_TEKST$I WHERE TOKEN_TEXT = 'GŁUPCY';

-- zadanie 15
ALTER INDEX idx_cytaty_tekst REBUILD;

-- zadanie 16
SELECT TOKEN_TEXT FROM DR$IDX_CYTATY_TEKST$I WHERE TOKEN_TEXT = 'GŁUPCY';
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'głupcy') > 0;
COMMIT;

-- zadanie 17
DROP INDEX idx_cytaty_tekst;
DROP TABLE CYTATY;


-- ZAAWANSOWANE INDEKSOWANIE I WYSZUKIWANIE 

-- zadanie 1 
CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;

-- zadanie 2
CREATE INDEX idx_quotes_text ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT;

-- zadanie 3
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'working') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$working') > 0;

-- zadanie 4
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it') > 0;
-- nic nie zwrócił, bo słowo it znajduje się na stop-liscie 

-- zadanie 5
SELECT * FROM CTX_STOPLISTS;
-- default_stoplist

-- zadanie 6
SELECT * FROM CTX_STOPWORDS;

-- zadanie 7
DROP INDEX idx_quotes_text;
CREATE INDEX idx_quotes_text ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT 
PARAMETERS ('STOPLIST CTXSYS.EMPTY_STOPLIST');

-- zadanie 8
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it') > 0;
-- zwrócił 4 wiersze 

-- zadanie 9 
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND humans') > 0;

-- zadanie 10
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND computer') > 0;

-- zadanie 11
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool WITHIN SENTENCE AND humans WITHIN SENTENCE') > 0;
-- domyślnie grupa sekcji nie rozpoznaje granic zdan ani akapitow 

-- zadanie 12
DROP INDEX idx_quotes_text;
-- zadanie 13
BEGIN
  CTX_DDL.CREATE_SECTION_GROUP('my_section_group', 'NULL_SECTION_GROUP');
  CTX_DDL.ADD_SPECIAL_SECTION('my_section_group', 'SENTENCE');
  CTX_DDL.ADD_SPECIAL_SECTION('my_section_group', 'PARAGRAPH');
END;
/

-- zadanie 14
CREATE INDEX idx_quotes_text ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT 
PARAMETERS ('SECTION GROUP my_section_group STOPLIST CTXSYS.EMPTY_STOPLIST');

-- zadanie 15
-- 'fool' i 'humans' w jednym zdaniu
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND humans) WITHIN SENTENCE') > 0;

-- 'fool' i 'computer' w jednym zdaniu
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND computer) WITHIN SENTENCE') > 0;

-- zadanie 16
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;
-- tak, zwrócił też non-humans bo myślnik jest traktowany jako separator 

-- zadanie 17
BEGIN
  CTX_DDL.CREATE_PREFERENCE('my_lexer', 'BASIC_LEXER');
  CTX_DDL.SET_ATTRIBUTE('my_lexer', 'printjoins', '-');
END;
/

DROP INDEX idx_quotes_text;

CREATE INDEX idx_quotes_text ON QUOTES(TEXT) 
INDEXTYPE IS CTXSYS.CONTEXT 
PARAMETERS ('LEXER my_lexer SECTION GROUP my_section_group STOPLIST CTXSYS.EMPTY_STOPLIST');

-- zadanie 18
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;
-- nie 

-- zadanie 19
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '{non-humans}') > 0;

-- zadanie 20
DROP TABLE QUOTES;
BEGIN
  CTX_DDL.DROP_PREFERENCE('my_lexer');
END;
BEGIN
  CTX_DDL.DROP_SECTION_GROUP('my_section_group');
END;
/