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
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);
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
        max-width: 1200px;
        margin: 0 auto;
    }
    
    header {
        text-align: center;
        margin-bottom: 30px;
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
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        padding: 30px;
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.3);
        max-height: calc(100vh - 200px);
        overflow-y: auto;
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }
    
    .form-field {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        padding: 20px;
        border-radius: 12px;
        border: 1px solid rgba(102, 126, 234, 0.1);
        transition: all 0.3s ease;
        position: relative;
    }
    
    .form-field::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 3px;
        height: 100%;
        background: linear-gradient(135deg, #667eea, #764ba2);
        transition: width 0.3s ease;
    }
    
    .form-field:hover::before {
        width: 5px;
    }
    
    .form-field:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(102, 126, 234, 0.15);
        border-color: rgba(102, 126, 234, 0.3);
    }
    
    .form-field-full {
        grid-column: 1 / -1;
    }
    
    .field-header {
        font-size: 0.85rem;
        font-weight: 600;
        color: #667eea;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .field-icon {
        font-size: 1.1rem;
    }
    
    .form-group {
        margin-bottom: 0;
    }
    
    label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 6px;
        font-size: 0.9rem;
    }
    
    input[type="text"],
    input[type="number"],
    input[type="file"],
    textarea,
    select {
        width: 100%;
        padding: 10px 14px;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: white;
        font-family: inherit;
    }
    
    input[type="text"]:focus,
    input[type="number"]:focus,
    input[type="file"]:focus,
    textarea:focus,
    select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        transform: translateY(-1px);
    }
    
    textarea {
        resize: vertical;
        min-height: 80px;
    }
    
    .id-display {
        background: linear-gradient(135deg, #e8f5e8, #d4edda);
        padding: 15px;
        border-radius: 12px;
        font-weight: bold;
        color: #2e7d32;
        text-align: center;
        margin-bottom: 25px;
        font-size: 1rem;
        border: 1px solid rgba(46, 125, 50, 0.2);
        box-shadow: 0 3px 10px rgba(46, 125, 50, 0.1);
    }
    
    .submit-btn {
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        border: none;
        padding: 15px 30px;
        border-radius: 12px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .submit-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }
    
    .submit-btn:hover::before {
        left: 100%;
    }
    
    .submit-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(76, 175, 80, 0.4);
    }
    
    .back-link {
        text-align: center;
        margin-top: 20px;
    }
    
    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1rem;
        padding: 12px 25px;
        border-radius: 25px;
        background: rgba(255,255,255,0.1);
        backdrop-filter: blur(10px);
        transition: all 0.3s ease;
        display: inline-block;
        border: 1px solid rgba(255,255,255,0.2);
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
    }
    
    @media (max-width: 768px) {
        .form-grid {
            grid-template-columns: 1fr;
            gap: 15px;
        }
        
        .form-field {
            padding: 15px;
        }
        
        .form-container {
            padding: 20px;
            max-height: none;
        }
        
        h1 {
            font-size: 2rem;
        }
    }
    
    @media (max-width: 480px) {
        .container {
            padding: 10px;
        }
        
        .form-container {
            padding: 15px;
        }
        
        h1 {
            font-size: 1.5rem;
        }
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <h1> Add New Product</h1>
            <p class="subtitle">Welcome, <%= username != null ? username : "Admin" %>! Add to menu</p>
            <div style="text-align: center; margin-bottom: 20px;">
               
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
                    <label for="category_id">Category</label>
                    <select id="category_id" name="category_id" required style="width: 100%; padding: 12px 16px; border: 2px solid #e1e5e9; border-radius: 8px; font-size: 1rem; background: #f8f9fa;">
                        <option value="">Select Category</option>
                        <option value="Mo">📱 Mobile</option>
                        <option value="Ms">👞 Men Shoe</option>
                        <option value="Lp">💻 Laptop</option>
                        <option value="Wt">⌚ Watch</option>
                        <option value="Hp">🎧 Headphones</option>
                        <option value="Ca">📷 Camera</option>
                    </select><br><br>
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