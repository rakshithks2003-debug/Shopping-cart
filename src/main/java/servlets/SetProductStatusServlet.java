package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SetProductStatusServlet")
public class SetProductStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        String proId = request.getParameter("proId");
        String status = request.getParameter("status");
        
        boolean success = false;
        String message = "Error updating product status";
        
        try {
            if (proId == null || proId.trim().isEmpty()) {
                message = "Product PIN is required";
            } else if (status == null || (!status.equals("pending") && !status.equals("rejected"))) {
                message = "Invalid status. Must be 'pending' or 'rejected'";
            } else {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                
                // Add status column if it doesn't exist
                try {
                    String checkColumnQuery = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'mscart' AND TABLE_NAME = 'Sproduct' AND COLUMN_NAME = 'status'";
                    PreparedStatement checkStmt = con.prepareStatement(checkColumnQuery);
                    java.sql.ResultSet rs = checkStmt.executeQuery();
                    
                    if (!rs.next()) {
                        // Add status column to Sproduct table
                        String alterQuery = "ALTER TABLE Sproduct ADD COLUMN status VARCHAR(20) DEFAULT 'approved'";
                        PreparedStatement alterStmt = con.prepareStatement(alterQuery);
                        alterStmt.executeUpdate();
                        alterStmt.close();
                        System.out.println("Added status column to Sproduct table");
                    }
                    
                    rs.close();
                    checkStmt.close();
                } catch (Exception e) {
                    System.err.println("Error checking/adding status column: " + e.getMessage());
                }
                
                // Update product status or delete if rejected
                if (status.equals("rejected")) {
                    // Delete rejected product from Sproduct table
                    String deleteQuery = "DELETE FROM Sproduct WHERE pro_id = ?";
                    PreparedStatement deleteStmt = con.prepareStatement(deleteQuery);
                    deleteStmt.setString(1, proId);
                    int rowsDeleted = deleteStmt.executeUpdate();
                    deleteStmt.close();
                    
                    if (rowsDeleted > 0) {
                        success = true;
                        message = "Product rejected and removed successfully";
                        System.out.println("Deleted product PIN " + proId + " from Sproduct table");
                    } else {
                        message = "Product not found or deletion failed";
                    }
                } else {
                    // Update product status to pending
                    String updateQuery = "UPDATE Sproduct SET status = ? WHERE pro_id = ?";
                    PreparedStatement updateStmt = con.prepareStatement(updateQuery);
                    updateStmt.setString(1, status);
                    updateStmt.setString(2, proId);
                    
                    int rowsUpdated = updateStmt.executeUpdate();
                    updateStmt.close();
                    
                    if (rowsUpdated > 0) {
                        success = true;
                        message = "Product status updated successfully to " + status;
                        System.out.println("Updated product PIN " + proId + " status to: " + status);
                    } else {
                        message = "Product not found or status update failed";
                    }
                }
                
                con.close();
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
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
