import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import products.Dbase;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        PrintWriter out = response.getWriter();
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        String errorMessage = "";
        String successMessage = "";
        
        try {
            // Validate passwords match
            if (!password.equals(confirmPassword)) {
                errorMessage = "Passwords do not match!";
            }
            // Validate username
            else if (username == null || username.trim().isEmpty()) {
                errorMessage = "Username is required";
            }
            // Validate password
            else if (password == null || password.trim().isEmpty()) {
                errorMessage = "Password is required";
            }
            // Length validation
            else if (username.length() < 3 || username.length() > 20) {
                errorMessage = "Username must be 3-20 characters";
            }
            else if (password.length() < 6 || password.length() > 20) {
                errorMessage = "Password must be 6-20 characters";
            }
            else {
                // Connect to database
                Dbase db = new Dbase();
                Connection con = db.initailizeDatabase();
                
                if (con == null || con.isClosed()) {
                    errorMessage = "Database connection failed!";
                } else {
                    // Validate and fix table structure
                    if (!validateAndFixTableStructure(con, out)) {
                        errorMessage = "Database table structure error!";
                        con.close();
                        return;
                    }
                    
                    // Check if username already exists
                    PreparedStatement checkPs = con.prepareStatement("SELECT COUNT(*) FROM users WHERE username = ?");
                    checkPs.setString(1, username);
                    ResultSet rs = checkPs.executeQuery();
                    rs.next();
                    int count = rs.getInt(1);
                    rs.close();
                    checkPs.close();
                    
                    if (count > 0) {
                        errorMessage = "Username already exists!";
                    } else {
                        // Generate random user_id
                        String userId = "USR" + String.format("%06d", (int)(Math.random() * 1000000));
                        
                        // Check if user_id already exists (very rare but possible)
                        PreparedStatement checkIdPs = con.prepareStatement("SELECT COUNT(*) FROM users WHERE user_id = ?");
                        checkIdPs.setString(1, userId);
                        ResultSet idRs = checkIdPs.executeQuery();
                        idRs.next();
                        int idCount = idRs.getInt(1);
                        idRs.close();
                        checkIdPs.close();
                        
                        // If user_id exists, generate a new one
                        if (idCount > 0) {
                            userId = "USR" + String.format("%06d", (int)(Math.random() * 1000000) + 1000000);
                        }
                        
                        // Insert new user
                        PreparedStatement insertPs = con.prepareStatement("INSERT INTO users(user_id, username, password, role) VALUES(?, ?, ?, ?)");
                        insertPs.setString(1, userId);
                        insertPs.setString(2, username);
                        insertPs.setString(3, password);
                        insertPs.setString(4, "user");
                        
                        int result = insertPs.executeUpdate();
                        insertPs.close();
                        
                        if (result > 0) {
                            successMessage = "Registration successful!";
                        } else {
                            errorMessage = "Registration failed!";
                        }
                    }
                    con.close();
                }
            }
        } 
        catch (Exception e) {
            errorMessage = "Database Error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Set messages as request attributes and forward back to signup page
        if (!errorMessage.isEmpty()) {
            request.setAttribute("errorMessage", errorMessage);
        }
        if (!successMessage.isEmpty()) {
            request.setAttribute("successMessage", successMessage);
        }
        
        // Forward back to signup page
        request.getRequestDispatcher("Signup.jsp").forward(request, response);
    }
    
    private boolean validateAndFixTableStructure(Connection con, PrintWriter out) {
        try {
            // Check if users table has correct structure
            PreparedStatement checkTablePs = con.prepareStatement("SHOW COLUMNS FROM users LIKE 'user_id'");
            ResultSet tableRs = checkTablePs.executeQuery();
            
            if (!tableRs.next()) {
                // user_id column doesn't exist, need to recreate table
                Statement alterStmt = con.createStatement();
                try {
                    // Try to add user_id column
                    alterStmt.executeUpdate("ALTER TABLE users ADD COLUMN user_id VARCHAR(20) UNIQUE");
                    out.println("<!-- Added user_id column to existing table -->");
                } catch (Exception alterEx) {
                    // If that fails, recreate the entire table
                    alterStmt.executeUpdate("DROP TABLE IF EXISTS users");
                    alterStmt.executeUpdate(
                        "CREATE TABLE users (" +
                        "id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "user_id VARCHAR(20) UNIQUE NOT NULL, " +
                        "username VARCHAR(50) UNIQUE NOT NULL, " +
                        "password VARCHAR(100) NOT NULL, " +
                        "role VARCHAR(20) DEFAULT 'user', " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ")"
                    );
                    out.println("<!-- Recreated users table with correct structure -->");
                }
                alterStmt.close();
            } else {
                // Check if user_id column is VARCHAR type
                String columnType = tableRs.getString("Type");
                if (!columnType.toLowerCase().contains("varchar")) {
                    // Wrong type, need to fix
                    Statement alterStmt = con.createStatement();
                    alterStmt.executeUpdate("ALTER TABLE users DROP COLUMN user_id");
                    alterStmt.executeUpdate("ALTER TABLE users ADD COLUMN user_id VARCHAR(20) UNIQUE");
                    alterStmt.close();
                    out.println("<!-- Fixed user_id column type -->");
                }
            }
            tableRs.close();
            checkTablePs.close();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}