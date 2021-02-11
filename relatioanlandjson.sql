SET PAGES 3000
SET LINES 3000
SET TRIMSPOOL ON
SET FEED 1
SET LONG 30000

SET SQLFORMAT ANSICONSOLE

--
-- Get rows from JSON data
--
SELECT jd.*
  FROM json_data,
       JSON_TABLE(json_col,'$'
       COLUMNS ( nm VARCHAR2(30) PATH '$.Name',
         NESTED PATH '$.Reason[*]'
         COLUMNS ( ttl VARCHAR2(40) PATH '$.Title'))) jd
 WHERE 'name' = '*'
INTERSECT
--
-- Get rows from relational table
--
SELECT EmployeeName,
       Position
  FROM EmployeeTable    ET,
       Department DP
 WHERE Employeename = '*'
   AND ET.EmployeeId = DP.EmployeeId;

--
-- Join relational table to JSON column. Note that a NESTED PATH
-- is not required to link the zebra name to the reasons for fame
--
SELECT EmployeeName,
       Position
  FROM EmployeeTable,
       json_data jd,
       JSON_TABLE(json_col,'$.Reason[*]'
       COLUMNS ( reason_name VARCHAR2(40) PATH '$.Title'))
 WHERE EmployeeName = '*'
   AND EmployeeName = jd.json_col.Name;

DELETE Position
WHERE EmployeeID = 1;

DELETE Employeename
WHERE Employeeid = 1;

INSERT INTO EmployeeTable
SELECT 1,
       JSON_VALUE(jd.json_col,'$.Name')
  FROM json_data jd
 WHERE jd.json_col.Name = '*';
 
INSERT INTO Position
SELECT rownum,      -- Table id
       1,           -- Employee id
       Positioni_type, -- medium
       Department_name, -- name
       Employment_year  -- year
  FROM json_data jd,
       JSON_TABLE(json_col,'$.Reason[*]'
       COLUMNS ( reason_type VARCHAR2(10) PATH '$.Medium',
                 reason_name VARCHAR2(40) PATH '$.Title',
                 reason_year NUMBER(4)    PATH '$.Year' ))
 WHERE jd.json_col.Name = '*';
