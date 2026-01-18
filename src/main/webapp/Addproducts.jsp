<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}

// Check if user has admin role
String userRole = (String) sessionObg.getAttribute("userRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect("users.html");
    return;
}

String username = (String) sessionObg.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Product - Mini Shopping cart</title>
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
        max-width: 600px;
        margin: 0 auto;
    }
    
    header {
        text-align: center;
        margin-bottom: 40px;
        color: white;
    }
    
    h1 {
        font-size: 2.5rem;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .subtitle {
        font-size: 1.1rem;
        opacity: 0.9;
        margin-bottom: 20px;
    }
    
    .form-container {
        background: white;
        padding: 40px;
        border-radius: 15px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.1);
    }
    
    .form-group {
        margin-bottom: 20px;
    }
    
    label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        font-size: 1rem;
    }
    
    input[type="text"],
    input[type="number"],
    input[type="file"] {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 1rem;
        transition: border-color 0.3s ease;
        background: #f8f9fa;
    }
    
    input[type="text"]:focus,
    input[type="number"]:focus,
    input[type="file"]:focus {
        outline: none;
        border-color: #667eea;
        background: white;
    }
    
    .id-display {
        background: #e8f5e8;
        padding: 12px 16px;
        border-radius: 8px;
        font-weight: bold;
        color: #2e7d32;
        text-align: center;
        margin-bottom: 20px;
        font-size: 1.1rem;
    }
    
    .submit-btn {
        background: #4CAF50;
        color: white;
        border: none;
        padding: 14px 28px;
        border-radius: 8px;
        font-size: 1.1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .submit-btn:hover {
        background: #45a049;
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    }
    
    .back-link {
        text-align: center;
        margin-top: 30px;
    }
    
    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1.1rem;
        padding: 12px 24px;
        border-radius: 25px;
        background: rgba(255,255,255,0.1);
        transition: all 0.3s ease;
        display: inline-block;
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🍽️ Add New Product</h1>
            <p class="subtitle">Welcome, <%= username != null ? username : "Admin" %>! Add to menu</p>
            <div style="text-align: center; margin-bottom: 20px;">
                <a href="LogoutServlet" class="admin-btn" style="background: #f44336; text-decoration: none; padding: 10px 20px; border-radius: 5px; color: white;">🚪 Logout</a>
            </div>
        </header>
        
        <div class="form-container">
            <div class="id-display">
                🆔 Enter ID
            </div>
            
            <form action="Uploadproducts" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="pid">ID</label>
                    <input type="text" id="pid" name="pid" placeholder="Enter ID (A-Z, 0-9)" pattern="[A-Za-z0-9]+" title="Only alphabetic characters allowed" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="pname">Product Name</label>
                    <input type="text" id="pname" name="pname" placeholder="Enter product name" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="price">Price (₹)</label>
                    <input type="number" id="price" name="price" placeholder="0.00" step="0.01" min="0" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" placeholder="Enter product description" rows="4" style="width: 100%; padding: 12px 16px; border: 2px solid #e1e5e9; border-radius: 8px; font-size: 1rem; font-family: inherit; resize: vertical; background: #f8f9fa;"></textarea><br><br>
                </div>
                
                <div class="form-group">
                    <label for="img">Product Image</label>
                    <input type="file" id="img" name="img" accept="image/*" required><br><br>
                </div>
                
                <button type="submit" class="submit-btn">📤 Upload Product</button>
            </form>
        </div><br><br>
        
        <div class="back-link">
            <a href="Showproducts.jsp">← View All Products</a>
        </div>
    </div>
</body>
</html>