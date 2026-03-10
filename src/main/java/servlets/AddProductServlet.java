package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 15,      // 15MB per image
    maxRequestSize = 1024 * 1024 * 200   // 200MB total (supports 13+ images)
)
@WebServlet("/AddProductServlet")
public class AddProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get user role and determine ID type
        String userRole = (String) request.getSession().getAttribute("userRole");
        String username = (String) request.getSession().getAttribute("username");
        String sellerId = null;
        
        // For seller role, fetch seller_id from users table
        if ("seller".equals(userRole)) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                String sellerQuery = "SELECT seller_id FROM users WHERE username = ?";
                PreparedStatement sellerStmt = con.prepareStatement(sellerQuery);
                sellerStmt.setString(1, username);
                ResultSet rs = sellerStmt.executeQuery();
                
                if (rs.next()) {
                    sellerId = rs.getString("seller_id");
                }
                rs.close();
                sellerStmt.close();
                con.close();
            } catch (Exception e) {
                // Error fetching seller_id
            }
        }
        
        // Get form parameters
        String productId = request.getParameter("productId");
        String productName = request.getParameter("productName");
        String brand = request.getParameter("brand");
        String category = request.getParameter("category");
        String price = request.getParameter("price");
        String description = request.getParameter("description");
        
        boolean success = false;
        String message = "Error adding product";
        
        try {
            // Validate required fields
            if (productId == null || productId.trim().isEmpty() ||
                productName == null || productName.trim().isEmpty() ||
                brand == null || brand.trim().isEmpty() ||
                category == null || category.trim().isEmpty() ||
                price == null || price.trim().isEmpty()) {
                
                message = "Please fill in all required fields";
            } else {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                
                // Ensure seller table has all required columns
                try {
                    java.sql.DatabaseMetaData meta = con.getMetaData();
                    java.sql.ResultSet columns = meta.getColumns(null, null, "seller", null);
                    
                    // Check for required columns and add if missing
                    java.util.Set<String> existingColumns = new java.util.HashSet<>();
                    while (columns.next()) {
                        existingColumns.add(columns.getString("COLUMN_NAME").toLowerCase());
                    }
                    columns.close();
                    
                    java.sql.Statement alterStmt = con.createStatement();
                    
                    if (!existingColumns.contains("status")) {
                        alterStmt.executeUpdate("ALTER TABLE seller ADD COLUMN status VARCHAR(20) DEFAULT 'pending'");
                    }
                    
                    if (!existingColumns.contains("submission_date")) {
                        alterStmt.executeUpdate("ALTER TABLE seller ADD COLUMN submission_date DATE");
                    }
                    
                    if (!existingColumns.contains("product_name")) {
                        alterStmt.executeUpdate("ALTER TABLE seller ADD COLUMN product_name VARCHAR(255)");
                    }
                    
                    alterStmt.close();
                } catch (Exception e) {
                    // Error checking/adding seller table columns
                }
                
                // Skip duplicate check - allow same Product IDs
                if (false) { // Always false to skip duplicate check
                    message = "Product ID already exists. Please use a different ID.";
                } else {
                    // Handle file uploads
                    List<String> imagePaths = new ArrayList<>();
                    try {
                        int imageCount = 0;
                        for (Part part : request.getParts()) {
                            if (part.getName().equals("productImage") && part.getSize() > 0) {
                                String fileName = part.getSubmittedFileName();
                                if (fileName != null && !fileName.isEmpty()) {
                                    // Validate file type
                                    if (!fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
                                        message = "Invalid file type: " + fileName + ". Only JPG, PNG, GIF, and WEBP images are allowed.";
                                        break;
                                    }
                                    
                                    // Create unique filename with counter
                                    String timestamp = String.valueOf(System.currentTimeMillis());
                                    String uniqueFileName = productId + "_" + timestamp + "_" + (imageCount + 1) + "_" + fileName;
                                    
                                    // Save to product_images directory
                                    String uploadPath = getServletContext().getRealPath("") + "product_images";
                                    java.io.File uploadDir = new java.io.File(uploadPath);
                                    if (!uploadDir.exists()) {
                                        uploadDir.mkdir();
                                    }
                                    
                                    java.io.File file = new java.io.File(uploadDir, uniqueFileName);
                                    part.write(file.getAbsolutePath());
                                    imagePaths.add(uniqueFileName);
                                    imageCount++;
                                }
                            }
                        }
                        
                        if (imagePaths.isEmpty()) {
                            message = "Please select at least one image.";
                        } else if (message != null && message.startsWith("Invalid file type")) {
                            // Image validation failed, don't proceed
                        } else {
                            
                            // Combine image paths into comma-separated string
                            String imagePathsStr = String.join(",", imagePaths);
                            if (imagePathsStr.isEmpty()) {
                                imagePathsStr = "default.jpg";
                            }
                            
                            // Insert product into Sproduct table
                            String insertQuery = "INSERT INTO Sproduct (id, pro_id, brand, price, description, image, Category, product_name, Seller_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            PreparedStatement insertStmt = con.prepareStatement(insertQuery);
                            
                            // Generate a unique 4-digit PIN for pro_id
                            String proId = generateFourDigitPin(con);
                            
                            insertStmt.setString(1, productId);           // id
                            insertStmt.setString(2, proId);               // pro_id (4-digit PIN)
                            insertStmt.setString(3, brand);               // brand
                            insertStmt.setDouble(4, Double.parseDouble(price)); // price
                            insertStmt.setString(5, description);         // description
                            insertStmt.setString(6, imagePathsStr);       // image
                            insertStmt.setString(7, category);            // Category
                            insertStmt.setString(8, productName);         // product_name
                            insertStmt.setString(9, sellerId);            // Seller_id from users table
                            
                            int rowsInserted = insertStmt.executeUpdate();
                            insertStmt.close();
                            
                            if (rowsInserted > 0) {
                                success = true;
                                message = "Product added successfully! Product ID: " + productId + ", PIN: " + proId + " (" + imageCount + " images uploaded - Available in Approved Products)";
                            } else {
                                message = "Failed to add product - no rows affected";
                            }
                        }
                    } catch (Exception e) {
                        message = "Error uploading files: " + e.getMessage();
                    }
                }
                
                con.close();
            }
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
        }
        
        // Redirect back to AddProduct.jsp with result
        try {
            if (success) {
                response.sendRedirect("AddProduct.jsp?success=" + 
                    java.net.URLEncoder.encode(message, "UTF-8"));
            } else {
                response.sendRedirect("AddProduct.jsp?error=" + 
                    java.net.URLEncoder.encode(message, "UTF-8"));
            }
        } catch (Exception e) {
            out.println("<html><body>");
            out.println("<h3>" + message + "</h3>");
            out.println("<p><a href='AddProduct.jsp'>Go Back</a></p>");
            out.println("</body></html>");
        }
    }
    
    /**
     * Generates a unique 4-digit PIN for pro_id field
     * @param con Database connection
     * @return Unique 4-digit PIN as String
     * @throws SQLException If database error occurs
     */
    private String generateFourDigitPin(Connection con) throws SQLException {
        PreparedStatement checkStmt = null;
        ResultSet rs = null;
        
        try {
            // Generate random 4-digit number (1000-9999)
            int randomPin;
            String pin;
            boolean isUnique = false;
            
            // Keep trying until we find a unique PIN
            do {
                randomPin = 1000 + (int)(Math.random() * 9000); // Generate 4-digit number
                pin = String.valueOf(randomPin);
                
                // Check if this PIN already exists in the Sproduct table
                String checkQuery = "SELECT pro_id FROM Sproduct WHERE pro_id = ?";
                checkStmt = con.prepareStatement(checkQuery);
                checkStmt.setString(1, pin);
                rs = checkStmt.executeQuery();
                
                // If no record found, the PIN is unique
                if (!rs.next()) {
                    isUnique = true;
                }
                
                // Clean up for next iteration
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                
            } while (!isUnique);
            
            return pin;
            
        } catch (SQLException e) {
            throw e;
        } finally {
            // Ensure resources are closed
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
            } catch (SQLException e) {
                // Log error but don't throw
            }
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
