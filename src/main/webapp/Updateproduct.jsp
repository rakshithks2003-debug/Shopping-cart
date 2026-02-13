<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // Check if user is logged in
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
        !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
        response.sendRedirect("Login.html");
        return;
    }
    
    // Get user role and determine ID type
    String userRole = (String) sessionObj.getAttribute("userRole");
    String username = (String) sessionObj.getAttribute("username");
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
            System.err.println("Error fetching seller_id: " + e.getMessage());
        }
    }
    
    // Get restaurant parameter from request or session
    String restaurantId = request.getParameter("restaurant");
    
    // For restaurant users, get restaurantId from session
    if ("restaurant".equals(userRole)) {
        restaurantId = (String) sessionObj.getAttribute("restaurantId");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Products - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #8b5cf6;
            --primary-light: #a78bfa;
            --secondary: #ec4899;
            --accent: #14b8a6;
            --success: #22c55e;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #1e293b;
            --light: #f1f5f9;
            --white: #ffffff;
            --gray: #64748b;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: var(--dark);
            line-height: 1.6;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
            z-index: 0;
            pointer-events: none;
        }

        .page-wrapper {
            position: relative;
            z-index: 1;
        }

        /* Top Navigation Bar */
        .top-nav {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 12px 28px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
        }

        .back-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.5);
        }

        .user-badge {
            display: flex;
            align-items: center;
            gap: 12px;
            background: var(--light);
            padding: 10px 20px;
            border-radius: 50px;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.1rem;
        }

        .user-details {
            display: flex;
            flex-direction: column;
        }

        .user-name {
            font-weight: 600;
            color: var(--dark);
            font-size: 0.95rem;
        }

        .user-role {
            font-size: 0.75rem;
            color: var(--gray);
            text-transform: capitalize;
        }

        /* Page Header */
        .page-header {
            text-align: center;
            padding: 60px 20px 40px;
            color: white;
        }

        .page-header h1 {
            font-size: 3.5rem;
            font-weight: 900;
            margin-bottom: 15px;
            text-shadow: 0 4px 20px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 20px;
        }

        .page-header p {
            font-size: 1.3rem;
            opacity: 0.95;
            font-weight: 400;
        }

        /* Container */
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 30px 60px;
        }

        /* Search Bar */
        .search-bar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            padding: 25px 30px;
            border-radius: 25px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            margin-bottom: 40px;
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .search-icon {
            font-size: 1.5rem;
            color: var(--primary);
        }

        .search-input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid var(--light);
            border-radius: 15px;
            font-size: 1rem;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s;
            background: white;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1);
        }

        .btn-clear {
            padding: 15px 30px;
            background: var(--light);
            color: var(--gray);
            border: none;
            border-radius: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-family: 'Poppins', sans-serif;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-clear:hover {
            background: var(--gray);
            color: white;
            transform: translateY(-2px);
        }

        /* Alert Messages */
        .alert {
            padding: 20px 25px;
            border-radius: 20px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
            font-weight: 500;
            animation: slideIn 0.5s ease;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
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

        .alert-success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }

        .alert-error {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
        }

        .alert i {
            font-size: 1.8rem;
        }

        /* Update Form */
        .update-form {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 50px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            margin-bottom: 50px;
        }

        .form-title {
            font-size: 2.2rem;
            font-weight: 800;
            text-align: center;
            margin-bottom: 40px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }

        .form-label {
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 10px;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-label i {
            color: var(--primary);
        }

        .form-input,
        .form-textarea {
            padding: 15px 20px;
            border: 2px solid var(--light);
            border-radius: 15px;
            font-size: 1rem;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s;
            background: white;
        }

        .form-input:focus,
        .form-textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1);
        }

        .form-textarea {
            resize: vertical;
            min-height: 120px;
        }

        .form-hint {
            font-size: 0.85rem;
            color: var(--gray);
            margin-top: 8px;
        }

        .current-images {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .current-image {
            width: 100%;
            height: 140px;
            object-fit: cover;
            border-radius: 15px;
            border: 3px solid var(--light);
            transition: all 0.3s;
            cursor: pointer;
        }

        .current-image:hover {
            transform: scale(1.05);
            border-color: var(--primary);
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.3);
        }

        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 40px;
        }

        .btn {
            padding: 16px 40px;
            border: none;
            border-radius: 50px;
            font-size: 1.05rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            font-family: 'Poppins', sans-serif;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(139, 92, 246, 0.6);
        }

        .btn-secondary {
            background: var(--gray);
            color: white;
        }

        .btn-secondary:hover {
            background: var(--dark);
            transform: translateY(-3px);
        }

        /* Products Grid */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 35px;
        }

        .product-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
        }

        .product-card:hover {
            transform: translateY(-15px) scale(1.02);
            box-shadow: 0 25px 60px rgba(0,0,0,0.25);
        }

        .product-image {
            width: 100%;
            height: 240px;
            object-fit: cover;
            background: var(--light);
        }

        .product-content {
            padding: 30px;
        }

        .product-name {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 12px;
        }

        .product-desc {
            color: var(--gray);
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 20px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .product-price {
            font-size: 2rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 25px;
        }

        .btn-update {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, var(--warning), #f97316);
            color: white;
            border: none;
            border-radius: 15px;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-update:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(245, 158, 11, 0.5);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 100px 20px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
        }

        .empty-state i {
            font-size: 6rem;
            color: var(--gray);
            opacity: 0.3;
            margin-bottom: 25px;
        }

        .empty-state h3 {
            font-size: 2rem;
            color: var(--dark);
            margin-bottom: 15px;
        }

        .empty-state p {
            font-size: 1.1rem;
            color: var(--gray);
        }

        /* Footer */
        .footer {
            background: rgba(30, 41, 59, 0.95);
            backdrop-filter: blur(20px);
            color: white;
            padding: 40px 20px;
            text-align: center;
            margin-top: 80px;
        }

        .footer p {
            opacity: 0.9;
            font-size: 0.95rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .top-nav {
                padding: 15px 20px;
                flex-direction: column;
                gap: 15px;
            }

            .page-header h1 {
                font-size: 2.5rem;
                flex-direction: column;
                gap: 10px;
            }

            .search-bar {
                flex-direction: column;
                padding: 20px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .update-form {
                padding: 30px 20px;
            }

            .products-grid {
                grid-template-columns: 1fr;
            }

            .form-actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="page-wrapper">
        <!-- Top Navigation -->
        <div class="top-nav">
            <a href="javascript:history.back()" class="back-btn">
                <i class="fas fa-arrow-left"></i> Back
            </a>
            <div class="user-badge">
                <div class="user-avatar">
                    <%= username != null ? username.substring(0, 1).toUpperCase() : "U" %>
                </div>
                <div class="user-details">
                    <span class="user-name"><%= username != null ? username : "User" %></span>
                    <span class="user-role"><%= userRole != null ? userRole : "Guest" %></span>
                </div>
            </div>
        </div>

        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <i class="fas fa-edit"></i>
                Update Products
            </h1>
            <p>Manage and edit your product catalog</p>
        </div>

        <div class="container">
            <!-- Search Bar -->
            <div class="search-bar">
                <i class="fas fa-search search-icon"></i>
                <input type="text" id="searchInput" class="search-input" placeholder="Search products by name or description..." onkeyup="searchItems()">
                <button type="button" class="btn-clear" onclick="clearSearch()">
                    <i class="fas fa-times"></i> Clear
                </button>
            </div>

<%
    // Get item ID for updating
    String updateItemId = request.getParameter("updateId");
    
    // Check for update success message
    String updateMessage = request.getParameter("message");
    if (updateMessage != null && updateMessage.equals("success")) {
%>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <span>Product updated successfully!</span>
            </div>
<%
    }
    
    // If updateItemId is provided, show the update form
    if (updateItemId != null && !updateItemId.trim().isEmpty()) {
        try {
            Dbase db = new Dbase();
            Connection  con = db.initailizeDatabase();
            PreparedStatement ps;
            String productQuery;
            
            // Filter by seller_id if user is seller, otherwise get any product
            if ("seller".equals(userRole) && sellerId != null) {
                productQuery = "SELECT id, pid, product_name, price, description, image FROM product WHERE id=? AND Seller_id=?";
                ps = con.prepareStatement(productQuery);
                ps.setString(1, updateItemId);
                ps.setString(2, sellerId);
            } else {
                productQuery = "SELECT id, pid, product_name, price, description, image FROM product WHERE id=?";
                ps = con.prepareStatement(productQuery);
                ps.setString(1, updateItemId);
            }
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
%>
            <div class="update-form">
                <h2 class="form-title">
                    <i class="fas fa-pen-to-square"></i>
                    Edit Product Details
                </h2>
                <form action="UpdateServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="<%=rs.getString("id")%>">
                    <input type="hidden" name="restaurant" value="<%=restaurantId%>">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="name">
                                <i class="fas fa-tag"></i> Product Name
                            </label>
                            <input type="text" id="name" name="name" class="form-input" value="<%=rs.getString("product_name")%>" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="pid">
                                <i class="fas fa-barcode"></i> Product ID
                            </label>
                            <input type="text" id="pid" name="pid" class="form-input" value="<%=rs.getString("pid")%>" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="price">
                                <i class="fas fa-indian-rupee-sign"></i> Price
                            </label>
                            <input type="number" id="price" name="price" class="form-input" value="<%=rs.getDouble("price")%>" step="0.01" min="0" required>
                        </div>
                        
                        <div class="form-group full">
                            <label class="form-label" for="description">
                                <i class="fas fa-align-left"></i> Description
                            </label>
                            <textarea id="description" name="description" class="form-textarea"><%=rs.getString("description") != null ? rs.getString("description") : ""%></textarea>
                        </div>
                        
                        <div class="form-group full">
                            <label class="form-label" for="image">
                                <i class="fas fa-images"></i> Product Images
                            </label>
                            <input type="file" id="image" name="image" class="form-input" accept="image/*" multiple>
                            <span class="form-hint">Select up to 5 images. Leave empty to keep current images. Supported: JPG, PNG, GIF, WebP</span>
<%
        String currentImage = rs.getString("image");
        if (currentImage != null && !currentImage.trim().isEmpty()) {
            String[] currentImages = currentImage.split(",");
%>
                            <div class="current-images">
<%
            for (int i = 0; i < currentImages.length && i < 5; i++) {
                String img = currentImages[i].trim();
                if (!img.isEmpty()) {
%>
                                <img src="product_images/<%=img%>" alt="Product image <%=i+1%>" class="current-image">
<%
                }
            }
%>
                            </div>
<%
        } else {
%>
                            <div style="margin-top: 10px; color: var(--gray); font-size: 0.9rem;">
                                <em>No current images</em>
                            </div>
<%
        }
%>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Product
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="cancelUpdate()">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                    </div>
                </form>
            </div>
<%
            }
            
            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
%>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-triangle"></i>
                <span>Error loading product: <%=e.getMessage()%></span>
            </div>
<%
        }
    }
    
try {
    Dbase db = new Dbase();
    Connection  con = db.initailizeDatabase();
    PreparedStatement ps;
    String query;
    
    // Filter products by seller_id if user is seller, otherwise show all products
    if ("seller".equals(userRole) && sellerId != null) {
        query = "SELECT id, product_name, price, image, description FROM product WHERE Seller_id = ? ORDER BY id DESC";
        ps = con.prepareStatement(query);
        ps.setString(1, sellerId);
    } else {
        query = "SELECT id, product_name, price, image, description FROM product ORDER BY id DESC";
        ps = con.prepareStatement(query);
    }
    
    ResultSet rs = ps.executeQuery();
    
    boolean hasItems = false;
%>
            <div class="products-grid">
<%
    while(rs.next()) {
        hasItems = true;
%>
                <div class="product-card">
<%
        String imageFileName = rs.getString("image");
        String imageSrc = "";
        
        if (imageFileName != null && !imageFileName.trim().isEmpty()) {
            String[] images = imageFileName.split(",");
            if (images.length > 0 && !images[0].trim().isEmpty()) {
                imageSrc = "product_images/" + images[0].trim();
            }
        }
        
        if (imageSrc.isEmpty()) {
            imageSrc = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='300' viewBox='0 0 400 300'%3E%3Crect fill='%23f1f5f9' width='400' height='300'/%3E%3Ctext fill='%2394a3b8' font-family='Arial' font-size='18' x='50%25' y='50%25' text-anchor='middle' dominant-baseline='middle'%3ENo Image%3C/text%3E%3C/svg%3E";
        }
%>
                    <img class="product-image" src="<%=imageSrc%>" alt="<%=rs.getString("product_name")%>">
                    <div class="product-content">
                        <div class="product-name"><%=rs.getString("product_name")%></div>
<%
        String description = rs.getString("description");
        if (description != null && !description.trim().isEmpty()) {
%>
                        <div class="product-desc"><%=description%></div>
<%
        }
%>
                        <div class="product-price">₹<%=String.format("%.2f", rs.getDouble("price"))%></div>
                        <form action="Updateproduct.jsp" method="get">
                            <input type="hidden" name="updateId" value="<%=rs.getString("id")%>">
                            <input type="hidden" name="restaurant" value="<%=restaurantId%>">
                            <button type="submit" class="btn-update">
                                <i class="fas fa-pen-to-square"></i> Edit Product
                            </button>
                        </form>
                    </div>
                </div>
<%
    }
    
    if (!hasItems) {
%>
                <div class="empty-state" style="grid-column: 1 / -1;">
                    <i class="fas fa-box-open"></i>
                    <h3>No Products Found</h3>
                    <p>There are no products available to update at this time.</p>
                </div>
<%
    }
%>
            </div>
<%
    
    rs.close();
    ps.close();
    con.close();
    
} catch (Exception e) {
%>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-triangle"></i>
                <span>Error loading products: <%=e.getMessage()%></span>
            </div>
<%
}
%>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>&copy; 2026 Mini Shopping Cart. All rights reserved.</p>
        </div>
    </div>
    
    <script>
        function searchItems() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const productCards = document.querySelectorAll('.product-card');
            
            productCards.forEach(card => {
                const productName = card.querySelector('.product-name').textContent.toLowerCase();
                const productDesc = card.querySelector('.product-desc');
                const descText = productDesc ? productDesc.textContent.toLowerCase() : '';
                
                if (productName.includes(searchTerm) || descText.includes(searchTerm)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }
        
        function clearSearch() {
            document.getElementById('searchInput').value = '';
            searchItems();
        }
        
        function cancelUpdate() {
            window.location.href = 'Updateproduct.jsp';
        }
    </script>
</body>
</html>
