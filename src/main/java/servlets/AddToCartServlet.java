package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String productId = request.getParameter("productId");
        String userId = (String) request.getSession().getAttribute("username");
        
        boolean success = false;
        String message = "Error adding to cart";
        
        try {
            if (userId == null || userId.trim().isEmpty()) {
                message = "Please login to add items to cart";
            } else if (productId == null || productId.trim().isEmpty()) {
                message = "Product ID is required";
            } else {
                // Database connection
                Connection con = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/mscart", "root", "123456");
                    
                    // Get product details
                    String getProductQuery = "SELECT id, name, price, image FROM product WHERE id = ?";
                    PreparedStatement psProduct = con.prepareStatement(getProductQuery);
                    psProduct.setString(1, productId);
                    ResultSet rsProduct = psProduct.executeQuery();
                    
                    if (rsProduct.next()) {
                        String productName = rsProduct.getString("name");
                        double price = rsProduct.getDouble("price");
                        String image = rsProduct.getString("image");
                        
                        // Check if item already exists in cart
                        String checkCartQuery = "SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ?";
                        PreparedStatement psCheck = con.prepareStatement(checkCartQuery);
                        psCheck.setString(1, userId);
                        psCheck.setString(2, productId);
                        ResultSet rsCheck = psCheck.executeQuery();
                        
                        if (rsCheck.next()) {
                            // Update quantity if item already exists
                            int existingQuantity = rsCheck.getInt("quantity");
                            String updateCartQuery = "UPDATE cart SET quantity = ? WHERE id = ?";
                            PreparedStatement psUpdate = con.prepareStatement(updateCartQuery);
                            psUpdate.setInt(1, existingQuantity + 1);
                            psUpdate.setInt(2, rsCheck.getInt("id"));
                            psUpdate.executeUpdate();
                            psUpdate.close();
                            
                            message = "Item quantity updated in cart";
                        } else {
                            // Add new item to cart
                            String insertCartQuery = "INSERT INTO cart (user_id, product_id, product_name, price, image, quantity) VALUES (?, ?, ?, ?, ?, 1)";
                            PreparedStatement psInsert = con.prepareStatement(insertCartQuery);
                            psInsert.setString(1, userId);
                            psInsert.setString(2, productId);
                            psInsert.setString(3, productName);
                            psInsert.setDouble(4, price);
                            psInsert.setString(5, image);
                            psInsert.executeUpdate();
                            psInsert.close();
                            
                            message = "Item added to cart successfully";
                        }
                        
                        rsCheck.close();
                        success = true;
                    } else {
                        message = "Product not found";
                    }
                    
                    rsProduct.close();
                    psProduct.close();
                    con.close();
                    
                } catch (Exception e) {
                    message = "Database error: " + e.getMessage();
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            message = "System error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Return JSON response
        out.print("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
        out.flush();
    }
}
