<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/html");
    response.setCharacterEncoding("UTF-8");
    
    String sellerId = request.getParameter("sellerId");
    
    // For debugging: Store debug info in a variable
    StringBuilder debugInfo = new StringBuilder();
    debugInfo.append("DEBUG: All received parameters: ");
    java.util.Enumeration<String> paramNames = request.getParameterNames();
    while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        String paramValue = request.getParameter(paramName);
        debugInfo.append(paramName).append("='").append(paramValue).append("' ");
    }
    debugInfo.append("Extracted sellerId='").append(sellerId).append("'");
    
    boolean success = false;
    String message = "Error processing request";
    
    try {
        if (sellerId == null || sellerId.trim().isEmpty()) {
            message = "Seller ID is required";
        } else {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            
            // Use the correct table and column names: seller table with sid column
            String getSellerQuery = "SELECT * FROM seller WHERE sid = ?";
            PreparedStatement psSeller = con.prepareStatement(getSellerQuery);
            psSeller.setString(1, sellerId);
            ResultSet rsSeller = psSeller.executeQuery();
            
            if (rsSeller.next()) {
                String usedColumn = "sid";
                
                // DEBUG: Print all available columns and their values
                debugInfo.append(" DEBUG: Available columns in seller table: ");
                ResultSetMetaData rsMeta = rsSeller.getMetaData();
                int columnCount = rsMeta.getColumnCount();
                
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = rsMeta.getColumnName(i);
                    String columnValue = rsSeller.getString(i);
                    debugInfo.append("Column").append(i).append(":").append(columnName).append("='").append(columnValue).append("' ");
                }
                
                // Get data - try multiple possible column names for product name
                String productName = "";
                double price = 0.0;
                String description = "";
                String image = "";
                
                // Try different possible column names for product name
                if (productName == null || productName.trim().isEmpty()) {
                    try { productName = rsSeller.getString("product_brand"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'product_brand' column failed:").append(e.getMessage());
                    }
                }
                if (productName == null || productName.trim().isEmpty()) {
                    try { productName = rsSeller.getString("name"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'name' column failed:").append(e.getMessage());
                    }
                }
                if (productName == null || productName.trim().isEmpty()) {
                    try { productName = rsSeller.getString("product_name"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'product_name' column failed:").append(e.getMessage());
                    }
                }
                if (productName == null || productName.trim().isEmpty()) {
                    try { productName = rsSeller.getString("title"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'title' column failed:").append(e.getMessage());
                    }
                }
                if (productName == null || productName.trim().isEmpty()) {
                    try { productName = rsSeller.getString("product_title"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'product_title' column failed:").append(e.getMessage());
                    }
                }
                if (productName == null || productName.trim().isEmpty()) {
                    productName = "Product " + sellerId; // Fallback
                    debugInfo.append(" DEBUG: Using fallback name:").append(productName);
                }
                
                // Get price
                try { price = rsSeller.getDouble("price"); } catch (Exception e) { 
                    debugInfo.append(" DEBUG: 'price' column failed:").append(e.getMessage());
                    price = 0.0;
                }
                
                // Get description
                try { description = rsSeller.getString("description"); } catch (Exception e) { 
                    debugInfo.append(" DEBUG: 'description' column failed:").append(e.getMessage());
                    description = "";
                }
                
                // Get image
                try { image = rsSeller.getString("image"); } catch (Exception e) { 
                    debugInfo.append(" DEBUG: 'image' column failed:").append(e.getMessage());
                    image = "";
                }
                
                debugInfo.append(" DEBUG: Final data to insert: Name='").append(productName).append("' Price:").append(price).append(" Description='").append(description).append("' Image='").append(image).append("'");
                
                // Move seller data to products table - using correct column names
                // First, get the next available ID for the product table
                String getMaxIdQuery = "SELECT COALESCE(MAX(id), 0) + 1 as nextId FROM product";
                PreparedStatement psMaxId = con.prepareStatement(getMaxIdQuery);
                ResultSet rsMaxId = psMaxId.executeQuery();
                
                int nextProductId = 1;
                if (rsMaxId.next()) {
                    nextProductId = rsMaxId.getInt("nextId");
                }
                rsMaxId.close();
                psMaxId.close();
                
                debugInfo.append(" DEBUG: Using product ID:").append(nextProductId);
                
                String insertQuery = "INSERT INTO product (id, name, price, description, image, category_id) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement psInsert = con.prepareStatement(insertQuery);
                psInsert.setInt(1, nextProductId);
                psInsert.setString(2, productName);
                psInsert.setDouble(3, price);
                psInsert.setString(4, description);
                psInsert.setString(5, image);
                psInsert.setInt(6, 1); // Default category
                
                int rowsInserted = psInsert.executeUpdate();
                debugInfo.append(" DEBUG: INSERT result:").append(rowsInserted).append(" rows affected");
                psInsert.close();
                
                if (rowsInserted > 0) {
                    // Remove from seller table using the correct sid column
                    String deleteQuery = "DELETE FROM seller WHERE sid = ?";
                    PreparedStatement psDelete = con.prepareStatement(deleteQuery);
                    psDelete.setString(1, sellerId);
                    psDelete.executeUpdate();
                    psDelete.close();
                    
                    success = true;
                    message = "Product approved successfully - now available in Showproducts.jsp";
                    debugInfo.append(" DEBUG: Product successfully moved to product table");
                } else {
                    message = "Failed to insert product into main store";
                    debugInfo.append(" DEBUG: INSERT failed - no rows affected");
                }
                
                rsSeller.close();
                psSeller.close();
            } else {
                message = "Seller not found with ID: " + sellerId + " in seller table (using sid column)";
                debugInfo.append(" DEBUG: No seller found with sid='").append(sellerId).append("'");
            }
            
            con.close();
        }
    } catch (Exception e) {
        message = "Database error: " + e.getMessage();
        debugInfo.append(" DEBUG: Exception occurred:").append(e.getMessage());
    }
    
    // Include debug info in the message for debugging
    if (!success && debugInfo.length() > 0) {
        message = message + " [" + debugInfo.toString() + "]";
    }
    
    // Return JSON response only
    out.println("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
%>
