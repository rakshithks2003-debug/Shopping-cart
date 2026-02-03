package servlets;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import products.Dbase;

@SuppressWarnings("serial")
@WebServlet("/SelleruploadServlet")
@MultipartConfig
public class SellerUploadServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null || 
            !(Boolean) session.getAttribute("isLoggedIn")) {
            response.sendRedirect("Login.html");
            return;
        }

        // Check if user has admin role
        String userRole = (String) session.getAttribute("userRole");
        if (!"admin".equals(userRole)) {
            response.sendRedirect("users.html");
            return;
        }

        String username = (String) session.getAttribute("username");
        String message = "";
        String messageType = "";

        // Get form parameters
        String sellerId = request.getParameter("sellerId");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String productBrand = request.getParameter("productBrand");
        String productName = request.getParameter("productName");
        String category = request.getParameter("category");
        String categoryId = request.getParameter("categoryId");
        String price = request.getParameter("price");
        String description = request.getParameter("description");
        String imageFileNames = ""; // Will store comma-separated image names

        // Generate seller ID if not provided
        if (sellerId == null || sellerId.trim().isEmpty()) {
            sellerId = "S" + (System.currentTimeMillis() % 1000000);
        }
        
        // Generate 4-digit PID automatically
        String pid = String.format("%04d", (int)(Math.random() * 10000));
        System.out.println("Generated PID: " + pid + " for seller: " + sellerId);

        // Validate required fields
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            productBrand == null || productBrand.trim().isEmpty() ||
            category == null || category.trim().isEmpty() ||
            categoryId == null || categoryId.trim().isEmpty() ||
            price == null || price.trim().isEmpty() ||
            description == null || description.trim().isEmpty()) {
            
            message = "Please fill in all required fields.";
            messageType = "error";
        } else if (phone.length() > 10) {
            message = "Phone number too long! Maximum 10 characters allowed.";
            messageType = "error";
        } else {
            try {
                Dbase db = new Dbase();
                Connection con = db.initailizeDatabase();
                
                // Debug: Check existing table structure and data
                try (Statement stmt = con.createStatement()) {
                    // Show all existing sellers before insertion
                    System.out.println("=== DEBUG: Existing sellers in database ===");
                    ResultSet existingSellers = stmt.executeQuery("SELECT sid, full_name FROM seller ORDER BY sid");
                    while (existingSellers.next()) {
                        System.out.println("Found seller - SID: " + existingSellers.getString("sid") + ", Name: " + existingSellers.getString("full_name"));
                    }
                    existingSellers.close();
                    System.out.println("=== END DEBUG: Existing sellers ===");
                    
                    // Check table structure
                    try {
                        ResultSet tableInfo = stmt.executeQuery("DESCRIBE seller");
                        System.out.println("=== TABLE STRUCTURE ===");
                        while (tableInfo.next()) {
                            System.out.println("Column: " + tableInfo.getString("Field") + 
                                             ", Type: " + tableInfo.getString("Type") + 
                                             ", Key: " + tableInfo.getString("Key") + 
                                             ", Extra: " + tableInfo.getString("Extra"));
                        }
                        tableInfo.close();
                        System.out.println("=== END TABLE STRUCTURE ===");
                    } catch (Exception e) {
                        System.out.println("Could not get table structure: " + e.getMessage());
                    }
                    
                    String createTableSQL = "CREATE TABLE IF NOT EXISTS seller (" +
                        "sid VARCHAR(20), " +
                        "pid VARCHAR(10), " +
                        "full_name VARCHAR(100) NOT NULL, " +
                        "email_address VARCHAR(100) NOT NULL, " +
                        "phone_number VARCHAR(20) NOT NULL, " +
                        "product_brand VARCHAR(100) NOT NULL, " +
                        "Category VARCHAR(50) NOT NULL, " +
                        "Category_id VARCHAR(20) NOT NULL, " +
                        "price DECIMAL(10,2) NOT NULL, " +
                        "description TEXT, " +
                        "image VARCHAR(255)" +
                        ")";
                    stmt.executeUpdate(createTableSQL);
                }
                
                // Create table if not exists (optional safety)
              

                // Handle multiple file uploads
                Collection<Part> fileParts = request.getParts();
                List<String> uploadedImages = new ArrayList<>();
                String uploadPath = getServletContext().getRealPath("") + "seller_images";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                
                System.out.println("=== DEBUG: Multiple Image Upload ===");
                System.out.println("Upload path: " + uploadPath);
                System.out.println("Total parts received: " + fileParts.size());
                
                int imageCount = 0;
                for (Part filePart : fileParts) {
                    System.out.println("Part name: " + filePart.getName() + ", size: " + filePart.getSize());
                    if (filePart.getName().equals("images") && filePart.getSize() > 0) {
                        String fileName = filePart.getSubmittedFileName();
                        System.out.println("Processing file: " + fileName);
                        if (fileName != null && !fileName.trim().isEmpty()) {
                            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                            String imageFileName = sellerId + "_" + System.currentTimeMillis() + "_" + imageCount + fileExtension;
                            
                            File file = new File(uploadPath, imageFileName);
                            try (InputStream input = filePart.getInputStream()) {
                                Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                                System.out.println("Saved file: " + imageFileName);
                            }
                            
                            uploadedImages.add(imageFileName);
                            imageCount++;
                        }
                    }
                }
                
                // Convert list to comma-separated string
                imageFileNames = String.join(",", uploadedImages);
                System.out.println("Final image string: " + imageFileNames);
                System.out.println("=== END DEBUG ===");

                // Try to insert with duplicate sid handling
                String sql = "INSERT INTO seller (sid, pid, full_name, email_address, phone_number, product_brand, Category, Category_id, price, description, image,product_name) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                
                ps.setString(1, sellerId);
                ps.setString(2, pid);
                ps.setString(3, name);
                ps.setString(4, email);
                ps.setString(5, phone);
                ps.setString(6, productBrand);
                ps.setString(7, category);
                ps.setString(8, categoryId);
                ps.setString(9, price);
                ps.setString(10, description);
                ps.setString(11, imageFileNames);
                ps.setString(12, productName);
                
                int result = 0;
                try {
                    result = ps.executeUpdate();
                    System.out.println("Successfully inserted seller with sid: " + sellerId);
                    
                    // Verify the insertion by querying the database
                    PreparedStatement verifyPs = con.prepareStatement("SELECT sid FROM seller WHERE sid = ?");
                    verifyPs.setString(1, sellerId);
                    ResultSet verifyRs = verifyPs.executeQuery();
                    if (verifyRs.next()) {
                        System.out.println("VERIFICATION: Seller with sid '" + sellerId + "' found in database after insertion");
                    } else {
                        System.out.println("VERIFICATION ERROR: Seller with sid '" + sellerId + "' NOT found in database after insertion");
                    }
                    verifyRs.close();
                    verifyPs.close();
                    
                } catch (Exception e) {
                    // If insertion fails due to primary key constraint, try to update existing record
                    System.out.println("Insertion failed, trying to handle duplicate sid: " + e.getMessage());
                    
                    // Try to create a new unique sid by adding timestamp
                    String newSellerId = sellerId + "_" + System.currentTimeMillis();
                    ps.setString(1, newSellerId);
                    ps.setString(12, productName); // Also set product_name for duplicate case
                    result = ps.executeUpdate();
                    System.out.println("Successfully inserted seller with new sid: " + newSellerId);
                    
                    // Verify the new insertion
                    PreparedStatement verifyPs = con.prepareStatement("SELECT sid FROM seller WHERE sid = ?");
                    verifyPs.setString(1, newSellerId);
                    ResultSet verifyRs = verifyPs.executeQuery();
                    if (verifyRs.next()) {
                        System.out.println("VERIFICATION: Seller with new sid '" + newSellerId + "' found in database after insertion");
                    } else {
                        System.out.println("VERIFICATION ERROR: Seller with new sid '" + newSellerId + "' NOT found in database after insertion");
                    }
                    verifyRs.close();
                    verifyPs.close();
                    
                    // Update the sellerId variable for response message
                    sellerId = newSellerId;
                }
                if (result > 0) {
                    if (uploadedImages.size() > 1) {
                        message = "Seller added successfully with PID: " + pid + " and " + uploadedImages.size() + " images!";
                    } else if (uploadedImages.size() == 1) {
                        message = "Seller added successfully with PID: " + pid + " and 1 image!";
                    } else {
                        message = "Seller added successfully with PID: " + pid + " (no images uploaded)!";
                    }
                    messageType = "success";
                } else {
                    message = "Failed to add seller.";
                    messageType = "error";
                }
                ps.close();
                con.close();
                
            } catch (Exception e) {
                message = "Database error: " + e.getMessage();
                messageType = "error";
                e.printStackTrace();
            }
        }

        // Set request attributes for JSP
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.setAttribute("username", username);
        request.setAttribute("userRole", userRole);

        // Forward back to JSP
        request.getRequestDispatcher("Sellerupload.jsp").forward(request, response);
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to JSP for GET requests
        request.getRequestDispatcher("Sellerupload.jsp").forward(request, response);
    }
}
