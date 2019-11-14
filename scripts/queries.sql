-- 1st

EXPLAIN ANALYSE
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

-- 3th

EXPLAIN ANALYSE
SELECT DISTINCT P0.id
FROM release R, release_country RC, country C, artist P0, release_has_artist RhA
WHERE RhA.artist = P0.id AND RhA.release = R.id AND RC.release = R.id AND RC.country = C.id AND C.name LIKE 'A%';

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

-- 8th

EXPLAIN ANALYSE
SELECT RC.release, RC.country, RC.year, RC.month, RC.day
FROM release_country RC
WHERE RC.country <> (
                        SELECT RCin.country
                        FROM release_country RCin, country C
                        WHERE RCin.release = RC.release AND RCin.country = C.id
                        ORDER BY (RCin.year, RCin.month, RCin.day) LIMIT 1
                    )
ORDER BY (RC.year, RC.month, RC.day, RC.country);

-- 9th

-- First a query to count the number of people born before a specific Person id = 228117
-- P must be born before P0

EXPLAIN
SELECT C.name, P0.name,
    (
        SELECT COUNT(*)
        FROM artist P
        WHERE P.area = P0.area AND P.type = 1 AND
              ( (P0.syear IS NULL OR P.syear IS NULL ) OR
                ( P0.syear > P.syear OR ( P0.syear = P.syear AND
                ( (P0.smonth IS NULL OR P.smonth IS NULL) OR
                ( P0.smonth > P.smonth OR (P0.smonth = P.smonth AND
                ( (P0.sday IS NULL OR P.sday IS NULL)
                OR (P0.sday >= P.sday))))))))
        ) as nb,
       (
        SELECT COUNT(*)
        FROM artist P
        WHERE   P.type = 1 AND ( (P0.syear IS NULL OR P.syear IS NULL ) OR
                ( P0.syear > P.syear OR ( P0.syear = P.syear AND
                ( (P0.smonth IS NULL OR P.smonth IS NULL) OR
                ( P0.smonth > P.smonth OR (P0.smonth = P.smonth AND
                ( (P0.sday IS NULL OR P.sday IS NULL)
                OR (P0.sday >= P.sday))))))))
           ) as nb_global
FROM artist P0, country C
WHERE P0.type = 1 -- 1 -> 'Person'
ORDER BY nb, nb_global
LIMIT 2;
