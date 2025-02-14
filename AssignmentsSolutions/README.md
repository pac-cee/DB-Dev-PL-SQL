# Library Management System Database

## Student Information
- **ID:** 26798
- **Name:** Your Name (replace with your full name)
- **Concentration:** Your Concentration

## Problem Statement
This project involves designing and implementing a database system for managing a library. The system comprises tables for Authors, Books, Categories, BookCategories (to manage many-to-many relationships between books and categories), and Borrowings (to track transactions for borrowed books). The design ensures data integrity, provides extensive sample data, and demonstrates a variety of Oracle SQL operations.

## PDB & Environment Setup
- **Pluggable Database:**  
  A pluggable database named `26798_pdb_assI` must be created, following the instructions provided in the SQL script. Ensure that the PDB is open and accessible before running the script.
  
- **SQL Developer/CLI:**  
  Execute the SQL script using Oracle SQL Developer or SQL*Plus once the environment is set up.

## Conceptual Diagram
A conceptual diagram illustrating the relationships between the tables is included as a PlantUML block within the SQL script. To view the diagram:
- Copy the PlantUML code from the SQL script and paste it into any PlantUML editor (or use an online PlantUML tool) to generate the diagram.

Optionally, you can also include an image (e.g., `conceptual_diagram.png`) in the repository.

## SQL Operations Executed
The SQL script demonstrates a wide range of operations:

- **DDL Operations:**
  - Creation of tables (`Authors`, `Books`, `Categories`, `BookCategories`, and `Borrowings`) with primary and foreign key constraints.
  - Alteration of tables (adding the "Nationality" column to the Authors table).
  - Index creation for performance optimization.
  - Creation of a view (`vw_BookDetails`) for easier data retrieval.

- **DML Operations:**
  - Insertion of sample data into all tables, including additional records for richer data.
  - UPDATE operations to correct and update data.
  - DELETE operations to clean up incorrect records.
  - A MERGE statement to demonstrate conditional insert/update logic.

- **DQL (SELECT) Operations:**
  - Basic data retrieval with SELECT statements.
  - Complex joins between tables.
  - Queries using analytic functions, subqueries, and aggregations (such as identifying top records and counting related records).

- **TCL (Transaction Control) Operations:**
  - Use of SAVEPOINT, ROLLBACK, and COMMIT to manage transactions and ensure data integrity.

- **DCL (Data Control Language):**
  - Sample GRANT command (commented) provided for reference on access control.

## Results and Screenshots
- Include screenshots of the SQL queries results as executed in Oracle SQL Developer.
- The outputs verify:
  - Successful identification of recent transactions.
  - Accurate retrieval of top records and aggregated data.
  - Proper implementation of table relationships and transaction control.

## Conclusion
This Library Management System Database project demonstrates a comprehensive application of Oracle PL/SQL features, covering DDL, DML, DQL, TCL, and DCL operations within a pluggable database environment. The extended sample data, additional SQL commands, and the included PlantUML diagram provide a robust illustration of advanced database management techniques.