-- ==========================================
-- VIEW RAW DATA
-- ==========================================
SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- ==========================================
-- PRIMARY KEYS & FOREIGN KEYS (BOOKS & ISSUED/RETURN)
-- ==========================================

ALTER TABLE books
ADD PRIMARY KEY (isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_book
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE return_status
ADD CONSTRAINT fk_return_book
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);


-- ==========================================
-- BRANCH & EMPLOYEES
-- ==========================================

SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;

-- Modify branch_id to match other tables
ALTER TABLE branch
MODIFY COLUMN branch_id VARCHAR(10);

ALTER TABLE employees
MODIFY COLUMN branch_id VARCHAR(10);

-- Add primary key on branch
ALTER TABLE branch
ADD PRIMARY KEY (branch_id);

-- Foreign key: employee → branch
ALTER TABLE employees
ADD CONSTRAINT fk_employee_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- Modify employee id types
ALTER TABLE employees
MODIFY COLUMN emp_id VARCHAR(10);

ALTER TABLE branch
MODIFY COLUMN manager_id VARCHAR(10);

-- Add primary key employee id
ALTER TABLE employees
ADD PRIMARY KEY (emp_id);

-- Branch manager foreign key
ALTER TABLE branch
ADD CONSTRAINT fk_branch_manager
FOREIGN KEY (manager_id)
REFERENCES employees(emp_id);


-- ==========================================
-- MEMBERS & ISSUED STATUS
-- ==========================================

ALTER TABLE members
MODIFY COLUMN member_id VARCHAR(10);

ALTER TABLE issued_status
MODIFY COLUMN issued_member_id VARCHAR(10);

ALTER TABLE members
ADD PRIMARY KEY (member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_member
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);


-- ==========================================
-- ISSUED / RETURN STATUS LINKING
-- ==========================================

-- Modify issued_id as primary key
ALTER TABLE issued_status
MODIFY COLUMN issued_id VARCHAR(10) PRIMARY KEY;

ALTER TABLE return_status
MODIFY COLUMN issued_id VARCHAR(10);

ALTER TABLE return_status
ADD CONSTRAINT fk_return_issued
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


-- ==========================================
-- FIX INVALID ISSUED_ID IN RETURN TABLE
-- ==========================================
SELECT issued_id
FROM return_status
WHERE issued_id NOT IN (SELECT issued_id FROM issued_status);

SET SQL_SAFE_UPDATES = 0;

UPDATE return_status
SET issued_id = NULL
WHERE issued_id NOT IN (SELECT issued_id FROM issued_status);


-- ==========================================
-- EMPLOYEE RELATION IN ISSUED TABLE
-- ==========================================
ALTER TABLE issued_status
MODIFY COLUMN issued_emp_id VARCHAR(10);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_employee
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


-- ==========================================
-- CRUD TASKS
-- ==========================================

-- TASK 1: Add a new book
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- TASK 2: Update a member address
UPDATE members
SET member_address = '125 Main St'
WHERE member_address = '123 Main St';

-- TASK 3: Delete an issued record
DELETE FROM issued_status
WHERE issued_id = 'IS121';


-- ==========================================
-- ANALYSIS TASKS
-- ==========================================

-- 4: Retrieve all books issued by employee E101
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Count how many
SELECT COUNT(*) AS total_issued_by_emp
FROM issued_status
WHERE issued_emp_id = 'E101';


-- 5: Members who issued more than one book
SELECT issued_member_id, COUNT(*) AS total_books
FROM issued_status
GROUP BY issued_member_id
HAVING total_books > 1;


-- ==========================================
-- CTAS: Book Issue Count Table
-- ==========================================
CREATE TABLE book_count AS
SELECT b.isbn, b.book_title, COUNT(i.issued_id) AS book_issued
FROM books b
JOIN issued_status i ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;


-- ==========================================
-- CATEGORY FILTER
-- ==========================================
SELECT *
FROM books
WHERE category = 'Classic';


-- ==========================================
-- RENTAL INCOME BY CATEGORY
-- ==========================================
SELECT 
    category,
    SUM(rental_price) AS total_income,
    COUNT(*) AS total_issued
FROM books AS b
JOIN issued_status AS i ON i.issued_book_isbn = b.isbn
GROUP BY category
ORDER BY total_income DESC;


-- ==========================================
-- MEMBERS REGISTERED LAST 180 DAYS
-- ==========================================
SELECT *
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;


-- ==========================================
-- EMPLOYEES WITH BRANCH MANAGER & BRANCH DETAILS
-- ==========================================
SELECT e.*, b.*, m.emp_name AS manager_name
FROM employees e
JOIN branch b ON e.branch_id = b.branch_id
JOIN employees m ON m.emp_id = b.manager_id;


-- ==========================================
-- EXPENSIVE BOOKS (Rental price > AVG)
-- ==========================================
SELECT * FROM books
WHERE rental_price > (SELECT ROUND(AVG(rental_price)) FROM books);

CREATE TABLE expensive_books AS
SELECT *
FROM books
WHERE rental_price > 6;


-- ==========================================
-- BOOKS NOT RETURNED
-- ==========================================
SELECT DISTINCT i.issued_book_name
FROM issued_status i
LEFT JOIN return_status r ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL;


-- ==========================================
-- ADD BOOK QUALITY FIELD
-- ==========================================
ALTER TABLE return_status
ADD COLUMN book_quality VARCHAR(15) DEFAULT 'Good';

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id IN ('IS112', 'IS117', 'IS118');


-- ==========================================
-- ADVANCED SQL OPERATIONS
-- ==========================================


-- ==========================================
-- TASK 13: Identify Members with Overdue Books
-- Overdue = books not returned for more than 30 days
-- Display: member_id, member_name, book_title, issue_date, days_overdue
-- ==========================================

SELECT 
    mb.member_id,
    mb.member_name,
    bk.book_title,
    ist.issued_date,
    DATEDIFF(CURRENT_DATE, ist.issued_date) AS days_overdue
FROM issued_status AS ist
JOIN members AS mb
    ON mb.member_id = ist.issued_member_id
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rt
    ON rt.issued_id = ist.issued_id
WHERE 
    rt.return_date IS NULL
    AND DATEDIFF(CURRENT_DATE, ist.issued_date) > 30
ORDER BY mb.member_id;



-- ==========================================
-- TASK 14: Update Book Status on Return
-- Mark books as "Yes" (available) when returned
-- ==========================================

UPDATE books AS b
JOIN return_status AS rt
    ON b.isbn = rt.return_book_isbn
SET b.status = 'Yes'
WHERE rt.return_date IS NOT NULL;



-- ==========================================
-- TASK 15: Branch Performance Report
-- Show: branch_id, manager_id, total issued, total returned, total revenue
-- ==========================================

SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS total_books_issued,
    COUNT(rtn.return_id) AS total_books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON b.branch_id = e.branch_id
LEFT JOIN return_status AS rtn
    ON rtn.issued_id = ist.issued_id
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn
GROUP BY b.branch_id, b.manager_id
ORDER BY b.branch_id;



-- ==========================================
-- TASK 16: CTAS - Create Table of Active Members
-- Members who issued a book in the last 2 months
-- ==========================================

CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
);

SELECT * FROM active_members;



-- ==========================================
-- TASK 17: Employees with Most Book Issues Processed
-- Show: employee_name, branch, number_of_books_issued
-- Top employees by issuing activity
-- ==========================================

SELECT 
    e.emp_name,
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS total_books_processed
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.manager_id
ORDER BY total_books_processed DESC
LIMIT 3;
