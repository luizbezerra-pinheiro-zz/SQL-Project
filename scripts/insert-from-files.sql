--- REMOVE ALL CONSTRAINTS --------------------



-- Insert from files --
copy artist from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/artist';
copy artist_type from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/artist_type';
copy country from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/country';
copy gender from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/gender';
copy release from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/release';
copy release_country from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/release_country';
copy release_has_artist from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/release_has_artist';
copy release_status from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/release_status';
copy track from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/track';
copy track_has_artist from '/home/luiz/Documents/Polytechnique/INF553-2019/Cours/mbdump_reduced/track_has_artist';

UPDATE artist
SET
    eyear = 2004
WHERE NOT (((eyear IS NULL) OR (syear IS NULL) OR ((eyear > syear) OR ((eyear = syear) AND ((emonth IS NULL) OR (smonth IS NULL) OR ((emonth > smonth) OR ((emonth = smonth) AND ((eday IS NULL) OR (sday IS NULL) OR (eday >= sday)))))))));


-- ADD BACK ALL CONSTRAINTS  --


