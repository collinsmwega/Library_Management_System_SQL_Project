--SQL Project - Library Management System Query 2
SELECT * FROM return_status
SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issue_status
SELECT * FROM members

--task 1. 
--Identify Members with overdue books
--write a query to identify members who have overdue books (assume a 30-day return period). 
--display the member's_id, member's name, book_title, issue_date, and days overdue

--issued_status == members == books == return_status
-- filter books which are returned
-- overdue > 20

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
	
	

--task 2. Update Book Status on Return
--write a query to update the status of the book to 'yes' when they are returned (based on the entries in the return_status table)
SELECT * FROM issue_status
WHERE issued_book_isbn = '978-0-451-52994-2';

--check whether we have this record in the books table
SELECT * FROM books
WHERE isbn = '978-0-451-52994-2'
--change the status to 'no'
UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

--check whether the book has been returned in the return table. 
--(since we do not have isbn we will use issued_id)
SELECT * FROM return_status
WHERE issued_id = 'IS130'

--as soon as the member returns a book we can add/insert the book manually.
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS120', 'IS130', CURRENT_DATE, 'Good');

--once the book status has been returned we will need to change the book status to returned.
--manually we can use the update statement
UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';


--Stored Procedure Syntax(where everything will be done automatically)
-- as soon as somebody enters a record in the return table it should update the status('yes' or 'no') availability of the books in the books table.
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

--in the parameter we do not have book 'isbn' the book table doesn't have return_id and issue_id
--we can get the isbn based on the issue_id in the issue_status table while the book is being issued by the employer we write the book name and book isbn 
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

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

SELECT * FROM issue_status
WHERE issued_book_isbn = '978-0-375-41398-8'

UPDATE return_status
SET book_quality = 'Good'
WHERE return_id = 'RS122'


--task 3. Branch Performance Report
--(create a query that generates a performance report for each branch, showing the number of books issued,  number of books returned, and the total revenue generated from books rentals)
SELECT * FROM issue_status
SELECT * FROM employees
SELECT * FROM return_status
SELECT * FROM books
SELECT * FROM branch
SELECT * FROM members

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

--task 4. CTAS: Create a table of active members
--(use the Create Table AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months)

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT -- this line of code is our active members.
						DISTINCT issued_member_id 
					FROM issue_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '6 months'
					);

SELECT * FROM active_members
--task 5. Find employees with the most book issues processed
--(write a query to find the top 3 employees who have processed the most book issues. Display the employees name, number of books processed and their branch)
SELECT 
	e.emp_name,
	COUNT(ist.issued_id) as Numbers_books_processed,
	b.branch_id
FROM issue_status as ist
JOIN
employees as e
ON ist.issued_emp_id = e.emp_id
JOIN 
branch as b
ON b.branch_id = e.branch_id 
GROUP BY 1,3
--task 6. Identify members issuing high-risk books
--(write a query to identify members who have issued books more than twice with the status 'damaged' in the books table. display the member name, book title, and the number of times they've issued the damaged books).
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

--**Task 19: Stored Procedure**
--Objective:
--Create a stored procedure to manage the status of books in a library system.
--Description:
--Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
--The stored procedure should take the book_id as an input parameter.
--The procedure should first check if the book is available (status = 'yes').
--If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
--If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

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

