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
            
            // Insert new seller into signupseller table
            String insertSignupQuery = "INSERT INTO signupseller (first_name, last_name, shop_name, email, phone, address, city, state, pincode, username, password, business_type, gst_number, registration_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, 'pending')";
            insertStmt = con.prepareStatement(insertSignupQuery);
            
            insertStmt.setString(1, firstName);
            insertStmt.setString(2, lastName);
            insertStmt.setString(3, shopName);
            insertStmt.setString(4, email);
            insertStmt.setString(5, phone);
            insertStmt.setString(6, address);
            insertStmt.setString(7, city);
            insertStmt.setString(8, state);
            insertStmt.setString(9, pincode);
            insertStmt.setString(10, username);
            insertStmt.setString(11, password); // In production, you should hash this password
            insertStmt.setString(12, businessType);
            insertStmt.setString(13, gstNumber != null && !gstNumber.trim().isEmpty() ? gstNumber : null);
            
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
                // Handle duplicate entry or other insertion errors
                if (userEx.getMessage().contains("Duplicate entry")) {
                    System.err.println("Username already exists in users table: " + userEx.getMessage());
                } else {
                    System.err.println("Error inserting into users table: " + userEx.getMessage());
                }
            }
            
            if (signupResult > 0) {
                // Registration successful
                response.sendRedirect("SellerRegistration.jsp?success=" + 
                    java.net.URLEncoder.encode("Registration successful! Your seller account has been created and is pending approval. You will be notified once approved.", "UTF-8"));
            } else {
                // Registration failed
                response.sendRedirect("SellerRegistration.jsp?error=" + 
                    java.net.URLEncoder.encode("Registration failed! Please try again.", "UTF-8"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("SellerRegistration.jsp?error=" + 
                java.net.URLEncoder.encode("Database error! Please try again later.", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SellerRegistration.jsp?error=" + 
                java.net.URLEncoder.encode("An error occurred! Please try again.", "UTF-8"));
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect to registration page for GET requests
        response.sendRedirect("SellerRegistration.jsp");
    }
}
