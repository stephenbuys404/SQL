SELECT 2 + 2;    -- addition
SELECT 9 - 1;    -- subtraction
SELECT 3 * 4;    -- multiplication
SELECT 11 / 6;   -- integer division
SELECT 11 % 6;   -- modulo division
SELECT 11.0 / 6; -- decimal division

SELECT CAST(11 AS numeric(3,1)) / 6;-- casting result

SELECT 3 ^ 4;    -- exponentiation
SELECT |/ 10;    -- square root (operator)
SELECT sqrt(10); -- square root (function)
SELECT ||/ 10;   -- cube root
SELECT 4 !;      -- factorial

-- operations order
SELECT 7 + 8 * 9; 	-- answer: 79
SELECT (7 + 8) * 9;	-- answer: 135
SELECT 3 ^ 3 - 1;   -- answer: 26
SELECT 3 ^ (3 - 1); -- answer: 9

-- changing hard column names into easy column names
SELECT geo_name,
       state_us_abbreviation AS "st",
       p0010001 AS "Total Population",
       p0010003 AS "White Alone",
       p0010004 AS "Black or African American Alone",
       p0010005 AS "Am Indian/Alaska Native Alone",
       p0010006 AS "Asian Alone",
       p0010007 AS "Native Hawaiian and Other Pacific Islander Alone",
       p0010008 AS "Some Other Race Alone",
       p0010009 AS "Two or More Races"
FROM us_counties_2010;

SELECT geo_name,
       state_us_abbreviation AS "st",
       p0010003 AS "White Alone",
       p0010004 AS "Black Alone",
       -- changing 2 columns into one column
       p0010003 + p0010004 AS "Total White and Black"
FROM us_counties_2010;

SELECT geo_name,
       state_us_abbreviation AS "st",
       p0010001 AS "Total",
       -- changing many columns into one column
       p0010003 + p0010004 + p0010005 + p0010006 + p0010007 + p0010008 + p0010009 AS "All Races",
       (p0010003 + p0010004 + p0010005 + p0010006 + p0010007 + p0010008 + p0010009) - p0010001 AS "Difference"
FROM us_counties_2010
ORDER BY "Difference" DESC;

-- percentage of asians in every county
SELECT geo_name,
       state_us_abbreviation AS "st",
       (CAST(p0010006 AS numeric(8,1)) / p0010001) * 100 AS "pct_asian"
FROM us_counties_2010
ORDER BY "pct_asian" DESC;

-- calculating percent change
CREATE TABLE percent_change (
    department varchar(20),
    spend_2014 numeric(10,2),
    spend_2017 numeric(10,2)
);

INSERT INTO percent_change
VALUES
    ('Building', 250000, 289000),
    ('Assessor', 178556, 179500),
    ('Library', 87777, 90001),
    ('Clerk', 451980, 650000),
    ('Police', 250000, 223000),
    ('Recreation', 199000, 195000);

SELECT department,
       spend_2014,
       spend_2017,
       round( (spend_2017 - spend_2014) / spend_2014 * 100, 1 ) AS "pct_change"
FROM percent_change;

-- using sum() count all rows and avg() count all rows / total
SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 0) AS "County Average"
FROM us_counties_2010;

-- testing percentile
CREATE TABLE percentile_test (
    numbers integer
);

INSERT INTO percentile_test (numbers) VALUES
    (1), (2), (3), (4), (5), (6);

SELECT
    percentile_cont(.5) -- continuous .5=50th percentile
    WITHIN GROUP (ORDER BY numbers),
    percentile_disc(.5) -- discrete
    WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

SELECT sum(p0010001) AS "County Sum", -- sum()
       round(avg(p0010001), 0) AS "County Average", -- avg()
       percentile_cont(.5) -- continuous
       WITHIN GROUP (ORDER BY p0010001) AS "County Median"
FROM us_counties_2010;

-- quartiles
SELECT percentile_cont(array[.25,.5,.75]) -- continuous
       WITHIN GROUP (ORDER BY p0010001) AS "quartiles"
FROM us_counties_2010; -- pasing array to percentile_cont()

-- quintiles
SELECT percentile_cont(array[.2,.4,.6,.8])
       WITHIN GROUP (ORDER BY p0010001) AS "quintiles"
FROM us_counties_2010;

-- deciles
SELECT percentile_cont(array[.1,.2,.3,.4,.5,.6,.7,.8,.9])
       WITHIN GROUP (ORDER BY p0010001) AS "deciles"
FROM us_counties_2010;

SELECT unnest( -- turn an array into rows
            percentile_cont(array[.25,.5,.75])
            WITHIN GROUP (ORDER BY p0010001)) AS "quartiles"
FROM us_counties_2010;

CREATE OR REPLACE FUNCTION _final_median(anyarray)
   RETURNS float8 AS -- creates function
$$
  WITH q AS
  (
     SELECT val
     FROM unnest($1) val
     WHERE VAL IS NOT NULL
     ORDER BY 1
  ),
  cnt AS
  (
    SELECT COUNT(*) AS c FROM q
  )
  SELECT AVG(val)::float8
  FROM
  (
    SELECT val FROM q
    LIMIT  2 - MOD((SELECT c FROM cnt), 2)
    OFFSET GREATEST(CEIL((SELECT c FROM cnt) / 2.0) - 1,0)
  ) q2;
$$
LANGUAGE sql IMMUTABLE;

CREATE AGGREGATE median(anyelement) (
  SFUNC=array_append, --must create this
  STYPE=anyarray,
  FINALFUNC=_final_median,
  INITCOND='{}'
);

-- median() aggregate
SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 0) AS "County Average",
       median(p0010001) AS "County Median",
       percentile_cont(.5)
       WITHIN GROUP (ORDER BY P0010001) AS "50th Percentile"
FROM us_counties_2010;

-- most-frequent value
SELECT mode() WITHIN GROUP (ORDER BY p0010001)
FROM us_counties_2010;
