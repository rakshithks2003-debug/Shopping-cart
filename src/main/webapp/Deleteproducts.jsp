<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in and is admin
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn") || 
    !"admin".equals(sessionObg.getAttribute("userRole"))) {
    response.sendRedirect("Login.html");
    return;
}

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Handle deletion
String deleteMessage = "";
String messageType = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String productId = request.getParameter("id");
    String imageFileName = request.getParameter("imageFileName");
    
    if (productId != null && !productId.trim().isEmpty()) {
        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            // First get the image file name if not provided
            if (imageFileName == null || imageFileName.trim().isEmpty()) {
                PreparedStatement psGet = con.prepareStatement("SELECT image FROM product WHERE id = ?");
                psGet.setString(1, productId);
                ResultSet rs = psGet.executeQuery();
                if (rs.next()) {
                    imageFileName = rs.getString("image");
                }
                rs.close();
                psGet.close();
            }
            
            // Delete the product from database
            PreparedStatement ps = con.prepareStatement("DELETE FROM product WHERE id = ?");
            ps.setString(1, productId);
            int result = ps.executeUpdate();
            ps.close();
            con.close();
            
            if (result > 0) {
                deleteMessage = "Product deleted successfully!";
                messageType = "success";
                
                // Delete the image file if it exists
                if (imageFileName != null && !imageFileName.trim().isEmpty()) {
                    String imagePath = application.getRealPath("/product_images/") + imageFileName;
                    java.io.File imageFile = new java.io.File(imagePath);
                    if (imageFile.exists()) {
                        imageFile.delete();
                    }
                }
            } else {
                deleteMessage = "Failed to delete product. Please try again.";
                messageType = "error";
            }
            
        } catch (Exception e) {
            deleteMessage = "Error: " + e.getMessage();
            messageType = "error";
        }
    } else {
        deleteMessage = "Invalid product ID.";
        messageType = "error";
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Products - Mini Shopping Cart</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        header {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            text-align: center;
            color: white;
        }
        
        h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            background: linear-gradient(45deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .user-info {
            font-size: 1.1rem;
            opacity: 0.9;
            margin-bottom: 20px;
        }
        
        .nav-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .nav-btn {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 12px 25px;
            text-decoration: none;
            border-radius: 30px;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
            font-weight: 500;
            backdrop-filter: blur(5px);
        }
        
        .nav-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }
        
        .nav-btn.primary {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            border-color: transparent;
        }
        
        .nav-btn.admin {
            background: linear-gradient(135deg, #2196F3, #1976D2);
            border-color: transparent;
        }
        
        .nav-btn.logout {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            border-color: transparent;
        }
        
        .main-content {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 25px;
            padding: 40px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .section-title {
            font-size: 2rem;
            color: #333;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 700;
        }
        
        .message {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 500;
            animation: slideIn 0.3s ease;
        }
        
        .message.success {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            box-shadow: 0 10px 25px rgba(76, 175, 80, 0.3);
        }
        
        .message.error {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            color: white;
            box-shadow: 0 10px 25px rgba(244, 67, 54, 0.3);
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .product-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }
        
        .product-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            background: #f8f9fa;
        }
        
        .product-info {
            padding: 20px;
        }
        
        .product-name {
            font-size: 1.3rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        .product-price {
            font-size: 1.5rem;
            font-weight: bold;
            color: #ff6b6b;
            margin-bottom: 15px;
        }
        
        .product-price::before {
            content: "₹";
            margin-right: 2px;
        }
        
        .delete-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .delete-btn {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            flex: 1;
        }
        
        .delete-btn:hover {
            background: linear-gradient(135deg, #d32f2f, #c62828);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(244, 67, 54, 0.3);
        }
        
        .no-products {
            text-align: center;
            padding: 60px 40px;
            color: #666;
            font-size: 1.2rem;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            header {
                padding: 20px;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .main-content {
                padding: 25px;
            }
            
            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🗑️ Delete Products</h1>
            <div class="user-info">👤 <%= username != null ? username : "Admin" %> (<%= userRole != null ? userRole : "Admin" %>)</div>
            
            <div class="nav-buttons">
                <a href="Dashboard.jsp" class="nav-btn admin">📊 Dashboard</a>
                <a href="Showproducts.jsp" class="nav-btn primary">🛍️ View Products</a>
                <a href="admin.jsp" class="nav-btn admin">🔧 Add Products</a>
                
            </div>
        </header>
        
        <main>
            <div class="main-content">
                <h2 class="section-title">Manage Products</h2>
                
                <% if (!deleteMessage.isEmpty()) { %>
                    <div class="message <%= messageType %>">
                        <%= deleteMessage %>
                    </div>
                <% } %>
                
                <div class="products-grid">
                    <%
                    try {
                        Dbase db = new Dbase();
                        Connection con = db.initailizeDatabase();
                        PreparedStatement ps = con.prepareStatement("SELECT id, name, price, image FROM product ORDER BY id DESC");
                        ResultSet rs = ps.executeQuery();
                        
                        boolean hasProducts = false;
                        while(rs.next()) {
                            hasProducts = true;
                    %>
                        <div class="product-card">
                            <img class="product-image" src="product_images/<%= rs.getString("image") != null ? rs.getString("image") : "placeholder.jpg" %>" 
                                 alt="<%= rs.getString("name") %>"
                                 onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4='">
                            
                            <div class="product-info">
                                <div class="product-name"><%= rs.getString("name") %></div>
                                <div class="product-price"><%= String.format("%.2f", rs.getDouble("price")) %></div>
                                
                                <form class="delete-form" action="Deleteproducts.jsp" method="post" 
                                      onsubmit="return confirm('Are you sure you want to delete this product?')">
                                    <input type="hidden" name="id" value="<%= rs.getString("id") %>">
                                    <input type="hidden" name="imageFileName" value="<%= rs.getString("image") != null ? rs.getString("image") : "" %>">
                                    <button type="submit" class="delete-btn">🗑️ Delete Product</button>
                                </form>
                            </div>
                        </div>
                    <%
                        }
                        
                        if (!hasProducts) {
                    %>
                        <div class="no-products">
                            <h3>📦 No Products Found</h3>
                            <p>No products available to delete. Add some products first!</p>
                        </div>
                    <%
                        }
                        
                        rs.close();
                        ps.close();
                        con.close();
                        
                    } catch (Exception e) {
                    %>
                        <div class="message error">
                            Error loading products: <%= e.getMessage() %>
                        </div>
                    <%
                    }
                    %>
                </div>
            </div>
        </main>
    </div>
</body>
</html>