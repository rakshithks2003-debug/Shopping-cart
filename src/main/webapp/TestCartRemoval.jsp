<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String username = (String) session.getAttribute("username");
    
    out.println("<h2>Cart Removal Debug Test</h2>");
    out.println("<p><strong>Username:</strong> " + (username != null ? username : "NULL") + "</p>");
    
    if (username != null && !username.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            
            // Show cart items for this user
            String sql = "SELECT id, product_id, product_name, price, quantity FROM cart WHERE user_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            
            out.println("<h3>Your Cart Items:</h3>");
            boolean hasItems = false;
            
            while (rs.next()) {
                hasItems = true;
                String cartId = rs.getString("id");
                String productName = rs.getString("product_name");
                double price = rs.getDouble("price");
                int quantity = rs.getInt("quantity");
                
                out.println("<div style='border: 1px solid #ccc; padding: 10px; margin: 10px 0;'>");
                out.println("<p><strong>Cart ID:</strong> " + cartId + "</p>");
                out.println("<p><strong>Product:</strong> " + productName + "</p>");
                out.println("<p><strong>Price:</strong> ₹" + price + "</p>");
                out.println("<p><strong>Quantity:</strong> " + quantity + "</p>");
                out.println("<button onclick='testRemove(\"" + cartId + "\")' style='background: red; color: white; padding: 5px 10px; border: none; cursor: pointer;'>Test Remove</button>");
                out.println("</div>");
            }
            
            if (!hasItems) {
                out.println("<p>No items in cart to test!</p>");
            }
            
            rs.close();
            ps.close();
            con.close();
            
        } catch (Exception e) {
            out.println("<p style='color: red;'><strong>Database Error:</strong> " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    } else {
        out.println("<p style='color: red;'><strong>Please login first!</strong></p>");
    }
%>

<script>
function testRemove(cartId) {
    console.log('Testing removal of cart ID:', cartId);
    
    fetch('RemoveFromCart.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'cartId=' + encodeURIComponent(cartId)
    })
    .then(response => {
        console.log('Response status:', response.status);
        return response.text();
    })
    .then(data => {
        console.log('Raw response:', data);
        try {
            const jsonData = JSON.parse(data);
            alert('Response: ' + JSON.stringify(jsonData, null, 2));
            if (jsonData.success) {
                location.reload();
            }
        } catch (e) {
            alert('Invalid JSON response: ' + data);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Network error: ' + error.message);
    });
}
</script>

<hr>
<p><a href='Cart.jsp'>← Back to Cart</a></p>
