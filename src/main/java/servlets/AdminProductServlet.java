package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB per image
    maxRequestSize = 1024 * 1024 * 50    // 50MB total
)
@WebServlet("/AdminProductServlet")
public class AdminProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get form parameters from Adminproduct.jsp
        String pid = request.getParameter("pid");
        String brand = request.getParameter("brand");
        String productName = request.getParameter("productName");
        String price = request.getParameter("price");
        String categoryId = request.getParameter("categoryId");
        String description = request.getParameter("description");
        
        boolean success = false;
        String message = "Error adding product";
        
        try {
            // Validate required fields
            if (pid == null || pid.trim().isEmpty() ||
                brand == null || brand.trim().isEmpty() ||
                productName == null || productName.trim().isEmpty() ||
                price == null || price.trim().isEmpty() ||
                categoryId == null || categoryId.trim().isEmpty()) {
                
                message = "Please fill in all required fields";
            } else {
                // Validate price
                try {
                    double priceValue = Double.parseDouble(price);
                    if (priceValue < 0) {
                        message = "Price cannot be negative";
                    } else {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                        
                        // Check if product ID already exists
                        String checkQuery = "SELECT id FROM product WHERE id = ?";
                        PreparedStatement checkStmt = con.prepareStatement(checkQuery);
                        checkStmt.setString(1, pid);
                        ResultSet rs = checkStmt.executeQuery();
                        
                        if (rs.next()) {
                            message = "Product ID already exists. Please use a different ID.";
                            rs.close();
                            checkStmt.close();
                        } else {
                            rs.close();
                            checkStmt.close();
                            
                            // Handle multiple image uploads
                            java.util.List<String> imagePaths = new java.util.ArrayList<>();
                            String imagePath = "default.jpg"; // Default image
                            
                            try {
                                System.out.println("DEBUG: Starting image upload process...");
                                
                                // Count image parts
                                int imageCount = 0;
                                for (Part part : request.getParts()) {
                                    if (part.getName().equals("productImage") && part.getSize() > 0) {
                                        imageCount++;
                                    }
                                }
                                
                                System.out.println("DEBUG: Found " + imageCount + " image parts");
                                
                                // Validate minimum 5 images
                                if (imageCount < 5) {
                                    message = "Minimum 5 images required. You uploaded " + imageCount + " images.";
                                    System.out.println("DEBUG: Not enough images: " + imageCount);
                                } else if (imageCount > 10) {
                                    message = "Maximum 10 images allowed. You uploaded " + imageCount + " images.";
                                    System.out.println("DEBUG: Too many images: " + imageCount);
                                } else {
                                    // Process each image
                                    int imageIndex = 0;
                                    for (Part part : request.getParts()) {
                                        if (part.getName().equals("productImage") && part.getSize() > 0) {
                                            String fileName = part.getSubmittedFileName();
                                            System.out.println("DEBUG: Processing image " + (imageIndex + 1) + ": " + fileName);
                                            
                                            if (fileName != null && !fileName.isEmpty()) {
                                                // Validate file type
                                                if (!fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
                                                    message = "Invalid file type: " + fileName + ". Only JPG, PNG, GIF, and WEBP images are allowed.";
                                                    System.out.println("DEBUG: Invalid file type detected: " + fileName);
                                                    break;
                                                }
                                                
                                                // Validate file size (5MB max per image)
                                                if (part.getSize() > 5 * 1024 * 1024) {
                                                    message = "File " + fileName + " is too large. Maximum size is 5MB per image.";
                                                    System.out.println("DEBUG: File too large: " + fileName + " (" + part.getSize() + " bytes)");
                                                    break;
                                                }
                                                
                                                // Create unique filename
                                                String timestamp = String.valueOf(System.currentTimeMillis());
                                                String uniqueFileName = pid + "_" + timestamp + "_" + (imageIndex + 1) + "_" + fileName;
                                                
                                                // Save to product_images directory
                                                String uploadPath = getServletContext().getRealPath("") + "product_images";
                                                java.io.File uploadDir = new java.io.File(uploadPath);
                                                System.out.println("DEBUG: Upload path: " + uploadPath);
                                                
                                                if (!uploadDir.exists()) {
                                                    boolean created = uploadDir.mkdir();
                                                    System.out.println("DEBUG: Directory created: " + created);
                                                }
                                                
                                                java.io.File file = new java.io.File(uploadDir, uniqueFileName);
                                                part.write(file.getAbsolutePath());
                                                imagePaths.add(uniqueFileName);
                                                
                                                System.out.println("DEBUG: Successfully uploaded image " + (imageIndex + 1) + ": " + uniqueFileName);
                                                imageIndex++;
                                            }
                                        }
                                    }
                                    
                                    // Combine image paths
                                    if (imagePaths.size() >= 5) {
                                        imagePath = String.join(",", imagePaths);
                                        System.out.println("DEBUG: Combined image paths: " + imagePath);
                                    } else if (message == null || message.equals("Error adding product")) {
                                        message = "Failed to process required number of images. Processed: " + imagePaths.size();
                                    }
                                }
                            } catch (Exception e) {
                                System.err.println("Error uploading images: " + e.getMessage());
                                e.printStackTrace();
                                message = "Error processing images: " + e.getMessage();
                            }
                            
                            // Insert product into product table
                            String insertQuery = "INSERT INTO product (id, product_name, brand, price, image, description, category_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
                            PreparedStatement insertStmt = con.prepareStatement(insertQuery);
                            
                            insertStmt.setString(1, pid);                    // id
                            insertStmt.setString(2, productName);            // product_name
                            insertStmt.setString(3, brand);                  // brand
                            insertStmt.setDouble(4, priceValue);             // price
                            insertStmt.setString(5, imagePath);              // image
                            insertStmt.setString(6, description != null ? description : ""); // description
                            insertStmt.setString(7, categoryId);             // category_id
                            
                            System.out.println("DEBUG: Inserting product with values:");
                            System.out.println("  ID: " + pid);
                            System.out.println("  Name: " + productName);
                            System.out.println("  Brand: " + brand);
                            System.out.println("  Price: " + priceValue);
                            System.out.println("  Image: " + imagePath);
                            System.out.println("  Category: " + categoryId);
                            int rowsInserted = insertStmt.executeUpdate();
                            insertStmt.close();
                            
                            System.out.println("DEBUG: Product insertion result: " + rowsInserted + " rows affected");
                            System.out.println("DEBUG: Inserted product with ID: " + pid + " into product table");
                            
                            if (rowsInserted > 0) {
                                success = true;
                                message = "Product added successfully! Product ID: " + pid + " - Available in Products";
                                System.out.println("DEBUG: Product successfully added to product table");
                            } else {
                                message = "Failed to add product - no rows affected";
                                System.err.println("DEBUG: INSERT failed - no rows affected");
                            }
                        }
                        
                        con.close();
                    }
                } catch (NumberFormatException e) {
                    message = "Invalid price format. Please enter a valid number.";
                }
            }
        } catch (ClassNotFoundException e) {
            message = "Database driver not found: " + e.getMessage();
            e.printStackTrace();
        } catch (SQLException e) {
            message = "Database error: " + e.getMessage();
            e.printStackTrace();
        } catch (Exception e) {
            message = "Unexpected error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Redirect back to Adminproduct.jsp with result
        try {
            if (success) {
                response.sendRedirect("Adminproduct.jsp?success=" + 
                    java.net.URLEncoder.encode(message, "UTF-8"));
            } else {
                response.sendRedirect("Adminproduct.jsp?error=" + 
                    java.net.URLEncoder.encode(message, "UTF-8"));
            }
        } catch (Exception e) {
            out.println("<html><body>");
            out.println("<h3>" + message + "</h3>");
            out.println("<p><a href='Adminproduct.jsp'>Go Back</a></p>");
            out.println("</body></html>");
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
