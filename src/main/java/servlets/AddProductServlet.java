package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
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
                        System.out.println("Added status column to seller table");
                    }
                    
                    if (!existingColumns.contains("submission_date")) {
                        alterStmt.executeUpdate("ALTER TABLE seller ADD COLUMN submission_date DATE");
                        System.out.println("Added submission_date column to seller table");
                    }
                    
                    if (!existingColumns.contains("product_name")) {
                        alterStmt.executeUpdate("ALTER TABLE seller ADD COLUMN product_name VARCHAR(255)");
                        System.out.println("Added product_name column to seller table");
                    }
                    
                    alterStmt.close();
                } catch (Exception e) {
                    System.err.println("Error checking/adding seller table columns: " + e.getMessage());
                }
                
                // Skip duplicate check - allow same Product IDs
                if (false) { // Always false to skip duplicate check
                    message = "Product ID already exists. Please use a different ID.";
                } else {
                    // Handle file uploads
                    List<String> imagePaths = new ArrayList<>();
                    try {
                        for (Part part : request.getParts()) {
                            if (part.getName().equals("productImage") && part.getSize() > 0) {
                                String fileName = part.getSubmittedFileName();
                                if (fileName != null && !fileName.isEmpty()) {
                                    // Create unique filename
                                    String timestamp = String.valueOf(System.currentTimeMillis());
                                    String uniqueFileName = productId + "_" + timestamp + "_" + fileName;
                                    
                                    // Save to product_images directory
                                    String uploadPath = getServletContext().getRealPath("") + "product_images";
                                    java.io.File uploadDir = new java.io.File(uploadPath);
                                    if (!uploadDir.exists()) {
                                        uploadDir.mkdir();
                                    }
                                    
                                    String filePath = uploadPath + java.io.File.separator + uniqueFileName;
                                    part.write(filePath);
                                    imagePaths.add(uniqueFileName);
                                }
                            }
                        }
                    } catch (Exception e) {
                        System.err.println("Error uploading files: " + e.getMessage());
                    }
                    
                    // Combine image paths into comma-separated string
                    String imagePathsStr = String.join(",", imagePaths);
                    if (imagePathsStr.isEmpty()) {
                        imagePathsStr = "default.jpg";
                    }
                    
                    // Insert product into Sproduct table
                    String insertQuery = "INSERT INTO Sproduct (id, brand, price, description, image, Category, product_name) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement insertStmt = con.prepareStatement(insertQuery);
                    
                    insertStmt.setString(1, productId);           // id
                    insertStmt.setString(2, brand);               // brand
                    insertStmt.setDouble(3, Double.parseDouble(price)); // price
                    insertStmt.setString(4, description);         // description
                    insertStmt.setString(5, imagePathsStr);       // image
                    insertStmt.setString(6, category);            // Category
                    insertStmt.setString(7, productName);         // product_name
                    
                    int rowsInserted = insertStmt.executeUpdate();
                    insertStmt.close();
                    
                    System.out.println("DEBUG: Product insertion result: " + rowsInserted + " rows affected");
                    System.out.println("DEBUG: Inserted product with ID: " + productId + " into Sproduct table");
                    
                    if (rowsInserted > 0) {
                        success = true;
                        message = "Product added successfully! Product ID: " + productId + " (Available in Approved Products)";
                        System.out.println("DEBUG: Product successfully added to Sproduct table");
                    } else {
                        message = "Failed to add product - no rows affected";
                        System.err.println("DEBUG: INSERT failed - no rows affected");
                    }
                }
                
                con.close();
            }
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            e.printStackTrace();
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
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
