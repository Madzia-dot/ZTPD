-- cwiczenie 1
--a)
CREATE TABLE S6_LRS (
    GEOM SDO_GEOMETRY
);

--b) 
INSERT INTO S6_LRS
SELECT S.GEOM
FROM STREETS_AND_RAILROADS S, MAJOR_CITIES C
WHERE UPPER(C.CITY_NAME) = 'KOSZALIN' -- Zmiana na wielkie litery
  AND SDO_ANYINTERACT(S.GEOM, SDO_GEOM.SDO_BUFFER(C.GEOM, 10, 0.005, 'unit=km')) = 'TRUE';

--c) 
SELECT SDO_GEOM.SDO_LENGTH(geom, 0.005, 'unit=km') AS DISTANCE_ST,
       SDO_UTIL.GETNUMVERTICES(geom) AS NUMPOINTS
FROM S6_LRS;

--d)
UPDATE S6_LRS
SET geom = SDO_LRS.CONVERT_TO_LRS_GEOM(geom, 0, SDO_GEOM.SDO_LENGTH(geom, 0.005, 'unit=km'));

--e) i f)
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
  'S6_LRS',
  'GEOM',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('X', 14, 25, 0.005),
    SDO_DIM_ELEMENT('Y', 49, 55, 0.005),
    SDO_DIM_ELEMENT('M', 0, 300, 0.005) -- Wymiar dla miary LRS
  ),
  8307
);

CREATE INDEX S6_LRS_IDX ON S6_LRS(GEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- cwiczenie 2
--a) 
SELECT SDO_LRS.VALID_MEASURE(geom, 500) FROM S6_LRS;

--b) i c)
-- Punkt końcowy
SELECT SDO_LRS.GEOM_SEGMENT_END_PT(geom) FROM S6_LRS;

-- Punkt na 150. kilometrze
SELECT SDO_LRS.LOCATE_PT(geom, 150) FROM S6_LRS;

--d)
SELECT SDO_LRS.CLIP_GEOM_SEGMENT(geom, 120, 160) FROM S6_LRS;

--e)
SELECT SDO_LRS.PROJECT_PT(
    S6.GEOM, 
    C.GEOM
) AS WJAZD_NA_S6
FROM S6_LRS S6, MAJOR_CITIES C 
WHERE UPPER(C.CITY_NAME) = 'SŁUPSK';

--f) 
SELECT SDO_GEOM.SDO_LENGTH(
    SDO_LRS.OFFSET_GEOM_SEGMENT(
        GEOM, 
        50,          
        200,         
        0.05,       
        0.005,       
        'unit=km'    
    ),
    0.005,           
    'unit=km'       
) * 1 AS KOSZT       
FROM S6_LRS;