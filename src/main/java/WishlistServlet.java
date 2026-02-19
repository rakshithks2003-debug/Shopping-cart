import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import products.Dbase;

@WebServlet("/WishlistServlet")
public class WishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Helper method to build JSON response manually
    private String buildJsonResponse(Map<String, Object> responseMap) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : responseMap.entrySet()) {
            if (!first) {
                json.append(",");
            }
            json.append("\"").append(entry.getKey()).append("\":");
            Object value = entry.getValue();
            if (value instanceof String) {
                json.append("\"").append(escapeJson((String) value)).append("\"");
            } else if (value instanceof Boolean) {
                json.append(value);
            } else if (value instanceof Number) {
                json.append(value);
            } else {
                json.append("\"").append(escapeJson(String.valueOf(value))).append("\"");
            }
            first = false;
        }
        json.append("}");
        return json.toString();
    }
    
    // Helper method to escape JSON strings
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                 .replace("\"", "\\\"")
                 .replace("\n", "\\n")
                 .replace("\r", "\\r")
                 .replace("\t", "\\t");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        // Check if user is logged in
        String username = (String) request.getSession().getAttribute("username");
        if (username == null) {
            responseMap.put("success", false);
            responseMap.put("message", "Please login to manage your wishlist");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Dbase db = new Dbase();
            con = db.initailizeDatabase();
            
            // Create wishlist table if it doesn't exist
            createWishlistTable(con);
            
            String action = request.getParameter("action");
            
            if (action == null) {
                // Handle JSON request for syncing local wishlist
                handleJsonRequest(request, response, con, username);
                return;
            }
            
            switch (action) {
                case "add":
                    handleAddToWishlist(request, response, con, username);
                    break;
                    
                case "addMultiple":
                    handleAddMultipleToWishlist(request, response, con, username);
                    break;
                    
                case "remove":
                    handleRemoveFromWishlist(request, response, con, username);
                    break;
                    
                case "clear":
                    handleClearWishlist(request, response, con, username);
                    break;
                    
                case "check":
                    handleCheckWishlist(request, response, con, username);
                    break;
                    
                default:
                    responseMap.put("success", false);
                    responseMap.put("message", "Invalid action");
                    out.print(buildJsonResponse(responseMap));
                    break;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            responseMap.put("success", false);
            responseMap.put("message", "Server error: " + e.getMessage());
            out.print(buildJsonResponse(responseMap));
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private void createWishlistTable(Connection con) throws SQLException {
        // Check if table exists first
        String checkTableSQL = "SHOW TABLES LIKE 'wishlist'";
        try (Statement stmt = con.createStatement()) {
            ResultSet rs = stmt.executeQuery(checkTableSQL);
            if (rs.next()) {
                // Table exists, no need to create
                System.out.println("✅ Wishlist table already exists");
                rs.close();
                return;
            }
            rs.close();
        } catch (Exception e) {
            System.out.println("⚠️ Could not check if table exists: " + e.getMessage());
        }
        
        // Create new simplified table only if it doesn't exist
        String createTableSQL = "CREATE TABLE IF NOT EXISTS wishlist (" +
            "id INT NOT NULL AUTO_INCREMENT, " +
            "user_id varchar(20) NOT NULL, " +
            "pro_name VARCHAR(255) NOT NULL, " +
            "pro_image VARCHAR(255) NOT NULL, " +
            "saved_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
            "PRIMARY KEY (id), " +
            "UNIQUE KEY unique_user_product (user_id, pro_name)" +
            ")";
        
        try (Statement stmt = con.createStatement()) {
            stmt.execute(createTableSQL);
            System.out.println("✅ Wishlist table created successfully");
        }
    }
    
    private void handleAddToWishlist(HttpServletRequest request, HttpServletResponse response, 
                                   Connection con, String username) throws IOException, SQLException {
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        String productId = request.getParameter("productId");
        System.out.println("🔍 DEBUG: Received productId: '" + productId + "' (type: " + (productId != null ? productId.getClass().getSimpleName() : "null") + ")");
        
        if (productId == null || productId.trim().isEmpty()) {
            responseMap.put("success", false);
            responseMap.put("message", "Product ID is required");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        // Get user_id from users table
        String userId = getUserId(con, username);
        if (userId == null) {
            responseMap.put("success", false);
            responseMap.put("message", "User not found");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        // Check if product exists and get details
        String[] productDetails = getProductDetails(con, productId);
        if (productDetails == null) {
            responseMap.put("success", false);
            responseMap.put("message", "Product not found");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        // Check if already in wishlist
        String checkSQL = "SELECT COUNT(*) FROM wishlist WHERE user_id = ? AND pro_name = ?";
        try (PreparedStatement checkPs = con.prepareStatement(checkSQL)) {
            checkPs.setString(1, userId); // user_id as String
            checkPs.setString(2, productDetails[0]); // pro_name
            ResultSet checkRs = checkPs.executeQuery();
            checkRs.next();
            int count = checkRs.getInt(1);
            checkRs.close();
            
            if (count > 0) {
                responseMap.put("success", false);
                responseMap.put("message", "Product already in wishlist");
                out.print(buildJsonResponse(responseMap));
                return;
            }
        }
        
        // Add to wishlist
        String insertSQL = "INSERT INTO wishlist (user_id, pro_name, pro_image) VALUES (?, ?, ?)";
        try (PreparedStatement insertPs = con.prepareStatement(insertSQL)) {
            insertPs.setString(1, userId); // user_id as String
            insertPs.setString(2, productDetails[0]); // pro_name
            
            // Debug image insertion
            System.out.println("🔍 DEBUG: Inserting image into wishlist: '" + productDetails[3] + "'");
            insertPs.setString(3, productDetails[3]); // pro_image
            
            int result = insertPs.executeUpdate();
            
            if (result > 0) {
                responseMap.put("success", true);
                responseMap.put("message", "Added to wishlist successfully");
            } else {
                responseMap.put("success", false);
                responseMap.put("message", "Failed to add to wishlist");
            }
        }
        
        out.print(buildJsonResponse(responseMap));
    }
    
    private void handleRemoveFromWishlist(HttpServletRequest request, HttpServletResponse response, 
                                         Connection con, String username) throws IOException, SQLException {
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        String productId = request.getParameter("productId");
        
        if (productId == null || productId.trim().isEmpty()) {
            responseMap.put("success", false);
            responseMap.put("message", "Product ID is required");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        String deleteSQL = "DELETE FROM wishlist WHERE username = ? AND product_id = ?";
        try (PreparedStatement deletePs = con.prepareStatement(deleteSQL)) {
            deletePs.setString(1, username);
            deletePs.setString(2, productId);
            int result = deletePs.executeUpdate();
            
            if (result > 0) {
                responseMap.put("success", true);
                responseMap.put("message", "Removed from wishlist successfully");
            } else {
                responseMap.put("success", false);
                responseMap.put("message", "Item not found in wishlist");
            }
        }
        
        out.print(buildJsonResponse(responseMap));
    }
    
    private void handleAddMultipleToWishlist(HttpServletRequest request, HttpServletResponse response, 
                                       Connection con, String username) throws IOException, SQLException {
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        String productsParam = request.getParameter("products");
        System.out.println("🔍 DEBUG: Received products parameter: '" + productsParam + "'");
        System.out.println("🔍 DEBUG: Products parameter length: " + (productsParam != null ? productsParam.length() : "null"));
        
        if (productsParam == null || productsParam.trim().isEmpty()) {
            responseMap.put("success", false);
            responseMap.put("message", "Products list is required");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        // Get user_id from users table
        String userId = getUserId(con, username);
        if (userId == null) {
            responseMap.put("success", false);
            responseMap.put("message", "User not found");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        // Split products by comma and trim
        String[] productNames = productsParam.split(",");
        System.out.println("🔍 DEBUG: Split into " + productNames.length + " products:");
        for (int i = 0; i < productNames.length; i++) {
            System.out.println("🔍 DEBUG: Product[" + i + "]: '" + productNames[i].trim() + "'");
        }
        
        int addedCount = 0;
        int duplicateCount = 0;
        int notFoundCount = 0;
        StringBuilder duplicates = new StringBuilder();
        StringBuilder notFound = new StringBuilder();
        
        // Use batch processing for better performance
        try {
            con.setAutoCommit(false); // Start transaction
            
            for (String productName : productNames) {
                productName = productName.trim();
                if (productName.isEmpty()) continue;
                
                System.out.println("🔍 DEBUG: Processing product: '" + productName + "'");
                
                // Check if product exists and get details
                String[] productDetails = getProductDetails(con, productName);
                if (productDetails == null) {
                    notFoundCount++;
                    if (notFound.length() > 0) notFound.append(", ");
                    notFound.append(productName);
                    continue;
                }
                
                // Check if already in wishlist
                String checkSQL = "SELECT COUNT(*) FROM wishlist WHERE user_id = ? AND pro_name = ?";
                try (PreparedStatement checkPs = con.prepareStatement(checkSQL)) {
                    checkPs.setString(1, userId);
                    checkPs.setString(2, productDetails[0]);
                    ResultSet checkRs = checkPs.executeQuery();
                    checkRs.next();
                    int count = checkRs.getInt(1);
                    checkRs.close();
                    
                    if (count > 0) {
                        duplicateCount++;
                        if (duplicates.length() > 0) duplicates.append(", ");
                        duplicates.append(productName);
                        continue;
                    }
                    
                    // Add to wishlist
                    String insertSQL = "INSERT INTO wishlist (user_id, pro_name, pro_image) VALUES (?, ?, ?)";
                    try (PreparedStatement insertPs = con.prepareStatement(insertSQL)) {
                        insertPs.setString(1, userId);
                        insertPs.setString(2, productDetails[0]);
                        insertPs.setString(3, productDetails[3]);
                        
                        int result = insertPs.executeUpdate();
                        if (result > 0) {
                            addedCount++;
                            System.out.println("✅ Added to wishlist: " + productDetails[0]);
                        }
                    }
                }
            }
            
            con.commit(); // Commit transaction
            System.out.println("✅ Transaction committed. Added: " + addedCount + ", Duplicates: " + duplicateCount + ", Not found: " + notFoundCount);
            
            // Verify actual database records
            String verifySQL = "SELECT COUNT(*) FROM wishlist WHERE user_id = ?";
            try (PreparedStatement verifyPs = con.prepareStatement(verifySQL)) {
                verifyPs.setString(1, userId);
                ResultSet verifyRs = verifyPs.executeQuery();
                verifyRs.next();
                int totalRecords = verifyRs.getInt(1);
                verifyRs.close();
                System.out.println("🔍 VERIFICATION: Total records in wishlist for user " + userId + ": " + totalRecords);
                
                // Get recent additions for debugging
                String recentSQL = "SELECT pro_name, saved_date FROM wishlist WHERE user_id = ? ORDER BY saved_date DESC LIMIT 5";
                try (PreparedStatement recentPs = con.prepareStatement(recentSQL)) {
                    recentPs.setString(1, userId);
                    ResultSet recentRs = recentPs.executeQuery();
                    System.out.println("🔍 RECENT ADDITIONS:");
                    while (recentRs.next()) {
                        System.out.println("  - " + recentRs.getString("pro_name") + " (added: " + recentRs.getTimestamp("saved_date") + ")");
                    }
                    recentRs.close();
                }
            }
            
        } catch (Exception e) {
            try {
                con.rollback(); // Rollback on error
                System.out.println("❌ Transaction rolled back: " + e.getMessage());
            } catch (Exception rollbackEx) {
                System.out.println("❌ Rollback failed: " + rollbackEx.getMessage());
            }
            throw e;
        } finally {
            try {
                con.setAutoCommit(true); // Reset auto-commit
            } catch (Exception e) {
                System.out.println("⚠️ Could not reset auto-commit: " + e.getMessage());
            }
        }
        
        // Build response message
        StringBuilder message = new StringBuilder();
        if (addedCount > 0) {
            message.append("Added ").append(addedCount).append(" product").append(addedCount > 1 ? "s" : "").append(" to wishlist");
        }
        
        if (duplicateCount > 0) {
            if (message.length() > 0) message.append(". ");
            message.append(duplicateCount).append(" already in wishlist: ").append(duplicates.toString());
        }
        
        if (notFoundCount > 0) {
            if (message.length() > 0) message.append(". ");
            message.append(notFoundCount).append(" not found: ").append(notFound.toString());
        }
        
        responseMap.put("success", addedCount > 0);
        responseMap.put("message", message.toString());
        responseMap.put("addedCount", addedCount);
        responseMap.put("duplicateCount", duplicateCount);
        responseMap.put("notFoundCount", notFoundCount);
        
        out.print(buildJsonResponse(responseMap));
    }
    
    private void handleClearWishlist(HttpServletRequest request, HttpServletResponse response, 
                                   Connection con, String username) throws IOException, SQLException {
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        String deleteSQL = "DELETE FROM wishlist WHERE username = ?";
        try (PreparedStatement deletePs = con.prepareStatement(deleteSQL)) {
            deletePs.setString(1, username);
            int result = deletePs.executeUpdate();
            
            responseMap.put("success", true);
            responseMap.put("message", "Wishlist cleared successfully");
            responseMap.put("deletedCount", result);
        }
        
        out.print(buildJsonResponse(responseMap));
    }
    
    private void handleCheckWishlist(HttpServletRequest request, HttpServletResponse response, 
                                   Connection con, String username) throws IOException, SQLException {
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        String productId = request.getParameter("productId");
        
        if (productId == null || productId.trim().isEmpty()) {
            responseMap.put("success", false);
            responseMap.put("message", "Product ID is required");
            out.print(buildJsonResponse(responseMap));
            return;
        }
        
        String checkSQL = "SELECT COUNT(*) FROM wishlist WHERE username = ? AND product_id = ?";
        try (PreparedStatement checkPs = con.prepareStatement(checkSQL)) {
            checkPs.setString(1, username);
            checkPs.setString(2, productId);
            ResultSet checkRs = checkPs.executeQuery();
            checkRs.next();
            int count = checkRs.getInt(1);
            checkRs.close();
            
            responseMap.put("success", true);
            responseMap.put("inWishlist", count > 0);
        }
        
        out.print(buildJsonResponse(responseMap));
    }
    
    private void handleJsonRequest(HttpServletRequest request, HttpServletResponse response, 
                                 Connection con, String username) throws IOException, SQLException {
        PrintWriter out = response.getWriter();
        Map<String, Object> responseMap = new HashMap<>();
        
        try {
            // Read JSON from request
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            
            // Simple manual JSON parsing for syncLocal action
            String jsonStr = sb.toString();
            String action = null;
            
            // Extract action from JSON
            if (jsonStr.contains("\"action\":")) {
                int actionStart = jsonStr.indexOf("\"action\":\"") + 10;
                int actionEnd = jsonStr.indexOf("\"", actionStart);
                if (actionEnd > actionStart) {
                    action = jsonStr.substring(actionStart, actionEnd);
                }
            }
            
            if ("syncLocal".equals(action)) {
                // For now, just return success for syncLocal
                // In a real implementation, you'd parse the items array
                responseMap.put("success", true);
                responseMap.put("message", "Sync completed");
            } else {
                responseMap.put("success", false);
                responseMap.put("message", "Invalid JSON action");
            }
            
        } catch (Exception e) {
            responseMap.put("success", false);
            responseMap.put("message", "Error processing JSON request: " + e.getMessage());
        }
        
        out.print(buildJsonResponse(responseMap));
    }
    
    private boolean productExists(Connection con, String productId) throws SQLException {
        String checkSQL = "SELECT COUNT(*) FROM product WHERE id = ?";
        try (PreparedStatement checkPs = con.prepareStatement(checkSQL)) {
            checkPs.setString(1, productId);
            ResultSet checkRs = checkPs.executeQuery();
            checkRs.next();
            int count = checkRs.getInt(1);
            checkRs.close();
            return count > 0;
        }
    }
    
    private String getUserId(Connection con, String username) throws SQLException {
        String sql = "SELECT user_id FROM users WHERE username = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String userId = rs.getString("user_id");
                rs.close();
                return userId;
            }
            rs.close();
        }
        return null; // Not found
    }
    
    private String[] getProductDetails(Connection con, String productId) throws SQLException {
        String sql = "SELECT product_name, price, description, image, brand FROM product WHERE id = ?";
        System.out.println("🔍 DEBUG: Executing SQL: " + sql);
        System.out.println("🔍 DEBUG: With productId: '" + productId + "'");
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String[] details = new String[5];
                details[0] = rs.getString("product_name"); // pro_name
                details[1] = rs.getString("price"); // pro_price
                details[2] = rs.getString("description"); // pro_description
                
                // Extract only the first image from potentially multiple images
                String imageField = rs.getString("image");
                if (imageField != null && !imageField.trim().isEmpty()) {
                    // Split by comma and take the first image if multiple exist
                    String[] images = imageField.split(",");
                    details[3] = images[0].trim(); // Take only the first image
                    System.out.println("🔍 DEBUG: Original image field: '" + imageField + "'");
                    System.out.println("🔍 DEBUG: Using first image: '" + details[3] + "'");
                } else {
                    details[3] = ""; // Empty if no image
                    System.out.println("🔍 DEBUG: No image found, using empty string");
                }
                
                details[4] = rs.getString("brand"); // Seller_id (using brand as fallback)
                
                // Debug image retrieval
                System.out.println("✅ DEBUG: Found product - Name: " + details[0]);
                System.out.println("✅ DEBUG: Product Price: " + details[1]);
                System.out.println("✅ DEBUG: Final Image for Wishlist: '" + details[3] + "'");
                System.out.println("✅ DEBUG: Product Brand: " + details[4]);
                
                rs.close();
                return details;
            } else {
                System.out.println("❌ DEBUG: No product found with id: " + productId);
            }
            rs.close();
        } catch (Exception e) {
            System.out.println("❌ DEBUG: SQL Error in getProductDetails: " + e.getMessage());
            e.printStackTrace();
        }
        return null; // Not found
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}