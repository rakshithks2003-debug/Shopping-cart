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
 * Servlet implementation for creating orders from cart items
 * Handles order creation, item transfer, shipping info, and cart clearing
 */
@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles POST requests for order creation
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type to JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        // Debug: Print all received parameters
        System.out.println("=== DEBUG: OrderServlet ===");
        System.out.println("Payment Method: " + request.getParameter("paymentMethod"));
        System.out.println("Full Name: " + request.getParameter("fullName"));
        System.out.println("Email: " + request.getParameter("email"));
        System.out.println("Phone: " + request.getParameter("phone"));
        System.out.println("Address: " + request.getParameter("address"));
        System.out.println("City: " + request.getParameter("city"));
        System.out.println("Pincode: " + request.getParameter("pincode"));
        System.out.println("Total Amount: " + request.getParameter("totalAmount"));

        // Check if user is logged in
        HttpSession sessionObj = request.getSession(false);
        if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
            !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
            out.print("{\"success\": false, \"message\": \"Please login to place an order\"}");
            return;
        }

        String username = (String) sessionObj.getAttribute("username");

        // Get payment details
        String paymentMethod = request.getParameter("paymentMethod");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String pincode = request.getParameter("pincode");
        String totalAmountStr = request.getParameter("totalAmount");

        // Build debug message
        StringBuilder debugMsg = new StringBuilder();
        debugMsg.append("Received parameters: ");
        if (paymentMethod != null) debugMsg.append("paymentMethod=[").append(paymentMethod).append("] ");
        if (fullName != null) debugMsg.append("fullName=[").append(fullName).append("] ");
        if (email != null) debugMsg.append("email=[").append(email).append("] ");
        if (phone != null) debugMsg.append("phone=[").append(phone).append("] ");
        if (address != null) debugMsg.append("address=[").append(address).append("] ");
        if (city != null) debugMsg.append("city=[").append(city).append("] ");
        if (pincode != null) debugMsg.append("pincode=[").append(pincode).append("] ");
        if (totalAmountStr != null) debugMsg.append("totalAmount=[").append(totalAmountStr).append("] ");

        // Check for missing parameters
        if (paymentMethod == null || fullName == null || email == null || phone == null || 
            address == null || city == null || pincode == null || totalAmountStr == null) {
            
            String missingParams = "";
            if (paymentMethod == null) missingParams += "paymentMethod ";
            if (fullName == null) missingParams += "fullName ";
            if (email == null) missingParams += "email ";
            if (phone == null) missingParams += "phone ";
            if (address == null) missingParams += "address ";
            if (city == null) missingParams += "city ";
            if (pincode == null) missingParams += "pincode ";
            if (totalAmountStr == null) missingParams += "totalAmount ";
            
            out.print("{\"success\": false, \"message\": \"Missing required information: " + missingParams.trim() + "\", \"debug\": \"" + escapeJson(debugMsg.toString()) + "\"}");
            return;
        }

        // Check for empty parameters
        if (paymentMethod.trim().isEmpty() || fullName.trim().isEmpty() || email.trim().isEmpty() || phone.trim().isEmpty() || 
            address.trim().isEmpty() || city.trim().isEmpty() || pincode.trim().isEmpty() || totalAmountStr.trim().isEmpty()) {
            
            String emptyParams = "";
            if (paymentMethod.trim().isEmpty()) emptyParams += "paymentMethod ";
            if (fullName.trim().isEmpty()) emptyParams += "fullName ";
            if (email.trim().isEmpty()) emptyParams += "email ";
            if (phone.trim().isEmpty()) emptyParams += "phone ";
            if (address.trim().isEmpty()) emptyParams += "address ";
            if (city.trim().isEmpty()) emptyParams += "city ";
            if (pincode.trim().isEmpty()) emptyParams += "pincode ";
            if (totalAmountStr.trim().isEmpty()) emptyParams += "totalAmount ";
            
            out.print("{\"success\": false, \"message\": \"Empty parameters: " + emptyParams.trim() + "\", \"debug\": \"" + escapeJson(debugMsg.toString()) + "\"}");
            return;
        }

        try {
            double totalAmount = Double.parseDouble(totalAmountStr);
            
            // Initialize database connection
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            if (con != null && !con.isClosed()) {
                con.setAutoCommit(false); // Start transaction
                
                try {
                    // Generate unique order ID
                    String orderId = "ORD" + System.currentTimeMillis();
                    
                    // 1. Insert into orders table
                    String orderSql = "INSERT INTO orders (order_id, user_id, total_amount, status, payment_method) VALUES (?, ?, ?, 'pending', ?)";
                    PreparedStatement orderStmt = con.prepareStatement(orderSql);
                    orderStmt.setString(1, orderId);
                    orderStmt.setString(2, username);
                    orderStmt.setDouble(3, totalAmount);
                    orderStmt.setString(4, paymentMethod);
                    orderStmt.executeUpdate();
                    orderStmt.close();
                    
                    // 2. Get cart items and insert into order_items
                    String cartSql = "SELECT product_id, product_name, price, quantity FROM cart WHERE user_id = ?";
                    PreparedStatement cartStmt = con.prepareStatement(cartSql);
                    cartStmt.setString(1, username);
                    ResultSet cartRs = cartStmt.executeQuery();
                    
                    int itemCount = 0;
                    while (cartRs.next()) {
                        String productId = cartRs.getString("product_id");
                        String productName = cartRs.getString("product_name");
                        double price = cartRs.getDouble("price");
                        int quantity = cartRs.getInt("quantity");
                        
                        String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity) VALUES (?, ?, ?, ?, ?)";
                        PreparedStatement itemStmt = con.prepareStatement(itemSql);
                        itemStmt.setString(1, orderId);
                        itemStmt.setString(2, productId);
                        itemStmt.setString(3, productName);
                        itemStmt.setDouble(4, price);
                        itemStmt.setInt(5, quantity);
                        itemStmt.executeUpdate();
                        itemStmt.close();
                        
                        itemCount++;
                    }
                    cartRs.close();
                    cartStmt.close();
                    
                    // 3. Insert shipping information
                    // Try with full_name field first, then fallback to first_name/last_name
                    String shippingSql;
                    try {
                        // Try to insert using full_name field
                        shippingSql = "INSERT INTO order_shipping (order_id, full_name, email, phone, address, city, zip_code, country) VALUES (?, ?, ?, ?, ?, ?, ?, 'India')";
                        PreparedStatement shippingStmt = con.prepareStatement(shippingSql);
                        shippingStmt.setString(1, orderId);
                        shippingStmt.setString(2, fullName);
                        shippingStmt.setString(3, email);
                        shippingStmt.setString(4, phone);
                        shippingStmt.setString(5, address);
                        shippingStmt.setString(6, city);
                        shippingStmt.setString(7, pincode);
                        shippingStmt.executeUpdate();
                        shippingStmt.close();
                    } catch (Exception e) {
                        // If full_name field doesn't exist, use first_name/last_name
                        shippingSql = "INSERT INTO order_shipping (order_id, first_name, last_name, email, phone, address, city, zip_code, country) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'India')";
                        PreparedStatement shippingStmt = con.prepareStatement(shippingSql);
                        
                        // Split full name into first and last name
                        String firstName = fullName;
                        String lastName = "";
                        if (fullName != null && fullName.contains(" ")) {
                            String[] nameParts = fullName.split(" ", 2);
                            firstName = nameParts[0];
                            lastName = nameParts[1];
                        }
                        
                        shippingStmt.setString(1, orderId);
                        shippingStmt.setString(2, firstName);
                        shippingStmt.setString(3, lastName);
                        shippingStmt.setString(4, email);
                        shippingStmt.setString(5, phone);
                        shippingStmt.setString(6, address);
                        shippingStmt.setString(7, city);
                        shippingStmt.setString(8, pincode);
                        shippingStmt.executeUpdate();
                        shippingStmt.close();
                    }
                    
                    // 4. Clear cart after successful order creation
                    String clearCartSql = "DELETE FROM cart WHERE user_id = ?";
                    PreparedStatement clearCartStmt = con.prepareStatement(clearCartSql);
                    clearCartStmt.setString(1, username);
                    clearCartStmt.executeUpdate();
                    clearCartStmt.close();
                    
                    // Commit transaction
                    con.commit();
                    
                    out.print("{\"success\": true, \"message\": \"Order created successfully with " + itemCount + " items\", \"orderId\": \"" + orderId + "\", \"debug\": \"" + escapeJson(debugMsg.toString()) + "\"}");
                    
                } catch (Exception e) {
                    // Rollback transaction on error
                    con.rollback();
                    throw e;
                } finally {
                    con.setAutoCommit(true);
                    con.close();
                }
            } else {
                out.print("{\"success\": false, \"message\": \"Database connection failed\", \"debug\": \"" + escapeJson(debugMsg.toString()) + "\"}");
            }
            
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"Invalid total amount format: " + escapeJson(totalAmountStr) + "\", \"debug\": \"" + escapeJson(debugMsg.toString()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Server error: " + escapeJson(e.getMessage()) + "\", \"debug\": \"" + escapeJson(debugMsg.toString()) + "\"}");
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
        out.print("{\"success\": false, \"message\": \"GET method not supported for order creation\"}");
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
