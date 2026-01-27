<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/html");
    response.setCharacterEncoding("UTF-8");
    
    out.println("<h2>🔍 Showproducts.jsp Display Test</h2>");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
        
        out.println("<h3>✅ Database Connected</h3>");
        
        // Test the exact same query as Showproducts.jsp
        String sql = "SELECT id, name, price, image, description FROM product ORDER BY id DESC";
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        out.println("<h3>Testing Showproducts.jsp Query and Display Logic:</h3>");
        
        boolean hasProducts = false;
        int productCount = 0;
        
        while(rs.next()) {
            hasProducts = true;
            productCount++;
            
            // Extract data exactly like Showproducts.jsp
            String id = rs.getString("id");
            String name = rs.getString("name");
            double price = rs.getDouble("price");
            String image = rs.getString("image");
            String description = rs.getString("description");
            
            out.println("<div style='border: 2px solid #333; margin: 10px 0; padding: 15px; background: #f9f9f9;'>");
            out.println("<h4>Product #" + productCount + " (ID: " + id + ")</h4>");
            
            // Show extracted values
            out.println("<p><strong>Extracted Data:</strong></p>");
            out.println("<ul>");
            out.println("<li>ID: <code>" + id + "</code></li>");
            out.println("<li>Name: <code>" + name + "</code></li>");
            out.println("<li>Price: <code>" + price + "</code></li>");
            out.println("<li>Image: <code>" + image + "</code></li>");
            out.println("<li>Description: <code>" + description + "</code></li>");
            out.println("</ul>");
            
            // Test the exact display logic from Showproducts.jsp
            out.println("<p><strong>Showproducts.jsp Display Logic Test:</strong></p>");
            out.println("<div style='border: 1px solid #ccc; padding: 10px; background: white;'>");
            out.println("<div class='product-name' style='font-weight: bold; color: #333; margin-bottom: 5px;'>");
            out.println("Name: " + name); // This is exactly what Showproducts.jsp does
            out.println("</div>");
            out.println("<div class='product-price' style='color: #e74c3c; font-size: 18px; margin-bottom: 10px;'>");
            out.println("Price: ₹" + String.format("%.2f", price)); // This is exactly what Showproducts.jsp does
            out.println("</div>");
            out.println("<button style='background: #27ae60; color: white; padding: 8px 15px; border: none; cursor: pointer;'>");
            out.println("🛒 Add to Cart (ID: " + id + ")");
            out.println("</button>");
            out.println("</div>");
            
            out.println("</div>");
        }
        
        if (!hasProducts) {
            out.println("<div style='text-align: center; padding: 50px; background: #f8f9fa; border: 2px dashed #dee2e6;'>");
            out.println("<h3 style='color: #6c757d;'>📦 No Products Found</h3>");
            out.println("<p style='color: #6c757d;'>The product table is empty or no products match the query.</p>");
            out.println("</div>");
        }
        
        out.println("<h3>Summary:</h3>");
        out.println("<p><strong>Total Products Found:</strong> " + productCount + "</p>");
        out.println("<p><strong>Has Products:</strong> " + (hasProducts ? "YES ✅" : "NO ❌") + "</p>");
        
        rs.close();
        ps.close();
        con.close();
        
    } catch (Exception e) {
        out.println("<h3 style='color: red;'>❌ Database Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    }
%>

<hr>
<p><a href='Showproducts.jsp'>← Back to Showproducts</a></p>
<p><a href='ProductTableDebug.jsp'>← Check Product Table</a></p>
<p><a href='seller.jsp'>← Back to Seller</a></p>

<p><strong>What this shows:</strong></p>
<ul>
    <li>Exact data extraction like Showproducts.jsp</li>
    <li>Display logic test</li>
    <li>Whether names are being displayed correctly</li>
</ul>
