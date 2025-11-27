-- cwiczenie 1
--a) 
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
  'FIGURY',
  'KSZTALT',
  MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 0, 100, 0.01),
    MDSYS.SDO_DIM_ELEMENT('Y', 0, 100, 0.01)
  ),
  NULL
);

--b)
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(
    3000000,    
    8192,       
    10,        
    2,          
    0           
) AS ROZMIAR
FROM DUAL;

--c)
CREATE INDEX FIGURY_RTREE_IDX
ON FIGURY(KSZTALT)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

--d)
SELECT ID
FROM FIGURY f
WHERE SDO_FILTER(
        f.KSZTALT,
        SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3,3,NULL), NULL, NULL)
      ) = 'TRUE';

--e)
SELECT ID
FROM FIGURY f
WHERE SDO_RELATE(
        f.KSZTALT,
        SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3,3,NULL), NULL, NULL),
        'MASK=ANYINTERACT'
      ) = 'TRUE';

-- cwiczenie 2
--a)
SELECT DISTINCT t.GEOM.SDO_SRID AS SRID
FROM MAJOR_CITIES t
WHERE t.GEOM IS NOT NULL;

SELECT 
    A.CITY_NAME AS MIASTO,
    SDO_NN_DISTANCE(1) AS ODL_KM
FROM 
    MAJOR_CITIES A
WHERE 
    SDO_NN(
        A.GEOM,
        MDSYS.SDO_GEOMETRY(
            2001,
            8307,
            MDSYS.SDO_POINT_TYPE(21.0118794, 52.2449452, NULL),
            NULL,
            NULL
        ),
        'sdo_num_res=10 unit=km',
        1
    ) = 'TRUE'
    AND A.CITY_NAME <> 'Warsaw'
ORDER BY ODL_KM;

--b)
SELECT 
    CITY_NAME AS MIASTO
FROM 
    MAJOR_CITIES
WHERE 
    SDO_WITHIN_DISTANCE(
        GEOM,
        MDSYS.SDO_GEOMETRY(
            2001,
            8307,
            MDSYS.SDO_POINT_TYPE(21.0118794, 52.2449452, NULL),
            NULL,
            NULL
        ),
        'distance=100 unit=km'
    ) = 'TRUE'
    AND CITY_NAME <> 'Warsaw'
ORDER BY CITY_NAME;

--c)
SELECT 
    C.CNTRY_NAME AS KRAJ,
    M.CITY_NAME AS MIASTO
FROM 
    COUNTRY_BOUNDARIES C,
    MAJOR_CITIES M
WHERE 
    C.CNTRY_NAME = 'Slovakia'
    AND SDO_RELATE(
            M.GEOM,
            C.GEOM,
            'mask=INSIDE'
        ) = 'TRUE'
ORDER BY M.CITY_NAME;


--d)
SELECT 
    C2.CNTRY_NAME AS PANSTWO,
    SDO_GEOM.SDO_DISTANCE(
        C1.GEOM,
        C2.GEOM,
        0.005,
        'unit=KM'
    ) AS ODL_KM
FROM 
    COUNTRY_BOUNDARIES C1,
    COUNTRY_BOUNDARIES C2
WHERE 
    C1.CNTRY_NAME = 'Poland'
    AND C2.CNTRY_NAME NOT IN (
        'Poland', 
        'Germany', 
        'Czech Republic', 
        'Slovakia', 
        'Ukraine', 
        'Byelarus', 
        'Lithuania', 
        'Russia'
    ) 
ORDER BY ODL_KM;

-- cwiczenie 3
--a)
SELECT 
    C2.CNTRY_NAME,
    SDO_GEOM.SDO_LENGTH(
        SDO_GEOM.SDO_INTERSECTION(C1.GEOM, C2.GEOM, 0.005),
        0.005,
        'unit=KM'
    ) AS ODLEGLOSC
FROM 
    COUNTRY_BOUNDARIES C1,
    COUNTRY_BOUNDARIES C2
WHERE 
    C1.CNTRY_NAME = 'Poland'
    AND C2.CNTRY_NAME <> 'Poland'
    AND SDO_RELATE(
        C1.GEOM,
        C2.GEOM,
        'mask=TOUCH'
    ) = 'TRUE'
ORDER BY ODLEGLOSC DESC;

--b) 
SELECT 
    CNTRY_NAME
FROM 
    COUNTRY_BOUNDARIES
ORDER BY SDO_GEOM.SDO_AREA(
            SDO_CS.TRANSFORM(GEOM, 2180),
            0.005
        ) DESC
FETCH FIRST 1 ROWS ONLY;

--c)
SELECT (
    SDO_GEOM.SDO_AREA((
        SDO_GEOM.SDO_MBR(
            SDO_GEOM.SDO_UNION(C.GEOM, D.GEOM, 1)
        )
    ), 1, 'unit=SQ_KM')
) AS SQ_KM
FROM COUNTRY_BOUNDARIES B, MAJOR_CITIES C, MAJOR_CITIES D
WHERE SDO_RELATE(C.GEOM, B.GEOM,
    'mask=INSIDE') = 'TRUE'
    AND B.CNTRY_NAME = 'Poland'
    AND C.CITY_NAME = 'Warsaw'
    AND D.CITY_NAME = 'Lodz';

--d) 
SELECT SDO_GEOM.SDO_UNION(B.GEOM, C.GEOM, 1).SDO_GTYPE 
AS GTYPE
FROM COUNTRY_BOUNDARIES B, MAJOR_CITIES C
WHERE B.CNTRY_NAME = 'Poland'
    AND C.CITY_NAME = 'Prague';

--e) 
SELECT C.CITY_NAME, B.CNTRY_NAME
FROM COUNTRY_BOUNDARIES B, MAJOR_CITIES C
WHERE SDO_RELATE(C.GEOM, B.GEOM, 'mask=INSIDE') = 'TRUE'
ORDER BY ROUND(SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(B.GEOM,1), C.GEOM, 1, 'unit=km'))
FETCH FIRST 1 ROWS ONLY;

--f)
SELECT R."NAME",
       ROUND(SUM(SDO_GEOM.SDO_LENGTH(
           SDO_GEOM.SDO_INTERSECTION(B.GEOM, R.GEOM, 1),
           1,
           'unit=km'
       )),2) AS DLUGOSC
FROM COUNTRY_BOUNDARIES B, RIVERS R
WHERE B.CNTRY_NAME = 'Poland'
  AND SDO_RELATE(R.GEOM, B.GEOM, 'mask=ANYINTERACT') = 'TRUE'
GROUP BY R."NAME";













