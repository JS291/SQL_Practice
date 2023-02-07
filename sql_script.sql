-- creating initial tables
CREATE TABLE target_table (
    id INTEGER PRIMARY KEY,
    val TEXT );

CREATE TABLE source_table (
    id INTEGER PRIMARY KEY,
    val TEXT );


-- We are manually inserting the values into the table, but you can also import it from CSV, files are provided
-- inserting data into target table
INSERT INTO target_table 
VALUES (1, 'A'),
(2, 'A'),
(3, null),
(5, 'A'),
(8, 'A'),
(9, null),
(10, null);

-- checking that the data is correct
SELECT* FROM target_table;


-- insert data into source table
INSERT INTO source_table 
VALUES (1, null),
(2, 'B'),
(4, 'B'),
(8, 'B'),
(9, 'B'),
(10, null),
(11, null);

-- checking that the data is correct
SELECT * FROM source_table;


-- We will be solving these questions using SQLite and due to the limitations of SQLite, we will need to recreate the target table for each problem
-- As such we will name the target table in the following format "ttable#" where # is the question number and then import the data from the original target_table into it

-- Question 1
-- Table for question 1
CREATE TABLE ttable1 (
    id INTEGER PRIMARY KEY,
    val TEXT );

INSERT INTO ttable1 
SELECT id,val 
FROM target_table ;


-- Objective : ttable1.id is kept, but ttable.val is updated with source_table.val
UPDATE ttable1
SET val = (SELECT val from source_table WHERE source_table.id = ttable1.id)
WHERE ttable1.id IN (SELECT id FROM source_table);

-- result check
SELECT* 
FROM ttable1;


-- Question 2
-- Table for question 2
CREATE TABLE ttable2 (
    id INTEGER PRIMARY KEY,
    val TEXT );

INSERT INTO ttable2
SELECT id,val 
FROM target_table ;

-- Objective : ttable2.id and source_table.id are both kept, ttable2.val is updated with source.val
-- This works if we work under the idea that id is a PRIMARY KEY
REPLACE INTO ttable2(id,val)
SELECT id,val
FROM source_table;

-- result check
SELECT * 
FROM ttable2;


-- What if id was not a PRIMARY KEY? Then the above would not work.
-- Alternative solution to this scenario would be:

-- Rebuilding the table where id is not a PRIMARY KEY
CREATE TABLE ttable2a (
    id INTEGER ,
    val TEXT );

INSERT INTO ttable2a
SELECT id,val 
FROM target_table ;
SELECT* FROM ttable2a;

-- Alternative solution part 1
REPLACE INTO ttable2a(id,val)
SELECT id,val
FROM source_table
WHERE id NOT IN (SELECT id FROM ttable2a);
-- Alternative solution part2
UPDATE ttable2a
SET val=(SELECT val FROM source_table WHERE source_table.id=ttable2a.id)
FROM source_table 
WHERE ttable2a.id=source_table.id;

-- checking the results, we need to order by id because when we used "REPLACE INTO" in part 1 it added the records to the bottom
SELECT*FROM ttable2a
ORDER BY 1;


-- Question 3
-- We can see in the expected results table that there are duplicate ids therefore id is not a PRIMARY KEY in this question
-- Since id is not a PRIMARY KEY we can rebuild the table quickly like so
CREATE TABLE ttable3 AS
SELECT *
FROM target_table;

-- Objective : target table and source table are combined, all id and values from source table are added into target table
INSERT INTO ttable3(id,val)
SELECT* 
FROM source_table ;

-- checking the results
SELECT* FROM ttable3
ORDER BY id,val NULLS LAST;

/*
In this scenario, using the code below will also yield the same results
Making sure to check documentation on REPLACE in your version and type of SQL as REPLACE removes the old record and writes in a new one 
Compared to INSERT which will insert a record without modifying the others

REPLACE INTO ttable3(id,val)
SELECT id,val
FROM source_table st ;

*/

-- If the nature of the question was querying rather than modifying and updating the database then you can use UNION ALL
SELECT * 
FROM target_table  
UNION ALL
SELECT * 
FROM source_table
ORDER BY id,val NULLS LAST;


-- Question 4
-- Table for question 4

CREATE TABLE ttable4 (
    id INTEGER PRIMARY KEY,
    val TEXT );

INSERT INTO ttable4
SELECT id,val 
FROM target_table ;

-- Objective : Target.id is kept, but target.val is being updated with source.val only in areas where target.val is NULL
UPDATE ttable4
SET val=(SELECT val FROM source_table
         WHERE source_table.id=ttable4.id)
WHERE ttable4.val IS NULL;

-- checking the results
SELECT * FROM ttable4;


-- Question 5
-- Table for question 5
CREATE TABLE ttable5 (
    id INTEGER PRIMARY KEY,
    val TEXT );

INSERT INTO ttable5
SELECT id,val 
FROM target_table ;

-- Objective : target table id and source table id merged into one table, target table value is kept unless :
-- Possibility 1 : Target id doesnt exist, then it will take id and val from source table
-- Possibility 2 : Target id exist but val is NULL, in this case it will take val from source table

-- part 1
INSERT INTO ttable5
SELECT id,val
FROM source_table 
WHERE id NOT IN (SELECT id FROM ttable5);
--part 2
UPDATE ttable5
SET val=(SELECT val FROM source_table WHERE source_table.id=ttable5.id)
WHERE ttable5.val IS NULL;

-- result check
SELECT* FROM ttable5;

/*
Alternative : doing it with REPLACE in one code block instead of 2 step process

REPLACE INTO ttable5(id,val)
SELECT id,val
FROM source_table
WHERE id NOT IN (SELECT id FROM ttable5) OR id IN (SELECT id FROM ttable5 WHERE val IS null);

*/


-- Question 6
-- Table for question 6
CREATE TABLE ttable6 (
    id INTEGER PRIMARY KEY,
    val TEXT );

INSERT INTO ttable6
SELECT id,val 
FROM target_table ;

-- Objective : target table id is kept, target table val gets replaced with source_table.val if source.val IS NOT NULL
UPDATE ttable6
SET val = IFNULL((SELECT val FROM source_table WHERE ttable6.id = source_table.id),val);

-- result check
SELECT * FROM ttable6;


-- Question 7
-- Table for question 7
CREATE TABLE ttable7 (
    id INTEGER PRIMARY KEY,
    val TEXT );

INSERT INTO ttable7
SELECT id,val 
FROM target_table ;

-- Objective : target table id and source table id is merged, target table val is replace by source table val if source table val IN NOT NULL

-- part 1
INSERT INTO ttable7
SELECT id,val
FROM source_table 
WHERE id NOT IN (SELECT id FROM ttable7);
-- part 2
UPDATE ttable7 
SET val=IFNULL((SELECT val FROM source_table WHERE ttable7.id=source_table.id),val);

-- result check
SELECT* FROM ttable7;

/* 
Alternative : doing it with REPLACE in one code block instead of 2 step process

REPLACE into ttable7(id,val)
SELECT id,val 
FROM source_table
WHERE id NOT IN (SELECT id from ttable7) OR id IN (SELECT id from s2 WHERE val IS NOT NULL);


*/


