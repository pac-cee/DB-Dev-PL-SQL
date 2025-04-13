import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

public class DBConnector {
    // Configuration for PostgreSQL
    private static final String PG_USER = "postgres";
    private static final String PG_PASSWORD = "Euqificap12";
    private static final String PG_HOST = "localhost";
    private static final String PG_PORT = "5432";
    // For PostgreSQL, the default database to connect and list other db's is often "postgres"
    private static final String PG_DEFAULT_DB = "postgres";

    // Configuration for MySQL
    private static final String MYSQL_USER = "root";
    private static final String MYSQL_PASSWORD = "Euqificap12";
    private static final String MYSQL_HOST = "localhost";
    private static final String MYSQL_PORT = "3306";
    // For MySQL, we can connect to the "mysql" system database to list available ones.
    private static final String MYSQL_DEFAULT_DB = "mysql";

    // Helper method to read user input
    private static String readInput(Scanner scanner, String prompt) {
        System.out.print(prompt);
        return scanner.nextLine().trim();
    }

    // Connect to PostgreSQL
    public static Connection connectPostgres(String dbName) throws SQLException {
        String url = "jdbc:postgresql://" + PG_HOST + ":" + PG_PORT + "/" + dbName;
        Connection conn = DriverManager.getConnection(url, PG_USER, PG_PASSWORD);
        System.out.println("Connected to PostgreSQL database: " + dbName);
        return conn;
    }

    // Connect to MySQL
    public static Connection connectMySQL(String dbName) throws SQLException {
        String url = "jdbc:mysql://" + MYSQL_HOST + ":" + MYSQL_PORT + "/" + dbName;
        Connection conn = DriverManager.getConnection(url, MYSQL_USER, MYSQL_PASSWORD);
        System.out.println("Connected to MySQL database: " + dbName);
        return conn;
    }

    // List PostgreSQL databases
    public static void listPostgresDatabases(Connection conn) throws SQLException {
        String sql = "SELECT datname FROM pg_database WHERE datistemplate = false";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        System.out.println("\nAvailable PostgreSQL databases:");
        int index = 1;
        while (rs.next()) {
            System.out.println("  " + (index++) + ") " + rs.getString("datname"));
        }
        rs.close();
        stmt.close();
    }

    // List MySQL databases
    public static void listMySQLDatabases(Connection conn) throws SQLException {
        String sql = "SHOW DATABASES";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        System.out.println("\nAvailable MySQL databases:");
        int index = 1;
        while (rs.next()) {
            System.out.println("  " + (index++) + ") " + rs.getString(1));
        }
        rs.close();
        stmt.close();
    }

    // Create database method (for both PostgreSQL and MySQL)
    public static void createDatabase(Connection conn, String dbName, String dbType) throws SQLException {
        String createSQL = "";
        if (dbType.equals("postgres")) {
            createSQL = "CREATE DATABASE " + dbName;
        } else if (dbType.equals("mysql")) {
            createSQL = "CREATE DATABASE " + dbName;
        }
        Statement stmt = conn.createStatement();
        stmt.executeUpdate(createSQL);
        stmt.close();
        System.out.println("Database '" + dbName + "' created successfully.");
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Choose the database system:");
        System.out.println("1) PostgreSQL");
        System.out.println("2) MySQL");
        String choice = readInput(scanner, "Enter 1 or 2: ");
        String dbType = "";

        if (choice.equals("1")) {
            dbType = "postgres";
        } else if (choice.equals("2")) {
            dbType = "mysql";
        } else {
            System.err.println("Invalid choice.");
            scanner.close();
            return;
        }

        try {
            if (dbType.equals("postgres")) {
                // Connect using default database
                Connection defaultConn = connectPostgres(PG_DEFAULT_DB);
                listPostgresDatabases(defaultConn);
                System.out.println("  0) Create a new database");
                String option = readInput(scanner, "Choose a database by number (or 0 to create): ");

                String targetDB = "";
                if (option.equals("0")) {
                    targetDB = readInput(scanner, "Enter the new database name: ");
                    createDatabase(defaultConn, targetDB, "postgres");
                } else {
                    // We need to re-run the query to map the choice to the database name.
                    // For simplicity, we fetch the list again.
                    Statement stmt = defaultConn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT datname FROM pg_database WHERE datistemplate = false");
                    int index = 1;
                    while (rs.next()) {
                        if (Integer.toString(index).equals(option)) {
                            targetDB = rs.getString("datname");
                            break;
                        }
                        index++;
                    }
                    rs.close();
                    stmt.close();
                    if (targetDB.isEmpty()) {
                        System.err.println("Invalid selection.");
                        defaultConn.close();
                        scanner.close();
                        return;
                    }
                }
                defaultConn.close();
                // Connect to the selected/created database
                Connection targetConn = connectPostgres(targetDB);
                // Continue using targetConn for your project logic...
                targetConn.close();

            } else if (dbType.equals("mysql")) {
                // Connect using default MySQL database.
                Connection defaultConn = connectMySQL(MYSQL_DEFAULT_DB);
                listMySQLDatabases(defaultConn);
                System.out.println("  0) Create a new database");
                String option = readInput(scanner, "Choose a database by number (or 0 to create): ");

                String targetDB = "";
                if (option.equals("0")) {
                    targetDB = readInput(scanner, "Enter the new database name: ");
                    createDatabase(defaultConn, targetDB, "mysql");
                } else {
                    Statement stmt = defaultConn.createStatement();
                    ResultSet rs = stmt.executeQuery("SHOW DATABASES");
                    int index = 1;
                    while (rs.next()) {
                        if (Integer.toString(index).equals(option)) {
                            targetDB = rs.getString(1);
                            break;
                        }
                        index++;
                    }
                    rs.close();
                    stmt.close();
                    if (targetDB.isEmpty()) {
                        System.err.println("Invalid selection.");
                        defaultConn.close();
                        scanner.close();
                        return;
                    }
                }
                defaultConn.close();
                // Connect to the selected/created MySQL database.
                Connection targetConn = connectMySQL(targetDB);
                // Continue using targetConn for your project logic...
                targetConn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        scanner.close();
    }
}
