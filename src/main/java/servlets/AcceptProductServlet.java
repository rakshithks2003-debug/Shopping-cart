package servlets;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/AcceptProductServlet")
public class AcceptProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("AcceptProductServlet: doPost method called");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String sellerId = request.getParameter("sellerId");
        String action = request.getParameter("action");
        
        System.out.println("AcceptProductServlet called with sellerId: " + sellerId + ", action: " + action);
        
        if (sellerId == null || action == null) {
            System.out.println("Missing parameters error");
            out.print("{\"success\": false, \"message\": \"Missing parameters\"}");
            return;
        }
        
        Connection conn = null;
        try {
            // Use direct connection for reliability
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            
            if (conn == null || conn.isClosed()) {
                System.out.println("Database connection failed");
                out.print("{\"success\": false, \"message\": \"Database connection failed\"}");
                return;
            }
            conn.setAutoCommit(false);
            
            if ("accept".equals(action)) {
                // First, check if the product table has proper structure
                try {
                    PreparedStatement checkTable = conn.prepareStatement("SHOW COLUMNS FROM product WHERE Field = 'id' AND Extra = 'auto_increment'");
                    ResultSet checkRs = checkTable.executeQuery();
                    
                    if (!checkRs.next()) {
                        System.out.println("AcceptProductServlet: Product table needs fixing - adding auto_increment");
                        // Fix the table structure
                        PreparedStatement fixTable = conn.prepareStatement(
                            "CREATE TABLE IF NOT EXISTS product_fixed AS SELECT * FROM product");
                        fixTable.executeUpdate();
                        
                        // Drop old table and rename the fixed one
                        PreparedStatement dropTable = conn.prepareStatement("DROP TABLE IF EXISTS product");
                        dropTable.executeUpdate();
                        
                        // Rename the fixed table
                        PreparedStatement renameTable = conn.prepareStatement("RENAME TABLE product_fixed TO product");
                        renameTable.executeUpdate();
                        
                        // Add proper auto_increment
                        PreparedStatement alterTable = conn.prepareStatement("ALTER TABLE product MODIFY id INT AUTO_INCREMENT PRIMARY KEY");
                        alterTable.executeUpdate();
                        
                        // Update NULL IDs
                        PreparedStatement updateIds = conn.prepareStatement(
                            "UPDATE product SET id = (@row_number := @row_number + 1) WHERE id IS NULL ORDER BY sid");
                        int updatedRows = updateIds.executeUpdate();
                        System.out.println("AcceptProductServlet: Updated " + updatedRows + " NULL IDs to sequential values");
                        
                        // Reset auto-increment
                        PreparedStatement resetAuto = conn.prepareStatement("ALTER TABLE product AUTO_INCREMENT = 1");
                        resetAuto.executeUpdate();
                        
                        checkRs.close();
                    } else {
                        checkRs.close();
                    }
                } catch (Exception e) {
                    System.out.println("AcceptProductServlet: Error checking table structure: " + e.getMessage());
                }
                
                // Get seller details first
                String getSellerSql = "SELECT * FROM seller WHERE sid = ?";
                PreparedStatement getSellerStmt = conn.prepareStatement(getSellerSql);
                getSellerStmt.setString(1, sellerId);
                ResultSet rs = getSellerStmt.executeQuery();
                
                if (rs.next()) {
                    String sellerName = rs.getString("full_name");
                    String productBrand = rs.getString("product_brand");
                    String description = rs.getString("description");
                    double price = rs.getDouble("price");
                    String category = rs.getString("Category"); // Use Category field
                    String categoryId = rs.getString("Category_id"); // Use Category_id field
                    String imageUrl = rs.getString("image");
                    
                    // Copy image from seller_images to product_images if it exists
                    String newImageUrl = imageUrl;
                    if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                        try {
                            String sellerImagePath = getServletContext().getRealPath("") + "seller_images" + File.separator + imageUrl;
                            String productImagePath = getServletContext().getRealPath("") + "product_images" + File.separator + imageUrl;
                            
                            File sellerImageFile = new File(sellerImagePath);
                            if (sellerImageFile.exists()) {
                                File productImageFile = new File(productImagePath);
                                // Ensure product_images directory exists
                                productImageFile.getParentFile().mkdirs();
                                // Copy the file
                                java.nio.file.Files.copy(sellerImageFile.toPath(), productImageFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                                System.out.println("AcceptProductServlet: Copied image from seller_images to product_images: " + imageUrl);
                            }
                        } catch (Exception e) {
                            System.out.println("AcceptProductServlet: Error copying image: " + e.getMessage());
                            // Continue with original image path if copy fails
                        }
                    }
                    
                    System.out.println("AcceptProductServlet: Processing seller: " + sellerName + ", Brand: " + productBrand + ", Category: " + category);
                    
                    // Check if product already exists for this seller
                    String checkProductSql = "SELECT id FROM product WHERE name = ? OR (category_id = ? AND name = ?)";
                    PreparedStatement checkProductStmt = conn.prepareStatement(checkProductSql);
                    checkProductStmt.setString(1, productBrand);
                    checkProductStmt.setString(2, categoryId);
                    checkProductStmt.setString(3, productBrand);
                    ResultSet checkProductRs = checkProductStmt.executeQuery();
                    
                    if (checkProductRs.next()) {
                        // Product already exists, update it
                        String updateProductSql = "UPDATE product SET name = ?, description = ?, price = ?, category_id = ?, image = ? WHERE id = ?";
                        PreparedStatement updateProductStmt = conn.prepareStatement(updateProductSql);
                        
                        updateProductStmt.setString(1, productBrand);
                        updateProductStmt.setString(2, description);
                        updateProductStmt.setDouble(3, price);
                        updateProductStmt.setString(4, categoryId);
                        updateProductStmt.setString(5, imageUrl);
                        updateProductStmt.setInt(6, checkProductRs.getInt("id"));
                        
                        int updatedRows = updateProductStmt.executeUpdate();
                        System.out.println("AcceptProductServlet: Updated existing product, rows affected: " + updatedRows);
                        
                        checkProductRs.close();
                        updateProductStmt.close();
                    } else {
                        // Insert new product
                        String insertProductSql = "INSERT INTO product (name, description, price, category_id, image) VALUES (?, ?, ?, ?, ?)";
                        PreparedStatement insertStmt = conn.prepareStatement(insertProductSql);
                        
                        insertStmt.setString(1, productBrand);
                        insertStmt.setString(2, description);
                        insertStmt.setDouble(3, price);
                        insertStmt.setString(4, categoryId);
                        insertStmt.setString(5, imageUrl);
                        
                        int rowsInserted = insertStmt.executeUpdate();
                        System.out.println("AcceptProductServlet: Inserted new product, rows affected: " + rowsInserted);
                        
                        insertStmt.close();
                    }
                    
                    checkProductStmt.close();
                    
                    // Commit transaction (no status update needed)
                    conn.commit();
                    System.out.println("AcceptProductServlet: Transaction committed successfully");
                    out.print("{\"success\": true, \"message\": \"Product '" + productBrand + "' added to Showproducts.jsp successfully!\"}");
                    
                } else {
                    conn.rollback();
                    System.out.println("AcceptProductServlet: Seller not found with ID: " + sellerId);
                    out.print("{\"success\": false, \"message\": \"Seller not found with ID: " + sellerId + "\"}");
                }
                
                rs.close();
                getSellerStmt.close();
                
            } else {
                System.out.println("Invalid action: " + action);
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            System.out.println("SQL Error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (Exception e) {
            System.out.println("General Error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            out.close();
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("AcceptProductServlet: doGet method called");
        response.getWriter().print("AcceptProductServlet is working - Use POST method for functionality");
    }
}
