<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, products.Dbase" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>❤️ My Wishlist - Shopping Cart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            backdrop-filter: blur(10px);
        }

        header {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            padding: 30px;
            text-align: center;
            position: relative;
        }

        header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }

        header p {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        .back-to-home-btn {
            position: absolute;
            top: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .back-to-home-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            text-decoration: none;
            color: white;
        }

        .wishlist-content {
            padding: 40px 30px;
        }

        .empty-wishlist {
            text-align: center;
            padding: 80px 20px;
            color: #666;
        }

        .empty-wishlist i {
            font-size: 5rem;
            color: #e74c3c;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .empty-wishlist h2 {
            font-size: 2rem;
            margin-bottom: 15px;
            color: #333;
        }

        .empty-wishlist p {
            font-size: 1.1rem;
            margin-bottom: 30px;
            color: #666;
        }

        .shop-now-btn {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .shop-now-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(231, 76, 60, 0.3);
            text-decoration: none;
            color: white;
        }

        .wishlist-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }

        .wishlist-item {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            position: relative;
        }

        .wishlist-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        .wishlist-item-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            background: #f8f9fa;
        }

        .wishlist-item-details {
            padding: 20px;
        }

        .wishlist-item-name {
            font-size: 1.2rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            line-height: 1.4;
        }

        .wishlist-item-price {
            font-size: 1.4rem;
            color: #e74c3c;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .wishlist-item-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .add-to-cart-btn {
            flex: 1;
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .add-to-cart-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.3);
        }

        .remove-btn {
            background: rgba(231, 76, 60, 0.1);
            color: #e74c3c;
            border: 2px solid #e74c3c;
            padding: 10px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.1rem;
            width: 45px;
            height: 45px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .remove-btn:hover {
            background: #e74c3c;
            color: white;
            transform: scale(1.1);
        }

        .wishlist-stats {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding: 20px;
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            border-radius: 12px;
        }

        .stats-info h3 {
            color: #333;
            font-size: 1.3rem;
            margin-bottom: 5px;
        }

        .stats-info p {
            color: #666;
            font-size: 1rem;
        }

        .clear-wishlist-btn {
            background: rgba(231, 76, 60, 0.1);
            color: #e74c3c;
            border: 2px solid #e74c3c;
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .clear-wishlist-btn:hover {
            background: #e74c3c;
            color: white;
            transform: translateY(-2px);
        }

        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            border-radius: 8px;
            color: white;
            font-weight: 600;
            z-index: 1000;
            opacity: 0;
            transform: translateX(100%);
            transition: all 0.3s ease;
        }

        .notification.show {
            opacity: 1;
            transform: translateX(0);
        }

        .notification.success {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
        }

        .notification.error {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            header h1 {
                font-size: 2rem;
            }

            .back-to-home-btn {
                position: static;
                display: inline-block;
                margin-bottom: 20px;
            }

            .wishlist-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }

            .wishlist-stats {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
        }

        @media (max-width: 480px) {
            .container {
                border-radius: 0;
                margin: 0;
                min-height: 100vh;
            }

            .wishlist-grid {
                grid-template-columns: 1fr;
            }

            .wishlist-item-actions {
                flex-direction: column;
            }

            .add-to-cart-btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <a href="Dashboard.jsp" class="back-to-home-btn">
                <i class="fas fa-arrow-left"></i> Back to Home
            </a>
            <h1>❤️ My Wishlist</h1>
            <p>Your favorite products saved in one place</p>
        </header>

        <div class="wishlist-content">
            <%
                // Check if user is logged in
                String username = (String) session.getAttribute("username");
                if (username == null) {
                    response.sendRedirect("Login.html");
                    return;
                }

                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                
                try {
                    products.Dbase db = new products.Dbase();
                    con = null;
                    
                    try {
                        con = db.initailizeDatabase();
                    } catch (Exception e) {
                        // Fallback to direct connection
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
                    }
                    
                    if (con == null || con.isClosed()) {
                        throw new Exception("Failed to establish database connection");
                    }
                    
                    System.out.println("✅ Database connected successfully for wishlist");
                    
                    // Create wishlist table if it doesn't exist
                    try {
                        String createWishlistTable = "CREATE TABLE IF NOT EXISTS wishlist (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "username VARCHAR(50) NOT NULL, " +
                            "product_id VARCHAR(50) NOT NULL, " +
                            "added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                            "UNIQUE KEY unique_user_product (username, product_id)" +
                            ")";
                        Statement stmt = con.createStatement();
                        stmt.execute(createWishlistTable);
                        stmt.close();
                        System.out.println("✅ Wishlist table created/verified successfully");
                    } catch (Exception tableEx) {
                        System.out.println("❌ Error creating wishlist table: " + tableEx.getMessage());
                        throw tableEx;
                    }
                    
                    // Get user_id from users table first
                    String getUserIdSQL = "SELECT user_id FROM users WHERE username = ?";
                    PreparedStatement userPs = con.prepareStatement(getUserIdSQL);
                    userPs.setString(1, username);
                    ResultSet userRs = userPs.executeQuery();
                    
                    String userId = null;
                    if (userRs.next()) {
                        userId = userRs.getString("user_id");
                    }
                    userRs.close();
                    userPs.close();
                    
                    if (userId == null) {
                        throw new Exception("User not found in database");
                    }
                    
                    System.out.println("✅ Found user_id: " + userId + " for username: " + username);
                    
                    // Get wishlist items for the user
                    String query = "SELECT w.pro_name, w.pro_image, w.saved_date, p.product_name, p.price, p.description, p.brand " +
                                 "FROM wishlist w " +
                                 "JOIN product p ON w.pro_name = p.product_name " +
                                 "WHERE w.user_id = ? " +
                                 "ORDER BY w.saved_date DESC";
                    
                    ps = con.prepareStatement(query);
                    ps.setString(1, userId); // user_id is now String
                    System.out.println("🔍 Executing wishlist query for user_id: " + userId);
                    rs = ps.executeQuery();
                    
                    boolean hasResults = false;
                    while (rs.next()) {
                        hasResults = true;
                        // Only use image from wishlist table
                        String imageName = rs.getString("pro_image");
                        System.out.println("🔍 DEBUG: Wishlist image for product '" + rs.getString("product_name") + "': " + imageName);
            %>
                                <div class="wishlist-item" data-product-id="<%=rs.getString("pro_name")%>">
                                    <img src="<%=imageName != null && !imageName.trim().isEmpty() ? "product_images/" + imageName : "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+Cjx0ZXh0IHg9IjE1MCIgeT0iMTYwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjE0IiBmb250LWZhbWlseT0iQXJpYWwiPkltYWdlIE5vdCBBdmFpbGFibGU8L3RleHQ+Cjwvc3ZnPgo="%>" alt="<%=rs.getString("product_name")%>" class="wishlist-item-image">
                                    <div class="wishlist-item-details">
                                        <h3 class="wishlist-item-name"><%=rs.getString("product_name")%></h3>
                                        <div class="wishlist-item-price">₹<%=String.format("%.2f", rs.getDouble("price"))%></div>
                                        <div class="wishlist-item-actions">
                                            <button class="add-to-cart-btn" 
                                                    data-product-id="<%=rs.getString("pro_name")%>"
                                                    data-product-name="<%=rs.getString("product_name").replace("\"", "&quot;").replace("'", "&#39;")%>"
                                                    data-price="<%=rs.getDouble("price")%>"
                                                    data-image="<%=imageName%>"
                                                    data-seller-id="<%=rs.getString("brand")%>"
                                                    onclick="addToCartFromWishlist(this)">
                                                <i class="fas fa-shopping-cart"></i> Add to Cart
                                            </button>
                                            <button class="remove-btn" onclick="removeFromWishlist('<%=rs.getString("pro_name")%>')" title="Remove from Wishlist">
                                                <i class="fas fa-heart"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
            <%
                    }
                    
                    if (!hasResults) {
                        System.out.println("📋 No wishlist items found for user: " + username);
                        // Empty wishlist
            %>
                        <div class="empty-wishlist">
                            <i class="fas fa-heart"></i>
                            <h2>Your wishlist is empty</h2>
                            <p>Start adding products you love to your wishlist!</p>
                            <a href="Showproducts.jsp" class="shop-now-btn">
                                <i class="fas fa-shopping-bag"></i> Shop Now
                            </a>
                        </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    System.out.println("Error loading wishlist: " + e.getMessage());
            %>
                    <div class="empty-wishlist">
                        <i class="fas fa-exclamation-triangle"></i>
                        <h2>Error loading wishlist</h2>
                        <p><%= e.getMessage() %></p>
                        <p>Please try again later.</p>
                        <a href="Dashboard.jsp" class="shop-now-btn">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
            <%
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                        if (con != null) con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            %>
        </div>
    </div>

    <!-- Notification -->
    <div class="notification" id="notification"></div>

    <script>
        function showNotification(message, type) {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = `notification ${type} show`;
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }

        function addToCartFromWishlist(button) {
                const productId = button.dataset.productId;
                const productName = button.dataset.productName;
                const price = parseFloat(button.dataset.price);
                const image = button.dataset.image;
                const sellerId = button.dataset.sellerId;
                
                addToCart(productId, productName, price, image, sellerId);
            }

        function addToCart(productId, productName, price, image, sellerId) {
            const button = event.target;
            const originalText = button.innerHTML;
            
            // Show loading state
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
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
                                // Optionally remove from wishlist after adding to cart
                                setTimeout(() => {
                                    removeFromWishlist(productId);
                                }, 2000);
                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            showNotification('Error adding to cart', 'error');
                        }
                    } else {
                        showNotification('Server error. Please try again.', 'error');
                    }
                }
            };
            
            xhr.send('action=addToCart&productId=' + encodeURIComponent(productId));
        }

        function removeFromWishlist(productId) {
            if (!confirm('Are you sure you want to remove this item from your wishlist?')) {
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'WishlistServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                showNotification('Removed from wishlist', 'success');
                                // Remove the item from DOM with animation
                                const item = document.querySelector(`[data-product-id="${productId}"]`);
                                if (item) {
                                    item.style.transition = 'all 0.3s ease';
                                    item.style.opacity = '0';
                                    item.style.transform = 'scale(0.8)';
                                    setTimeout(() => {
                                        item.remove();
                                        // Check if wishlist is now empty
                                        checkEmptyWishlist();
                                    }, 300);
                                }
                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            showNotification('Error removing item', 'error');
                        }
                    } else {
                        showNotification('Server error. Please try again.', 'error');
                    }
                }
            };
            
            xhr.send('action=remove&productId=' + encodeURIComponent(productId));
        }

        function clearWishlist() {
            if (!confirm('Are you sure you want to clear your entire wishlist? This action cannot be undone.')) {
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'WishlistServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                showNotification('Wishlist cleared successfully', 'success');
                                setTimeout(() => {
                                    location.reload();
                                }, 1500);
                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            showNotification('Error clearing wishlist', 'error');
                        }
                    } else {
                        showNotification('Server error. Please try again.', 'error');
                    }
                }
            };
            
            xhr.send('action=clear');
        }

        function checkEmptyWishlist() {
            const items = document.querySelectorAll('.wishlist-item');
            if (items.length === 0) {
                setTimeout(() => {
                    location.reload();
                }, 500);
            }
        }

        // Add to cart from localStorage (for items added from Details.jsp)
        function syncLocalWishlist() {
            const localWishlist = JSON.parse(localStorage.getItem('wishlist')) || [];
            if (localWishlist.length > 0) {
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'WishlistServlet', true);
                xhr.setRequestHeader('Content-Type', 'application/json');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        // Clear localStorage after syncing
                        localStorage.removeItem('wishlist');
                    }
                };
                xhr.send(JSON.stringify({
                    action: 'syncLocal',
                    items: localWishlist
                }));
            }
        }

        // Sync local wishlist on page load
        document.addEventListener('DOMContentLoaded', function() {
            syncLocalWishlist();
        });
    </script>
</body>
</html>
