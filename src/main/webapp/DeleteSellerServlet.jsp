<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/html");
    response.setCharacterEncoding("UTF-8");
    
    String sellerId = request.getParameter("sellerId");
    String action = request.getParameter("action");
    
    boolean success = false;
    String message = "Error processing request";
    
    try {
        if (sellerId == null || sellerId.trim().isEmpty()) {
            message = "Seller ID is required";
        } else if (action == null || action.trim().isEmpty()) {
            message = "Action is required";
        } else {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            
            if ("delete".equals(action)) {
                // Delete seller from database
                String deleteQuery = "DELETE FROM seller WHERE id = ?";
                PreparedStatement ps = con.prepareStatement(deleteQuery);
                ps.setString(1, sellerId);
                
                int rowsDeleted = ps.executeUpdate();
                ps.close();
                
                if (rowsDeleted > 0) {
                    success = true;
                    message = "Seller deleted successfully";
                } else {
                    message = "Seller not found or already deleted";
                }
            } else {
                message = "Invalid action: " + action;
            }
            
            con.close();
        }
    } catch (Exception e) {
        message = "Database error: " + e.getMessage();
        e.printStackTrace();
    }
    
    // Return JSON response
    out.println("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
%>
