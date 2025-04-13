package main

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"strings"

	// PostgreSQL driver
	_ "github.com/lib/pq"
	// MySQL driver
	_ "github.com/go-sql-driver/mysql"
)

// ... (Configuration variables and helper functions: checkErr, connectPostgres, connectMySQL, etc.)

// runSQLScript reads a SQL file, splits it into individual statements, and executes them.
func runSQLScript(db *sql.DB, filePath string) {
	// Read the entire file
	scriptBytes, err := ioutil.ReadFile(filePath)
	checkErr(err)
	script := string(scriptBytes)

	// A simple (and naive) way to split statements on semicolon.
	// Note: For complex SQL scripts (with semicolons in strings, comments, etc.), consider using a proper SQL parser.
	statements := strings.Split(script, ";")

	for _, stmt := range statements {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" {
			continue
		}
		// Execute each statement
		_, err := db.Exec(stmt)
		if err != nil {
			log.Fatalf("Error executing statement [%s]: %v", stmt, err)
		} else {
			fmt.Printf("Executed: %s\n", stmt)
		}
	}
}

func main() {
	// Select DBMS and database as in the prior example (interactive menu).
	// For demonstration, here we just connect to PostgreSQL using a hardcoded DB name.
	pgdb := connectPostgres("postgres")
	defer pgdb.Close()

	// Optionally, run your script file.
	// For example, let’s say your file is called "script.sql" in the project root.
	sqlFilePath := "script.sql"
	runSQLScript(pgdb, sqlFilePath)

	// After running the SQL script, you can continue with your application logic.
	fmt.Println("SQL script execution complete.")
}
