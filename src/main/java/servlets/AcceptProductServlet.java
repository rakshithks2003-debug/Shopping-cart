package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
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
                
                // First update seller status to approved
                String updateSellerSql = "UPDATE seller SET status = 'approved' WHERE sid = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSellerSql);
                updateStmt.setString(1, sellerId);
                int updatedRows = updateStmt.executeUpdate();
                System.out.println("Updated " + updatedRows + " seller rows");
                
                // Get seller details to insert into products table
                String getSellerSql = "SELECT * FROM seller WHERE sid = ?";
                PreparedStatement getSellerStmt = conn.prepareStatement(getSellerSql);
                getSellerStmt.setString(1, sellerId);
                ResultSet rs = getSellerStmt.executeQuery();
                
                if (rs.next()) {
                    // Insert into product table
                    String insertProductSql = "INSERT INTO product (name, description, price, category_id, image) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement insertStmt = conn.prepareStatement(insertProductSql);
                    
                    String productName = rs.getString("product_brand");
                    String description = rs.getString("description");
                    double price = rs.getDouble("price");
                    String category = rs.getString("sid"); // Use sid instead of Category
                    String imageUrl = rs.getString("image");
                    
                    System.out.println("Inserting product: " + productName + ", " + category + ", " + price);
                    
                    insertStmt.setString(1, productName);
                    insertStmt.setString(2, description);
                    insertStmt.setDouble(3, price);
                    insertStmt.setString(4, category);
                    insertStmt.setString(5, imageUrl);
                    
                    int rowsInserted = insertStmt.executeUpdate();
                    System.out.println("Inserted " + rowsInserted + " product rows");
                    
                    if (rowsInserted > 0) {
                        conn.commit();
                        System.out.println("Transaction committed successfully");
                        out.print("{\"success\": true, \"message\": \"Product accepted and added successfully!\"}");
                    } else {
                        conn.rollback();
                        System.out.println("Failed to insert product");
                        out.print("{\"success\": false, \"message\": \"Failed to add product\"}");
                    }
                } else {
                    conn.rollback();
                    System.out.println("Seller not found");
                    out.print("{\"success\": false, \"message\": \"Seller not found\"}");
                }
                
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
