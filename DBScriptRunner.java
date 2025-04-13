import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

public class DBScriptRunner {

    // Configuration for PostgreSQL
    private static final String PG_USER = "postgres";
    private static final String PG_PASSWORD = ""; // updated to remove sensitive information
    private static final String PG_HOST = "localhost";
    private static final String PG_PORT = "5432";
    // For demonstration, we will use the "postgres" database to run our SQL script.
    private static final String PG_DB = "postgres";

    // Configuration for MySQL
    private static final String MYSQL_USER = "root";
    private static final String MYSQL_PASSWORD = ""; // updated to remove sensitive information
    private static final String MYSQL_HOST = "localhost";
    private static final String MYSQL_PORT = "3306";
    // For demonstration, using the "mysql" database
    private static final String MYSQL_DB = "mysql";

    // Helper method for PostgreSQL connection
    public static Connection connectPostgres(String dbName) throws SQLException {
        String url = "jdbc:postgresql://" + PG_HOST + ":" + PG_PORT + "/" + dbName;
        Connection conn = DriverManager.getConnection(url, PG_USER, PG_PASSWORD);
        System.out.println("Connected to PostgreSQL database: " + dbName);
        return conn;
    }

    // Helper method for MySQL connection
    public static Connection connectMySQL(String dbName) throws SQLException {
        String url = "jdbc:mysql://" + MYSQL_HOST + ":" + MYSQL_PORT + "/" + dbName;
        Connection conn = DriverManager.getConnection(url, MYSQL_USER, MYSQL_PASSWORD);
        System.out.println("Connected to MySQL database: " + dbName);
        return conn;
    }

    // Read the entire SQL file into a String. Adjust the file path as needed.
    public static String readSQLFile(String filePath) {
        StringBuilder sqlScript = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                sqlScript.append(line).append("\n");
            }
        } catch (IOException e) {
            System.err.println("Error reading SQL file: " + e.getMessage());
        }
        return sqlScript.toString();
    }

    // Execute the SQL script by splitting on semicolons (simple parsing)
    public static void runSQLScript(Connection conn, String filePath) {
        String script = readSQLFile(filePath);
        // Splitting based on semicolon. For production use cases, you might want a more robust parser.
        String[] statements = script.split(";");
        try (Statement stmt = conn.createStatement()) {
            for (String command : statements) {
                command = command.trim();
                if (command.isEmpty()) {
                    continue;
                }
                stmt.execute(command);
                System.out.println("Executed: " + command);
            }
        } catch (SQLException e) {
            System.err.println("Error executing SQL script: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        // For this demonstration, let’s assume you choose which DBMS to use via CLI.
        Scanner scanner = new Scanner(System.in);
        System.out.println("Choose the database system:");
        System.out.println("1) PostgreSQL");
        System.out.println("2) MySQL");
        String choice = scanner.nextLine().trim();

        Connection connection = null;
        try {
            if ("1".equals(choice)) {
                connection = connectPostgres(PG_DB);
            } else if ("2".equals(choice)) {
                connection = connectMySQL(MYSQL_DB);
            } else {
                System.err.println("Invalid choice.");
                scanner.close();
                return;
            }

            // Path to your SQL file created in VS Code.
            String sqlFilePath = "script.sql";  // Ensure this file is at the correct location
            runSQLScript(connection, sqlFilePath);
            System.out.println("SQL script execution complete.");

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                    System.out.println("Connection closed.");
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            scanner.close();
        }
    }
}
