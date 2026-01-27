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
            
            if ("accept".equals(action)) {
                // Get seller details
                String getSellerQuery = "SELECT * FROM seller WHERE id = ?";
                PreparedStatement psSeller = con.prepareStatement(getSellerQuery);
                psSeller.setString(1, sellerId);
                ResultSet rsSeller = psSeller.executeQuery();
                
                if (rsSeller.next()) {
                    // Get data using correct column names
                    String productName = rsSeller.getString("name"); // Changed from product_name
                    double price = rsSeller.getDouble("price");
                    String description = rsSeller.getString("description");
                    String image = rsSeller.getString("image");
                    
                    // Move seller data to products table - using correct column names
                    String insertQuery = "INSERT INTO product (name, price, description, image, category_id, seller_id) VALUES (?, ?, ?, ?, ?, ?)";
                    PreparedStatement psInsert = con.prepareStatement(insertQuery);
                    psInsert.setString(1, productName);
                    psInsert.setDouble(2, rsSeller.getDouble("price"));
                    psInsert.setString(3, rsSeller.getString("description"));
                    psInsert.setString(4, rsSeller.getString("image"));
                    psInsert.setInt(5, 1); // Default category
                    psInsert.setString(6, sellerId);
                    
                    int rowsInserted = psInsert.executeUpdate();
                    psInsert.close();
                    
                    if (rowsInserted > 0) {
                        // Remove from seller table
                        String deleteQuery = "DELETE FROM seller WHERE id = ?";
                        PreparedStatement psDelete = con.prepareStatement(deleteQuery);
                        psDelete.setString(1, sellerId);
                        psDelete.executeUpdate();
                        psDelete.close();
                        
                        success = true;
                        message = "Product accepted and moved to main store successfully";
                    } else {
                        message = "Failed to insert product into main store";
                    }
                } else {
                    message = "Seller not found";
                }
                
                rsSeller.close();
                psSeller.close();
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
