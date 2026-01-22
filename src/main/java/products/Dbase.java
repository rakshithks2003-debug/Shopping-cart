package products;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Dbase {
    
    public Connection initailizeDatabase() throws SQLException {
        Connection con = null;
        String[] passwords = {"123456", "root", "", "mysql", "password"};
        String workingPassword = null;
        String lastError = "";
        
        try {
            // Load JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Try different passwords
            for (String pwd : passwords) {
                try {
                    con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/mscart?useSSL=false&allowPublicKeyRetrieval=true", 
                        "root", pwd);
                    workingPassword = pwd;
                    System.out.println("Connected with password: " + (pwd.isEmpty() ? "(empty)" : pwd));
                    break;
                } catch (Exception e) {
                    lastError = e.getMessage();
                    System.out.println("Failed with password '" + pwd + "': " + e.getMessage());
                }
            }
            
            if (con == null || con.isClosed()) {
                throw new SQLException("Failed to connect to database. Last error: " + lastError);
            }
            
            // Create database if it doesn't exist
            try {
                con.createStatement().executeUpdate("CREATE DATABASE IF NOT EXISTS mscart");
                System.out.println("Database 'mscart' created or already exists");
            } catch (Exception e) {
                System.out.println("Error creating database: " + e.getMessage());
            }
            
            return con;
            
        } catch (ClassNotFoundException e) {
            System.out.println("JDBC Driver not found: " + e.getMessage());
            return null;
        } catch (SQLException e) {
            System.out.println("Database connection error: " + e.getMessage());
            return null;
        }
    }
}