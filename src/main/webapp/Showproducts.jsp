<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.Dbase" %>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mini Shopping Cart - Products</title>
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
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        
        .header-content {
            text-align: center;
        }
        
        h1 {
            font-size: 3rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
            font-weight: 800;
        }
        
        .subtitle {
            color: #666;
            font-size: 1.2rem;
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
        
        .nav-btn.primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .nav-btn.admin {
            background: linear-gradient(135deg, #f093fb, #f5576c);
            color: white;
        }
        
        .nav-btn.logout {
            background: linear-gradient(135deg, #fa709a, #fee140);
            color: white;
        }
        
        .nav-btn.cart {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            position: relative;
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
        
        .product-info {
            padding: 25px;
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
        
        .product-description {
            color: #666;
            font-size: 0.9rem;
            line-height: 1.5;
        }
        
        .add-to-cart-btn {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 10px;
            width: 100%;
        }
        
        .add-to-cart-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
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
        
        @media (max-width: 768px) {
            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 20px;
            }
        }
        
        @media (max-width: 480px) {
            .products-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-content">
                <h1>🛍️ Mini Shopping cart</h1>
                <p class="subtitle">Browse our amazing cuisine</p>
                
                <div class="nav-buttons">
                    <a href="Addproducts.jsp" class="nav-btn primary">➕ Add New Product</a>
                    <a href="Cart.jsp" class="nav-btn cart" id="cartButton">
                        🛒 My Cart
                        <span class="cart-badge" id="cartBadge" style="display: none;">0</span>
                    </a>
                    <% if ("admin".equals(userRole)) { %>
                        <a href="admin.jsp" class="nav-btn admin">🔧 Admin Panel</a>
                    <% } else { %>
                        <a href="LogoutServlet" class="nav-btn logout">🚪 Logout</a>
                    <% } %>
                </div>
            </div>
        </header>
        
        <main>
            <div class="products-section">
                <div class="section-header">
                    <h2 class="section-title">Featured Products</h2>
                    <p class="section-subtitle">Discover our Accurated collection of premium items</p>
                </div>
                
                <div class="products-grid">
<%
String category = request.getParameter("category");

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
        
        if (category != null && !category.trim().isEmpty()) {
            sql = "SELECT id, name, price, image, description FROM product WHERE category_id = ? ORDER BY id DESC";
            ps = con.prepareStatement(sql);
            ps.setString(1, category);
        } else {
            sql = "SELECT id, name, price, image, description FROM product ORDER BY id DESC";
            ps = con.prepareStatement(sql);
        }
        
        ResultSet rs = ps.executeQuery();
        
        System.out.println("Showproducts: Executing query: " + sql);
        
        boolean hasProducts = false;
        int productCount = 0;
        
        while(rs.next()) {
            hasProducts = true;
            productCount++;
            if (productCount == 1) {
                System.out.println("Showproducts: Found first product - ID: " + rs.getString("id") + ", Name: " + rs.getString("name"));
            }
%>
                <div class="product-card">
<%
        String imageFileName = rs.getString("image");
        String imageSrc = "";
        
        if (imageFileName != null && !imageFileName.trim().isEmpty()) {
            // Try product_images first (for Addproducts.jsp uploads), then seller_images (for accepted seller products)
            imageSrc = "product_images/" + imageFileName;
            // Add fallback to seller_images for accepted products
            System.out.println("Showproducts: Trying image path: " + imageSrc);
        } else {
            imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+";
        }
%>
                    <div class="product-image-wrapper">
                        <img class="product-image" src="<%=imageSrc%>" alt="<%=rs.getString("name")%>" 
                             onclick="window.location.href='Details.jsp?id=<%=rs.getString("id")%>'"
                             onerror="tryFallbackImage(this, '<%=imageFileName%>')">
                    </div>
                    <div class="product-info">
                        <%
                        String productName = rs.getString("name");
                        String productId = rs.getString("id");
                        double productPrice = rs.getDouble("price");
                        String safeProductName = productName.replace("'", "\\'").replace("\"", "&quot;");
                        String safeImageFile = (imageFileName != null && !imageFileName.isEmpty()) ? imageFileName : "";
                        %>
                        <div class="product-name"><%=productName%></div>
                        <div class="product-price"><%=String.format("%.2f", productPrice)%></div>
                        <button class="add-to-cart-btn" data-id="<%= productId %>" data-name="<%= safeProductName %>" data-price="<%= productPrice %>" data-image="<%= safeImageFile %>" onclick="addToCartData(this)">
                            🛒 Add to Cart
                        </button>
                    </div>
                </div>
<%
        }
        
        System.out.println("Showproducts: Total products displayed: " + productCount);
        
        if (!hasProducts) {
%>
                <div class="no-products">
                    <h3>📦 No items Yet</h3>
                    <p>Start by adding your first item to the gallery!</p>
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
            <p>&copy; 2026 Mini Shopping cart.</p>
        </footer>
    </div>
    
    <script>
        // Test product table functionality
        function testProductTable() {
            console.log('Testing product table...');
            alert('Testing product table functionality. Check browser console for details.');
            
            const productCards = document.querySelectorAll('.product-card');
            console.log('Found ' + productCards.length + ' product cards on page');
            
            if (productCards.length === 0) {
                alert('No products found on page. Check if products were accepted from seller page.');
            } else {
                alert('Found ' + productCards.length + ' products displayed!');
                productCards.forEach((card, index) => {
                    const name = card.querySelector('.product-name');
                    const price = card.querySelector('.product-price');
                    console.log('Product ' + (index + 1) + ': ' + (name ? name.textContent : 'No name') + ' - ' + (price ? price.textContent : 'No price'));
                });
            }
        }
        
        // Show debug information
        function showDebugInfo() {
            console.log('Showproducts debug info:');
            console.log('Current URL:', window.location.href);
            console.log('User role:', '<%= userRole != null ? userRole : "Not set" %>');
            console.log('Username:', '<%= username != null ? username : "Not set" %>');
            
            const productCards = document.querySelectorAll('.product-card');
            const noProducts = document.querySelector('.no-products');
            const errorMessages = document.querySelectorAll('.error-message');
            
            let debugInfo = '=== DEBUG INFO ===\n';
            debugInfo += 'URL: ' + window.location.href + '\n';
            debugInfo += 'Products found: ' + productCards.length + '\n';
            debugInfo += 'No products message: ' + (noProducts ? 'Yes' : 'No') + '\n';
            debugInfo += 'Error messages: ' + errorMessages.length + '\n';
            
            if (productCards.length > 0) {
                debugInfo += '\nFirst product details:\n';
                const firstCard = productCards[0];
                const name = firstCard.querySelector('.product-name');
                const price = firstCard.querySelector('.product-price');
                const desc = firstCard.querySelector('.product-description');
                debugInfo += 'Name: ' + (name ? name.textContent : 'N/A') + '\n';
                debugInfo += 'Price: ' + (price ? price.textContent : 'N/A') + '\n';
                debugInfo += 'Description: ' + (desc ? desc.textContent.substring(0, 50) + '...' : 'N/A') + '\n';
            }
            
            alert(debugInfo);
            console.log(debugInfo);
        }
        
        // Auto-run debug on page load
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Showproducts page loaded');
            setTimeout(() => {
                const productCards = document.querySelectorAll('.product-card');
                console.log('Page load check - Found ' + productCards.length + ' products');
            }, 1000);
        });
        
        // Fallback image function - tries seller_images if product_images fails
        function tryFallbackImage(img, fileName) {
            if (!fileName || fileName.trim() === '') {
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+';
                return;
            }
            
            // If current src is product_images, try seller_images
            if (img.src.includes('product_images/')) {
                const newSrc = img.src.replace('product_images/', 'seller_images/');
                console.log('Image fallback: trying', newSrc);
                img.src = newSrc;
            } else {
                // If seller_images also fails, use placeholder
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz=';
            }
        }
        
        // Add to Cart function using data attributes
        function addToCartData(button) {
            const productId = button.getAttribute('data-id');
            const productName = button.getAttribute('data-name');
            const price = button.getAttribute('data-price');
            const image = button.getAttribute('data-image');
            
            const originalText = button.innerHTML;
            
            // Show loading state
            button.innerHTML = '⏳ Adding...';
            button.disabled = true;
            
            // Send AJAX request to CartServlet
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'CartServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    // Reset button
                    button.innerHTML = originalText;
                    button.disabled = false;
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                showNotification(response.message, 'success');
                                updateCartCount(response.cartSize);
                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing response:', e);
                            showNotification('Error adding to cart', 'error');
                        }
                    } else {
                        showNotification('Server error. Please try again.', 'error');
                    }
                }
            };
            
            const data = 'action=add&productId=' + encodeURIComponent(productId) + 
                        '&productName=' + encodeURIComponent(productName) + 
                        '&price=' + encodeURIComponent(price) + 
                        '&image=' + encodeURIComponent(image || '');
            xhr.send(data);
        }
        
        // Show notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 600; z-index: 10000; animation: slideIn 0.3s ease; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            }
            
            notification.textContent = message;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.animation = 'slideOut 0.3s ease forwards';
                setTimeout(() => {
                    if (notification.parentNode) {
                        document.body.removeChild(notification);
                    }
                }, 300);
            }, 3000);
        }
        
        // Update cart count badge
        function updateCartCount(count) {
            const badge = document.getElementById('cartBadge');
            if (count && count > 0) {
                badge.textContent = count;
                badge.style.display = 'flex';
            } else {
                badge.style.display = 'none';
            }
        }
        
        // Load cart count on page load
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Showproducts page loaded');
            
            // Fetch cart count from server
            fetch('CartServlet')
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.cartSize > 0) {
                        updateCartCount(data.cartSize);
                    }
                })
                .catch(err => console.log('Cart count fetch error:', err));
            
            setTimeout(() => {
                const productCards = document.querySelectorAll('.product-card');
                console.log('Page load check - Found ' + productCards.length + ' products');
            }, 1000);
        });
    </script>
</body>
</html>
