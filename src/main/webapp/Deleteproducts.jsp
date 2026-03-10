<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
// Check if user is logged in and is admin
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn"))
     {
    response.sendRedirect("Login.jsp");
    return;
}

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");
String sellerId = null;

// For seller role, fetch seller_id from users table
if ("seller".equals(userRole)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
        String sellerQuery = "SELECT seller_id FROM users WHERE username = ?";
        PreparedStatement sellerStmt = con.prepareStatement(sellerQuery);
        sellerStmt.setString(1, username);
        ResultSet rs = sellerStmt.executeQuery();
        
        if (rs.next()) {
            sellerId = rs.getString("seller_id");
        }
        rs.close();
        sellerStmt.close();
        con.close();
    } catch (Exception e) {
        // Error fetching seller_id
    }
}

// Handle deletion
String deleteMessage = "";
String messageType = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String productName = request.getParameter("productName");
    
    if (productName != null && !productName.trim().isEmpty()) {
        try {
            Dbase db = new Dbase();
            Connection con = null;
            
            try {
                con = db.initailizeDatabase();
            } catch (Exception e) {
                // Fallback to direct connection if Dbase fails
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            }
            
            if (con == null || con.isClosed()) {
                deleteMessage = "Database connection failed!";
                messageType = "error";
            } else {
                // First check if product exists by product_name
                PreparedStatement checkPs = null;
                ResultSet checkRs = null;
                boolean productFound = false;
                int productId = -1;
                String foundPid = null;
                
                try {
                    String checkQuery;
                    if ("seller".equals(userRole) && sellerId != null) {
                        checkQuery = "SELECT id, pid, product_name, brand FROM product WHERE product_name = ? AND Seller_id = ?";
                        checkPs = con.prepareStatement(checkQuery);
                        checkPs.setString(1, productName);
                        checkPs.setString(2, sellerId);
                    } else {
                        checkQuery = "SELECT id, pid, product_name, brand FROM product WHERE product_name = ?";
                        checkPs = con.prepareStatement(checkQuery);
                        checkPs.setString(1, productName);
                    }
                    checkRs = checkPs.executeQuery();
                    
                    if (checkRs.next()) {
                        productFound = true;
                        productId = checkRs.getInt("id");
                        foundPid = checkRs.getString("pid");
                    }
                } catch (Exception e) {
                    // Product name check failed
                } finally {
                    if (checkRs != null) checkRs.close();
                    if (checkPs != null) checkPs.close();
                }
                
                if (productFound) {
                    // Delete the product using the product_name
                    PreparedStatement ps = null;
                    int result = 0;
                    
                    try {
                        String deleteQuery;
                        if ("seller".equals(userRole) && sellerId != null) {
                            deleteQuery = "DELETE FROM product WHERE product_name = ? AND Seller_id = ?";
                            ps = con.prepareStatement(deleteQuery);
                            ps.setString(1, productName);
                            ps.setString(2, sellerId);
                        } else {
                            deleteQuery = "DELETE FROM product WHERE product_name = ?";
                            ps = con.prepareStatement(deleteQuery);
                            ps.setString(1, productName);
                        }
                        result = ps.executeUpdate();
                        
                    } finally {
                        if (ps != null) ps.close();
                    }
                    
                    if (result > 0) {
                        deleteMessage = "Product '" + productName + "' deleted successfully!";
                        messageType = "success";
                    } else {
                        deleteMessage = "Failed to delete product. Try checking database permissions.";
                        messageType = "error";
                    }
                } else {
                    
                    // Show all available product names
                    String allQuery;
                    PreparedStatement allPs;
                    if ("seller".equals(userRole) && sellerId != null) {
                        allQuery = "SELECT id, pid, product_name, brand FROM product WHERE Seller_id = ? ORDER BY product_name";
                        allPs = con.prepareStatement(allQuery);
                        allPs.setString(1, sellerId);
                    } else {
                        allQuery = "SELECT id, pid, product_name, brand FROM product ORDER BY product_name";
                        allPs = con.prepareStatement(allQuery);
                    }
                    ResultSet allRs = allPs.executeQuery();
                    StringBuilder availableProducts = new StringBuilder("Available products: ");
                    int productCount = 0;
                    
                    while (allRs.next()) {
                        productCount++;
                        String id = allRs.getString("id");
                        String pid = allRs.getString("pid");
                        String name = allRs.getString("product_name");
                        
                        // Handle null name gracefully
                        String displayName = (name != null && !name.trim().isEmpty() ? name : "No Name");
                        
                        availableProducts.append(displayName).append(", ");
                    }
                    allRs.close();
                    allPs.close();
                    
                    if (availableProducts.length() > 2) {
                        availableProducts.setLength(availableProducts.length() - 2); // Remove trailing comma
                        
                        // Safely truncate the message for display
                        String displayMessage = availableProducts.toString();
                        if (displayMessage.length() > 100) {
                            displayMessage = displayMessage.substring(0, 100) + "...";
                        }
                        deleteMessage = "Product not found. " + displayMessage;
                    } else {
                        deleteMessage = "Product not found. No products in database.";
                    }
                    messageType = "error";
                }
                
                con.close();
            }
            
        } catch (ClassNotFoundException e) {
            deleteMessage = "Database driver not found: " + e.getMessage();
            messageType = "error";
        } catch (SQLException e) {
            deleteMessage = "Database error: " + e.getMessage();
            messageType = "error";
        } catch (Exception e) {
            deleteMessage = "Error: " + e.getMessage();
            messageType = "error";
        }
    } else {
        deleteMessage = "Invalid product name: " + productName;
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
            position: relative;
        }
        
        .back-to-home-btn-left {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
        }
        
        .back-to-home-btn-left:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
            background: linear-gradient(135deg, #45a049, #3d8b40);
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
        
        .products-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        }
        
        .products-table thead {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .products-table th {
            padding: 18px 15px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .products-table td {
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 14px;
            color: #333;
        }
        
        .products-table tbody tr {
            transition: all 0.3s ease;
        }
        
        .products-table tbody tr:hover {
            background: #f8f9fa;
            transform: scale(1.01);
        }
        
        .products-table tbody tr:last-child td {
            border-bottom: none;
        }
        
        .product-id {
            font-weight: 600;
            color: #667eea;
            font-size: 13px;
        }
        
        .product-name {
            font-weight: 600;
            color: #333;
            max-width: 200px;
        }
        
        .category-id {
            background: #e3f2fd;
            color: #1976d2;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        
        .product-price {
            font-weight: bold;
            color: #ff6b6b;
            font-size: 16px;
        }
        
        .product-price::before {
            content: "₹";
            margin-right: 2px;
        }
        
        .product-description {
            color: #666;
            font-size: 13px;
            max-width: 250px;
            line-height: 1.4;
        }
        
        .delete-btn {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .delete-btn:hover {
            background: linear-gradient(135deg, #d32f2f, #c62828);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(244, 67, 54, 0.3);
        }
        
        .no-products {
            text-align: center;
            padding: 60px 40px;
            color: #666;
            font-size: 1.2rem;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
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
            
            .products-table {
                font-size: 12px;
            }
            
            .products-table th,
            .products-table td {
                padding: 10px 8px;
            }
            
            .product-name {
                max-width: 120px;
            }
            
            .product-description {
                max-width: 150px;
                font-size: 11px;
            }
        }
    </style>
</head>
<body>
    <!-- Back to Home Button -->
    <a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page">
        <i class="fas fa-home"></i> Back 
    </a>

    <div class="container">
        <header>
            <h1>🗑️ Delete Products</h1>
            <div class="user-info">👤 <%= username != null ? username : "Admin" %> (<%= userRole != null ? userRole : "Admin" %>)</div>
            
                    </header>
        
        <main>
            <div class="main-content">
                <h2 class="section-title">Manage Products</h2>
                
                <% if (!deleteMessage.isEmpty()) { %>
                    <div class="message <%= messageType %>">
                        <%= deleteMessage %>
                    </div>
                <% } %>
                
                <table class="products-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>PID</th>
                            <th>Product Name</th>
                            <th>Brand</th>
                            <th>Category ID</th>
                            <th>Price</th>
                            <th>Description</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            Dbase db = new Dbase();
                            Connection con = null;
                            
                            try {
                                con = db.initailizeDatabase();
                            } catch (Exception e) {
                                // Fallback to direct connection if Dbase fails
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                con = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/mscart", "root", "123456");
                            }
                            
                            if (con == null || con.isClosed()) {
                        %>
                            <tr>
                                <td colspan="8" class="message error">
                                    Database connection failed!
                                </td>
                            </tr>
                        <%
                            } else {
                                PreparedStatement ps;
                                String query;
                                
                                // Filter products by seller_id if user is seller, otherwise show all products
                                if ("seller".equals(userRole) && sellerId != null) {
                                    query = "SELECT id, pid, product_name, brand, category_id, price, description FROM product WHERE Seller_id = ? ORDER BY id DESC";
                                    ps = con.prepareStatement(query);
                                    ps.setString(1, sellerId);
                                } else {
                                    query = "SELECT id, pid, product_name, brand, category_id, price, description FROM product ORDER BY id DESC";
                                    ps = con.prepareStatement(query);
                                }
                                ResultSet rs = ps.executeQuery();
                                
                                boolean hasProducts = false;
                                while(rs.next()) {
                                    hasProducts = true;
                        %>
                            <tr>
                                <td class="product-id">#<%= rs.getString("id") %></td>
                                <td class="product-id"><%= rs.getString("pid") != null ? rs.getString("pid") : "N/A" %></td>
                                <td class="product-name"><%= rs.getString("product_name") %></td>
                                <td class="product-name"><%= rs.getString("brand") != null ? rs.getString("brand") : "No Brand" %></td>
                                <td class="category-id"><%= rs.getString("category_id") %></td>
                                <td class="product-price"><%= String.format("%.2f", rs.getDouble("price")) %></td>
                                <td class="product-description"><%= rs.getString("description") != null ? rs.getString("description") : "No description" %></td>
                                <td>
                                    <form action="Deleteproducts.jsp" method="post" 
                                          onsubmit="return confirm('Are you sure you want to delete this product?')">
                                        <input type="hidden" name="productName" value="<%= rs.getString("product_name") %>">
                                        <button type="submit" class="delete-btn">🗑️ Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <%
                                }
                                
                                if (!hasProducts) {
                        %>
                            <tr>
                                <td colspan="8" class="no-products">
                                    <h3>📦 No Products Found</h3>
                                    <p>No products available to delete. Add some products first!</p>
                                </td>
                            </tr>
                        <%
                                }
                                
                                rs.close();
                                ps.close();
                                con.close();
                            }
                            
                        } catch (ClassNotFoundException e) {
                        %>
                            <tr>
                                <td colspan="8" class="message error">
                                    Database driver not found: <%= e.getMessage() %>
                                </td>
                            </tr>
                        <%
                        } catch (SQLException e) {
                        %>
                            <tr>
                                <td colspan="8" class="message error">
                                    Database error: <%= e.getMessage() %>
                                </td>
                            </tr>
                        <%
                        } catch (Exception e) {
                        %>
                            <tr>
                                <td colspan="8" class="message error">
                                    Error loading products: <%= e.getMessage() %>
                                </td>
                            </tr>
                        <%
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
