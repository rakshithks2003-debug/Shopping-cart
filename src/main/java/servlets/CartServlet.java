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
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import products.Dbase;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String action = request.getParameter("action");
            String username = (String) request.getSession().getAttribute("username");
            
            if (username == null) {
                out.print("{\"success\": false, \"message\": \"User not logged in\"}");
                return;
            }
            
            // Initialize database connection
            Dbase db = new Dbase();
            Connection con = null;
            
            try {
                con = db.initailizeDatabase();
            } catch (Exception e) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = java.sql.DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/mscart", "root", "123456");
                } catch (ClassNotFoundException | SQLException ex) {
                    out.print("{\"success\": false, \"message\": \"Database connection failed\"}");
                    return;
                }
            }
            
            if (con == null || con.isClosed()) {
                out.print("{\"success\": false, \"message\": \"Database connection failed\"}");
                return;
            }
            
            if ("remove".equals(action)) {
                String productId = request.getParameter("productId");
                if (productId != null && !productId.trim().isEmpty()) {
                    String deleteSQL = "DELETE FROM cart WHERE user_id = ? AND product_id = ?";
                    PreparedStatement deleteStmt = con.prepareStatement(deleteSQL);
                    deleteStmt.setString(1, username);
                    deleteStmt.setString(2, productId);
                    int rowsDeleted = deleteStmt.executeUpdate();
                    deleteStmt.close();
                    
                    if (rowsDeleted > 0) {
                        out.print("{\"success\": true, \"message\": \"Item removed from cart\"}");
                    } else {
                        out.print("{\"success\": false, \"message\": \"Item not found in cart\"}");
                    }
                } else {
                    out.print("{\"success\": false, \"message\": \"Product ID is required\"}");
                }
            } else if ("addToCart".equals(action)) {
                String productId = request.getParameter("productId");
                if (productId != null && !productId.trim().isEmpty()) {
                    // Get product details with seller_id
                    String productSQL = "SELECT product_name, price, image, seller_id FROM product WHERE id = ?";
                    PreparedStatement productStmt = con.prepareStatement(productSQL);
                    productStmt.setString(1, productId);
                    ResultSet productRs = productStmt.executeQuery();
                    
                    if (!productRs.next()) {
                        out.print("{\"success\": false, \"message\": \"Product not found\"}");
                        productRs.close();
                        productStmt.close();
                        return;
                    }
                    
                    String productName = productRs.getString("product_name");
                    double price = productRs.getDouble("price");
                    String image = productRs.getString("image");
                    String sellerId = productRs.getString("seller_id");
                    
                    productRs.close();
                    productStmt.close();
                    
                    // Check if item already exists in cart
                    String checkSQL = "SELECT quantity FROM cart WHERE user_id = ? AND product_id = ?";
                    PreparedStatement checkStmt = con.prepareStatement(checkSQL);
                    checkStmt.setString(1, username);
                    checkStmt.setString(2, productId);
                    ResultSet checkRs = checkStmt.executeQuery();
                    
                    if (checkRs.next()) {
                        // Update quantity if item exists
                        int currentQty = checkRs.getInt("quantity");
                        String updateSQL = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
                        PreparedStatement updateStmt = con.prepareStatement(updateSQL);
                        updateStmt.setInt(1, currentQty + 1);
                        updateStmt.setString(2, username);
                        updateStmt.setString(3, productId);
                        updateStmt.executeUpdate();
                        updateStmt.close();
                    } else {
                        // Insert new item with seller_id
                        String insertSQL = "INSERT INTO cart (user_id, product_id, product_name, price, quantity, image, seller_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
                        PreparedStatement insertStmt = con.prepareStatement(insertSQL);
                        insertStmt.setString(1, username);
                        insertStmt.setString(2, productId);
                        insertStmt.setString(3, productName);
                        insertStmt.setDouble(4, price);
                        insertStmt.setInt(5, 1);
                        insertStmt.setString(6, image);
                        insertStmt.setString(7, sellerId);
                        insertStmt.executeUpdate();
                        insertStmt.close();
                    }
                    
                    checkRs.close();
                    checkStmt.close();
                    
                    out.print("{\"success\": true, \"message\": \"Product added to cart successfully!\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Product ID is required\"}");
                }
            } else if ("update".equals(action)) {
                String productId = request.getParameter("productId");
                String quantityStr = request.getParameter("quantity");
                
                if (productId != null && !productId.trim().isEmpty() && quantityStr != null && !quantityStr.trim().isEmpty()) {
                    int quantity = Integer.parseInt(quantityStr);
                    
                    if (quantity <= 0) {
                        // Remove item if quantity is 0 or less
                        String deleteSQL = "DELETE FROM cart WHERE user_id = ? AND product_id = ?";
                        PreparedStatement deleteStmt = con.prepareStatement(deleteSQL);
                        deleteStmt.setString(1, username);
                        deleteStmt.setString(2, productId);
                        deleteStmt.executeUpdate();
                        deleteStmt.close();
                        out.print("{\"success\": true, \"message\": \"Item removed from cart\"}");
                    } else {
                        // Update quantity
                        String updateSQL = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
                        PreparedStatement updateStmt = con.prepareStatement(updateSQL);
                        updateStmt.setInt(1, quantity);
                        updateStmt.setString(2, username);
                        updateStmt.setString(3, productId);
                        int rowsUpdated = updateStmt.executeUpdate();
                        updateStmt.close();
                        
                        if (rowsUpdated > 0) {
                            out.print("{\"success\": true, \"message\": \"Cart updated successfully\"}");
                        } else {
                            out.print("{\"success\": false, \"message\": \"Item not found in cart\"}");
                        }
                    }
                } else {
                    out.print("{\"success\": false, \"message\": \"Product ID and quantity are required\"}");
                }
            } else if ("clear".equals(action)) {
                String deleteSQL = "DELETE FROM cart WHERE user_id = ?";
                PreparedStatement deleteStmt = con.prepareStatement(deleteSQL);
                deleteStmt.setString(1, username);
                int rowsDeleted = deleteStmt.executeUpdate();
                deleteStmt.close();
                out.print("{\"success\": true, \"message\": \"Cart cleared successfully\"}");
            } else if ("singleCheckout".equals(action)) {
                String productId = request.getParameter("productId");
                String quantityStr = request.getParameter("quantity");
                
                if (productId != null && !productId.trim().isEmpty() && quantityStr != null && !quantityStr.trim().isEmpty()) {
                    try {
                        int quantity = Integer.parseInt(quantityStr);
                        
                        // Get product details for checkout
                        String productSQL = "SELECT product_name, price, image FROM product WHERE id = ?";
                        PreparedStatement productStmt = con.prepareStatement(productSQL);
                        productStmt.setString(1, productId);
                        ResultSet productRs = productStmt.executeQuery();
                        
                        if (productRs.next()) {
                            String productName = productRs.getString("product_name");
                            double price = productRs.getDouble("price");
                            String image = productRs.getString("image");
                            
                            productRs.close();
                            productStmt.close();
                            
                            // Store single product data in session for payment
                            request.getSession().setAttribute("singleCheckout", true);
                            request.getSession().setAttribute("checkoutProductId", productId);
                            request.getSession().setAttribute("checkoutProductName", productName);
                            request.getSession().setAttribute("checkoutPrice", price);
                            request.getSession().setAttribute("checkoutQuantity", quantity);
                            request.getSession().setAttribute("checkoutImage", image);
                            
                            out.print("{\"success\": true, \"message\": \"Preparing checkout for single product\"}");
                        } else {
                            out.print("{\"success\": false, \"message\": \"Product not found\"}");
                        }
                    } catch (NumberFormatException e) {
                        out.print("{\"success\": false, \"message\": \"Invalid quantity\"}");
                    } catch (Exception e) {
                        out.print("{\"success\": false, \"message\": \"Error preparing checkout: " + e.getMessage() + "\"}");
                    }
                } else {
                    out.print("{\"success\": false, \"message\": \"Missing product information\"}");
                }
            } else if ("checkoutWithCartData".equals(action)) {
                try {
                    // Get current cart items before clearing
                    String getCartSql = "SELECT c.product_id, c.quantity, p.product_name, p.brand, p.price, p.image, p.seller_id " +
                                      "FROM cart c JOIN product p ON c.product_id = p.id " +
                                      "WHERE c.user_id = ?";
                    PreparedStatement getCartStmt = con.prepareStatement(getCartSql);
                    getCartStmt.setString(1, username);
                    ResultSet cartRs = getCartStmt.executeQuery();
                    
                    // Store cart data in session for Payment.jsp
                    java.util.List<java.util.Map<String, Object>> cartData = new java.util.ArrayList<>();
                    while (cartRs.next()) {
                        java.util.Map<String, Object> item = new java.util.HashMap<>();
                        item.put("productId", cartRs.getString("product_id"));
                        item.put("productName", cartRs.getString("product_name"));
                        item.put("productBrand", cartRs.getString("brand"));
                        item.put("price", cartRs.getDouble("price"));
                        item.put("quantity", cartRs.getInt("quantity"));
                        item.put("image", cartRs.getString("image"));
                        item.put("sellerId", cartRs.getString("seller_id"));
                        cartData.add(item);
                    }
                    cartRs.close();
                    getCartStmt.close();
                    
                    // Store cart data in session
                    request.getSession().setAttribute("checkoutCartData", cartData);
                    
                    // Clear cart after storing data
                    String clearCartSql = "DELETE FROM cart WHERE user_id = ?";
                    PreparedStatement clearCartStmt = con.prepareStatement(clearCartSql);
                    clearCartStmt.setString(1, username);
                    int rowsDeleted = clearCartStmt.executeUpdate();
                    clearCartStmt.close();
                    
                    out.print("{\"success\": true, \"message\": \"Cart data stored and cart cleared for checkout\"}");
                    
                } catch (Exception e) {
                    out.print("{\"success\": false, \"message\": \"Error preparing checkout: " + e.getMessage() + "\"}");
                }
            } else if ("prepareCheckoutForPayment".equals(action)) {
                try {
                    // Get current cart items WITHOUT clearing
                    String getCartSql = "SELECT c.product_id, c.quantity, p.product_name, p.brand, p.price, p.image, p.seller_id " +
                                      "FROM cart c JOIN product p ON c.product_id = p.id " +
                                      "WHERE c.user_id = ?";
                    PreparedStatement getCartStmt = con.prepareStatement(getCartSql);
                    getCartStmt.setString(1, username);
                    ResultSet cartRs = getCartStmt.executeQuery();
                    
                    // Store cart data in session for Payment.jsp
                    java.util.List<java.util.Map<String, Object>> cartData = new java.util.ArrayList<>();
                    while (cartRs.next()) {
                        java.util.Map<String, Object> item = new java.util.HashMap<>();
                        item.put("productId", cartRs.getString("product_id"));
                        item.put("productName", cartRs.getString("product_name"));
                        item.put("productBrand", cartRs.getString("brand"));
                        item.put("price", cartRs.getDouble("price"));
                        item.put("quantity", cartRs.getInt("quantity"));
                        item.put("image", cartRs.getString("image"));
                        item.put("sellerId", cartRs.getString("seller_id"));
                        cartData.add(item);
                    }
                    cartRs.close();
                    getCartStmt.close();
                    
                    // Store cart data in session WITHOUT clearing cart
                    request.getSession().setAttribute("checkoutCartData", cartData);
                    
                    out.print("{\"success\": true, \"message\": \"Cart data prepared for checkout\"}");
                    
                } catch (Exception e) {
                    out.print("{\"success\": false, \"message\": \"Error preparing checkout: " + e.getMessage() + "\"}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
            
            con.close();
            
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"Invalid quantity format\"}");
        } catch (SQLException e) {
            out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
   
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String username = (String) request.getSession().getAttribute("username");
            
            if (username == null) {
                out.print("{\"success\": false, \"message\": \"User not logged in\"}");
                return;
            }
            
            // Initialize database connection
            Dbase db = new Dbase();
            Connection con = null;
            
            try {
                con = db.initailizeDatabase();
            } catch (Exception e) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = java.sql.DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/mscart", "root", "123456");
                } catch (ClassNotFoundException | SQLException ex) {
                    out.print("{\"success\": false, \"message\": \"Database connection failed\"}");
                    return;
                }
            }
            
            if (con == null || con.isClosed()) {
                out.print("{\"success\": false, \"message\": \"Database connection failed\"}");
                return;
            }
            
            // Get sorting parameters
            String sortBy = request.getParameter("sortBy");
            String sortOrder = request.getParameter("sortOrder");
            
            if (sortBy == null) sortBy = "cart_id";
            if (sortOrder == null) sortOrder = "DESC";
            
            // Get cart items
            String sql = "SELECT c.product_id, c.price, c.quantity, c.image, p.product_name as product_name, p.brand as product_brand FROM cart c JOIN product p ON c.product_id = p.id WHERE c.user_id = ? ORDER BY " + sortBy + " " + sortOrder;
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            List<CartItem> items = new ArrayList<>();
            while (rs.next()) {
                CartItem item = new CartItem(
                    rs.getString("product_id"),
                    rs.getString("product_name"),
                    rs.getDouble("price"),
                    rs.getInt("quantity"),
                    rs.getString("image")
                );
                items.add(item);
            }
            
            rs.close();
            stmt.close();
            con.close();
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"items\": [");
            
            for (int i = 0; i < items.size(); i++) {
                CartItem item = items.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"productId\": \"").append(escapeJson(item.getProductId())).append("\",");
                json.append("\"productName\": \"").append(escapeJson(item.getProductName())).append("\",");
                json.append("\"price\": ").append(item.getPrice()).append(",");
                json.append("\"quantity\": ").append(item.getQuantity()).append(",");
                json.append("\"image\": \"").append(escapeJson(item.getImage())).append("\",");
                json.append("\"total\": ").append(item.getPrice() * item.getQuantity());
                json.append("}");
            }
            
            json.append("]}");
            out.print(json.toString());
            
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    // Inner class for Cart Item
    public static class CartItem {
        private String productId;
        private String productName;
        private double price;
        private int quantity;
        private String image;
        
        public CartItem(String productId, String productName, double price, int quantity, String image) {
            this.productId = productId;
            this.productName = productName;
            this.price = price;
            this.quantity = quantity;
            this.image = image;
        }
        
        public String getProductId() { return productId; }
        public String getProductName() { return productName; }
        public double getPrice() { return price; }
        public int getQuantity() { return quantity; }
        public String getImage() { return image; }
        
        public void setQuantity(int quantity) { this.quantity = quantity; }
    }
}
