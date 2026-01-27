<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/html");
    response.setCharacterEncoding("UTF-8");
    
    out.println("<h2>🔍 Product Table Debug - Check What's Being Inserted</h2>");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
        
        out.println("<h3>✅ Database Connected</h3>");
        
        // Check product table structure
        out.println("<h3>Product Table Structure:</h3>");
        DatabaseMetaData meta = con.getMetaData();
        ResultSet columns = meta.getColumns(null, null, "product", null);
        
        out.println("<table border='1' style='border-collapse: collapse; width: 100%;'>");
        out.println("<tr><th>Column Name</th><th>Data Type</th><th>Size</th><th>Nullable</th></tr>");
        
        while (columns.next()) {
            out.println("<tr>");
            out.println("<td><strong>" + columns.getString("COLUMN_NAME") + "</strong></td>");
            out.println("<td>" + columns.getString("TYPE_NAME") + "</td>");
            out.println("<td>" + columns.getString("COLUMN_SIZE") + "</td>");
            out.println("<td>" + columns.getString("IS_NULLABLE") + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
        columns.close();
        
        // Show all product data
        out.println("<h3>Product Table All Data:</h3>");
        String productQuery = "SELECT * FROM product ORDER BY id DESC";
        PreparedStatement psProduct = con.prepareStatement(productQuery);
        ResultSet rsProduct = psProduct.executeQuery();
        
        ResultSetMetaData rsMeta = rsProduct.getMetaData();
        int columnCount = rsMeta.getColumnCount();
        
        out.println("<table border='1' style='border-collapse: collapse; width: 100%;'>");
        out.println("<tr>");
        for (int i = 1; i <= columnCount; i++) {
            out.println("<th>" + rsMeta.getColumnName(i) + "</th>");
        }
        out.println("</tr>");
        
        boolean hasProducts = false;
        while (rsProduct.next()) {
            hasProducts = true;
            out.println("<tr>");
            for (int i = 1; i <= columnCount; i++) {
                String value = rsProduct.getString(i);
                String columnName = rsMeta.getColumnName(i);
                
                // Highlight important columns
                if (columnName.equals("name")) {
                    if (value == null || value.trim().isEmpty()) {
                        out.println("<td style='background-color: red; color: white; font-weight: bold;'>NULL/EMPTY</td>");
                    } else {
                        out.println("<td style='background-color: green; color: white; font-weight: bold;'>" + value + "</td>");
                    }
                } else if (columnName.equals("id")) {
                    out.println("<td style='background-color: #e0e0e0; font-weight: bold;'>" + value + "</td>");
                } else {
                    out.println("<td>" + value + "</td>");
                }
            }
            out.println("</tr>");
        }
        
        if (!hasProducts) {
            out.println("<tr><td colspan='" + columnCount + "' style='text-align: center; color: red; font-size: 18px;'><strong>❌ NO PRODUCTS FOUND IN PRODUCT TABLE</strong></td></tr>");
        }
        
        out.println("</table>");
        rsProduct.close();
        psProduct.close();
        
        con.close();
        
    } catch (Exception e) {
        out.println("<h3 style='color: red;'>❌ Database Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    }
%>

<hr>
<p><a href='Showproducts.jsp'>← Back to Showproducts</a></p>
<p><a href='seller.jsp'>← Back to Seller</a></p>

<p><strong>What this shows:</strong></p>
<ul>
    <li><span style='background-color: green; color: white; padding: 2px;'>GREEN</span> = Name has correct data</li>
    <li><span style='background-color: red; color: white; padding: 2px;'>RED</span> = Name is NULL/EMPTY</li>
    <li><span style='background-color: #e0e0e0; padding: 2px;'>GRAY</span> = Product ID</li>
</ul>

<p><strong>If name column shows ID instead of product name:</strong></p>
<ul>
    <li>The INSERT statement is putting ID in the wrong column</li>
    <li>Need to fix the parameter order in AcceptProductToProductsSimple.jsp</li>
</ul>
