package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import products.Dbase;

@WebServlet("/SellerRegistrationServlet")
public class SellerRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get form parameters
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String shopName = request.getParameter("shopName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String businessType = request.getParameter("businessType");
        String gstNumber = request.getParameter("gstNumber");
        
        Connection con = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;
        
        try {
            // Initialize database connection
            Dbase db = new Dbase();
            con = db.initailizeDatabase();
            
            // Ensure the id column exists in signupseller table
            try {
                java.sql.DatabaseMetaData meta = con.getMetaData();
                java.sql.ResultSet columns = meta.getColumns(null, null, "signupseller", "id");
                if (!columns.next()) {
                    // id column doesn't exist, add it
                    java.sql.Statement alterStmt = con.createStatement();
                    alterStmt.executeUpdate("ALTER TABLE signupseller ADD COLUMN id VARCHAR(10) UNIQUE");
                    alterStmt.close();
                }
                columns.close();
            } catch (Exception e) {
                // Silently handle column check/add errors
            }
            
            // Check if username already exists in signupseller table
            String checkUsernameQuery = "SELECT username FROM signupseller WHERE username = ?";
            checkStmt = con.prepareStatement(checkUsernameQuery);
            checkStmt.setString(1, username);
            rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // Username already exists
                response.sendRedirect("SellerRegistration.jsp?error=" + 
                    java.net.URLEncoder.encode("Username already exists! Please choose a different username.", "UTF-8"));
                return;
            }
            
            // Check if email already exists in signupseller table
            String checkEmailQuery = "SELECT email FROM signupseller WHERE email = ?";
            checkStmt = con.prepareStatement(checkEmailQuery);
            checkStmt.setString(1, email);
            rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // Email already exists
                response.sendRedirect("SellerRegistration.jsp?error=" + 
                    java.net.URLEncoder.encode("Email already registered! Please use a different email.", "UTF-8"));
                return;
            }
            
            // Generate a unique 4-digit seller ID
            String sellerId = generateSellerId(con);
            
            // Insert new seller into signupseller table
            String insertSignupQuery = "INSERT INTO signupseller (id, first_name, last_name, shop_name, email, phone, address, city, state, pincode, username, password, business_type, gst_number, registration_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, 'pending')";
            insertStmt = con.prepareStatement(insertSignupQuery);
            
            insertStmt.setString(1, sellerId);
            insertStmt.setString(2, firstName);
            insertStmt.setString(3, lastName);
            insertStmt.setString(4, shopName);
            insertStmt.setString(5, email);
            insertStmt.setString(6, phone);
            insertStmt.setString(7, address);
            insertStmt.setString(8, city);
            insertStmt.setString(9, state);
            insertStmt.setString(10, pincode);
            insertStmt.setString(11, username);
            insertStmt.setString(12, password); // In production, you should hash this password
            insertStmt.setString(13, businessType);
            insertStmt.setString(14, gstNumber != null && !gstNumber.trim().isEmpty() ? gstNumber : null);
            
            int signupResult = insertStmt.executeUpdate();
            
            // Also insert into users table with role='seller'
            int userResult = 0;
            try {
                String insertUserQuery = "INSERT INTO users (username, password, role) VALUES (?, ?, 'seller')";
                PreparedStatement userStmt = con.prepareStatement(insertUserQuery);
                userStmt.setString(1, username);
                userStmt.setString(2, password);
                userResult = userStmt.executeUpdate();
                userStmt.close();
            } catch (Exception userEx) {
                // Silently handle duplicate entry or other insertion errors
            }
            
            if (signupResult > 0) {
                // Registration successful
                response.sendRedirect("SellerRegistration.jsp?success=" + 
                    java.net.URLEncoder.encode("Registration successful! Your seller ID is " + sellerId + ". Your account has been created and is pending approval. You will be notified once approved.", "UTF-8"));
            } else {
                // Registration failed
                response.sendRedirect("SellerRegistration.jsp?error=" + 
                    java.net.URLEncoder.encode("Registration failed! Please try again.", "UTF-8"));
            }
            
        } catch (SQLException e) {
            String errorMsg = "Database error: " + e.getMessage();
            if (e.getMessage().contains("Duplicate entry")) {
                errorMsg = "Duplicate entry error. Please try again.";
            } else if (e.getMessage().contains("Column") && e.getMessage().contains("doesn't exist")) {
                errorMsg = "Database schema error. Please contact administrator.";
            }
            
            response.sendRedirect("SellerRegistration.jsp?error=" + 
                java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        } catch (Exception e) {
            response.sendRedirect("SellerRegistration.jsp?error=" + 
                java.net.URLEncoder.encode("An error occurred: " + e.getMessage(), "UTF-8"));
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                // Silently handle resource cleanup errors
            }
        }
    }
    
    /**
     * Generates a unique 4-digit seller ID
     * @param con Database connection
     * @return Unique 4-digit seller ID as String
     * @throws SQLException If database error occurs
     */
    private String generateSellerId(Connection con) throws SQLException {
        PreparedStatement checkStmt = null;
        ResultSet rs = null;
        
        try {
            // Generate random 4-digit number (1000-9999)
            int randomId;
            String sellerId;
            boolean isUnique = false;
            
            // Keep trying until we find a unique ID
            do {
                randomId = 1000 + (int)(Math.random() * 9000); // Generate 4-digit number
                sellerId = String.valueOf(randomId);
                
                // Check if this ID already exists in the database
                String checkQuery = "SELECT id FROM signupseller WHERE id = ?";
                checkStmt = con.prepareStatement(checkQuery);
                checkStmt.setString(1, sellerId);
                rs = checkStmt.executeQuery();
                
                // If no record found, the ID is unique
                if (!rs.next()) {
                    isUnique = true;
                }
                
                // Clean up for next iteration
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                
            } while (!isUnique);
            
            return sellerId;
            
        } catch (SQLException e) {
            throw e;
        } finally {
            // Ensure resources are closed
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
            } catch (SQLException e) {
                // Silently handle resource cleanup errors
            }
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
