-- 1st

EXPLAIN
SELECT C.name, P0.name
FROM country C, artist P0
WHERE C.id = P0.area
ORDER BY (C.name, P0.name);

-- 2nd

EXPLAIN ANALYSE
WITH aux AS
    (
        SELECT C.id, C.name, count(*) as cnt
        FROM country C, artist P0
        WHERE C.id = P0.area
        GROUP BY (C.id)
        ORDER BY cnt DESC
    ),
max_countries AS
    (
        SELECT aux.name
        FROM aux
        WHERE aux.cnt >= ALL(SELECT cnt FROM aux)
    )

SELECT C.name, A.name
FROM country C
INNER JOIN artist A ON A.area = C.id
WHERE C.name IN (SELECT name FROM max_countries);

-- 3th --------------

EXPLAIN ANALYSE
SELECT DISTINCT P0.id
FROM release R, release_country RC, country C, artist P0, release_has_artist RhA
WHERE RhA.artist = P0.id AND RhA.release = R.id AND RC.release = R.id AND RC.country = C.id AND C.name LIKE 'A%';

-- Optimized 3th
EXPLAIN ANALYSE
WITH ACountries AS
    (
     SELECT C.id
     FROM country C
     WHERE C.name LIKE 'A%'
    ),
     releasesAtA AS
    (
        SELECT RC.release
        FROM release_country RC
        INNER JOIN ACountries C ON RC.country = C.id
    )
    SELECT R.artist
    FROM release_has_artist R
    INNER JOIN releasesAtA RAA ON R.release = RAA.release
    GROUP BY R.artist
    ORDER BY R.artist;

-- 4th

EXPLAIN ANALYSE
SELECT C.id, count(1) AS cc
FROM release_country RC, country C
WHERE RC.country = C.id
GROUP BY (C.id)
ORDER BY count(1) DESC;

-- 5th

EXPLAIN ANALYSE
SELECT RhA.release, RhA.artist
FROM release_has_artist RhA, release R, artist P0
WHERE RhA.artist = P0.id AND RhA.release = R.id AND RhA.contribution = 0
ORDER BY (RhA.release, RhA.artist);

-- 6th

EXPLAIN ANALYSE
SELECT RhA1.artist, RhA2.artist, count(1)
FROM release_has_artist RhA1, release_has_artist RhA2, release R
WHERE RhA1.release = R.id AND RhA2.release = R.id AND RhA1.artist <> RhA2.artist
GROUP BY (RhA1.artist, RhA2.artist)
ORDER BY (RhA1.artist, RhA2.artist);

-- 7th

EXPLAIN ANALYSE
SELECT RC.country, RC.release
FROM release_country RC, release R
WHERE RC.release = R.id AND ( (SELECT COUNT(*) FROM track T, release R1 WHERE T.release = R1.id) >= 2)
ORDER BY (RC.release, RC.country);

-- 8th -------

EXPLAIN ANALYSE
SELECT RC.release, RC.country, RC.year, RC.month, RC.day
FROM release_country RC
WHERE RC.country <> (
                        SELECT RCin.country
                        FROM release_country RCin, country C
                        WHERE RCin.release = RC.release AND RCin.country = C.id
                        ORDER BY (RCin.year, RCin.month, RCin.day) LIMIT 1
                    )
ORDER BY RC.year, RC.month, RC.day, RC.country;

-- Optimized 8th

CREATE VIEW ReleaseCountryOrdered AS
    (SELECT row_number() OVER (PARTITION BY RC.release ORDER BY  RC.year, RC.month, RC.day) release_order, *
    FROM release_country RC);

EXPLAIN ANALYSE
SELECT RC.release, RC.country
FROM ReleaseCountryOrdered RC
WHERE RC.release_order > 1
ORDER BY RC.year, RC.month, RC.day, country;


-- 9th
-- OLD QUERY

SELECT C.name, P0.name,
    (
        SELECT COUNT(*)
        FROM artist P
        WHERE P.area = P0.area AND
              (
		        (P.syear IS NOT NULL) AND
                ( P0.syear > P.syear OR ( P0.syear = P.syear AND
                ( (P0.smonth IS NOT NULL AND P.smonth IS NOT NULL) AND
                ( P0.smonth > P.smonth OR (P0.smonth = P.smonth AND
                ( (P0.sday IS NOT NULL AND P.sday IS NOT NULL)
                AND (P0.sday > P.sday))))))))
        ) as nb,

    (
        SELECT COUNT(*)
        FROM artist P
        WHERE (
		        ( P.syear IS NOT NULL) AND
                ( P0.syear > P.syear OR ( P0.syear = P.syear AND
                ( (P0.smonth IS NOT NULL AND P.smonth IS NOT NULL) AND
                ( P0.smonth > P.smonth OR (P0.smonth = P.smonth AND
                ( (P0.sday IS NOT NULL AND P.sday IS NOT NULL)
                AND (P0.sday > P.sday))))))))
        ) as nb_global
FROM artist P0
INNER JOIN country C ON C.id = P0.area
WHERE P0.type = 1 AND P0.syear IS NOT NULL; -- 1 -> 'Person';

-- Optimized 9th
CREATE VIEW ArtistsOrdered AS
    (SELECT row_number() OVER (ORDER BY A.syear, A.smonth, A.sday) - 1 AS nb_global, row_number() OVER (PARTITION BY area ORDER BY area, syear, smonth, sday) - 1 AS nb, *
    FROM Artist A
    WHERE A.syear IS NOT NULL AND A.smonth IS NOT NULL AND A.sday IS NOT NULL);

EXPLAIN ANALYSE
SELECT C.name as country, P0.name as name, P0.nb, P0.nb_global
FROM ArtistsOrdered P0
INNER JOIN country c on P0.area = c.id
WHERE P0.type = 1
ORDER BY nb, nb_global;


------------------- 3th Assignment ------------------

SELECT A.id, A.name
FROM artist A, release_has_artist RhA, release_country RC, country C
WHERE RhA.artist = A.id AND
      RhA.release = RC.release AND
      RC.country = C.id AND
      C.name = 'Canada' AND
      RC.year > 1991;