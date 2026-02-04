package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/AcceptProductToProductsServlet")
public class AcceptProductToProductsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        String sellerId = request.getParameter("sellerId");
        // This is now actually the PID from the seller table
        String pid = sellerId;
        
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
                Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                
                // Use PID directly as the product ID with more specific query to avoid duplicates
                String getSellerQuery = "SELECT * FROM seller WHERE pid = ? ORDER BY sid DESC LIMIT 1";
                PreparedStatement psSeller = con.prepareStatement(getSellerQuery);
                psSeller.setString(1, pid);
                ResultSet rsSeller = psSeller.executeQuery();
                
                debugInfo.append(" DEBUG: Executed query: ").append(getSellerQuery).append(" with PID='").append(pid).append("'");
                
                if (rsSeller.next()) {
                    
                    // Get the actual SID from the seller record
                    String actualSid = rsSeller.getString("sid");
                    debugInfo.append(" DEBUG: Found seller - SID: ").append(actualSid).append(", PID: ").append(pid);
                    
                    // Get data - separate variables for name and product_name columns
                    String productName = ""; // For product table 'product_name' column
                    String brandName = ""; // This will hold the brand from seller table
                    double price = 0.0;
                    String description = "";
                    String image = "";
                    String categoryId = "";
                    
                    // First, get the brand field from seller table for the product_brand field
                    try { brandName = rsSeller.getString("brand"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'brand' column failed:").append(e.getMessage());
                    }
                    if (brandName == null || brandName.trim().isEmpty()) {
                        try { brandName = rsSeller.getString("product_brand"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'product_brand' column failed:").append(e.getMessage());
                        }
                    }
                    if (brandName == null || brandName.trim().isEmpty()) {
                        brandName = "Unknown Brand"; // Fallback
                        debugInfo.append(" DEBUG: Using fallback brand:").append(brandName);
                    }
                    
                    // Get value for 'product_name' column - prioritize product_name (actual product name)
                    try { productName = rsSeller.getString("product_name"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'product_name' column failed:").append(e.getMessage());
                    }
                    if (productName == null || productName.trim().isEmpty()) {
                        try { productName = rsSeller.getString("product_brand"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'product_brand' column failed for product_name:").append(e.getMessage());
                        }
                    }
                    if (productName == null || productName.trim().isEmpty()) {
                        try { productName = rsSeller.getString("title"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'title' column failed for product_name:").append(e.getMessage());
                        }
                    }
                    if (productName == null || productName.trim().isEmpty()) {
                        try { productName = rsSeller.getString("product_title"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'product_title' column failed for product_name:").append(e.getMessage());
                        }
                    }
                    if (productName == null || productName.trim().isEmpty()) {
                        productName = "Product " + sellerId; // Use name as fallback for product_name
                        debugInfo.append(" DEBUG: Using fallback for product_name:").append(productName);
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
                    try { 
                        image = rsSeller.getString("image"); 
                        debugInfo.append(" DEBUG: Retrieved image='").append(image).append("'");
                        if (image == null || image.trim().isEmpty()) {
                            debugInfo.append(" DEBUG: Image is null or empty, checking for other image columns");
                            try { image = rsSeller.getString("images"); } catch (Exception e2) { 
                                debugInfo.append(" DEBUG: 'images' column also failed:").append(e2.getMessage());
                            }
                        }
                    } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'image' column failed:").append(e.getMessage());
                        image = "";
                    }
                    
                    // Get Category_id - try multiple possible column names
                    try { categoryId = rsSeller.getString("Category_id"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'Category_id' column failed:").append(e.getMessage());
                    }
                    if (categoryId == null || categoryId.trim().isEmpty()) {
                        try { categoryId = rsSeller.getString("category_id"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'category_id' column failed:").append(e.getMessage());
                        }
                    }
                    if (categoryId == null || categoryId.trim().isEmpty()) {
                        try { categoryId = rsSeller.getString("Category"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'Category' column failed:").append(e.getMessage());
                        }
                    }
                    if (categoryId == null || categoryId.trim().isEmpty()) {
                        categoryId = "1"; // Fallback
                        debugInfo.append(" DEBUG: Using fallback Category_id:").append(categoryId);
                    }
                    
                    debugInfo.append(" DEBUG: Final data to insert: ProductName='").append(productName).append("' Brand='").append(brandName).append("' Price:").append(price).append(" Description='").append(description).append("' Image='").append(image).append("' Category_id='").append(categoryId).append("'");
                    
                    // Generate a unique 4-digit product ID
                    String uniqueProductId = generateFourDigitId(con);
                    debugInfo.append(" DEBUG: Generated 4-digit product ID: ").append(uniqueProductId);
                    
                    String insertQuery = "INSERT INTO product (id, pid, brand, price, description, image, Category_id, product_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement psInsert = con.prepareStatement(insertQuery);
                    psInsert.setString(1, uniqueProductId); // Use 4-digit product ID
                    psInsert.setString(2, pid); // Insert PID as separate column
                    psInsert.setString(3, brandName); // Set brand to seller's brand field
                    psInsert.setDouble(4, price);
                    psInsert.setString(5, description);
                    psInsert.setString(6, image);
                    psInsert.setString(7, categoryId); // Use extracted Category_id instead of hardcoded 1
                    psInsert.setString(8, productName); // Use product name for 'product_name' column
                    
                    int rowsInserted = psInsert.executeUpdate();
                    debugInfo.append(" DEBUG: INSERT result:").append(rowsInserted).append(" rows affected");
                    psInsert.close();
                    
                    if (rowsInserted > 0) {
                        // Update seller status for the specific product only (not all products with same SID)
                        String updateStatusQuery = "UPDATE seller SET status = 'approved' WHERE sid = ? AND pid = ?";
                        PreparedStatement psUpdateStatus = con.prepareStatement(updateStatusQuery);
                        psUpdateStatus.setString(1, actualSid); // Use actual SID from database
                        psUpdateStatus.setString(2, pid); // Also use PID to target specific product
                        int updatedRows = psUpdateStatus.executeUpdate();
                        psUpdateStatus.close();
                        
                        debugInfo.append(" DEBUG: Updated seller status to 'approved' with SID:").append(actualSid).append(" and PID:").append(pid).append(" rows:").append(updatedRows);
                        
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
                    message = "Seller not found with PID: " + pid + " in seller table (using pid column)";
                    debugInfo.append(" DEBUG: No seller found with pid='").append(pid).append("'");
                }
                
                con.close();
            }
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            debugInfo.append(" DEBUG: Exception occurred:").append(e.getMessage());
            e.printStackTrace();
        }
        
        // Include debug info in the message for debugging
        if (!success && debugInfo.length() > 0) {
            message = message + " [" + debugInfo.toString() + "]";
        }
        
        // Create manual JSON response
        StringBuilder jsonResponse = new StringBuilder();
        jsonResponse.append("{\"success\":");
        jsonResponse.append(success);
        jsonResponse.append(",\"message\":\"");
        jsonResponse.append(message.replace("\"", "\\\""));
        jsonResponse.append("\"}");
        
        out.print(jsonResponse.toString());
        out.flush();
    }
    
    /**
     * Generates a unique 4-digit product ID
     * @param con Database connection
     * @return Unique 4-digit product ID as String
     * @throws SQLException If database error occurs
     */
    private String generateFourDigitId(Connection con) throws SQLException {
        PreparedStatement checkStmt = null;
        ResultSet rs = null;
        
        try {
            // Generate random 4-digit number (1000-9999)
            int randomId;
            String productId;
            boolean isUnique = false;
            
            // Keep trying until we find a unique ID
            do {
                randomId = 1000 + (int)(Math.random() * 9000); // Generate 4-digit number
                productId = String.valueOf(randomId);
                
                // Check if this ID already exists in the product table
                String checkQuery = "SELECT id FROM product WHERE id = ?";
                checkStmt = con.prepareStatement(checkQuery);
                checkStmt.setString(1, productId);
                rs = checkStmt.executeQuery();
                
                // If no record found, the ID is unique
                if (!rs.next()) {
                    isUnique = true;
                }
                
                // Clean up for next iteration
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                
            } while (!isUnique);
            
            return productId;
            
        } catch (SQLException e) {
            throw e;
        } finally {
            // Ensure resources are closed
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
            } catch (SQLException e) {
                // Log error but don't throw
                System.err.println("Error closing resources in generateFourDigitId: " + e.getMessage());
            }
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
