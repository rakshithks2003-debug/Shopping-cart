package servlets;

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

@WebServlet("/ApproveSproductServlet")
public class ApproveSproductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        boolean success = false;
        String message = "Error approving product";
        
        try {
            String productId = request.getParameter("productId");
            String productName = request.getParameter("productName");
            
            if (productId == null || productId.trim().isEmpty()) {
                message = "Product ID is required";
            } else {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                
                // Get product details from Sproduct table
                String getSproductQuery = "SELECT id, brand, price, description, image, Category, product_name FROM Sproduct WHERE id = ?";
                PreparedStatement psSproduct = con.prepareStatement(getSproductQuery);
                psSproduct.setString(1, productId);
                ResultSet rsSproduct = psSproduct.executeQuery();
                
                if (rsSproduct.next()) {
                    // Generate a unique 4-digit ID for the main product table
                    String uniqueProductId = generateFourDigitId(con);
                    
                    // Insert into main product table
                    String insertQuery = "INSERT INTO product (id, pid, brand, price, description, image, Category_id, product_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement psInsert = con.prepareStatement(insertQuery);
                    
                    psInsert.setString(1, uniqueProductId); // 4-digit ID
                    psInsert.setString(2, productId); // Original PID from Sproduct
                    psInsert.setString(3, rsSproduct.getString("brand"));
                    psInsert.setDouble(4, rsSproduct.getDouble("price"));
                    psInsert.setString(5, rsSproduct.getString("description"));
                    psInsert.setString(6, rsSproduct.getString("image"));
                    psInsert.setString(7, rsSproduct.getString("Category")); // Category_id
                    psInsert.setString(8, rsSproduct.getString("product_name"));
                    
                    int rowsInserted = psInsert.executeUpdate();
                    psInsert.close();
                    
                    if (rowsInserted > 0) {
                        // Remove the product from Sproduct table after successful approval
                        String deleteQuery = "DELETE FROM Sproduct WHERE id = ?";
                        PreparedStatement psDelete = con.prepareStatement(deleteQuery);
                        psDelete.setString(1, productId);
                        int deletedRows = psDelete.executeUpdate();
                        psDelete.close();
                        
                        success = true;
                        message = "Product approved successfully! Assigned ID: " + uniqueProductId;
                    } else {
                        message = "Failed to insert product into main store";
                    }
                } else {
                    message = "Product not found in Sproduct table";
                }
                
                rsSproduct.close();
                psSproduct.close();
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
