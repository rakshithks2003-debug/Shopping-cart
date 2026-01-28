<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Set response content type to JSON
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

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
        
        out.print("{\"success\": true, \"message\": \"" + productName + " quantity updated in cart\"}");
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
        
        out.print("{\"success\": true, \"message\": \"" + productName + " added to cart\"}");
    }
    
    cartRs.close();
    cartPs.close();
    con.close();
    
} catch (Exception e) {
    e.printStackTrace();
    out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
}
%>
