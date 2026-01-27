<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/html");
    response.setCharacterEncoding("UTF-8");
    
    String sellerId = request.getParameter("sellerId");
    String action = request.getParameter("action");
    
    out.println("<h2>Accept Product Debug</h2>");
    out.println("<p><strong>Seller ID:</strong> " + (sellerId != null ? sellerId : "NULL") + "</p>");
    out.println("<p><strong>Action:</strong> " + (action != null ? action : "NULL") + "</p>");
    
    if (sellerId != null && !sellerId.trim().isEmpty() && "accept".equals(action)) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            
            out.println("<h3>Seller Table Structure:</h3>");
            DatabaseMetaData meta = con.getMetaData();
            ResultSet columns = meta.getColumns(null, null, "seller", null);
            out.println("<table border='1'><tr><th>Column Name</th><th>Type</th></tr>");
            while (columns.next()) {
                out.println("<tr><td>" + columns.getString("COLUMN_NAME") + "</td><td>" + columns.getString("TYPE_NAME") + "</td></tr>");
            }
            out.println("</table>");
            columns.close();
            
            out.println("<h3>Seller Data:</h3>");
            String getSellerQuery = "SELECT * FROM seller WHERE id = ?";
            PreparedStatement psSeller = con.prepareStatement(getSellerQuery);
            psSeller.setString(1, sellerId);
            ResultSet rsSeller = psSeller.executeQuery();
            
            if (rsSeller.next()) {
                out.println("<p><strong>Found seller!</strong></p>");
                ResultSetMetaData rsMeta = rsSeller.getMetaData();
                int columnCount = rsMeta.getColumnCount();
                
                out.println("<table border='1'><tr>");
                for (int i = 1; i <= columnCount; i++) {
                    out.println("<th>" + rsMeta.getColumnName(i) + "</th>");
                }
                out.println("</tr><tr>");
                
                for (int i = 1; i <= columnCount; i++) {
                    out.println("<td>" + rsSeller.getString(i) + "</td>");
                }
                out.println("</tr></table>");
                
                // Try to insert into product table
                out.println("<h3>Product Table Structure:</h3>");
                columns = meta.getColumns(null, null, "product", null);
                out.println("<table border='1'><tr><th>Column Name</th><th>Type</th></tr>");
                while (columns.next()) {
                    out.println("<th>" + columns.getString("COLUMN_NAME") + "</th><td>" + columns.getString("TYPE_NAME") + "</td></tr>");
                }
                out.println("</table>");
                columns.close();
                
                // Test insert
                String insertQuery = "INSERT INTO product (name, price, description, image, category_id, seller_id) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement psInsert = con.prepareStatement(insertQuery);
                
                // Try different column names
                try {
                    psInsert.setString(1, rsSeller.getString("product_name"));
                } catch (Exception e) {
                    psInsert.setString(1, rsSeller.getString("name"));
                }
                
                psInsert.setDouble(2, rsSeller.getDouble("price"));
                psInsert.setString(3, rsSeller.getString("description"));
                psInsert.setString(4, rsSeller.getString("image"));
                psInsert.setInt(5, 1);
                psInsert.setString(6, sellerId);
                
                out.println("<h3>Insert Query:</h3>");
                out.println("<p>" + insertQuery + "</p>");
                
                int rowsInserted = psInsert.executeUpdate();
                psInsert.close();
                
                if (rowsInserted > 0) {
                    out.println("<p style='color: green;'><strong>Product inserted successfully!</strong></p>");
                    
                    // Delete from seller
                    String deleteQuery = "DELETE FROM seller WHERE id = ?";
                    PreparedStatement psDelete = con.prepareStatement(deleteQuery);
                    psDelete.setString(1, sellerId);
                    int rowsDeleted = psDelete.executeUpdate();
                    psDelete.close();
                    
                    out.println("<p style='color: green;'><strong>Seller deleted! Rows affected: " + rowsDeleted + "</strong></p>");
                } else {
                    out.println("<p style='color: red;'><strong>Failed to insert product</strong></p>");
                }
                
            } else {
                out.println("<p style='color: red;'><strong>Seller not found with ID: " + sellerId + "</strong></p>");
            }
            
            rsSeller.close();
            psSeller.close();
            con.close();
            
        } catch (Exception e) {
            out.println("<p style='color: red;'><strong>Error:</strong> " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
%>

<hr>
<p><a href='seller.jsp'>← Back to Seller</a></p>
