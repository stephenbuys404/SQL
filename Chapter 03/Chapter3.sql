-- char(1) fixed one value, varchar(1) max 1
CREATE TABLE char_data_types (
    varchar_column varchar(10),
    char_column char(10),
    text_column text
);

INSERT INTO char_data_types
VALUES
    ('abc', 'abc', 'abc'),
    ('defghi', 'defghi', 'defghi');

--Don't insert the header
--insert values into table separated by a delimiter
COPY char_data_types TO 'C:\edb\typetest.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

--Auto-Incrementing id
CREATE TABLE people (
id serial,
person_name varchar(100)
);

-- smallint,integer,bigint
CREATE TABLE number_data_types (
    numeric_column numeric(20,5),
    real_column real,
    double_column double precision
);

INSERT INTO number_data_types
VALUES
    (.7, .7, .7),
    (2.13579, 2.13579, 2.13579),
    (2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;

-- float columns rounding issue
SELECT
    numeric_column * 10000000 AS "Fixed",
    real_column * 10000000 AS "Float"
FROM number_data_types
WHERE numeric_column = .7;

-- Timestamp and interval types in action
CREATE TABLE date_time_types (
    timestamp_column timestamp with time zone,
    interval_column interval
);

INSERT INTO date_time_types
VALUES
    ('2018-12-31 01:00 EST','2 days'),
    ('2018-12-31 01:00 PST','1 month'),
    ('2018-12-31 01:00 Australia/Melbourne','1 century'),
    (now(),'1 week');

SELECT * FROM date_time_types;

-- using the interval data type
SELECT
    timestamp_column,
    interval_column,
    timestamp_column - interval_column AS new_date
FROM date_time_types;

-- CAST() examples transforming values from one type into another
SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT numeric_column,
       CAST(numeric_column AS integer),
       CAST(numeric_column AS varchar(6))
FROM number_data_types;--semicolon

-- cannot change string into integer:
SELECT CAST(char_column AS integer) FROM char_data_types;

-- casting directly
SELECT timestamp_column::varchar(10)
FROM date_time_types;
