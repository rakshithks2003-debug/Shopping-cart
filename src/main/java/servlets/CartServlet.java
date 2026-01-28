
package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import products.Dbase;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    public void init() throws ServletException {
        super.init();
        // Create cart table on servlet initialization
        createCartTable();
    }
    
    private void createCartTable() {
        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            if (con != null && !con.isClosed()) {
                String createTableSQL = "CREATE TABLE IF NOT EXISTS cart (" +
                    "cart_id INT AUTO_INCREMENT PRIMARY KEY," +
                    "user_id VARCHAR(100) NOT NULL," +
                    "product_id VARCHAR(50) NOT NULL," +
                    "product_name VARCHAR(255) NOT NULL," +
                    "price DECIMAL(10, 2) NOT NULL," +
                    "quantity INT NOT NULL," +
                    "image VARCHAR(255)" +
                ")";
                
                Statement stmt = con.createStatement();
                stmt.executeUpdate(createTableSQL);
                System.out.println("Cart table created or already exists");
                stmt.close();
                con.close();
            }
        } catch (Exception e) {
            System.err.println("Error creating cart table: " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        String userId = (String) session.getAttribute("username");
        
        if (userId == null) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"User not logged in!\"}");
            return;
        }
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            if ("add".equals(action)) {
                handleAddToCart(request, userId);
                int cartSize = getCartSize(userId);
                response.getWriter().write("{\"success\": true, \"message\": \"Product added to cart!\", \"cartSize\": " + cartSize + "}");
            } else if ("remove".equals(action)) {
                handleRemoveFromCart(request, userId);
                int cartSize = getCartSize(userId);
                response.getWriter().write("{\"success\": true, \"message\": \"Product removed from cart!\", \"cartSize\": " + cartSize + "}");
            } else if ("update".equals(action)) {
                handleUpdateQuantity(request, userId);
                int cartSize = getCartSize(userId);
                response.getWriter().write("{\"success\": true, \"message\": \"Cart updated!\", \"cartSize\": " + cartSize + "}");
            } else if ("clear".equals(action)) {
                clearCart(userId);
                response.getWriter().write("{\"success\": true, \"message\": \"Cart cleared!\", \"cartSize\": 0}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid action!\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("username");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (userId == null) {
            response.getWriter().write("{\"success\": true, \"cartSize\": 0, \"items\": []}");
            return;
        }
        
        try {
            List<CartItem> items = getCartItems(userId);
            
            if (items.isEmpty()) {
                response.getWriter().write("{\"success\": true, \"cartSize\": 0, \"items\": []}");
            } else {
                StringBuilder json = new StringBuilder();
                json.append("{\"success\": true, \"cartSize\": ").append(items.size()).append(", \"items\": [");
                
                for (int i = 0; i < items.size(); i++) {
                    CartItem item = items.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"productId\": \"").append(item.getProductId()).append("\",");
                    json.append("\"productName\": \"").append(escapeJson(item.getProductName())).append("\",");
                    json.append("\"price\": ").append(item.getPrice()).append(",");
                    json.append("\"quantity\": ").append(item.getQuantity()).append(",");
                    json.append("\"image\": \"").append(escapeJson(item.getImage())).append("\",");
                    json.append("\"total\": ").append(item.getPrice() * item.getQuantity());
                    json.append("}");
                }
                
                json.append("]}");
                response.getWriter().write(json.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private void handleAddToCart(HttpServletRequest request, String userId) throws Exception {
        String productId = request.getParameter("productId");
        String productName = request.getParameter("productName");
        String priceStr = request.getParameter("price");
        String image = request.getParameter("image");
        String quantityStr = request.getParameter("quantity");
        
        System.out.println("=== ADD TO CART DEBUG ===");
        System.out.println("User ID: " + userId);
        System.out.println("Product ID: " + productId);
        System.out.println("Product Name: " + productName);
        System.out.println("Price: " + priceStr);
        System.out.println("Quantity: " + quantityStr);
        System.out.println("Image: " + image);
        
        double price = Double.parseDouble(priceStr);
        int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 1;
        
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con == null || con.isClosed()) {
            System.err.println("Database connection is NULL or CLOSED!");
            throw new Exception("Database connection failed");
        }
        
        System.out.println("Database connection successful");
        
        // Check if item already exists
        String checkSQL = "SELECT quantity FROM cart WHERE user_id = ? AND product_id = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSQL);
        checkStmt.setString(1, userId);
        checkStmt.setString(2, productId);
        ResultSet rs = checkStmt.executeQuery();
        
        if (rs.next()) {
            // Update existing item
            int currentQty = rs.getInt("quantity");
            String updateSQL = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
            PreparedStatement updateStmt = con.prepareStatement(updateSQL);
            updateStmt.setInt(1, currentQty + quantity);
            updateStmt.setString(2, userId);
            updateStmt.setString(3, productId);
            int rowsUpdated = updateStmt.executeUpdate();
            updateStmt.close();
            System.out.println("Cart: Updated quantity for product " + productId + " to " + (currentQty + quantity) + " (Rows affected: " + rowsUpdated + ")");
        } else {
            // Insert new item
            String insertSQL = "INSERT INTO cart (user_id, product_id, product_name, price, quantity, image) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement insertStmt = con.prepareStatement(insertSQL);
            insertStmt.setString(1, userId);
            insertStmt.setString(2, productId);
            insertStmt.setString(3, productName);
            insertStmt.setDouble(4, price);
            insertStmt.setInt(5, quantity);
            insertStmt.setString(6, image);
            
            System.out.println("Executing INSERT with values:");
            System.out.println("  user_id: " + userId);
            System.out.println("  product_id: " + productId);
            System.out.println("  product_name: " + productName);
            System.out.println("  price: " + price);
            System.out.println("  quantity: " + quantity);
            System.out.println("  image: " + image);
            
            int rowsInserted = insertStmt.executeUpdate();
            insertStmt.close();
            System.out.println("Cart: INSERT completed - Rows affected: " + rowsInserted);
            
            if (rowsInserted == 0) {
                System.err.println("WARNING: INSERT returned 0 rows affected!");
            }
        }
        
        rs.close();
        checkStmt.close();
        con.close();
        System.out.println("=== END ADD TO CART ===");
    }
    
    private void handleRemoveFromCart(HttpServletRequest request, String userId) throws Exception {
        String productId = request.getParameter("productId");
        
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String deleteSQL = "DELETE FROM cart WHERE user_id = ? AND product_id = ?";
            PreparedStatement stmt = con.prepareStatement(deleteSQL);
            stmt.setString(1, userId);
            stmt.setString(2, productId);
            stmt.executeUpdate();
            stmt.close();
            con.close();
        }
    }
    
    private void handleUpdateQuantity(HttpServletRequest request, String userId) throws Exception {
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");
        int quantity = Integer.parseInt(quantityStr);
        
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            if (quantity > 0) {
                String updateSQL = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
                PreparedStatement stmt = con.prepareStatement(updateSQL);
                stmt.setInt(1, quantity);
                stmt.setString(2, userId);
                stmt.setString(3, productId);
                stmt.executeUpdate();
                stmt.close();
            } else {
                // Remove if quantity is 0 or negative
                String deleteSQL = "DELETE FROM cart WHERE user_id = ? AND product_id = ?";
                PreparedStatement stmt = con.prepareStatement(deleteSQL);
                stmt.setString(1, userId);
                stmt.setString(2, productId);
                stmt.executeUpdate();
                stmt.close();
            }
            con.close();
        }
    }
    
    private void clearCart(String userId) throws Exception {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String deleteSQL = "DELETE FROM cart WHERE user_id = ?";
            PreparedStatement stmt = con.prepareStatement(deleteSQL);
            stmt.setString(1, userId);
            stmt.executeUpdate();
            stmt.close();
            con.close();
        }
    }
    
    private List<CartItem> getCartItems(String userId) throws Exception {
        List<CartItem> items = new ArrayList<>();
        
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String selectSQL = "SELECT product_id, product_name, price, quantity, image FROM cart WHERE user_id = ? ORDER BY cart_id DESC";
            PreparedStatement stmt = con.prepareStatement(selectSQL);
            stmt.setString(1, userId);
            ResultSet rs = stmt.executeQuery();
            
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
        }
        
        return items;
    }
    
    private int getCartSize(String userId) throws Exception {
        int size = 0;
        
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String countSQL = "SELECT COUNT(*) as total FROM cart WHERE user_id = ?";
            PreparedStatement stmt = con.prepareStatement(countSQL);
            stmt.setString(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                size = rs.getInt("total");
            }
            
            rs.close();
            stmt.close();
            con.close();
        }
        
        return size;
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
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
