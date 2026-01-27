<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/html");
    response.setCharacterEncoding("UTF-8");
    
    out.println("<h2>Test Approve Functionality</h2>");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
        
        out.println("<h3>Database Connection: ✅ Success</h3>");
        
        // Check seller table
        out.println("<h3>Seller Table:</h3>");
        String sellerQuery = "SELECT id, name, price FROM seller LIMIT 5";
        PreparedStatement psSeller = con.prepareStatement(sellerQuery);
        ResultSet rsSeller = psSeller.executeQuery();
        
        out.println("<table border='1' style='border-collapse: collapse; width: 100%;'>");
        out.println("<tr><th>ID</th><th>Name</th><th>Price</th><th>Action</th></tr>");
        
        while (rsSeller.next()) {
            String id = rsSeller.getString("id");
            String name = rsSeller.getString("name");
            double price = rsSeller.getDouble("price");
            
            out.println("<tr>");
            out.println("<td>" + id + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("<td>₹" + price + "</td>");
            out.println("<td><button onclick='testApprove(\"" + id + "\")'>Test Approve</button></td>");
            out.println("</tr>");
        }
        
        out.println("</table>");
        
        rsSeller.close();
        psSeller.close();
        
        // Check product table
        out.println("<h3>Product Table (Recent):</h3>");
        String productQuery = "SELECT id, name, price, seller_id FROM product ORDER BY id DESC LIMIT 5";
        PreparedStatement psProduct = con.prepareStatement(productQuery);
        ResultSet rsProduct = psProduct.executeQuery();
        
        out.println("<table border='1' style='border-collapse: collapse; width: 100%;'>");
        out.println("<tr><th>ID</th><th>Name</th><th>Price</th><th>Seller ID</th></tr>");
        
        while (rsProduct.next()) {
            out.println("<tr>");
            out.println("<td>" + rsProduct.getString("id") + "</td>");
            out.println("<td>" + rsProduct.getString("name") + "</td>");
            out.println("<td>₹" + rsProduct.getDouble("price") + "</td>");
            out.println("<td>" + rsProduct.getString("seller_id") + "</td>");
            out.println("</tr>");
        }
        
        out.println("</table>");
        
        rsProduct.close();
        psProduct.close();
        con.close();
        
    } catch (Exception e) {
        out.println("<h3 style='color: red;'>Database Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    }
%>

<script>
function testApprove(sellerId) {
    console.log('Testing approve for seller ID:', sellerId);
    
    fetch('AcceptProductServlet.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'sellerId=' + encodeURIComponent(sellerId) + '&action=accept'
    })
    .then(response => {
        console.log('Response status:', response.status);
        return response.text();
    })
    .then(data => {
        console.log('Response data:', data);
        try {
            const jsonData = JSON.parse(data);
            if (jsonData.success) {
                alert('✅ Success: ' + jsonData.message);
                setTimeout(() => {
                    location.reload();
                }, 1000);
            } else {
                alert('❌ Error: ' + jsonData.message);
            }
        } catch (e) {
            alert('❌ Invalid JSON: ' + data);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('❌ Network Error: ' + error.message);
    });
}
</script>

<hr>
<p><a href='seller.jsp'>← Back to Seller</a></p>
<p><a href='AcceptProductDebug.jsp'>Debug Tool</a></p>
