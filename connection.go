package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"

	// PostgreSQL driver
	_ "github.com/lib/pq"
	// MySQL driver
	_ "github.com/go-sql-driver/mysql"
)

// Configuration variables
var (
	// PostgreSQL
	pgUser     = "postgres"
	pgPassword = ""          // updated to remove sensitive information
	pgHost     = "localhost" // update to your Docker container or alias if needed
	pgPort     = "5432"
	// MySQL
	mysqlUser     = "root"
	mysqlPassword = ""          // updated to remove sensitive information
	mysqlHost     = "localhost" // update to your Docker container or alias if needed
	mysqlPort     = "3306"
)

// Helper function to handle errors
func checkErr(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

// connectPostgres connects to PostgreSQL with the provided dbName.
func connectPostgres(dbName string) *sql.DB {
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		pgHost, pgPort, pgUser, pgPassword, dbName)
	db, err := sql.Open("postgres", connStr)
	checkErr(err)
	err = db.Ping()
	checkErr(err)
	fmt.Printf("Connected to PostgreSQL database: %s\n", dbName)
	return db
}

// connectMySQL connects to MySQL with the provided dbName.
func connectMySQL(dbName string) *sql.DB {
	connStr := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		mysqlUser, mysqlPassword, mysqlHost, mysqlPort, dbName)
	db, err := sql.Open("mysql", connStr)
	checkErr(err)
	err = db.Ping()
	checkErr(err)
	fmt.Printf("Connected to MySQL database: %s\n", dbName)
	return db
}

// listPostgresDatabases returns a slice of available PostgreSQL databases.
func listPostgresDatabases(db *sql.DB) []string {
	query := "SELECT datname FROM pg_database WHERE datistemplate = false"
	rows, err := db.Query(query)
	checkErr(err)
	defer rows.Close()

	var databases []string
	for rows.Next() {
		var dbname string
		err := rows.Scan(&dbname)
		checkErr(err)
		databases = append(databases, dbname)
	}
	return databases
}

// listMySQLDatabases returns a slice of available MySQL databases.
func listMySQLDatabases(db *sql.DB) []string {
	query := "SHOW DATABASES"
	rows, err := db.Query(query)
	checkErr(err)
	defer rows.Close()

	var databases []string
	for rows.Next() {
		var dbname string
		err := rows.Scan(&dbname)
		checkErr(err)
		databases = append(databases, dbname)
	}
	return databases
}

// createDatabase creates a new database with the provided name.
func createDatabase(db *sql.DB, query string, dbName string) {
	_, err := db.Exec(query)
	if err != nil {
		log.Fatalf("Error creating database %s: %v", dbName, err)
	}
	fmt.Printf("Database '%s' created successfully.\n", dbName)
}

// readInput reads a line from standard input.
func readInput(prompt string) string {
	fmt.Print(prompt)
	reader := bufio.NewReader(os.Stdin)
	text, err := reader.ReadString('\n')
	checkErr(err)
	return strings.TrimSpace(text)
}

func connectionMain() {
	fmt.Println("Choose the database system you wish to work with:")
	fmt.Println("1) PostgreSQL")
	fmt.Println("2) MySQL")
	choice := readInput("Enter 1 or 2: ")

	var dbms string
	switch choice {
	case "1":
		dbms = "postgres"
	case "2":
		dbms = "mysql"
	default:
		log.Fatal("Invalid choice.")
	}

	if dbms == "postgres" {
		// Connect to a default db to list available ones (connect to 'postgres' db in PG)
		db := connectPostgres("postgres")
		defer db.Close()
		databases := listPostgresDatabases(db)
		fmt.Println("\nAvailable PostgreSQL databases:")
		for i, name := range databases {
			fmt.Printf("  %d) %s\n", i+1, name)
		}
		fmt.Println("  0) Create a new database")
		option := readInput("Choose a database by number (or 0 to create a new one): ")

		var targetDB string
		if option == "0" {
			targetDB = readInput("Enter the new database name: ")
			// Create database using SQL query
			createQuery := fmt.Sprintf("CREATE DATABASE %s", targetDB)
			_, err := db.Exec(createQuery)
			checkErr(err)
			fmt.Printf("Database '%s' created.\n", targetDB)
		} else {
			// Use existing database
			index := 0
			fmt.Sscanf(option, "%d", &index)
			if index < 1 || index > len(databases) {
				log.Fatal("Invalid selection.")
			}
			targetDB = databases[index-1]
		}
		// Connect to the selected/created database
		pgdb := connectPostgres(targetDB)
		defer pgdb.Close()
		// Continue with application logic using pgdb ...
		fmt.Println("You may now use the PostgreSQL connection as needed.")

	} else if dbms == "mysql" {
		// Connect to a default db to list available databases.
		// For MySQL, connecting to "mysql" system database is common.
		db := connectMySQL("mysql")
		defer db.Close()
		databases := listMySQLDatabases(db)
		fmt.Println("\nAvailable MySQL databases:")
		for i, name := range databases {
			fmt.Printf("  %d) %s\n", i+1, name)
		}
		fmt.Println("  0) Create a new database")
		option := readInput("Choose a database by number (or 0 to create a new one): ")

		var targetDB string
		if option == "0" {
			targetDB = readInput("Enter the new database name: ")
			createQuery := fmt.Sprintf("CREATE DATABASE %s", targetDB)
			_, err := db.Exec(createQuery)
			checkErr(err)
			fmt.Printf("Database '%s' created.\n", targetDB)
		} else {
			index := 0
			fmt.Sscanf(option, "%d", &index)
			if index < 1 || index > len(databases) {
				log.Fatal("Invalid selection.")
			}
			targetDB = databases[index-1]
		}
		// Connect to the selected/created database
		mysqldb := connectMySQL(targetDB)
		defer mysqldb.Close()
		// Continue with application logic using mysqldb...
		fmt.Println("You may now use the MySQL connection as needed.")
	}
}

func main() {
	connectionMain()
}
