--1.library management system
CREATE DATABASE library_database_p1

--create the branch table

CREATE TABLE branch 
(
branch_id VARCHAR(10) PRIMARY KEY,	
manager_id VARCHAR(10),
branch_address VARCHAR(55),	
contact_no VARCHAR(10)
);

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

--2. CRUD OPERATION
--QUESTIONS
--task 1. Create a New book record -- '976-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('976-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books

--task 2. Update an existing member's address
UPDATE members
SET member_address = '256 Main St'
WHERE member_id = 'C101';
SELECT * FROM members

--task 2. delete a record from the issued status table -- Objective: delete the record with issued_id = 'IS104' from the issued_status table.
DELETE FROM issue_status
WHERE issued_id = 'IS104';
SELECT * FROM issue_status

--task 3. Retreive all books issued by a specific employee -- objective:select all books issued by the employee with emp_id = 'E101'
SELECT * FROM issue_status
WHERE issued_emp_id = 'E101';

--task 4. List members who have issued more than one book -- objective: Use GROUP BY to find members who have issued more than one book
SELECT 
	issued_member_id,
	COUNT(*)
FROM issue_status
GROUP BY 1
HAVING COUNT(*) > 1

--3. CTAS (create table as select) 
--create summary tables: used CTAS to generate new tables based on query results - each book and total book_issued_count
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

--4. Data Analysis & Findings
--task 7. Retrieve All Books in a specific category
SELECT * FROM books
WHERE category = 'Classic'

--TASK 8. Find total Rental Income by Category
SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books as b
JOIN
issue_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1
 
-- TASK 9. List members who registered in the last 180 days
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'


-- TASK 10. list employees with their branch manager's name and their branch details
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


-- TASK 11. create a table of books with rental price above a certain threshold usd 10
CREATE TABLE books_greater_than_seven
AS
SELECT * FROM books
WHERE rental_price > 7


-- task 12. retrieve the list of books not yet returned
SELECT 
	DISTINCT ist.issued_book_name
FROM issue_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE return_id IS NULL

SELECT * FROM return_status