<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String cartId = request.getParameter("cartId");
    String quantity = request.getParameter("quantity");
    String username = (String) session.getAttribute("username");
    
    boolean success = false;
    String message = "Error updating quantity";
    
    try {
        if (username == null || username.trim().isEmpty()) {
            message = "Please login to update cart";
        } else if (cartId == null || cartId.trim().isEmpty()) {
            message = "Cart ID is required";
        } else if (quantity == null || quantity.trim().isEmpty()) {
            message = "Quantity is required";
        } else {
            Connection con = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/mscart", "root", "123456");
                
                String updateQuery = "UPDATE cart SET quantity = ? WHERE id = ? AND user_id = ?";
                PreparedStatement ps = con.prepareStatement(updateQuery);
                ps.setInt(1, Integer.parseInt(quantity));
                ps.setString(2, cartId);
                ps.setString(3, username);
                
                int rowsUpdated = ps.executeUpdate();
                ps.close();
                con.close();
                
                if (rowsUpdated > 0) {
                    success = true;
                    message = "Quantity updated successfully";
                } else {
                    message = "Failed to update quantity";
                }
                
            } catch (Exception e) {
                message = "Database error: " + e.getMessage();
                e.printStackTrace();
            }
        }
    } catch (Exception e) {
        message = "System error: " + e.getMessage();
        e.printStackTrace();
    }
    
    out.print("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    out.flush();
%>
