-- creating a table to test vacuuming
CREATE TABLE vacuum_test (
    integer_column integer
);

-- determining the size of vacuum_test
SELECT pg_size_pretty(
           pg_total_relation_size('vacuum_test')
       );

-- optional: Determine database size   
SELECT pg_size_pretty(
           pg_database_size('analysis')
       );

-- inserting 500,000 rows into vacuum_test
INSERT INTO vacuum_test
SELECT * FROM generate_series(1,500000);

-- test its size again
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

-- updating all rows in vacuum_test
UPDATE vacuum_test
SET integer_column = integer_column + 1;

-- test its size again (35 MB)
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

-- viewing autovacuum statistics for vacuum_test
SELECT relname,
       last_vacuum,
       last_autovacuum,
       vacuum_count,
       autovacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- To see all columns available
SELECT *
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- running VACUUM manually
VACUUM vacuum_test;

VACUUM; -- vacuums the whole database

VACUUM VERBOSE; -- provides messages

-- using VACUUM FULL to reclaim disk space
VACUUM FULL vacuum_test;

-- Test its size again
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

SHOW config_file;

-- show the location of the data directory
SHOW data_directory;

-- BACKUP AND RESTORE
-- Listing 17-11: Backing up the analysis database with pg_dump
pg_dump -d analysis -U [user_name] -Fc > analysis_backup.sql

-- Back up just a table
pg_dump -t 'train_rides' -d analysis -U [user_name] -Fc > train_backup.sql 

-- Restoring the analysis database with pg_restore
pg_restore -C -d postgres -U postgres analysis_backup_custom.sql
