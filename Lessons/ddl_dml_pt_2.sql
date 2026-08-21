-- ============================================
-- 1. Create / refresh flattened job table
-- ============================================

CREATE OR REPLACE TABLE jobs_mart.staging.job_postings_flat AS

SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name

FROM data_jobs.job_postings_fact AS jpf

LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;


-- ============================================
-- 2. Check row count
-- ============================================

SELECT COUNT(*)
FROM jobs_mart.staging.job_postings_flat;


-- ============================================
-- 3. Create priority jobs view
-- ============================================

CREATE OR REPLACE VIEW jobs_mart.staging.priority_jobs_flat_view AS

SELECT
    jpf.*

FROM jobs_mart.staging.job_postings_flat AS jpf

JOIN jobs_mart.staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name

WHERE r.priority_lvl = 1;


-- ============================================
-- 4. Analyze priority jobs
-- ============================================

SELECT
    job_title_short,
    COUNT(*) AS job_count

FROM jobs_mart.staging.priority_jobs_flat_view

GROUP BY job_title_short

ORDER BY job_count DESC;


-- ============================================
-- 5. Create temporary table for
--    Senior Data Engineer jobs
-- ============================================

CREATE OR REPLACE TEMPORARY TABLE senior_jobs_flat_temp AS

SELECT *
FROM jobs_mart.staging.priority_jobs_flat_view

WHERE job_title_short = 'Senior Data Engineer';


SELECT
    job_title_short,
    COUNT(*) AS job_count

FROM senior_jobs_flat_temp

GROUP BY job_title_short

ORDER BY job_count DESC;


-- ============================================
-- 6. Check current row counts
-- ============================================

SELECT COUNT(*)
FROM jobs_mart.staging.job_postings_flat;

SELECT COUNT(*)
FROM jobs_mart.staging.priority_jobs_flat_view;

SELECT COUNT(*)
FROM senior_jobs_flat_temp;


-- ============================================
-- 7. DELETE example
--    Remove jobs posted before 2024
-- ============================================

DELETE FROM jobs_mart.staging.job_postings_flat

WHERE job_posted_date < '2024-01-01';


-- Check result after DELETE

SELECT COUNT(*)
FROM jobs_mart.staging.job_postings_flat;


-- ============================================
-- 8. TRUNCATE example
-- ============================================

-- Create a small example table

CREATE OR REPLACE TABLE jobs_mart.staging.truncate_example (
    id INTEGER,
    name VARCHAR
);


-- Insert some example data

INSERT INTO jobs_mart.staging.truncate_example
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');


-- Check the data

SELECT *
FROM jobs_mart.staging.truncate_example;


-- Check row count

SELECT COUNT(*)
FROM jobs_mart.staging.truncate_example;


-- ============================================
-- 9. TRUNCATE the table
-- ============================================

TRUNCATE TABLE jobs_mart.staging.truncate_example;


-- Check after TRUNCATE
-- The table still exists, but contains 0 rows

SELECT COUNT(*)
FROM jobs_mart.staging.truncate_example;


-- ============================================
-- 10. Insert data again
-- ============================================

INSERT INTO jobs_mart.staging.truncate_example
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');


-- Check that data is back

SELECT *
FROM jobs_mart.staging.truncate_example;

SELECT COUNT(*)
FROM jobs_mart.staging.truncate_example;


/*
============================================================
DDL & DML - PART 2
COMPREHENSIVE NOTES
============================================================

This lesson covers:

1. Flattened tables
2. Views
3. Temporary tables
4. COUNT()
5. Database and schema qualification
6. DELETE
7. TRUNCATE
8. Difference between permanent and temporary objects
9. Rerunning SQL scripts
10. DELETE vs TRUNCATE vs DROP

*/


/*
============================================================
1. DATABASE / SCHEMA / TABLE STRUCTURE
============================================================

Our main databases are:

    data_jobs
    jobs_mart

Inside jobs_mart we have:

    jobs_mart
        |
        +-- main
        |
        +-- staging

Therefore:

    jobs_mart.staging.job_postings_flat

means:

    jobs_mart       = database
    staging         = schema
    job_postings_flat = table


A fully qualified table name follows:

    database.schema.table

This is important when working with multiple databases.
*/


/*
============================================================
2. FLATTENED JOB TABLE
============================================================

We create:

    jobs_mart.staging.job_postings_flat

This table combines information from:

    data_jobs.job_postings_fact
                +
    data_jobs.company_dim

using a LEFT JOIN.

The purpose is to create a flattened table that is easier
to query and analyze.

We use:

    CREATE OR REPLACE TABLE

This means:

    If the table does not exist:
        -> create it

    If the table already exists:
        -> replace/recreate it

This is useful during development because we can run the
same SQL script multiple times without getting:

    "Table already exists"


ROW COUNT RESULT:

    1,615,930 rows

Approximately:

    1.62 million jobs

Therefore, our flattened job table currently contains
1.62 million records.
*/


/*
============================================================
3. PRIORITY JOBS VIEW
============================================================

We create:

    jobs_mart.staging.priority_jobs_flat_view

This is a VIEW.

The view uses:

    job_postings_flat
            +
    priority_roles

and keeps only records where:

    priority_lvl = 1

The resulting view contains:

    Data Engineer          = 391,957
    Senior Data Engineer   = 91,295

Total:

    391,957 + 91,295
    = 483,252 priority jobs


IMPORTANT:

A VIEW is not the same as a normal table.

A view stores the SQL logic used to retrieve the data.

When the underlying table changes, the view can return
different results.
*/


/*
============================================================
4. TEMPORARY TABLE
============================================================

We create:

    senior_jobs_flat_temp

using:

    CREATE OR REPLACE TEMPORARY TABLE

The temporary table contains only:

    Senior Data Engineer

The result is:

    91,295 rows


IMPORTANT:

This is NOT:

    jobs_mart.staging.senior_jobs_flat_temp

It is simply:

    senior_jobs_flat_temp

because it is a TEMPORARY TABLE.

A temporary table belongs to the current DuckDB session.

It is not stored permanently inside:

    jobs_mart.staging


Therefore this is correct:

    SELECT COUNT(*)
    FROM senior_jobs_flat_temp;


This is incorrect:

    SELECT COUNT(*)
    FROM jobs_mart.staging.senior_jobs_flat_temp;


When the DuckDB session ends, the temporary table disappears.
*/


/*
============================================================
5. PERMANENT TABLE vs VIEW vs TEMPORARY TABLE
============================================================

PERMANENT TABLE:

    jobs_mart.staging.job_postings_flat

    -> Stores actual data
    -> Remains after closing DuckDB


VIEW:

    jobs_mart.staging.priority_jobs_flat_view

    -> Stores SQL/query logic
    -> Remains after closing DuckDB
    -> Reads from underlying tables


TEMPORARY TABLE:

    senior_jobs_flat_temp

    -> Temporary session object
    -> Exists only during the current session
    -> Disappears when the session ends


Easy way to remember:

    TABLE
        = permanent stored data

    VIEW
        = saved query logic

    TEMP TABLE
        = temporary stored data
*/


/*
============================================================
6. WHY THIS QUERY FAILED
============================================================

We initially tried:

    SELECT COUNT(*)
    FROM staging.job_postings_flat;


At that time, the current database was:

    data_jobs

Therefore DuckDB interpreted the query as:

    data_jobs.staging.job_postings_flat


But data_jobs does not contain a schema named:

    staging


Therefore DuckDB returned:

    Schema "staging" does not exist


The correct fully qualified table name is:

    jobs_mart.staging.job_postings_flat


So the correct query is:

    SELECT COUNT(*)
    FROM jobs_mart.staging.job_postings_flat;
*/


/*
============================================================
7. DELETE
============================================================

We executed:

    DELETE FROM jobs_mart.staging.job_postings_flat
    WHERE job_posted_date < '2024-01-01';


DELETE removes rows that satisfy a condition.

In this example:

    job_posted_date < '2024-01-01'

means:

    Remove jobs posted before January 1, 2024.


BEFORE DELETE:

    1,615,930 rows


AFTER DELETE:

    828,574 rows


Rows removed:

    1,615,930 - 828,574
    = 787,356 rows


IMPORTANT:

DELETE does NOT remove the table.

It only removes rows.

The table still exists after DELETE.
*/


/*
============================================================
8. WHAT HAPPENED TO THE VIEW AFTER DELETE?
============================================================

Before DELETE:

    priority_jobs_flat_view
    = 483,252 rows


After DELETE:

    priority_jobs_flat_view
    = 251,946 rows


Why did the view change?

Because the view is based on:

    jobs_mart.staging.job_postings_flat


When the underlying table changes, the view reflects
those changes.

This demonstrates an important property of a VIEW:

    A view dynamically reads from its underlying data.
*/


/*
============================================================
9. WHAT HAPPENED TO THE TEMPORARY TABLE?
============================================================

Before DELETE:

    senior_jobs_flat_temp
    = 91,295 rows


After DELETE:

    senior_jobs_flat_temp
    = 91,295 rows


Why didn't it change?

Because:

    senior_jobs_flat_temp

is a TEMPORARY TABLE.

When it was created, the SELECT query copied the matching
rows into the temporary table.

It is not dynamically connected to the underlying table
like a VIEW is.

Therefore:

    DELETE from job_postings_flat

does not automatically change:

    senior_jobs_flat_temp
*/


/*
============================================================
10. RUNNING .READ AGAIN
============================================================

We use:

    .read 'Lessons/ddl_dml_pt_2.sql'


This executes the SQL file again.

The script contains:

    CREATE OR REPLACE TABLE
    jobs_mart.staging.job_postings_flat


Therefore, when the script runs again, the flattened table
is recreated from the original source data.

The previous DELETE operation is therefore overwritten.

The row count goes back to:

    1,615,930


This is why the script can be safely rerun during development.

The process is approximately:

    Original data
        |
        v
    Create/replace table
        |
        v
    1,615,930 rows
        |
        v
    DELETE old jobs
        |
        v
    828,574 rows
        |
        v
    Run script again
        |
        v
    Recreated from source
        |
        v
    1,615,930 rows
*/


/*
============================================================
11. TRUNCATE
============================================================

TRUNCATE is used to remove ALL rows from a table.

Example:

    TRUNCATE TABLE jobs_mart.staging.truncate_example;


TRUNCATE:

    -> removes all rows
    -> keeps the table
    -> table structure remains


In our example:

Before TRUNCATE:

    3 rows


After TRUNCATE:

    0 rows


The table still exists.

We can then INSERT data again.


IMPORTANT:

TRUNCATE does NOT mean:

    DROP TABLE


It only empties the table.
*/


/*
============================================================
12. DELETE vs TRUNCATE vs DROP
============================================================

DELETE:

    DELETE FROM table
    WHERE condition;


Purpose:

    Remove selected rows.

Example:

    DELETE FROM job_postings_flat
    WHERE job_posted_date < '2024-01-01';


TRUNCATE:

    TRUNCATE TABLE table;


Purpose:

    Remove ALL rows.

The table remains.


DROP:

    DROP TABLE table;


Purpose:

    Remove the entire table.

Both the data and table structure are removed.


Easy way to remember:

    DELETE
        -> Remove SOME rows


    TRUNCATE
        -> Remove ALL rows
        -> Keep table


    DROP
        -> Remove table
        -> Remove data
*/


/*
============================================================
13. FINAL RESULTS FROM THE LESSON
============================================================

Original flattened jobs:

    1,615,930


Priority jobs:

    483,252


Data Engineer:

    391,957


Senior Data Engineer:

    91,295


After DELETE:

    job_postings_flat
    = 828,574


After DELETE:

    priority_jobs_flat_view
    = 251,946


Temporary table:

    senior_jobs_flat_temp
    = 91,295


After rerunning the entire script:

    job_postings_flat
    = 1,615,930


The table returns to the original count because
CREATE OR REPLACE TABLE recreates it from the source data.
*/


/*
============================================================
14. DATA ENGINEERING PIPELINE CONCEPT
============================================================

This lesson is introducing a basic data engineering pattern:

SOURCE DATA
     |
     v
TRANSFORMATION
     |
     v
STAGING TABLE
     |
     v
VIEW / BUSINESS LOGIC
     |
     v
TEMPORARY ANALYSIS
     |
     v
RESULT


In our project:

    data_jobs.job_postings_fact
                +
    data_jobs.company_dim
                |
                v
    jobs_mart.staging.job_postings_flat
                |
                v
    jobs_mart.staging.priority_jobs_flat_view
                |
                v
    senior_jobs_flat_temp
                |
                v
             ANALYSIS


The important mindset is:

    SOURCE
       ->
    TRANSFORM
       ->
    STORE
       ->
    FILTER
       ->
    ANALYZE
*/


/*
============================================================
15. KEY LESSONS TO REMEMBER
============================================================

1. database.schema.table is the fully qualified naming
   structure.

2. A permanent table stores actual data.

3. A VIEW stores query logic.

4. A TEMPORARY TABLE exists only during the current session.

5. DELETE removes selected rows.

6. TRUNCATE removes all rows but keeps the table.

7. DROP removes the table itself.

8. A VIEW can reflect changes in its underlying table.

9. A temporary table does not automatically change when
   the source table changes.

10. CREATE OR REPLACE TABLE makes development scripts easier
    to rerun.

11. .read executes the SQL file in the current DuckDB session.

12. Always pay attention to which database and schema you
    are currently working in.

============================================================
END OF NOTES
============================================================
*/
