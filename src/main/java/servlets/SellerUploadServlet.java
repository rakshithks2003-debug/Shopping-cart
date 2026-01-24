package servlets;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;

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
        String category = request.getParameter("category");
        String categoryId = request.getParameter("categoryId");
        String price = request.getParameter("price");
        String description = request.getParameter("description");
        String imageFileName = "";

        // Generate seller ID if not provided
        if (sellerId == null || sellerId.trim().isEmpty()) {
            sellerId = "S" + (System.currentTimeMillis() % 1000000);
        }

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
                
                // Create table if not exists (optional safety)
                try (Statement stmt = con.createStatement()) {
                    String createTableSQL = "CREATE TABLE IF NOT EXISTS seller (" +
                        "sid VARCHAR(20) , " +
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
              

                // Handle file upload
                Part filePart = request.getPart("image");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                    imageFileName = sellerId + "_" + System.currentTimeMillis() + fileExtension;
                    
                    String uploadPath = getServletContext().getRealPath("") + "seller_images";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
                    File file = new File(uploadPath, imageFileName);
                    try (InputStream input = filePart.getInputStream()) {
                        Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }
                }

                // Insert new seller (10 columns, 10 placeholders)
                String sql = "INSERT INTO seller (sid, full_name, email_address, phone_number, product_brand, Category, Category_id, price, description, image) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                
                ps.setString(1, sellerId);
                ps.setString(2, name);
                ps.setString(3, email);
                ps.setString(4, phone);
                ps.setString(5, productBrand);
                ps.setString(6, category);
                ps.setString(7, categoryId);
                ps.setString(8, price);
                ps.setString(9, description);
                ps.setString(10, imageFileName);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Seller added successfully!";
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
