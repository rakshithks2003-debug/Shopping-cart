<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mini Shopping Cart - Home</title>
<style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            color: #333;
            overflow-x: hidden;
        }

        /* Header Styles */
        .main-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .logo-section {
            display: flex;
            flex-direction: column;
        }

        .institution-name {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .app-name {
            font-size: 2.2rem;
            font-weight: 800;
            margin: 0;
        }

        .user-info {
            background: rgba(255, 255, 255, 0.2);
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 500;
            backdrop-filter: blur(10px);
        }

        /* Search Bar Section */
        .search-section {
            background: white;
            padding: 30px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .search-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 20px;
            text-align: center;
        }

        .search-title {
            font-size: 1.8rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
        }

        .search-box {
            display: flex;
            max-width: 600px;
            margin: 0 auto;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-radius: 50px;
            overflow: hidden;
            background: white;
        }

        .search-input {
            flex: 1;
            padding: 15px 25px;
            border: none;
            font-size: 1.1rem;
            outline: none;
            background: transparent;
        }

        .search-input::placeholder {
            color: #999;
        }

        .search-button {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 0 30px;
            cursor: pointer;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .search-button:hover {
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            transform: scale(1.05);
        }

        /* Navigation */
        .navigation {
            background: white;
            padding: 15px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .nav-link {
            color: #333;
            text-decoration: none;
            padding: 12px 25px;
            border-radius: 25px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .nav-link:hover {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        /* Hero Section */
        .hero-section {
            background: white;
            padding: 60px 20px;
            text-align: center;
            margin: 30px auto;
            max-width: 1200px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }

        .hero-title {
            font-size: 2.8rem;
            font-weight: 800;
            color: #333;
            margin-bottom: 15px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-subtitle {
            font-size: 1.3rem;
            color: #666;
            font-weight: 400;
            max-width: 600px;
            margin: 0 auto 30px;
        }

        /* Categories Section */
        .categories-section {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .section-title {
            text-align: center;
            font-size: 2.2rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 40px;
            position: relative;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 4px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 2px;
        }

        .categories-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 30px;
        }

        .category-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            transition: all 0.4s ease;
            cursor: pointer;
            border: 2px solid transparent;
        }

        .category-card:hover {
            transform: translateY(-10px) scale(1.03);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            border-color: #667eea;
        }

        .category-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 20px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transition: all 0.3s ease;
        }

        .category-card:hover .category-icon {
            transform: scale(1.1) rotate(5deg);
        }

        .category-name {
            font-size: 1.5rem;
            font-weight: 700;
            color: #333;
            margin: 15px 0 10px;
        }

        .category-description {
            color: #666;
            font-size: 1rem;
            line-height: 1.5;
        }

        /* Footer */
        .footer {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            padding: 30px 20px;
            margin-top: 60px;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
        }

        .developers {
            font-size: 1.1rem;
            margin-top: 10px;
            opacity: 0.9;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                text-align: center;
            }

            .institution-name {
                font-size: 1.5rem;
            }

            .app-name {
                font-size: 1.8rem;
            }

            .search-box {
                flex-direction: column;
                border-radius: 20px;
            }

            .search-input, .search-button {
                width: 100%;
                border-radius: 0;
                padding: 15px;
            }

            .search-input {
                border-bottom: 1px solid #eee;
            }

            .hero-title {
                font-size: 2.2rem;
            }

            .categories-grid {
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
            }

            .nav-container {
                flex-direction: column;
                align-items: center;
            }

            .nav-link {
                width: 100%;
                max-width: 300px;
                justify-content: center;
            }
        }

        @media (max-width: 480px) {
            .categories-grid {
                grid-template-columns: 1fr;
            }

            .hero-title {
                font-size: 1.8rem;
            }

            .section-title {
                font-size: 1.8rem;
            }

            .category-icon {
                width: 80px;
                height: 80px;
                font-size: 2.5rem;
            }
        }
    </style>
</head>

<body>
    <!-- Main Header -->
    <header class="main-header">
        <div class="header-content">
            <div class="logo-section">
                <h2 class="institution-name">Cauvery Polytechnic Gonikoppal</h2>
                <h1 class="app-name">Mini Shopping Cart</h1>
            </div>
            <div class="user-info">
                👤 <%= username != null ? username : "User" %> (<%= userRole != null ? userRole : "Guest" %>)
            </div>
        </div>
    </header>

    <!-- Search Section -->
    <section class="search-section">
        <div class="search-container">
            <h2 class="search-title">Find Your Perfect Product</h2>
            <div class="search-box">
                <input type="text" class="search-input" placeholder="Search for products, brands, categories..." id="searchInput">
                <button class="search-button" onclick="performSearch()">🔍 Search</button>
            </div>
        </div>
    </section>

    <!-- Navigation -->
    <nav class="navigation">
        <div class="nav-container">
            <a href="Cart.jsp" class="nav-link">🛒 Cart</a>
            <a href="DeliveryTracking.jsp" class="nav-link">🚚 Track Order</a>
            <a href="Profile.jsp" class="nav-link">👤 My Profile</a>
            <% if ("admin".equals(userRole)) { %>
                <a href="Dashboard.jsp" class="nav-link">🔧 Admin Panel</a>
            <% } %>
            <a href="LogoutServlet" class="nav-link">🚪 Logout</a>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <h1 class="hero-title">Welcome to Our Store</h1>
        <p class="hero-subtitle">Discover amazing products at unbeatable prices. Shop smart, shop easy with our curated collection.</p>
    </section>

    <!-- Categories Section -->
    <section class="categories-section">
        <h2 class="section-title">Shop by Category</h2>
        <div class="categories-grid">
            <div class="category-card" onclick="window.location.href='Showproducts.jsp?category=Mo'">
                <div class="category-icon">📱</div>
                <h3 class="category-name">Mobile Phones</h3>
                <p class="category-description">Latest smartphones and accessories at competitive prices</p>
            </div>
            
            <div class="category-card" onclick="window.location.href='Showproducts.jsp?category=Ms'">
                <div class="category-icon">👟</div>
                <h3 class="category-name">Men's Shoes</h3>
                <p class="category-description">Stylish and comfortable footwear for every occasion</p>
            </div>
            
            <div class="category-card" onclick="window.location.href='Showproducts.jsp?category=Lp'">
                <div class="category-icon">💻</div>
                <h3 class="category-name">Laptops</h3>
                <p class="category-description">High-performance laptops for work and entertainment</p>
            </div>
              <div class="category-card" onclick="window.location.href='Showproducts.jsp?category=Wo'">
                <div class="category-icon">👗</div>
                <h3 class="category-name"> Fashion</h3>
                <p class="category-description">Trendy clothing and accessories for women</p>
            </div>
            
           
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-content">
            <p>© 2024 Mini Shopping Cart - All Rights Reserved</p>
            <p class="developers">Developed and Designed by Rakshith.k.S, Saajida.A.M, Prajwal.B.R, Mohammed Adil</p>
        </div>
    </footer>

    <script>
        // Search functionality
        function performSearch() {
            const searchTerm = document.getElementById('searchInput').value.trim();
            if (searchTerm) {
                // Redirect to search results page with the search term
                window.location.href = 'SearchResults.jsp?query=' + encodeURIComponent(searchTerm);
            } else {
                alert('Please enter a search term');
            }
        }

        // Allow search on Enter key
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                performSearch();
            }
        });

        // Add animation to category cards on hover
        document.querySelectorAll('.category-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.animation = 'pulse 0.5s ease';
            });
            
            card.addEventListener('animationend', function() {
                this.style.animation = '';
            });
        });

        // Add keyframes for pulse animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes pulse {
                0% { transform: scale(1); }
                50% { transform: scale(1.05); }
                100% { transform: scale(1); }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>