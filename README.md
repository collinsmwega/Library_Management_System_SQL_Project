# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_database_p1`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_database_p1`.
- **Table Creation**: Created tables for branches, employees, members, books, issue_status, and return_status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_database_p1;
--create the branch table

CREATE TABLE branch 
(
branch_id VARCHAR(10) PRIMARY KEY,	
manager_id VARCHAR(10),
branch_address VARCHAR(55),	
contact_no VARCHAR(10)
);

--altering data type for a contact_no column
ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);


CREATE TABLE employees 
(
emp_id	VARCHAR(10) PRIMARY KEY,
emp_name VARCHAR(25),	
position VARCHAR(15),	
salary	INT,
branch_id VARCHAR(10)
);


CREATE TABLE books
(
isbn VARCHAR(25) PRIMARY KEY,	
book_title VARCHAR(70),
category VARCHAR(15),	
rental_price FLOAT,	
status VARCHAR(10),
author VARCHAR(25),	
publisher VARCHAR(55)
);

--altering data type for category column
ALTER TABLE books
ALTER COLUMN category TYPE VARCHAR(20);


CREATE TABLE members
(
member_id VARCHAR(10) PRIMARY KEY,
member_name	VARCHAR(20),
member_address VARCHAR(70),
reg_date DATE
);


CREATE TABLE issue_status
(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(10),	
issued_book_name VARCHAR(75),	
issued_date DATE,	
issued_book_isbn VARCHAR(25),	
issued_emp_id VARCHAR(10)
);


CREATE TABLE return_status
(
return_id VARCHAR(10) PRIMARY KEY,
issued_id VARCHAR(10),	
return_book_name VARCHAR(75),	
return_date DATE,
return_book_isbn VARCHAR(20)
);
```
```sql
### SETTING UP FOREIGN KEY AND PRIMARY KEY IN EACH TABLE TO CREATE AN ERD DIAGRAM
--FOREIGN KEY
ALTER TABLE issue_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issue_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issue_status
ADD CONSTRAINT fk_employees 
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch  
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issue_status 
FOREIGN KEY (issued_id)
REFERENCES issue_status(issued_id);
```
### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('976-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '256 Main St'
WHERE member_id = 'C101';
SELECT * FROM members
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

```sql
DELETE FROM issue_status
WHERE issued_id = 'IS104';
SELECT * FROM issue_status
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issue_status
WHERE issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
	issued_member_id,
	COUNT(*)
FROM issue_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issue_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2

SELECT * FROM book_cnts
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books as b
JOIN
issue_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name as manager
FROM employees as e1
JOIN
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE books_greater_than_seven
AS
SELECT * FROM books
WHERE rental_price > 7
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
	DISTINCT ist.issued_book_name
FROM issue_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE return_id IS NULL

SELECT * FROM return_status
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	--rs.return_date,
	CURRENT_DATE - ist.issued_date as over_due_days
	
FROM issue_status as ist
JOIN
members as m
	ON m.member_id = ist.issued_member_id
JOIN
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
	rs.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15)) --prevent users from entering anything hence reason of defining data types. tells the database that the user should enter under 10 characters in the return_status same goes to issue_id and book quality
LANGUAGE             
AS $$

DECLARE 
-- tells the database hey! what is the data type i am expecting from this variable 
	v_isbn VARCHAR(25);
	v_book_name VARCHAR(70);
	
BEGIN
	-- all your logic and code
	--inserting into returns based on user input
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES
	(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality); --we want the values to be entered automatically based on what the user will enter


--in our code we need to save the isbn somewhere so that we can use the isbn to update it (variables) store information temporary in the language code

	SELECT 
		issued_book_isbn, --we need to save the name and isbn in a variable so that we can use it in the WHERE condition
		issued_book_name
		INTO
		v_isbn, -- we are storing the book isbn into this variable
		v_book_name -- are storing the book name into this variable
	FROM issue_status
	WHERE issued_id = p_issued_id; --(p_issued_id)parameter that will be entered by the employee/user
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank You for returning the book: %', v_book_name; 
	
END;
$$

--TESTING FUNCTION

SELECT * FROM issue_status
WHERE issued_book_isbn = '978-0-307-58837-1';

--check whether we have this record in the books table
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

--check whether the book has been returned in the return table 
--(since we do not have isbn we will use issued_id)
SELECT * FROM return_status
WHERE issued_id = 'IS135';

--calling a function and function name and give parameters
CALL add_return_records('RS121', 'IS135', 'Good');

CALL add_return_records('RS122', 'IS134', 'Damaged');


```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE Branch_Report
AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) as Number_of_books_issued,
	COUNT(rs.return_id) as Number_of_books_returned,
	SUM(bk.rental_price) as Total_Revenue	
FROM issue_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_report
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT -- this line of code is our active members.
						DISTINCT issued_member_id 
					FROM issue_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '6 months'
					);

SELECT * FROM active_members
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
SELECT 
	m.member_name,
	ist.issued_book_name,
	COUNT(ist.issued_id) as Number_of_damaged_books_issued,
	rs.book_quality
FROM issue_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
JOIN
members as m
ON m.member_id = ist.issued_member_id
--filter only damaged books
WHERE rs.book_quality = 'Damaged'
GROUP BY 1,2,4
HAVING COUNT (ist.issued_id) < 2;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(10)) --prevent users from entering anything hence reason of defining data types. tells the database that the user should enter under number of characters specified with VARCHAR in the defined column parameter.
LANGUAGE plpgsql            
AS $$

DECLARE 
-- ALL VARIABLES
	v_status VARCHAR(10);                                                                                                                  
BEGIN
-- all your logic and code
--check if the book is available 'yes' 
	SELECT 
		status --we need to save the status in a variable so that we can use it in the WHERE condition
		INTO
		v_status -- we are storing the status into this variable	
	FROM books
	WHERE isbn = p_issued_book_isbn; --(p_issued_book_isbn)parameter that will be entered by the employee/user


	IF v_status = 'yes' THEN
	--inserting into issue table based on user input
	INSERT INTO issue_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
	VALUES
	(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id); --we want the values to be entered automatically based on what the user will enter

	UPDATE books
	SET status = 'no'
	WHERE isbn = p_issued_book_isbn; --what the user is entering

		RAISE NOTICE 'The Book record added successfully for book isbn: %', p_issued_book_isbn; 
	ELSE
		RAISE NOTICE 'Sorry to inform you the book you have requested is currently unavailable book_isbn: %', p_issued_book_isbn;
	END IF;
END;
$$

--testing the function 
SELECT * FROM books
--978-0-553-29698-2 -- currently status showing is 'yes'
--978-0-7432-7357-1 -- currently status showing is 'no'
SELECT * FROM issue_status

--calling a function and function name and give parameters
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-7432-7357-1', 'E104');


--the status currently has been changed to 'no' because the book has already been issued
SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';
--the status is currently 'no' because the book is not available.
SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';


```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

