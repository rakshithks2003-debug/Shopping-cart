package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import products.Dbase;

/**
 * Servlet implementation for adding items to cart
 * Handles adding new items and updating quantities for existing items
 */
@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles POST requests for adding items to cart
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type to JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();

        // Check if user is logged in
        HttpSession sessionObj = request.getSession(false);
        if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
            !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
            out.print("{\"success\": false, \"message\": \"Please login to add items to cart\"}");
            return;
        }

        String username = (String) sessionObj.getAttribute("username");
        String productId = request.getParameter("productId");

        if (productId == null || productId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Product ID is required\"}");
            return;
        }

        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            // Check if product exists
            PreparedStatement checkPs = con.prepareStatement("SELECT id, name, price, image FROM product WHERE id = ?");
            checkPs.setString(1, productId);
            ResultSet rs = checkPs.executeQuery();
            
            if (!rs.next()) {
                out.print("{\"success\": false, \"message\": \"Product not found\"}");
                rs.close();
                checkPs.close();
                con.close();
                return;
            }
            
            String productName = rs.getString("name");
            double productPrice = rs.getDouble("price");
            String productImage = rs.getString("image");
            rs.close();
            checkPs.close();
            
            // Check if item already exists in cart
            PreparedStatement cartPs = con.prepareStatement("SELECT quantity FROM cart WHERE user_id = ? AND product_id = ?");
            cartPs.setString(1, username);
            cartPs.setString(2, productId);
            ResultSet cartRs = cartPs.executeQuery();
            
            if (cartRs.next()) {
                // Update quantity if item exists
                int currentQuantity = cartRs.getInt("quantity");
                PreparedStatement updatePs = con.prepareStatement("UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?");
                updatePs.setInt(1, currentQuantity + 1);
                updatePs.setString(2, username);
                updatePs.setString(3, productId);
                updatePs.executeUpdate();
                updatePs.close();
                
                out.print("{\"success\": true, \"message\": \"" + escapeJson(productName) + " quantity updated in cart\"}");
            } else {
                // Insert new item if doesn't exist
                PreparedStatement insertPs = con.prepareStatement("INSERT INTO cart (user_id, product_id, product_name, price, image, quantity) VALUES (?, ?, ?, ?, ?, 1)");
                insertPs.setString(1, username);
                insertPs.setString(2, productId);
                insertPs.setString(3, productName);
                insertPs.setDouble(4, productPrice);
                insertPs.setString(5, productImage);
                insertPs.executeUpdate();
                insertPs.close();
                
                out.print("{\"success\": true, \"message\": \"" + escapeJson(productName) + " added to cart\"}");
            }
            
            cartRs.close();
            cartPs.close();
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Database error: " + escapeJson(e.getMessage()) + "\"}");
        } finally {
            out.close();
        }
    }
    
    /**
     * Handles GET requests - redirects to POST or returns error
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"message\": \"GET method not supported for adding items to cart\"}");
        out.close();
    }
    
    /**
     * Utility method to escape JSON strings
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("/", "\\/")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
