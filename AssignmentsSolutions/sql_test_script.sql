-- ======================================================================================
-- This script is meant to be executed in your studentID_pdb_assI (e.g., 12345_pdb_assI) 
-- Oracle Pluggable Database.
-- The script creates tables based on a conceptual diagram for a Library Management System,
-- inserts sample data, and executes various queries as per the assignment requirements.
-- ======================================================================================

-- ======================================================================================
-- PLUGGABLE DATABASE CREATION INSTRUCTIONS (Run as SYSDBA)
-- ======================================================================================
-- The following PDB creation commands are for your reference.
-- Uncomment and execute them from a SYSDBA session if you need to create the pluggable database.
--
-- CREATE PLUGGABLE DATABASE 26798_pdb_assI
--   ADMIN USER pdbadmin IDENTIFIED BY YourStrongPassword1!
--   ROLES = (DBA)
--   DEFAULT TABLESPACE users
--   DATAFILE '/u01/app/oracle/oradata/ORCL/26798_pdb_assI_users01.dbf' SIZE 250M AUTOEXTEND ON
--   FILE_NAME_CONVERT = ('/u01/app/oracle/oradata/ORCL/pdbseed/', '/u01/app/oracle/oradata/ORCL/26798_pdb_assI/');
--
-- ALTER PLUGGABLE DATABASE 26798_pdb_assI OPEN READ WRITE;
-- ALTER SESSION SET CONTAINER = 26798_pdb_assI;
-- ======================================================================================

-- ======================================================================================
-- TABLE CREATION: Base Tables for Library Management System
-- ======================================================================================

-- Create table: Authors (One-to-Many: One author can write many books)
CREATE TABLE Authors (
    AuthorID NUMBER PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Bio CLOB
);

-- Create table: Books (Each book is linked to an author)
CREATE TABLE Books (
    BookID NUMBER PRIMARY KEY,
    Title VARCHAR2(255) NOT NULL,
    AuthorID NUMBER,
    PublishedDate DATE,
    CONSTRAINT fk_books_authors FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Create table: Categories (Book Categories)
CREATE TABLE Categories (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(100) NOT NULL
);

-- Create table: BookCategories (Many-to-Many relationship between Books and Categories)
CREATE TABLE BookCategories (
    BookID NUMBER,
    CategoryID NUMBER,
    PRIMARY KEY (BookID, CategoryID),
    CONSTRAINT fk_bc_books FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT fk_bc_categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create table: Borrowings (Represents transactions for borrowed books)
CREATE TABLE Borrowings (
    BorrowID NUMBER PRIMARY KEY,
    BookID NUMBER,
    BorrowDate DATE,
    ReturnDate DATE,
    CONSTRAINT fk_borrow_books FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- ======================================================================================
-- ADDITIONAL DDL OPERATIONS
-- ======================================================================================
-- Example: Add a new column "Nationality" to Authors table.
ALTER TABLE Authors ADD (Nationality VARCHAR2(50));

-- Create an index on Books for PublishedDate to improve query performance.
CREATE INDEX idx_books_pubdate ON Books(PublishedDate);

-- Create a view for quick look-up of book details with author information.
CREATE OR REPLACE VIEW vw_BookDetails AS
SELECT b.BookID, b.Title, a.Name AS AuthorName, b.PublishedDate
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID;

-- ======================================================================================
-- DML OPERATIONS: INSERT SAMPLE DATA
-- ======================================================================================

-- Insert sample data into Authors
INSERT INTO Authors (AuthorID, Name, Bio) VALUES (1, 'J.K. Rowling', 'British author known for the Harry Potter series.');
INSERT INTO Authors (AuthorID, Name, Bio) VALUES (2, 'George R.R. Martin', 'American novelist known for A Song of Ice and Fire.');

-- Insert additional Authors with the new Nationality column
INSERT INTO Authors (AuthorID, Name, Bio, Nationality) VALUES (3, 'Agatha Christie', 'Famous mystery writer.', 'British');
INSERT INTO Authors (AuthorID, Name, Bio, Nationality) VALUES (4, 'Stephen King', 'Master of horror.', 'American');

-- Insert sample data into Books
INSERT INTO Books (BookID, Title, AuthorID, PublishedDate) 
VALUES (1, 'Harry Potter and the Sorcerer''s Stone', 1, TO_DATE('1997-06-26', 'YYYY-MM-DD'));
INSERT INTO Books (BookID, Title, AuthorID, PublishedDate) 
VALUES (2, 'A Game of Thrones', 2, TO_DATE('1996-08-06', 'YYYY-MM-DD'));

-- Insert additional Books
INSERT INTO Books (BookID, Title, AuthorID, PublishedDate) 
VALUES (3, 'Murder on the Orient Express', 3, TO_DATE('1934-01-01', 'YYYY-MM-DD'));
INSERT INTO Books (BookID, Title, AuthorID, PublishedDate) 
VALUES (4, 'The Shining', 4, TO_DATE('1977-01-28', 'YYYY-MM-DD'));

-- Insert sample data into Categories
INSERT INTO Categories (CategoryID, CategoryName) VALUES (1, 'Fantasy');
INSERT INTO Categories (CategoryID, CategoryName) VALUES (2, 'Adventure');

-- Insert additional Categories
INSERT INTO Categories (CategoryID, CategoryName) VALUES (3, 'Mystery');
INSERT INTO Categories (CategoryID, CategoryName) VALUES (4, 'Horror');

-- Insert data into BookCategories (mapping books to categories)
INSERT INTO BookCategories (BookID, CategoryID) VALUES (1, 1);
INSERT INTO BookCategories (BookID, CategoryID) VALUES (1, 2);
INSERT INTO BookCategories (BookID, CategoryID) VALUES (2, 1);
INSERT INTO BookCategories (BookID, CategoryID) VALUES (3, 3);
INSERT INTO BookCategories (BookID, CategoryID) VALUES (4, 4);

-- Insert data into Borrowings with sample dates (existing samples)
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (1, 1, SYSDATE - 3, NULL);
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (2, 2, SYSDATE - 10, TO_DATE('2025-02-10', 'YYYY-MM-DD'));
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (3, 1, SYSDATE - 2, NULL);
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (4, 1, SYSDATE - 1, NULL);
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (5, 1, SYSDATE - 5, TO_DATE('2025-02-12', 'YYYY-MM-DD'));

-- Insert additional Borrowings for new Books
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (6, 3, SYSDATE - 4, TO_DATE('2025-02-15', 'YYYY-MM-DD'));
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (7, 3, SYSDATE - 2, NULL);
INSERT INTO Borrowings (BorrowID, BookID, BorrowDate, ReturnDate) 
VALUES (8, 4, SYSDATE - 6, TO_DATE('2025-02-18', 'YYYY-MM-DD'));

-- ======================================================================================
-- DML OPERATIONS: UPDATE, DELETE, and MERGE Examples
-- ======================================================================================

-- Update operation: Correct the book title if needed.
UPDATE Books 
SET Title = 'Harry Potter and the Philosopher''s Stone' 
WHERE BookID = 1;

-- Additional UPDATE example: Set nationality for an author if not already set.
UPDATE Authors 
SET Nationality = 'British'
WHERE AuthorID = 1;

-- Delete operation: Remove an incorrect entry from BookCategories (if applicable)
DELETE FROM BookCategories 
WHERE BookID = 2 AND CategoryID = 1;

-- Additional DML: MERGE statement example to update or insert an Author.
MERGE INTO Authors a
USING (SELECT 4 AS AuthorID, 'Stephen King' AS Name, 'Renowned horror author updated info.' AS Bio, 'American' AS Nationality FROM dual) src
ON (a.AuthorID = src.AuthorID)
WHEN MATCHED THEN 
  UPDATE SET a.Bio = src.Bio
WHEN NOT MATCHED THEN
  INSERT (AuthorID, Name, Bio, Nationality) VALUES (src.AuthorID, src.Name, src.Bio, src.Nationality);

-- ======================================================================================
-- DQL OPERATIONS: SELECT Queries to Retrieve Data
-- ======================================================================================

-- Basic SELECT: Retrieve all authors
SELECT * FROM Authors;

-- JOIN Query: Retrieve authors and their corresponding books
SELECT a.Name, b.Title, b.PublishedDate
FROM Authors a
JOIN Books b ON a.AuthorID = b.AuthorID;

-- Query: Identify borrowings (transactions) in the past week
SELECT * FROM Borrowings
WHERE BorrowDate >= TRUNC(SYSDATE) - 7;

-- Query: Retrieve the top 5 highest borrow counts for each category using analytic functions
SELECT CategoryName, Title, borrow_count 
FROM (
    SELECT c.CategoryName, b.Title, COUNT(br.BorrowID) AS borrow_count,
           ROW_NUMBER() OVER (PARTITION BY c.CategoryName ORDER BY COUNT(br.BorrowID) DESC) as rn
    FROM Books b
    JOIN BookCategories bc ON b.BookID = bc.BookID
    JOIN Categories c ON bc.CategoryID = c.CategoryID
    LEFT JOIN Borrowings br ON b.BookID = br.BookID
    GROUP BY c.CategoryName, b.Title
)
WHERE rn <= 5;

-- Query: Retrieve books that have more than 3 borrow transactions
SELECT b.BookID, b.Title, COUNT(br.BorrowID) AS borrow_count
FROM Books b
JOIN Borrowings br ON b.BookID = br.BookID
GROUP BY b.BookID, b.Title
HAVING COUNT(br.BorrowID) > 3;

-- Additional DQL: Retrieve count of books per author
SELECT a.Name, COUNT(b.BookID) AS BookCount
FROM Authors a
LEFT JOIN Books b ON a.AuthorID = b.AuthorID
GROUP BY a.Name;

-- Additional DQL: Retrieve borrowing details with book and author information
SELECT br.BorrowID, b.Title, a.Name, br.BorrowDate, br.ReturnDate
FROM Borrowings br
JOIN Books b ON br.BookID = b.BookID
JOIN Authors a ON b.AuthorID = a.AuthorID;

-- Additional DQL: Retrieve the book with the maximum borrow count (using FETCH FIRST for Oracle 12c+)
SELECT * FROM Books
WHERE BookID = (
    SELECT b.BookID
    FROM Books b
    JOIN Borrowings br ON b.BookID = br.BookID
    GROUP BY b.BookID
    ORDER BY COUNT(br.BorrowID) DESC
    FETCH FIRST 1 ROWS ONLY
);

-- ======================================================================================
-- TCL OPERATIONS: Transaction Control Examples
-- ======================================================================================

-- Set a savepoint before performing a risky DML operation
SAVEPOINT before_delete;

-- Delete operation: Delete a borrowing record (simulate a scenario)
DELETE FROM Borrowings WHERE BorrowID = 8;

-- Rolling back to the savepoint (if the delete is not desired)
ROLLBACK TO SAVEPOINT before_delete;

-- Finally, commit the transaction
COMMIT;

-- Example of DCL (Data Control Language) command (requires appropriate privileges)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON Authors TO your_username;

-- ======================================================================================
-- PLANTUML DIAGRAM FOR LIBRARY MANAGEMENT SYSTEM DATABASE
-- ======================================================================================
-- To generate the diagram, copy the following text into a PlantUML editor or save it as a .puml file.
--
/* 
@startuml
!define Table(name,desc) class name as "desc" << (T,#FFAAAA) >>
Table(Authors, "Authors Table") {
  +AuthorID : NUMBER <<PK>>
  +Name : VARCHAR2(100)
  +Bio : CLOB
  +Nationality : VARCHAR2(50)
}
Table(Books, "Books Table") {
  +BookID : NUMBER <<PK>>
  +Title : VARCHAR2(255)
  +AuthorID : NUMBER <<FK>>
  +PublishedDate : DATE
}
Table(Categories, "Categories Table") {
  +CategoryID : NUMBER <<PK>>
  +CategoryName : VARCHAR2(100)
}
Table(BookCategories, "Mapping Table for Books and Categories") {
  +BookID : NUMBER <<PK, FK>>
  +CategoryID : NUMBER <<PK, FK>>
}
Table(Borrowings, "Borrowings Table") {
  +BorrowID : NUMBER <<PK>>
  +BookID : NUMBER <<FK>>
  +BorrowDate : DATE
  +ReturnDate : DATE
}

Authors "1" -- "0..*" Books : "writes"
Books "1" -- "0..*" BookCategories : "belongs to"
Categories "1" -- "0..*" BookCategories : "mapped in"
Books "0..1" -- "0..*" Borrowings : "borrowed in"
@enduml
*/
-- ======================================================================================

-- End of Script