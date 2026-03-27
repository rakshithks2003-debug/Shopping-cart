package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.lang.ClassNotFoundException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        boolean success = false;
        String message = "Error";
        
        try {
            String action = request.getParameter("action");
            String username = request.getParameter("username");
            
            System.out.println("ChangePasswordServlet: action=" + action + ", username=" + username);
            
            if (action == null) {
                message = "Action parameter is missing";
            } else if (action.equals("getPassword")) {
                // Get password for username
                if (username == null || username.trim().isEmpty()) {
                    message = "Username is required";
                } else {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                        
                        String selectQuery = "SELECT password FROM users WHERE username = ?";
                        PreparedStatement selectStmt = con.prepareStatement(selectQuery);
                        selectStmt.setString(1, username);
                        ResultSet rs = selectStmt.executeQuery();
                        
                        if (rs.next()) {
                            success = true;
                            message = rs.getString("password");
                        } else {
                            message = "User not found";
                        }
                        
                        rs.close();
                        selectStmt.close();
                        con.close();
                    } catch (ClassNotFoundException e) {
                        message = "Database driver not found: " + e.getMessage();
                        e.printStackTrace();
                    } catch (SQLException e) {
                        message = "Database error: " + e.getMessage();
                        e.printStackTrace();
                    }
                }
            } else if (action != null && action.equals("changePassword")) {
                // Change password
                String newPassword = request.getParameter("newPassword");
                
                if (username == null || username.trim().isEmpty()) {
                    message = "Username is required";
                } else if (newPassword == null || newPassword.trim().isEmpty()) {
                    message = "New password is required";
                } else if (newPassword.length() < 6 || newPassword.length() > 20) {
                    message = "Password must be 6-20 characters";
                } else {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    
                    // Update password in users table
                    String updateQuery = "UPDATE users SET password = ? WHERE username = ?";
                    PreparedStatement updateStmt = con.prepareStatement(updateQuery);
                    updateStmt.setString(1, newPassword);
                    updateStmt.setString(2, username);
                    
                    int rowsUpdated = updateStmt.executeUpdate();
                    updateStmt.close();
                    con.close();
                    
                    if (rowsUpdated > 0) {
                        success = true;
                        message = "Password changed successfully!";
                    } else {
                        message = "User not found";
                    }
                }
            } else {
                message = "Invalid action";
            }
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Create JSON response
        StringBuilder jsonResponse = new StringBuilder();
        jsonResponse.append("{\"success\":");
        jsonResponse.append(success);
        jsonResponse.append(",\"message\":\"");
        jsonResponse.append(message.replace("\"", "\\\""));
        jsonResponse.append("\"}");
        
        out.print(jsonResponse.toString());
        out.flush();
    }
    
    @Override
    public void init() throws ServletException {
        super.init();
        System.out.println("ChangePasswordServlet initialized");
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
