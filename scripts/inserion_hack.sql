-- The commands needed in order to drop all the constraints from the database

SELECT 'ALTER TABLE "'||nspname||'"."'||relname||'" DROP CONSTRAINT "'||conname||'" CASCADE;'
FROM pg_constraint
INNER JOIN pg_class ON conrelid=pg_class.oid
INNER JOIN pg_namespace ON pg_namespace.oid=pg_class.relnamespace
WHERE nspname = current_schema()
ORDER BY CASE WHEN contype='f' THEN 0 ELSE 1 END,contype,nspname,relname,conname;

-----------------


-- The set of commands needed in order to re-create all the constraints:

SELECT 'ALTER TABLE "'||nspname||'"."'||relname||'" ADD CONSTRAINT "'||conname||'" '
||pg_get_constraintdef(pg_constraint.oid)||';'
FROM pg_constraint
INNER JOIN pg_class ON conrelid=pg_class.oid
INNER JOIN pg_namespace ON pg_namespace.oid=pg_class.relnamespace
WHERE nspname = current_schema()
ORDER BY CASE WHEN contype='f' THEN 0 ELSE 1 END DESC,contype DESC,nspname DESC,
relname DESC,conname DESC;
---------

SELECT * FROM "public"."artist" WHERE NOT (((syear IS NULL) OR ((syear >= 0) AND ((smonth IS NULL) OR ((sday IS NULL) AND (smonth >= 1) AND (smonth <= 12)) OR ((syear >= 0) AND (smonth >= 1) AND (smonth <= 12) AND ((((syear % 400) <> 0) AND (((syear % 100) = 0) OR ((syear % 4) <> 0))) OR (smonth <> 2) OR ((sday >= 1) AND (sday <= 29))) AND (((syear % 400) = 0) OR (((syear % 100) <> 0) AND ((syear % 4) = 0)) OR (smonth <> 2) OR ((sday >= 1) AND (sday <= 28))) AND ((smonth <> ALL (ARRAY[1, 3, 5, 7, 8, 10, 12])) OR ((sday >= 1) AND (sday <= 31))) AND ((smonth <> ALL (ARRAY[4, 6, 9, 11])) OR ((sday >= 1) AND (sday <= 30))))))));

SELECT * FROM "public"."artist" WHERE NOT (((eyear IS NULL) OR (syear IS NULL) OR ((eyear > syear) OR ((eyear = syear) AND ((emonth IS NULL) OR (smonth IS NULL) OR ((emonth > smonth) OR ((emonth = smonth) AND ((eday IS NULL) OR (sday IS NULL) OR (eday >= sday)))))))));

DELETE FROM "public"."artist" WHERE NOT (((eyear IS NULL) OR (syear IS NULL) OR ((eyear > syear) OR ((eyear = syear) AND ((emonth IS NULL) OR (smonth IS NULL) OR ((emonth > smonth) OR ((emonth = smonth) AND ((eday IS NULL) OR (sday IS NULL) OR (eday >= sday)))))))));

SELECT * FROM "public"."artist" WHERE NOT (((type <> 1) OR (gender IS NOT NULL)));

UPDATE artist
SET
    eyear = 2004
WHERE NOT (((eyear IS NULL) OR (syear IS NULL) OR ((eyear > syear) OR ((eyear = syear) AND ((emonth IS NULL) OR (smonth IS NULL) OR ((emonth > smonth) OR ((emonth = smonth) AND ((eday IS NULL) OR (sday IS NULL) OR (eday >= sday)))))))));

