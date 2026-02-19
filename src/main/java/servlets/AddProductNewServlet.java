package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
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
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import products.Dbase;

@WebServlet("/AddProductNewServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 15,       // 15MB per image
    maxRequestSize = 1024 * 1024 * 200    // 200MB total
)
public class AddProductNewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null || 
            !(Boolean) session.getAttribute("isLoggedIn")) {
            response.sendRedirect("Login.html");
            return;
        }
        
        String userRole = (String) session.getAttribute("userRole");
        if (!"seller".equals(userRole)) {
            response.sendRedirect("Home.jsp");
            return;
        }
        
        // Get form parameters
        String productId = request.getParameter("productId");
        String productName = request.getParameter("productName");
        String brand = request.getParameter("brand");
        String category = request.getParameter("category");
        String price = request.getParameter("price");
        String discount = request.getParameter("discount");
        String description = request.getParameter("description");
        String shortDescription = request.getParameter("shortDescription");
        String stock = request.getParameter("stock");
        String weight = request.getParameter("weight");
        String tags = request.getParameter("tags");
        
        boolean success = false;
        String message = "Error adding product";
        String redirectUrl = "AddProductsNew.jsp";
        
        try {
            // Validate required fields
            if (productId == null || productId.trim().isEmpty() ||
                productName == null || productName.trim().isEmpty() ||
                brand == null || brand.trim().isEmpty() ||
                category == null || category.trim().isEmpty() ||
                price == null || price.trim().isEmpty() ||
                description == null || description.trim().isEmpty()) {
                
                message = "Please fill in all required fields";
            } else {
                // Use Dbase connection
                Dbase db = new Dbase();
                Connection con = db.initailizeDatabase();
                
                if (con == null) {
                    message = "Database connection failed";
                } else {
                    try {
                        // Check if product ID already exists
                        String checkQuery = "SELECT id FROM Sproduct WHERE id = ?";
                        PreparedStatement checkStmt = con.prepareStatement(checkQuery);
                        checkStmt.setString(1, productId);
                        ResultSet rs = checkStmt.executeQuery();
                        
                        if (rs.next()) {
                            message = "Product ID '" + productId + "' already exists. Please use a different ID.";
                        } else {
                            // Handle file uploads
                            List<String> imagePaths = new ArrayList<>();
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
                                        
                                        // Validate file size (15MB)
                                        if (part.getSize() > 15 * 1024 * 1024) {
                                            message = "File " + fileName + " is too large. Maximum size is 15MB.";
                                            break;
                                        }
                                        
                                        // Create unique filename
                                        String timestamp = String.valueOf(System.currentTimeMillis());
                                        String uniqueFileName = productId + "_" + timestamp + "_" + (imageCount + 1) + "_" + fileName;
                                        
                                        // Save to product_images directory
                                        String uploadPath = getServletContext().getRealPath("") + "product_images";
                                        java.io.File uploadDir = new java.io.File(uploadPath);
                                        if (!uploadDir.exists()) {
                                            uploadDir.mkdirs();
                                        }
                                        
                                        java.io.File file = new java.io.File(uploadDir, uniqueFileName);
                                        part.write(file.getAbsolutePath());
                                        imagePaths.add(uniqueFileName);
                                        imageCount++;
                                        
                                        System.out.println("Uploaded image: " + uniqueFileName);
                                    }
                                }
                            }
                            
                            if (imagePaths.isEmpty()) {
                                message = "Please select at least one image.";
                            } else if (message != null && message.startsWith("Invalid file type")) {
                                // Image validation failed
                            } else {
                                // Combine image paths
                                String imagePathsStr = String.join(",", imagePaths);
                                
                                // Generate unique 4-digit PIN
                                String proId = generateFourDigitPin(con);
                                
                                // Insert product into Sproduct table
                                String insertQuery = "INSERT INTO Sproduct (id, pro_id, brand, price, description, image, Category, product_name, discount, short_description, stock, weight, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                                PreparedStatement insertStmt = con.prepareStatement(insertQuery);
                                
                                insertStmt.setString(1, productId);           // id
                                insertStmt.setString(2, proId);               // pro_id
                                insertStmt.setString(3, brand);               // brand
                                insertStmt.setDouble(4, Double.parseDouble(price)); // price
                                insertStmt.setString(5, description);         // description
                                insertStmt.setString(6, imagePathsStr);       // image
                                insertStmt.setString(7, category);            // Category
                                insertStmt.setString(8, productName);         // product_name
                                insertStmt.setDouble(9, discount != null && !discount.isEmpty() ? Double.parseDouble(discount) : 0.0); // discount
                                insertStmt.setString(10, shortDescription != null ? shortDescription : ""); // short_description
                                insertStmt.setInt(11, stock != null && !stock.isEmpty() ? Integer.parseInt(stock) : 10); // stock
                                insertStmt.setDouble(12, weight != null && !weight.isEmpty() ? Double.parseDouble(weight) : 0.0); // weight
                                insertStmt.setString(13, tags != null ? tags : ""); // tags
                                
                                int rowsInserted = insertStmt.executeUpdate();
                                
                                if (rowsInserted > 0) {
                                    success = true;
                                    message = "Product added successfully! Product ID: " + productId + ", PIN: " + proId + " (" + imageCount + " images uploaded)";
                                } else {
                                    message = "Failed to add product";
                                }
                                
                                insertStmt.close();
                            }
                        }
                        
                        rs.close();
                        checkStmt.close();
                    } finally {
                        con.close();
                    }
                }
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Redirect with result
        try {
            if (success) {
                response.sendRedirect(redirectUrl + "?success=" + 
                    java.net.URLEncoder.encode(message, "UTF-8"));
            } else {
                response.sendRedirect(redirectUrl + "?error=" + 
                    java.net.URLEncoder.encode(message, "UTF-8"));
            }
        } catch (Exception e) {
            out.println("<html><body>");
            out.println("<h3>" + message + "</h3>");
            out.println("<p><a href='" + redirectUrl + "'>Go Back</a></p>");
            out.println("</body></html>");
        }
    }
    
    /**
     * Generates a unique 4-digit PIN for pro_id field
     */
    private String generateFourDigitPin(Connection con) throws SQLException {
        PreparedStatement checkStmt = null;
        ResultSet rs = null;
        
        try {
            int randomPin;
            String pin;
            boolean isUnique = false;
            
            do {
                randomPin = 1000 + (int)(Math.random() * 9000);
                pin = String.valueOf(randomPin);
                
                String checkQuery = "SELECT pro_id FROM Sproduct WHERE pro_id = ?";
                checkStmt = con.prepareStatement(checkQuery);
                checkStmt.setString(1, pin);
                rs = checkStmt.executeQuery();
                
                if (!rs.next()) {
                    isUnique = true;
                }
                
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                
            } while (!isUnique);
            
            return pin;
            
        } finally {
            if (rs != null) rs.close();
            if (checkStmt != null) checkStmt.close();
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}