package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
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
                
                // Debug: Check if PID column exists and show all sellers
                System.out.println("=== DEBUG: AcceptProductToProductsServlet - Checking PID column ===");
                System.out.println("Looking for PID: '" + pid + "'");
                
                // Check if PID column exists
                boolean pidColumnExists = false;
                try {
                    ResultSetMetaData tableMeta = con.createStatement().executeQuery("SELECT * FROM seller LIMIT 1").getMetaData();
                    for (int i = 1; i <= tableMeta.getColumnCount(); i++) {
                        if ("pid".equalsIgnoreCase(tableMeta.getColumnName(i))) {
                            pidColumnExists = true;
                            break;
                        }
                    }
                } catch (Exception e) {
                    System.out.println("Could not check table structure: " + e.getMessage());
                }
                
                System.out.println("PID column exists: " + pidColumnExists);
                
                Statement debugStmt = con.createStatement();
                ResultSet allSellers = debugStmt.executeQuery("SELECT sid, full_name" + (pidColumnExists ? ", pid" : "") + " FROM seller ORDER BY sid");
                System.out.println("All sellers in database:");
                boolean foundAny = false;
                while (allSellers.next()) {
                    foundAny = true;
                    String dbSid = allSellers.getString("sid");
                    String dbPid = pidColumnExists ? allSellers.getString("pid") : null;
                    String dbName = allSellers.getString("full_name");
                    boolean isMatch = (dbPid != null && dbPid.equals(pid));
                    System.out.println("  - SID: '" + dbSid + "', PID: '" + (dbPid != null ? dbPid : "NULL") + "', Name: " + dbName + (isMatch ? " <-- MATCH!" : ""));
                }
                allSellers.close();
                debugStmt.close();
                
                if (!foundAny) {
                    System.out.println("NO SELLERS FOUND IN DATABASE!");
                }
                
                System.out.println("=== END DEBUG ===");

                // Ensure status column exists in seller table
                try {
                    Statement alterStmt = con.createStatement();
                    alterStmt.executeUpdate("ALTER TABLE seller ADD COLUMN status VARCHAR(20) DEFAULT 'pending'");
                    System.out.println("Added status column to seller table");
                    alterStmt.close();
                } catch (Exception e) {
                    System.out.println("Status column already exists or couldn't be added: " + e.getMessage());
                }
                
                // Use PID directly as the product ID without complex searching
                String getSellerQuery = "SELECT * FROM seller WHERE pid = ?";
                PreparedStatement psSeller = con.prepareStatement(getSellerQuery);
                psSeller.setString(1, pid);
                ResultSet rsSeller = psSeller.executeQuery();
                
                if (rsSeller.next()) {
                    
                    // Get the actual SID from the seller record
                    String actualSid = rsSeller.getString("sid");
                    debugInfo.append(" DEBUG: Found seller - SID: ").append(actualSid).append(", PID: ").append(pid);
                    
                    // DEBUG: Print all available columns and their values
                    debugInfo.append(" DEBUG: Available columns in seller table: ");
                    ResultSetMetaData rsMeta = rsSeller.getMetaData();
                    int columnCount = rsMeta.getColumnCount();
                    
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = rsMeta.getColumnName(i);
                        String columnValue = rsSeller.getString(i);
                        debugInfo.append("Column").append(i).append(":").append(columnName).append("='").append(columnValue).append("' ");
                    }
                    
                    // Get data - separate variables for name and product_name columns
                    String name = ""; // For product table 'name' column
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
                    
                    // Get value for 'name' column - prioritize full_name (seller's name)
                    try { name = rsSeller.getString("full_name"); } catch (Exception e) { 
                        debugInfo.append(" DEBUG: 'full_name' column failed for name:").append(e.getMessage());
                    }
                    if (name == null || name.trim().isEmpty()) {
                        try { name = rsSeller.getString("name"); } catch (Exception e) { 
                            debugInfo.append(" DEBUG: 'name' column failed for name:").append(e.getMessage());
                        }
                    }
                    if (name == null || name.trim().isEmpty()) {
                        name = "Product " + sellerId; // Fallback for name
                        debugInfo.append(" DEBUG: Using fallback name:").append(name);
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
                        productName = name; // Use name as fallback for product_name
                        debugInfo.append(" DEBUG: Using name as fallback for product_name:").append(productName);
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
                    
                    debugInfo.append(" DEBUG: Final data to insert: Name='").append(name).append("' ProductName='").append(productName).append("' Brand='").append(brandName).append("' Price:").append(price).append(" Description='").append(description).append("' Image='").append(image).append("' Category_id='").append(categoryId).append("'");
                    
                    // Move seller data to products table - inserting SID as ID and PID as PID
                    debugInfo.append(" DEBUG: Inserting product with ID=").append(actualSid).append(" and PID=").append(pid);
                    
                    String insertQuery = "INSERT INTO product (id, pid, name, brand, price, description, image, Category_id, product_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement psInsert = con.prepareStatement(insertQuery);
                    psInsert.setString(1, actualSid); // Use seller's SID as product id
                    psInsert.setString(2, pid); // Insert PID as separate column
                    psInsert.setString(3, name); // Use seller's name for 'name' column
                    psInsert.setString(4, brandName); // Set brand to seller's brand field
                    psInsert.setDouble(5, price);
                    psInsert.setString(6, description);
                    psInsert.setString(7, image);
                    psInsert.setString(8, categoryId); // Use extracted Category_id instead of hardcoded 1
                    psInsert.setString(9, productName); // Use product name for 'product_name' column
                    
                    int rowsInserted = psInsert.executeUpdate();
                    debugInfo.append(" DEBUG: INSERT result:").append(rowsInserted).append(" rows affected");
                    psInsert.close();
                    
                    if (rowsInserted > 0) {
                        // Insert seller ID into approved_sellers table when approved
                        try {
                            String insertApprovedSellerQuery = "INSERT INTO approved_sellers (sid, approval_date) VALUES (?, CURRENT_TIMESTAMP)";
                            PreparedStatement psApprovedSeller = con.prepareStatement(insertApprovedSellerQuery);
                            psApprovedSeller.setString(1, actualSid); // Use actual SID from database
                            int approvedRowsInserted = psApprovedSeller.executeUpdate();
                            psApprovedSeller.close();
                            
                            debugInfo.append(" DEBUG: Approved seller record inserted with SID:").append(actualSid).append(" rows:").append(approvedRowsInserted);
                        } catch (Exception e) {
                            debugInfo.append(" DEBUG: Error inserting approved seller:").append(e.getMessage());
                            // Continue even if approved_sellers insertion fails
                        }
                        
                        // Update seller status instead of deleting the record
                        String updateStatusQuery = "UPDATE seller SET status = 'approved' WHERE sid = ?";
                        PreparedStatement psUpdateStatus = con.prepareStatement(updateStatusQuery);
                        psUpdateStatus.setString(1, actualSid); // Use actual SID from database
                        int updatedRows = psUpdateStatus.executeUpdate();
                        psUpdateStatus.close();
                        
                        debugInfo.append(" DEBUG: Updated seller status to 'approved' with SID:").append(actualSid).append(" rows:").append(updatedRows);
                        
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
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}