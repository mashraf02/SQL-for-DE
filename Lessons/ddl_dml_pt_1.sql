-- .read 'Lessons/ddl_dml_pt_1.sql'

/*
============================================================
DDL & DML - PART 1
COMPREHENSIVE STUDY NOTES
============================================================

This lesson covers:

1. Databases
2. Schemas
3. Tables
4. Primary Keys
5. INSERT
6. SELECT
7. ALTER TABLE
8. ADD COLUMN
9. UPDATE
10. RENAME TABLE
11. RENAME COLUMN
12. ALTER COLUMN TYPE
13. DDL vs DML
14. Building a small staging table

*/


/*
============================================================
1. DATABASE STRUCTURE
============================================================

Our project contains databases such as:

    data_jobs
    jobs_mart

For this lesson, we work inside:

    jobs_mart


A database can contain multiple schemas.

Example:

    jobs_mart
        |
        +-- main
        |
        +-- staging


The general structure is:

    database.schema.table

Example:

    jobs_mart.staging.preferred_roles

means:

    jobs_mart        = database
    staging          = schema
    preferred_roles  = table
*/


/*
============================================================
2. SHOW DATABASES
============================================================

Command:

    SHOW DATABASES;


Purpose:

    Displays the databases available in the current
    DuckDB environment.

Example output may contain:

    data_jobs
    jobs_mart
    md_information_schema
    my_db
    sample_data


This is useful when you want to check whether the database
you need actually exists.
*/


SHOW DATABASES;


/*
============================================================
3. INFORMATION_SCHEMA
============================================================

DuckDB provides INFORMATION_SCHEMA views that allow us
to inspect metadata about databases, schemas, tables,
columns, etc.

Example:

    SELECT *
    FROM information_schema.schemata;


This shows available schemas.

Think of INFORMATION_SCHEMA as:

    "information about the database structure"


It contains metadata rather than the actual business data.
*/


SELECT *
FROM information_schema.schemata;


/*
============================================================
4. USE DATABASE
============================================================

Command:

    USE jobs_mart;


This changes the current database.

After:

    USE jobs_mart;


unqualified references such as:

    staging.preferred_roles


will refer to:

    jobs_mart.staging.preferred_roles


This is why knowing your current database is important.

You can always use the fully qualified form:

    jobs_mart.staging.preferred_roles

which removes ambiguity.
*/


USE jobs_mart;


/*
============================================================
5. CREATE SCHEMA
============================================================

Command:

    CREATE SCHEMA IF NOT EXISTS staging;


A schema is a logical container inside a database.

We create:

    jobs_mart.staging


The IF NOT EXISTS part means:

    If staging does not exist:
        -> create it

    If staging already exists:
        -> do nothing


This makes the script safer to rerun.
*/


CREATE SCHEMA IF NOT EXISTS staging;


/*
============================================================
6. CREATE TABLE
============================================================

We create:

    staging.preferred_roles


The full name is:

    jobs_mart.staging.preferred_roles


The table contains:

    role_id
    role_name


The SQL:

    CREATE TABLE IF NOT EXISTS

means:

    Create the table only if it does not already exist.


This prevents an error such as:

    "Table already exists"
*/


CREATE TABLE IF NOT EXISTS staging.preferred_roles
(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);


/*
============================================================
7. PRIMARY KEY
============================================================

The column:

    role_id INTEGER PRIMARY KEY


means role_id is the PRIMARY KEY.

A primary key is used to uniquely identify each row.

For example:

    role_id    role_name
    -------    ---------------------
       1       Data Engineer
       2       Senior Data Engineer
       3       Software Engineer


Each role_id should uniquely identify one role.

Therefore:

    1 -> Data Engineer
    2 -> Senior Data Engineer
    3 -> Software Engineer


Think of a primary key as:

    "The unique ID of a row."
*/


/*
============================================================
8. INFORMATION_SCHEMA.TABLES
============================================================

We can inspect existing tables using:

    SELECT *
    FROM information_schema.tables
    WHERE table_catalog = 'jobs_mart';


IMPORTANT:

The database name is:

    jobs_mart

NOT:

    job_mart


This query allows us to inspect table metadata.

It does not return the actual rows of the table.

It tells us information about the tables themselves.
*/


SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';


/*
============================================================
9. INSERT
============================================================

We now insert data into:

    staging.preferred_roles


INSERT adds new rows to a table.

Example:

    INSERT INTO staging.preferred_roles
        (role_id, role_name)

    VALUES
        (1, 'Data Engineer'),
        (2, 'Senior Data Engineer'),
        (3, 'Software Engineer');


After INSERT, the table contains:

    role_id    role_name
    -------    ---------------------
       1       Data Engineer
       2       Senior Data Engineer
       3       Software Engineer


INSERT is a DML operation.

DML = Data Manipulation Language.


Common DML commands:

    INSERT
    UPDATE
    DELETE
*/


INSERT INTO staging.preferred_roles
    (role_id, role_name)

VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');


/*
============================================================
10. SELECT
============================================================

We can inspect the data using:

    SELECT *
    FROM staging.preferred_roles;


SELECT reads data.

It does not change the table.

The result should be:

    1 | Data Engineer
    2 | Senior Data Engineer
    3 | Software Engineer
*/


SELECT *
FROM staging.preferred_roles;


/*
============================================================
11. ALTER TABLE - ADD COLUMN
============================================================

We now modify the structure of the table.

Command:

    ALTER TABLE staging.preferred_roles
    ADD COLUMN preferred_role BOOLEAN;


This adds a new column:

    preferred_role


The table changes from:

    role_id
    role_name


to:

    role_id
    role_name
    preferred_role


Existing rows initially contain NULL in the new column
until we update them.

ALTER TABLE is a DDL operation.


DDL = Data Definition Language.


Common DDL commands:

    CREATE
    ALTER
    DROP
    TRUNCATE
*/


ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;


/*
============================================================
12. UPDATE
============================================================

We now modify existing rows.

Command:

    UPDATE staging.preferred_roles
    SET preferred_role = TRUE
    WHERE role_id = 1 OR role_id = 2;


This changes rows where:

    role_id = 1
    OR
    role_id = 2


The result becomes:

    role_id    role_name               preferred_role
    -------    ----------------------  --------------
       1       Data Engineer           TRUE
       2       Senior Data Engineer    TRUE
       3       Software Engineer       NULL


UPDATE changes existing data.

UPDATE is a DML operation.
*/


UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE role_id = 1 OR role_id = 2;


/*
============================================================
13. SECOND UPDATE
============================================================

Now we update role_id = 3.

Command:

    UPDATE staging.preferred_roles
    SET preferred_role = FALSE
    WHERE role_id = 3;


The result becomes:

    role_id    role_name               preferred_role
    -------    ----------------------  --------------
       1       Data Engineer           TRUE
       2       Senior Data Engineer    TRUE
       3       Software Engineer       FALSE


Notice:

    UPDATE
        changes existing rows

It does not create new rows.
*/


UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE role_id = 3;


/*
============================================================
14. RENAME TABLE
============================================================

We now rename the table:

    preferred_roles

to:

    priority_roles


Command:

    ALTER TABLE staging.preferred_roles
    RENAME TO priority_roles;


Before:

    staging.preferred_roles


After:

    staging.priority_roles


The data remains.

Only the table name changes.
*/


ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;


/*
============================================================
15. CHECK THE RENAMED TABLE
============================================================

We can now query:

    staging.priority_roles


The result should be:

    role_id    role_name               preferred_role
    -------    ----------------------  --------------
       1       Data Engineer           TRUE
       2       Senior Data Engineer    TRUE
       3       Software Engineer       FALSE
*/


SELECT *
FROM staging.priority_roles;


/*
============================================================
16. RENAME COLUMN
============================================================

Now we rename:

    preferred_role

to:

    priority_lvl


Command:

    ALTER TABLE staging.priority_roles
    RENAME COLUMN preferred_role TO priority_lvl;


Before:

    preferred_role


After:

    priority_lvl


Again, the data itself is not deleted.

Only the column name changes.
*/


ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;


/*
============================================================
17. CHANGE COLUMN DATA TYPE
============================================================

Currently:

    priority_lvl

is BOOLEAN.

Its values are:

    TRUE
    FALSE


We now change the data type:

    BOOLEAN -> INTEGER


Command:

    ALTER TABLE staging.priority_roles
    ALTER COLUMN priority_lvl TYPE INTEGER;


The purpose is to represent priority using numbers.

For example:

    TRUE
    FALSE

can become numeric values.

This is useful when we want to represent different
priority levels such as:

    1 = High priority
    2 = Medium priority
    3 = Low priority
*/


ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;


/*
============================================================
18. UPDATE PRIORITY LEVEL
============================================================

After converting the column to INTEGER, we update:

    role_id = 3

to:

    priority_lvl = 3


So the final table becomes approximately:

    role_id    role_name               priority_lvl
    -------    ----------------------  ------------
       1       Data Engineer           1
       2       Senior Data Engineer    1
       3       Software Engineer       3


The first two roles are priority level 1.

Software Engineer is priority level 3.
*/


UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;


/*
============================================================
19. FINAL TABLE
============================================================

The final table is:

    jobs_mart.staging.priority_roles


Expected structure:

    role_id        INTEGER
    role_name      VARCHAR
    priority_lvl   INTEGER


Expected data:

    role_id | role_name              | priority_lvl
    --------+------------------------+-------------
       1    | Data Engineer          |      1
       2    | Senior Data Engineer   |      1
       3    | Software Engineer      |      3


This table will later be used to identify priority jobs
in the next part of the pipeline.
*/


/*
============================================================
20. DDL vs DML
============================================================

DDL = Data Definition Language

DDL changes the STRUCTURE of the database.

Examples:

    CREATE DATABASE
    CREATE SCHEMA
    CREATE TABLE
    ALTER TABLE
    DROP TABLE
    TRUNCATE TABLE


DML = Data Manipulation Language

DML changes the DATA inside the tables.

Examples:

    INSERT
    UPDATE
    DELETE


SELECT is generally classified separately as DQL
(Data Query Language), because it reads/query data.


Easy way to remember:

    DDL
      ->
    Define the structure


    DML
      ->
    Manipulate the data


    SELECT / DQL
      ->
    Query the data
*/


/*
============================================================
21. WHAT HAPPENED TO THE TABLE STEP-BY-STEP?
============================================================

STEP 1:

Created:

    preferred_roles

    role_id
    role_name


STEP 2:

Inserted:

    Data Engineer
    Senior Data Engineer
    Software Engineer


STEP 3:

Added:

    preferred_role BOOLEAN


STEP 4:

Updated:

    Data Engineer
        -> TRUE

    Senior Data Engineer
        -> TRUE

    Software Engineer
        -> FALSE


STEP 5:

Renamed table:

    preferred_roles
        ->
    priority_roles


STEP 6:

Renamed column:

    preferred_role
        ->
    priority_lvl


STEP 7:

Changed type:

    BOOLEAN
        ->
    INTEGER


STEP 8:

Updated Software Engineer:

    priority_lvl = 3


FINAL:

    priority_roles

    role_id | role_name              | priority_lvl
    --------+------------------------+-------------
       1    | Data Engineer          |      1
       2    | Senior Data Engineer   |      1
       3    | Software Engineer       |      3
*/


/*
============================================================
22. KEY DATA ENGINEERING LESSON
============================================================

This exercise demonstrates how a Data Engineer can build
and gradually modify a staging table.

The process was:

    CREATE
       |
       v
    INSERT
       |
       v
    ALTER TABLE
       |
       v
    UPDATE
       |
       v
    RENAME
       |
       v
    ALTER COLUMN
       |
       v
    UPDATE
       |
       v
    FINAL STAGING TABLE


The final table becomes a small piece of business logic:

    priority_roles

which can later be joined with job data.

For example:

    job_postings_flat
            |
            | JOIN on job_title_short
            v
    priority_roles
            |
            v
    priority jobs


This is how raw data gradually becomes useful
business-ready data.
*/


/*
============================================================
23. COMMANDS TO REMEMBER
============================================================

CREATE:

    Creates a new database object.


INSERT:

    Adds new rows.


SELECT:

    Reads data.


UPDATE:

    Changes existing rows.


DELETE:

    Removes selected rows.


ALTER TABLE:

    Changes table structure.


ADD COLUMN:

    Adds a new column.


RENAME TO:

    Renames a table.


RENAME COLUMN:

    Renames a column.


ALTER COLUMN TYPE:

    Changes a column's data type.


DROP:

    Removes a database object.


TRUNCATE:

    Removes all rows while keeping the table.


============================================================
END OF DDL & DML PART 1 NOTES
============================================================
*/






 