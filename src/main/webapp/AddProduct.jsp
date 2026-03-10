<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession, java.sql.*" %>
<%
// Check if user is logged in and is a seller
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.jsp");
    return;
}
String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Check if user is a seller
if (!"seller".equals(userRole)) {
    response.sendRedirect("Home.jsp");
    return;
}

// Fetch seller_id from users table for seller role
String sellerId = null;
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
    System.err.println("Error fetching seller_id: " + e.getMessage());
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Product - Seller Dashboard</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh; padding: 20px;
    }
    .header {
        background: rgba(255, 255, 255, 0.95);
        padding: 20px; text-align: center;
        color: #333; border-radius: 15px; margin-bottom: 30px;
    }
    .container {
        max-width: 800px; margin: 0 auto;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px; padding: 40px;
    }
    .form-group { margin-bottom: 20px; }
    .form-group label {
        display: block; margin-bottom: 8px;
        font-weight: 600; color: #333;
    }
    .form-group input, .form-group select, .form-group textarea {
        width: 100%; padding: 12px;
        border: 2px solid #e1e5e9; border-radius: 8px;
        font-size: 14px;
    }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .btn {
        padding: 12px 20px; border: none; border-radius: 8px;
        font-size: 16px; font-weight: 600; cursor: pointer;
        text-decoration: none; text-align: center;
    }
    .btn-primary {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
    }
    .btn-secondary { background: #6c757d; color: white; }
    .btn-success { background: #28a745; color: white; }
    .btn-group { display: flex; gap: 15px; margin-top: 20px; }
    .back-btn {
        position: fixed; top: 20px; left: 20px;
        background: #6c757d; color: white;
        padding: 10px 20px; border-radius: 25px;
        text-decoration: none; font-weight: 600;
    }
</style>
</head>
<body>
    <a href="SellerDashboard.jsp" class="back-btn">
        <i class="fas fa-arrow-left"></i> Back 
    </a>
    
    <div class="header">
        <h1><i class="fas fa-plus-circle"></i> Add New Product</h1>
        <p>Add a new product to your store inventory</p>
    </div>
    
    <div class="container">
        <%-- Display success or error messages --%>
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null && !error.trim().isEmpty()) {
        %>
            <div style="background: #f8d7da; color: #721c24; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <%
            }
            if (success != null && !success.trim().isEmpty()) {
        %>
            <div style="background: #d4edda; color: #155724; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
                <i class="fas fa-check-circle"></i> <%= success %>
            </div>
        <%
            }
        %>
        
        <form action="AddProductServlet" method="post" enctype="multipart/form-data">
            <div class="form-row">
                <div class="form-group">
                    <label for="productId">Product ID *</label>
                    <input type="text" id="productId" name="productId" required 
                           placeholder="Enter product ID (e.g., P1234)">
                </div>
                <div class="form-group">
                    <label for="productName">Product Name *</label>
                    <input type="text" id="productName" name="productName" required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="brand">Brand *</label>
                    <input type="text" id="brand" name="brand" required>
                </div>
                <div class="form-group">
                    <label for="category">Category *</label>
                    <select id="category" name="category" required>
                    <option value="">Select Category</option>
                    <option value="Mo">📱 Mobile</option>
                        <option value="Ms">👞 Men Shoe</option>
                        <option value="Lp">💻 Laptop</option>
                        <option value="Wo">👗Fashion</option>
                 
                    </select>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="price">Price *</label>
                    <input type="number" id="price" name="price" required min="0" step="0.01">
                </div>
                <div class="form-group">
                    <!-- Empty div for layout balance -->
                </div>
            </div>
            
            <div class="form-group">
                <label for="description">Description *</label>
                <textarea id="description" name="description" required rows="4"></textarea>
            </div>
            
            <div class="form-group">
                <label for="productImage">Product Images *</label>
                <input type="file" id="productImage" name="productImage" 
                       accept="image/*" multiple required>
            </div>
            
            <div class="btn-group">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Add Product
                </button>
                <button type="reset" class="btn btn-secondary">
                    <i class="fas fa-redo"></i> Reset
                </button>
            </div>
        </form>
    </div>
    
    <script>
        // Form validation can be added here if needed
    </script>
</body>
</html>