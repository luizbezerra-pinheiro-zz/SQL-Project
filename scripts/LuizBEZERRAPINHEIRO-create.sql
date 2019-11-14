CREATE TABLE artist_type(
    id int PRIMARY KEY,
    name varchar
);


CREATE TABLE gender(
    id int PRIMARY KEY,
    name varchar
);


CREATE TABLE country(
    id int PRIMARY KEY,
    name varchar
);


CREATE TABLE artist(
    id int PRIMARY KEY ,
    name varchar,
    gender int REFERENCES gender(id),
    sday int,
    smonth int,
    syear int,
    eday int,
    emonth int,
    eyear int,
    type int DEFAULT 3 REFERENCES artist_type(id),
    area int REFERENCES country(id) ON DELETE SET NULL,
    /*Starting-date check*/
    CONSTRAINT check_starting_date
            CHECK ( syear IS NULL
            OR ((smonth IS NULL
                    OR (sday IS NULL AND smonth >= 1 AND smonth <= 12)
                    OR ((smonth >= 1 AND smonth <= 12)
                        AND ((syear % 400 <> 0 AND (syear % 100 = 0 OR syear % 4 <> 0)) OR smonth <> 2 OR
                             (sday >= 1 AND sday <= 29))
                        AND ((syear % 400 = 0 OR (syear % 100 <> 0 AND syear % 4 = 0)) OR smonth <> 2 OR
                             (sday >= 1 AND sday <= 28))
                        AND ((smonth not in (1, 3, 5, 7, 8, 10, 12)) OR (sday >= 1 AND sday <= 31))
                        AND ((smonth not in (4, 6, 9, 11)) OR (sday >= 1 AND sday <= 30))
                        )
                    )
                    )
            ),
    /*Ending date check*/
    CONSTRAINT check_ending_date
            CHECK ( syear IS NULL
            OR ((smonth IS NULL
                    OR (sday IS NULL AND smonth >= 1 AND smonth <= 12)
                    OR ((smonth >= 1 AND smonth <= 12)
                        AND ((syear % 400 <> 0 AND (syear % 100 = 0 OR syear % 4 <> 0)) OR smonth <> 2 OR
                             (sday >= 1 AND sday <= 29))
                        AND ((syear % 400 = 0 OR (syear % 100 <> 0 AND syear % 4 = 0)) OR smonth <> 2 OR
                             (sday >= 1 AND sday <= 28))
                        AND ((smonth not in (1, 3, 5, 7, 8, 10, 12)) OR (sday >= 1 AND sday <= 31))
                        AND ((smonth not in (4, 6, 9, 11)) OR (sday >= 1 AND sday <= 30))
                        )
                    )
                    )
            ),
    /*Sanity check*/
    CONSTRAINT check_sanity
        CHECK ( (eyear IS NULL OR syear IS NULL ) OR
        ( eyear > syear OR ( eyear = syear AND
        ( (emonth IS NULL OR smonth IS NULL) OR
        ( emonth > smonth OR (emonth = smonth AND
        ( (eday IS NULL OR sday IS NULL)
        OR (eday >= sday))))))))
    /*Person_has_gender check*/
    -- CONSTRAINT check_gender CHECK ( (type = 1) OR (gender IS NULL ) )
);


CREATE TABLE release_status(
    id int PRIMARY KEY,
    name varchar
);


CREATE TABLE release(
    id int PRIMARY KEY,
    title varchar,
    status int REFERENCES release_status(id) ON DELETE SET NULL,
    barcode varchar,
    packaging varchar
);


CREATE TABLE release_country
(
    release int NOT NULL REFERENCES release (id) ON DELETE CASCADE ,
    country int REFERENCES country (id) ON DELETE SET NULL,
    day     int,
    month   int,
    year    int,
    PRIMARY KEY (release, country),
    /* date check */
    CONSTRAINT check_date
        CHECK ( year IS NULL
            OR ( ( month IS NULL
                    OR (day IS NULL AND month >= 1 AND month <= 12)
                    OR (( month >= 1 AND month <= 12)
                        AND ((year % 400 <> 0 AND (year % 100 = 0 OR year % 4 <> 0)) OR month <> 2 OR
                             (day >= 1 AND day <= 29))
                        AND ((year % 400 = 0 OR (year % 100 <> 0 AND year % 4 = 0)) OR month <> 2 OR
                             (day >= 1 AND day <= 28))
                        AND ((month not in (1, 3, 5, 7, 8, 10, 12)) OR (day >= 1 AND day <= 31))
                        AND ((month not in (4, 6, 9, 11)) OR (day >= 1 AND day <= 30))
                        )
                    )
                    )
            )
);


CREATE TABLE release_has_artist(
    release int REFERENCES release(id) ON DELETE CASCADE,
    artist int REFERENCES artist(id) ON DELETE CASCADE,
    contribution int,
    PRIMARY KEY (release, artist, contribution)
);


CREATE TABLE track(
    id int PRIMARY KEY,
    name varchar,
    no int,
    length int,
    release int NOT NULL REFERENCES release(id) ON DELETE CASCADE
);


CREATE TABLE track_has_artist(
    artist int REFERENCES artist(id) ON DELETE CASCADE,
    track int REFERENCES track(id) ON DELETE CASCADE,
    contribution int,
    PRIMARY KEY (artist, track)
);

ALTER TABLE release
ADD CONSTRAINT participation_event CHECK (
	(
		SELECT COUNT(*)
		FROM release_country
		WHERE release_country.release = release.id
	) > 0
);
