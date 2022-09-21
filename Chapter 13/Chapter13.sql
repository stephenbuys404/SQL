-- Case formatting
SELECT upper('Neal7');
SELECT lower('Randy');
SELECT initcap('at the end of the day');
SELECT initcap('Practical SQL');

-- Character Information
SELECT char_length(' Pat ');
SELECT length(' Pat ');
SELECT position(', ' in 'Tan, Bella');

-- Removing characters
SELECT trim('s' from 'socks');
SELECT trim(trailing 's' from 'socks');
SELECT trim(' Pat ');
SELECT char_length(trim(' Pat ')); -- note the length change
SELECT ltrim('socks', 's');
SELECT rtrim('socks', 's');

-- Extracting and replacing characters
SELECT left('703-555-1212', 3);
SELECT right('703-555-1212', 8);
SELECT replace('bat', 'b', 'c');

-- Any character one or more times
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '.+');
-- One or two digits followed by a space and p.m.
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{1,2} (?:a.m.|p.m.)');
-- One or more word characters at the start
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '^\w+');
-- One or more word characters followed by any character at the end.
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\w+.$');
-- The words May or June
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from 'May|June');
-- Four digits
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{4}');
-- May followed by a space, digit, comma, space, and four digits.
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from 'May \d, \d{4}');

CREATE TABLE crime_reports (
    crime_id bigserial PRIMARY KEY,
    date_1 timestamp with time zone,
    date_2 timestamp with time zone,
    street varchar(250),
    city varchar(100),
    crime_type varchar(100),
    description text,
    case_number varchar(50),
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM 'C:\edb\crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

SELECT original_text FROM crime_reports;

-- using regexp_match() to find the first date
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;

-- using the regexp_matches() function with the 'g' flag
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports;

-- using regexp_match() to find the second date
SELECT crime_id,
       regexp_match(original_text, '-\d{1,2}\/\d{1,2}\/\d{1,2}')
FROM crime_reports;

-- using a capture group to return only the date
SELECT crime_id,
       regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
FROM crime_reports;

-- matching case number, date, crime type, and city
SELECT
    regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number,
    regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
    regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
    regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n')
        AS city
FROM crime_reports;

-- get all parsed elements at once
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
       CASE WHEN EXISTS (SELECT regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})'))
            THEN regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
            ELSE NULL
            END AS date_2,
       regexp_match(original_text, '\/\d{2}\n(\d{4})') AS hour_1,
       CASE WHEN EXISTS (SELECT regexp_matches(original_text, '\/\d{2}\n\d{4}-(\d{4})'))
            THEN regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})')
            ELSE NULL
            END AS hour_2,
       regexp_match(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))') AS street,
       regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') AS city,
       regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
       regexp_match(original_text, ':\s(.+)(?:C0|SO)') AS description,
       regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number
FROM crime_reports;

-- retrieving a value from within an array
SELECT
    crime_id,
    (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1]
        AS case_number
FROM crime_reports;

SELECT crime_id,
       date_1,
       original_text
FROM crime_reports;

-- viewing selected crime data
SELECT date_1,
       street,
       city,
       crime_type
FROM crime_reports;

-- using regular expressions in a WHERE clause
SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '(.+lade.+|.+lare.+)'
ORDER BY geo_name;

SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '.+ash.+' AND geo_name !~ 'Wash.+'
ORDER BY geo_name;

-- regular expression functions to replace and split
SELECT regexp_replace('05/12/2018', '\d{4}', '2017');

SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

SELECT regexp_split_to_array('Phil Mike Tony Steve', ' ');

-- finding an array length
SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);

-- Full-text search operators:
-- & (AND)
-- | (OR)
-- ! (NOT)

-- converting text to tsvector data
SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- converting search terms to tsquery data
SELECT to_tsquery('walking & sitting');

-- querying a tsvector type with a tsquery
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & sitting');
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & running');

-- creating and filling the president_speeches table
CREATE TABLE president_speeches (
    sotu_id serial PRIMARY KEY,
    president varchar(100) NOT NULL,
    title varchar(250) NOT NULL,
    speech_date date NOT NULL,
    speech_text text NOT NULL,
    search_speech_text tsvector
);

COPY president_speeches (president, title, speech_date, speech_text)
FROM 'C:\edb\sotu-1946-1977.csv'
WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@');

SELECT * FROM president_speeches;

-- converting speeches to tsvector in the search_speech_text column
UPDATE president_speeches
SET search_speech_text = to_tsvector('english', speech_text);

-- creating a GIN index for text search
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);

-- finding speeches containing the word "Vietnam"
SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;

-- displaying search results with ts_headline()
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('Vietnam'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam');

-- finding speeches with the word "transportation" but not "roads"
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('transportation & !roads'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('transportation & !roads');

-- find speeches where "defense" follows "military"
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('military <-> defense'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <-> defense');

SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('military <2> defense'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=2')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <2> defense');

-- scoring relevance with ts_rank()
SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('war & security & threat & enemy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;

-- normalizing ts_rank() by speech length
SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('war & security & threat & enemy'), 2)::numeric 
               AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;


