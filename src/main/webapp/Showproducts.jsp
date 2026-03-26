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
    response.sendRedirect("Login.jsp");
    return;
}

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Show Products -  Shopping cart</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="css/back-button-styles.css">
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
    
    .back-button {
        position: fixed;
        top: 20px;
        left: 20px;
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        padding: 10px 20px;
        border-radius: 25px;
        text-decoration: none;
        font-weight: 600;
        font-size: 14px;
        box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
        transition: all 0.3s ease;
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 5px;
    }
    
    .back-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
        background: linear-gradient(135deg, #45a049, #3d8b40);
    }
    
    /* ========================================
       BACK TO HOME BUTTON STYLES
       ======================================== */
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
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        cursor: pointer;
        white-space: nowrap;
        text-transform: none;
        letter-spacing: 0.5px;
    }

    .back-to-home-btn-left:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
        background: linear-gradient(135deg, #45a049, #3d8b40);
        border-color: rgba(255, 255, 255, 0.1);
        text-decoration: none;
        color: white;
    }

    .back-to-home-btn-left:active {
        transform: translateY(0);
        box-shadow: 0 2px 10px rgba(76, 175, 80, 0.3);
        transition: all 0.1s ease;
    }

    .back-to-home-btn-left:focus {
        outline: none;
        box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3), 0 0 0 3px rgba(76, 175, 80, 0.2);
    }

    /* Icon styling */
    .back-to-home-btn-left i {
        font-size: 16px;
        margin-right: 2px;
        transition: transform 0.3s ease;
    }

    .back-to-home-btn-left:hover i {
        transform: scale(1.1);
    }

    /* Responsive design */
    @media (max-width: 768px) {
        .back-to-home-btn-left {
            top: 15px;
            left: 15px;
            padding: 10px 16px;
            font-size: 13px;
            border-radius: 20px;
        }
        
        .back-to-home-btn-left i {
            font-size: 14px;
        }
    }

    @media (max-width: 480px) {
        .back-to-home-btn-left {
            top: 10px;
            left: 10px;
            padding: 8px 14px;
            font-size: 12px;
            border-radius: 18px;
            gap: 6px;
        }
        
        .back-to-home-btn-left i {
            font-size: 13px;
        }
    }

    /* High contrast mode support */
    @media (prefers-contrast: high) {
        .back-to-home-btn-left {
            border: 2px solid #ffffff;
            background: #4CAF50;
        }
        
        .back-to-home-btn-left:hover {
            background: #45a049;
            border: 2px solid #ffffff;
        }
    }

    /* Reduced motion support */
    @media (prefers-reduced-motion: reduce) {
        .back-to-home-btn-left {
            transition: none;
        }
        
        .back-to-home-btn-left:hover {
            transform: none;
            transition: none;
        }
        
        .back-to-home-btn-left i {
            transition: none;
        }
        
        .back-to-home-btn-left:hover i {
            transform: none;
        }
    }

    /* Dark mode support */
    @media (prefers-color-scheme: dark) {
        .back-to-home-btn-left {
            background: linear-gradient(135deg, #45a049, #3d8b40);
            box-shadow: 0 4px 15px rgba(69, 160, 73, 0.4);
        }
        
        .back-to-home-btn-left:hover {
            background: linear-gradient(135deg, #3d8b40, #2e7d32);
            box-shadow: 0 6px 20px rgba(69, 160, 73, 0.5);
        }
    }

    /* Print styles */
    @media print {
        .back-to-home-btn-left {
            display: none !important;
        }
    }

    /* Loading state */
    .back-to-home-btn-left.loading {
        pointer-events: none;
        opacity: 0.7;
    }

    .back-to-home-btn-left.loading i::before {
        content: "\f110"; /* fa-spinner */
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* Success state */
    .back-to-home-btn-left.success {
        background: linear-gradient(135deg, #28a745, #20c997);
        animation: pulse 0.5s ease;
    }

    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
    }

    /* Error state */
    .back-to-home-btn-left.error {
        background: linear-gradient(135deg, #dc3545, #c82333);
        animation: shake 0.5s ease;
    }

    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-5px); }
        75% { transform: translateX(5px); }
    }

    .container {
        max-width: 1200px;
        margin: 0 auto;
    }
    
    header {
        text-align: center;
        padding: 40px 20px;
        color: white;
    }
    
    h1 {
        font-size: 3rem;
        font-weight: 700;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .subtitle {
        font-size: 1.2rem;
        opacity: 0.9;
        margin-bottom: 30px;
    }
    
    .nav-buttons {
        display: flex;
        justify-content: center;
        gap: 15px;
        flex-wrap: wrap;
    }
    
    .nav-btn {
        padding: 12px 25px;
        border: none;
        border-radius: 10px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
        cursor: pointer;
        font-size: 1rem;
    }
    
    .nav-btn.cart {
        background: linear-gradient(135deg, #ff6b6b, #ee5a24);
        color: white;
        position: relative;
    }
    
    .nav-btn.logout {
        background: linear-gradient(135deg, #fa709a, #fee140);
        color: white;
    }
    
    .cart-badge {
        position: absolute;
        top: -8px;
        right: -8px;
        background: #fff;
        color: #ff6b6b;
        border-radius: 50%;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        font-weight: 700;
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }
    
    .nav-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
    }
    
    .products-section {
        background: rgba(255, 255, 255, 0.95);
        border-radius: 20px;
        padding: 40px;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        backdrop-filter: blur(10px);
    }
    
    .section-header {
        text-align: center;
        margin-bottom: 50px;
    }
    
    .section-title {
        font-size: 2.5rem;
        color: #333;
        margin-bottom: 10px;
        font-weight: 700;
    }
    
    .section-subtitle {
        color: #666;
        font-size: 1.1rem;
    }
    
    .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 30px;
        margin-bottom: 40px;
    }
    
    .product-card {
        background: white;
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        position: relative;
        border: 1px solid rgba(0, 0, 0, 0.05);
    }
    
    .product-card:hover {
        transform: translateY(-10px) scale(1.02);
        box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
    }
    
    .product-image-wrapper {
        position: relative;
        overflow: hidden;
        height: 220px;
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
    }
    
    .product-image {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.6s ease;
        cursor: pointer;
    }
    
    .product-card:hover .product-image {
        transform: scale(1.1);
    }
    
    /* Multiple Images Display */
    .product-images-container {
        position: relative;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .product-image-nav {
        position: absolute;
        top: 100%;
        transform: translateY(-50%);
        background: rgba(255, 255, 255, 0.9);
        color: #333;
        border: none;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        z-index: 10;
        backdrop-filter: blur(5px);
    }
    
    .product-image-nav:hover {
        background: rgba(255, 255, 255, 1);
        transform: translateY(-50%) scale(1.1);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    }
    
    .product-image-nav.prev {
        left: 10px;
    }
    
    .product-image-nav.next {
        right: 10px;
    }
    
    .product-image-nav.disabled {
        opacity: 0.3;
        cursor: not-allowed;
        transform: translateY(-50%);
    }
    
    .product-image-nav.disabled:hover {
        background: rgba(255, 255, 255, 0.9);
        transform: translateY(-50%);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    }
    
    .product-image-counter {
        position: absolute;
        top: 10px;
        right: 10px;
        background: rgba(0, 0, 0, 0.7);
        color: white;
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 600;
        z-index: 5;
        backdrop-filter: blur(10px);
    }
    
    .product-thumbnails {
        position: absolute;
        bottom: 10px;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        gap: 4px;
        padding: 4px;
        background: rgba(0, 0, 0, 0.6);
        border-radius: 8px;
        backdrop-filter: blur(10px);
        max-width: 90%;
        overflow-x: auto;
        z-index: 5;
    }
    
    .product-thumbnail {
        width: 24px;
        height: 24px;
        object-fit: cover;
        border-radius: 4px;
        cursor: pointer;
        border: 1px solid transparent;
        transition: all 0.3s ease;
        flex-shrink: 0;
    }
    
    .product-thumbnail:hover {
        border-color: #667eea;
        transform: scale(1.1);
    }
    
    .product-thumbnail.active {
        border-color: #667eea;
        box-shadow: 0 0 0 1px rgba(102, 126, 234, 0.3);
    }
    
    .product-info {
        padding: 25px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .product-name {
        font-size: 1.4rem;
        font-weight: 600;
        color: #333;
        margin-bottom: 12px;
        line-height: 1.3;
    }
    
    .product-price {
        font-size: 1.8rem;
        font-weight: 700;
        color: #ff6b6b;
        margin-bottom: 20px;
        display: flex;
        align-items: baseline;
    }
    
    .product-price::before {
        content: "₹";
        margin-right: 4px;
        font-size: 1.4rem;
    }
    
    .no-products {
        text-align: center;
        padding: 80px 40px;
        color: #666;
    }
    
    .no-products h3 {
        font-size: 1.8rem;
        margin-bottom: 10px;
        color: #333;
    }
    
    .no-products p {
        font-size: 1.1rem;
        color: #666;
    }
    
    .error-message {
        background: linear-gradient(135deg, #f44336, #d32f2f);
        color: white;
        padding: 20px;
        border-radius: 15px;
        margin: 20px 0;
        text-align: center;
        font-weight: 500;
        box-shadow: 0 10px 25px rgba(244, 67, 54, 0.3);
    }
    
    footer {
        text-align: center;
        color: rgba(255, 255, 255, 0.8);
        margin-top: 50px;
        padding: 30px;
        font-size: 1rem;
    }
    
    /* Search Bar Styles */
    .search-section-with-cart {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        margin-bottom: 40px;
        backdrop-filter: blur(10px);
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 30px;
    }
    
    .search-section {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        margin-bottom: 40px;
        backdrop-filter: blur(10px);
    }
    
    .search-container {
        flex: 1;
        max-width: 700px;
    }
    
    .cart-section {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        min-width: 300px;
        gap: 10px;
        margin-top: 60px;
    }
    
    .nav-btn {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        padding: 12px 20px;
        text-decoration: none;
        border-radius: 25px;
        font-weight: 600;
        font-size: 14px;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 8px;
        border: 2px solid transparent;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        cursor: pointer;
        white-space: nowrap;
        text-transform: none;
        letter-spacing: 0.5px;
        position: relative;
    }
    
    .nav-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        background: linear-gradient(135deg, #5a6fd8, #6a4190);
        border-color: rgba(255, 255, 255, 0.1);
        text-decoration: none;
        color: white;
    }
    
    .nav-btn.cart {
        background: linear-gradient(135deg, #4CAF50, #45a049);
        box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
    }
    
    .nav-btn.cart:hover {
        background: linear-gradient(135deg, #45a049, #3d8b40);
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
    }
    
    .nav-btn.wishlist {
        background: linear-gradient(135deg, #e91e63, #c2185b);
        box-shadow: 0 4px 15px rgba(233, 30, 99, 0.3);
    }
    
    .nav-btn.wishlist:hover {
        background: linear-gradient(135deg, #c2185b, #ad1457);
        box-shadow: 0 6px 20px rgba(233, 30, 99, 0.4);
    }
    
    .cart-badge {
        background: #ff4757;
        color: white;
        border-radius: 50%;
        padding: 2px 6px;
        font-size: 12px;
        font-weight: bold;
        position: absolute;
        top: -8px;
        right: -8px;
        min-width: 20px;
        text-align: center;
        box-shadow: 0 2px 8px rgba(255, 71, 87, 0.4);
    }
    
    .search-title {
        text-align: center;
        font-size: 1.5rem;
        font-weight: 700;
        color: #333;
        margin-bottom: 20px;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .search-box {
        display: flex;
        gap: 10px;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
        border-radius: 50px;
        overflow: hidden;
        background: white;
    }
    
    .search-input {
        flex: 1;
        padding: 16px 25px;
        border: none;
        font-size: 1rem;
        outline: none;
        background: transparent;
        color: #333;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    .search-input::placeholder {
        color: #999;
    }
    
    .search-button {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        border: none;
        padding: 0 35px;
        cursor: pointer;
        font-size: 1rem;
        font-weight: 600;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .search-button:hover {
        background: linear-gradient(135deg, #5a6fd8, #6a4190);
        transform: scale(1.02);
    }
    
    .search-button i {
        font-size: 1.1rem;
    }
    
    .clear-search {
        display: none;
        text-align: center;
        margin-top: 15px;
    }
    
    .clear-search.show {
        display: block;
    }
    
    .clear-btn {
        background: transparent;
        color: #667eea;
        border: 2px solid #667eea;
        padding: 8px 20px;
        border-radius: 20px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s ease;
        font-size: 0.9rem;
    }
    
    .clear-btn:hover {
        background: #667eea;
        color: white;
    }
    
    .no-results {
        display: none;
        text-align: center;
        padding: 60px 20px;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 20px;
        margin-top: 30px;
    }
    
    .no-results.show {
        display: block;
    }
    
    .no-results i {
        font-size: 4rem;
        color: #667eea;
        margin-bottom: 20px;
        opacity: 0.5;
    }
    
    .no-results h3 {
        font-size: 1.8rem;
        color: #333;
        margin-bottom: 10px;
    }
    
    .no-results p {
        color: #666;
        font-size: 1.1rem;
    }
    
    @media (max-width: 768px) {
        .products-grid {
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
        }
        
        .search-section-with-cart {
            padding: 20px;
            flex-direction: column;
            gap: 20px;
        }
        
        .search-box {
            flex-direction: column;
            border-radius: 20px;
        }
        
        .search-input, .search-button {
            width: 100%;
            padding: 14px 20px;
            border-radius: 0;
        }
        
        .search-input {
            border-bottom: 1px solid #eee;
        }
        
        .cart-section {
            justify-content: center;
            min-width: auto;
        }
    }
    
    @media (max-width: 480px) {
        .products-grid {
            grid-template-columns: 1fr;
        }
        
        .search-title {
            font-size: 1.2rem;
        }
    }
</style>
</head>
<body>
    <!-- Back to Home Button -->
   <a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page"><i class="fas fa-home"></i> Back </a>

    <div class="container">
        <header>
            <h1>🛍️  Shopping cart</h1>
        </header>
        
        <!-- Search Section with Cart -->
        <div class="search-section-with-cart">
            <div class="search-container">
                <h2 class="search-title">
                    <% 
                    String searchParam = request.getParameter("search");
                    String categoryParam = request.getParameter("category");
                    if (searchParam != null && !searchParam.trim().isEmpty()) { 
                    %>
                        🔍 Search Results for "<%= searchParam %>"
                    <% } else if (categoryParam != null && !categoryParam.trim().isEmpty()) { 
                        String categoryName = "";
                        switch(categoryParam) {
                            case "Mo": categoryName = "Mobile Phones"; break;
                            case "Ms": categoryName = "Men's Shoes"; break;
                            case "Lp": categoryName = "Laptops"; break;
                            case "Wo": categoryName = "Fashion"; break;
                            default: categoryName = "Products"; break;
                        }
                    %>
                        📱 <%= categoryName %>
                    <% } else { %>
                        🔍 Find Your Perfect Product
                    <% } %>
                </h2>
                <div class="search-box">
                    <input type="text" class="search-input" id="searchInput" placeholder="Search for products, brands, categories..." onkeypress="handleSearchKeyPress(event)">
                    <button class="search-button" onclick="performSearch()">
                        <i class="fas fa-search"></i> Search
                    </button>
                </div>
                <div class="clear-search" id="clearSearchDiv">
                    <button class="clear-btn" onclick="clearSearch()">
                        <i class="fas fa-times"></i> Clear Search
                    </button>
                </div>
            </div>
            
            <!-- Cart and Wishlist Buttons -->
            <div class="cart-section">
                <a href="Cart.jsp" class="nav-btn cart" id="cartButton">
                    🛒 My Cart
                    <span class="cart-badge" id="cartBadge" style="display: none;">0</span>
                </a>
                <a href="Wishlist.jsp" class="nav-btn wishlist" id="wishlistButton">
                    ❤️ My Wishlist
                </a>
            </div>
        </div>
        
        <main>
            <div class="products-section">
                <div class="section-header">
                    <h2 class="section-title">Featured Products</h2>
                    <p class="section-subtitle">Discover our Accurated collection of premium items</p>
                </div>
                
                <div class="products-grid" id="productsGrid">
<%
try {
    Dbase db = new Dbase();
    Connection con = null;
    
    try {
    	 con = db.initailizeDatabase();
    } catch (Exception e) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
    }
    
    if (con == null || con.isClosed()) {
%>
                <div class="error-message">
                    ⚠️ Database connection failed!
                </div>
<%
    } else {
        PreparedStatement ps;
        String sql;
        String category = request.getParameter("category");
        String search = request.getParameter("search");
        
        if (category != null && !category.trim().isEmpty()) {
            // Filtering products by category
        }
        
        if (search != null && !search.trim().isEmpty()) {
            // Searching for products
        }
        
        // Filter by category if parameter is provided
        if (category != null && !category.trim().isEmpty()) {
            sql = "SELECT id, product_name, brand, price, image, description FROM product WHERE Category_id = ? ORDER BY id DESC";
            ps = con.prepareStatement(sql);
            ps.setString(1, category);
        } else if (search != null && !search.trim().isEmpty()) {
            // Search by product name, brand, or description
            sql = "SELECT id, product_name, brand, price, image, description FROM product WHERE " +
                  "LOWER(product_name) LIKE LOWER(?) OR " +
                  "LOWER(brand) LIKE LOWER(?) OR " +
                  "LOWER(description) LIKE LOWER(?) ORDER BY id DESC";
            ps = con.prepareStatement(sql);
            String searchPattern = "%" + search + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
        } else {
            // Show all products if no category or search filter
            sql = "SELECT id, product_name, brand, price, image, description FROM product ORDER BY id DESC";
            ps = con.prepareStatement(sql);
        }
        
        ResultSet rs = ps.executeQuery();
        
        boolean hasProducts = false;
        
        while(rs.next()) {
            hasProducts = true;
%>
                <div class="product-card">
<%
        String imageFileName = rs.getString("image");
        String[] imageArray = {};
        
        // Parse multiple images from comma-separated string
        if (imageFileName != null && !imageFileName.trim().isEmpty()) {
            imageArray = imageFileName.split(",");
            // Trim whitespace from each image name
            for (int i = 0; i < imageArray.length; i++) {
                imageArray[i] = imageArray[i].trim();
            }
        }
        
        String firstImageSrc = "";
        if (imageArray.length > 0) {
            firstImageSrc = "product_images/" + imageArray[0];
        } else {
            firstImageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIiLz4KPHBhdGggZD0iTTEzNy41IDkzLjc1TDE1MCAxMDYuMjVMMTYyLjUgOTMuNzVMMTc1IDExMi41SDE1MEgxMjVMMTM3LjUgOTMuNzVaIiBmaWxsPSIjQ0NDQ0NDIiLz4KPHRleHQgeD0iMTUwIiB5PSIxNjAiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IiM5OTk5OTkiIGZvbnQtc2l6ZT0iMTQiIGZvbnQtZmFtaWx5PSJBcmlhbCI+Tm8gSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==";
        }
%>
                    <div class="product-image-wrapper">
                        <div class="product-images-container">
                            <img id="productImage_<%=rs.getString("id")%>" class="product-image" src="<%=firstImageSrc%>" alt="<%=rs.getString("brand")%>" 
                                 onclick="window.location.href='Details.jsp?id=<%=rs.getString("id")%>'"
                                 onerror="tryFallbackImage(this, '<%=imageArray.length > 0 ? imageArray[0] : ""%>')">
                        </div>
                    </div>
                    <div class="product-info">
                        <div class="product-name"><%=rs.getString("brand")%></div>
                        <div class="product-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
                    </div>
                </div>
<%
        }
        
        if (!hasProducts) {
%>
                <div class="no-products">
                    <h3>📦 No items Yet</h3>
                    <p>Start by adding your first item to gallery!</p>
                </div>
<%
        }
        
        rs.close();
        ps.close();
        con.close();
    }
    
} catch (ClassNotFoundException e) {
%>
                <div class="error-message">
                    ⚠️ Database driver not found: <%=e.getMessage()%>
                </div>
<%
} catch (SQLException e) {
%>
                <div class="error-message">
                    ⚠️ Database error: <%=e.getMessage()%>
                </div>
<%
} catch (Exception e) {
%>
                <div class="error-message">
                    ⚠️ Error loading products: <%=e.getMessage()%>
                </div>
<%
}
%>
                </div>
            </div>
        </main>
        
        <footer>
            <p>&copy; 2026 Shopping cart.</p>
            <p class="developers">Developed and Designed by Rakshith.k.S, Saajida.A.M, Prajwal.B.R, Mohammed Adil</p>
        </footer>
    </div>
    
    <script>
        // Store product images data
        let productImagesData = {};
        
        // Initialize product images from JSP
        <%
        // Re-run the query to get all product images for JavaScript
        try {
            Dbase db2 = new Dbase();
            Connection con2 = null;
            String category = request.getParameter("category"); // Re-declare category variable
            String search = request.getParameter("search"); // Re-declare search variable
            
            try {
                con2 = db2.initailizeDatabase();
            } catch (Exception e) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con2 = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            }
            
            if (con2 != null && !con2.isClosed()) {
                PreparedStatement ps2;
                String sql2;
                
                // Get product images based on category filter or search
                if (category != null && !category.trim().isEmpty()) {
                    sql2 = "SELECT id, image FROM product WHERE Category_id = ? ORDER BY id DESC";
                    ps2 = con2.prepareStatement(sql2);
                    ps2.setString(1, category);
                } else if (search != null && !search.trim().isEmpty()) {
                    // Search by product name, brand, or description for images
                    sql2 = "SELECT id, image FROM product WHERE " +
                          "LOWER(product_name) LIKE LOWER(?) OR " +
                          "LOWER(brand) LIKE LOWER(?) OR " +
                          "LOWER(description) LIKE LOWER(?) ORDER BY id DESC";
                    ps2 = con2.prepareStatement(sql2);
                    String searchPattern = "%" + search + "%";
                    ps2.setString(1, searchPattern);
                    ps2.setString(2, searchPattern);
                    ps2.setString(3, searchPattern);
                } else {
                    sql2 = "SELECT id, image FROM product ORDER BY id DESC";
                    ps2 = con2.prepareStatement(sql2);
                }
                
                ResultSet rs2 = ps2.executeQuery();
                
                while(rs2.next()) {
                    String productId = rs2.getString("id");
                    String imageFileName = rs2.getString("image");
                    String[] imageArray = {};
                    
                    if (imageFileName != null && !imageFileName.trim().isEmpty()) {
                        imageArray = imageFileName.split(",");
                        for (int i = 0; i < imageArray.length; i++) {
                            imageArray[i] = imageArray[i].trim();
                        }
                    }
                    
                    out.print("productImagesData['" + productId + "'] = [");
                    for (int i = 0; i < imageArray.length; i++) {
                        if (i > 0) out.print(",");
                        out.print("'" + imageArray[i].replace("'", "\\'") + "'");
                    }
                    out.print("];");
                }
                
                rs2.close();
                ps2.close();
                con2.close();
            }
        } catch (Exception e) {
            // Handle error silently
        }
        %>
        
        // Store current image indices for each product
        let currentImageIndices = {};
        
        // Initialize product images on page load
        document.addEventListener('DOMContentLoaded', function() {
            Object.keys(productImagesData).forEach(productId => {
                currentImageIndices[productId] = 0;
                generateProductThumbnails(productId);
            });
        });
        
        // Navigate product images with arrows
        function navigateProductImage(productId, direction, event) {
            event.stopPropagation(); // Prevent card click
            
            const images = productImagesData[productId];
            if (!images || images.length <= 1) return;
            
            currentImageIndices[productId] += direction;
            
            // Wrap around
            if (currentImageIndices[productId] < 0) {
                currentImageIndices[productId] = images.length - 1;
            } else if (currentImageIndices[productId] >= images.length) {
                currentImageIndices[productId] = 0;
            }
            
            updateProductImageUI(productId);
        }
        
        // Update product image UI
        function updateProductImageUI(productId) {
            const images = productImagesData[productId];
            const currentIndex = currentImageIndices[productId];
            
            if (images && images.length > 0 && currentIndex >= 0 && currentIndex < images.length) {
                const imageName = images[currentIndex];
                const mainImage = document.getElementById('productImage_' + productId);
                const imageCounter = document.getElementById('imageCounter_' + productId);
                const prevBtn = document.getElementById('prevBtn_' + productId);
                const nextBtn = document.getElementById('nextBtn_' + productId);
                
                if (mainImage) {
                    mainImage.src = 'product_images/' + imageName;
                    mainImage.alt = 'Product Image ' + (currentIndex + 1);
                    mainImage.setAttribute('onerror', `tryFallbackImage(this, '${imageName}')`);
                }
                
                if (imageCounter) {
                    imageCounter.textContent = `${currentIndex + 1} / ${images.length}`;
                }
                
                // Update arrow states
                if (prevBtn && nextBtn) {
                    if (images.length <= 1) {
                        prevBtn.classList.add('disabled');
                        nextBtn.classList.add('disabled');
                    } else {
                        prevBtn.classList.remove('disabled');
                        nextBtn.classList.remove('disabled');
                    }
                }
                
                updateProductThumbnails(productId);
            }
        }
        
        // Generate thumbnails for a product
        function generateProductThumbnails(productId) {
            const images = productImagesData[productId];
            const thumbnailsContainer = document.getElementById('productThumbnails_' + productId);
            
            if (!thumbnailsContainer || !images || images.length <= 1) return;
            
            thumbnailsContainer.innerHTML = '';
            
            images.forEach((imageName, index) => {
                const thumb = document.createElement('img');
                thumb.src = 'product_images/' + imageName;
                thumb.className = 'product-thumbnail' + (index === currentImageIndices[productId] ? ' active' : '');
                thumb.onclick = (event) => {
                    event.stopPropagation();
                    goToProductImage(productId, index);
                };
                thumb.onmouseover = () => thumb.style.cursor = 'pointer';
                thumb.setAttribute('onerror', `tryFallbackImage(this, '${imageName}')`);
                thumbnailsContainer.appendChild(thumb);
            });
        }
        
        // Go to specific product image
        function goToProductImage(productId, index) {
            currentImageIndices[productId] = index;
            updateProductImageUI(productId);
        }
        
        // Update product thumbnails
        function updateProductThumbnails(productId) {
            const thumbnails = document.querySelectorAll('#productThumbnails_' + productId + ' .product-thumbnail');
            const currentIndex = currentImageIndices[productId];
            
            thumbnails.forEach((thumb, index) => {
                if (index === currentIndex) {
                    thumb.classList.add('active');
                } else {
                    thumb.classList.remove('active');
                }
            });
        }
        
        // Fallback image function
        function tryFallbackImage(img, fileName) {
            if (!fileName || fileName.trim() === '') {
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+';
                return;
            }
            
            if (img.src.includes('product_images/')) {
                const newSrc = img.src.replace('product_images/', 'seller_images/');
                img.src = newSrc;
            } else {
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4=';
            }
        }
        
        // ========================================
        // SEARCH FUNCTIONALITY
        // ========================================
        
        let allProducts = [];
        let currentFilter = 'all';
        
        // Store all products on page load
        document.addEventListener('DOMContentLoaded', function() {
            const productCards = document.querySelectorAll('.product-card');
            productCards.forEach(card => {
                const productName = card.querySelector('.product-name')?.textContent.toLowerCase() || '';
                const productPrice = card.querySelector('.product-price')?.textContent || '';
                allProducts.push({
                    element: card,
                    name: productName,
                    price: productPrice,
                    visible: true
                });
            });
        });
        
        // Search function
        function performSearch() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
            
            if (searchTerm === '') {
                showAllProducts();
                return;
            }
            
            let visibleCount = 0;
            
            allProducts.forEach(product => {
                const matchesSearch = product.name.includes(searchTerm);
                
                if (matchesSearch) {
                    product.element.style.display = 'block';
                    product.visible = true;
                    visibleCount++;
                } else {
                    product.element.style.display = 'none';
                    product.visible = false;
                }
            });
            
            // Show/hide no results message
            showNoResultsMessage(visibleCount === 0, searchTerm);
            
            // Show clear button
            document.getElementById('clearSearchDiv').classList.add('show');
        }
        
        // Handle Enter key press in search input
        function handleSearchKeyPress(event) {
            if (event.key === 'Enter') {
                performSearch();
            }
        }
        
        // Clear search
        function clearSearch() {
            document.getElementById('searchInput').value = '';
            showAllProducts();
            document.getElementById('clearSearchDiv').classList.remove('show');
        }
        
        // Show all products
        function showAllProducts() {
            allProducts.forEach(product => {
                product.element.style.display = 'block';
                product.visible = true;
            });
            
            showNoResultsMessage(false);
        }
        
        // Show/hide no results message
        function showNoResultsMessage(show, searchTerm = '') {
            let noResultsDiv = document.getElementById('noResultsMessage');
            
            if (!noResultsDiv) {
                // Create no results message div
                noResultsDiv = document.createElement('div');
                noResultsDiv.id = 'noResultsMessage';
                noResultsDiv.className = 'no-results';
                noResultsDiv.innerHTML = `
                    <i class="fas fa-search"></i>
                    <h3>No Products Found</h3>
                    <p>We couldn't find any products matching "<span id="searchTermDisplay"></span>"</p>
                    <p>Try adjusting your search or browse all products.</p>
                `;
                document.querySelector('.products-section').appendChild(noResultsDiv);
            }
            
            if (show) {
                document.getElementById('searchTermDisplay').textContent = searchTerm;
                noResultsDiv.classList.add('show');
            } else {
                noResultsDiv.classList.remove('show');
            }
        }
        
        // Real-time search (optional - searches as you type)
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    // Uncomment the line below for real-time search
                    // performSearch();
                });
            }
        });
    </script>
</body>
</html>