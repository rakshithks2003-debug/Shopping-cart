<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, products.Dbase" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wishlist - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            color: #333;
        }

        /* Top Bar */
        .top-bar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .top-bar-content {
            margin: 0;
            padding: 0 20px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            width: 100%;
        }

        .back-to-home-btn-left {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
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
        }

        .back-to-home-btn-left:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
            background: linear-gradient(135deg, #45a049, #3d8b40);
            border-color: rgba(255, 255, 255, 0.1);
            text-decoration: none;
            color: white;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 10px 20px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            backdrop-filter: blur(10px);
        }

        .back-btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateX(-5px);
            color: white;
        }

        /* Header */
        .header {
            background: white;
            padding: 50px 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
        }

        .header h1 {
            font-size: 3rem;
            font-weight: 800;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            display: inline-flex;
            align-items: center;
            gap: 15px;
        }

        .header h1 i {
            color: #e74c3c;
            animation: heartbeat 1.5s ease-in-out infinite;
        }

        @keyframes heartbeat {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.15); }
        }

        .header p {
            font-size: 1.2rem;
            color: #666;
        }

        /* Container */
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px 40px;
        }

        /* Wishlist Grid */
        .wishlist-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }

        .wishlist-item {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            transition: all 0.4s ease;
            position: relative;
        }

        .wishlist-item:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .wishlist-item-image {
            width: 100%;
            height: 250px;
            object-fit: cover;
            background: #f8f9fa;
        }

        .wishlist-item-details {
            padding: 25px;
        }

        .wishlist-item-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 10px;
            line-height: 1.4;
        }

        .wishlist-item-price {
            font-size: 1.8rem;
            font-weight: 800;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 20px;
        }

        .wishlist-item-actions {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
        }

        .add-to-cart-btn {
            flex: 1;
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            border: none;
            padding: 12px 16px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        .add-to-cart-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
        }

        .buy-now-btn {
            flex: 1;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 14px 20px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
        }

        .buy-now-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
            color: white;
        }

        .remove-btn {
            background: white;
            color: #ef4444;
            border: 2px solid #ef4444;
            padding: 12px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.2rem;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .remove-btn:hover {
            background: #ef4444;
            color: white;
            transform: scale(1.1);
        }

        /* Checkbox Styles */
        .wishlist-item-checkbox {
            position: absolute;
            top: 15px;
            left: 15px;
            z-index: 10;
        }

        .wishlist-item-checkbox input[type="checkbox"] {
            display: none;
        }

        .checkbox-label {
            width: 24px;
            height: 24px;
            border: 2px solid #ddd;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            background: white;
            transition: all 0.3s ease;
        }

        .checkbox-label i {
            color: white;
            font-size: 12px;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .wishlist-item-checkbox input[type="checkbox"]:checked + .checkbox-label {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-color: #667eea;
        }

        .wishlist-item-checkbox input[type="checkbox"]:checked + .checkbox-label i {
            opacity: 1;
        }

        .checkbox-label:hover {
            border-color: #667eea;
            transform: scale(1.1);
        }

        /* Bulk Actions Styles */
        .bulk-actions {
            background: white;
            padding: 20px 25px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            border: 1px solid #e5e7eb;
        }

        .bulk-actions-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .select-all-container {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-weight: 600;
            color: #374151;
        }

        .select-all-container input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .selected-count {
            color: #6b7280;
            font-size: 0.95rem;
        }

        .selected-count #selectedCount {
            font-weight: 700;
            color: #667eea;
        }

        .bulk-actions-right {
            display: flex;
            gap: 12px;
        }

        .bulk-buy-btn, .bulk-remove-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }

        .bulk-buy-btn {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .bulk-buy-btn:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);
        }

        .bulk-remove-btn {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }

        .bulk-remove-btn:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(239, 68, 68, 0.3);
        }

        .bulk-buy-btn:disabled, .bulk-remove-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        /* Empty State */
        .empty-wishlist {
            text-align: center;
            padding: 100px 20px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }

        .empty-wishlist i {
            font-size: 6rem;
            color: #e74c3c;
            margin-bottom: 25px;
            opacity: 0.6;
        }

        .empty-wishlist h2 {
            font-size: 2.2rem;
            margin-bottom: 15px;
            color: #333;
            font-weight: 700;
        }

        .empty-wishlist p {
            font-size: 1.2rem;
            margin-bottom: 35px;
            color: #666;
        }

        .shop-now-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 16px 40px;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 1.1rem;
        }

        .shop-now-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
            text-decoration: none;
            color: white;
        }

        /* Notification */
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 18px 30px;
            border-radius: 12px;
            color: white;
            font-weight: 600;
            z-index: 1000;
            opacity: 0;
            transform: translateX(100%);
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .notification.show {
            opacity: 1;
            transform: translateX(0);
        }

        .notification.success {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
        }

        .notification.error {
            background: linear-gradient(135deg, #ef4444, #dc2626);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .header h1 {
                font-size: 2.2rem;
            }

            .wishlist-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }
        }

        @media (max-width: 480px) {
            .wishlist-grid {
                grid-template-columns: 1fr;
            }

            .header h1 {
                font-size: 1.8rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .add-to-cart-btn, .remove-btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- Top Bar -->
    <div class="top-bar">
        <div class="top-bar-content">
               <a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page"><i class="fas fa-home"></i> Back </a>
           </div>

    <!-- Header -->
    <div class="header">
        <h1><i class="fas fa-heart"></i> My Wishlist</h1>
        <p>Your favorite products saved in one place</p>
    </div>

    <!-- Container -->
    <div class="container">
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
                    String query = "SELECT w.pro_name, w.pro_image, w.saved_date, p.id, p.product_name, p.price, p.description, p.brand, p.seller_id " +
                                 "FROM wishlist w " +
                                 "JOIN product p ON w.pro_name = p.product_name " +
                                 "WHERE w.user_id = ? " +
                                 "ORDER BY w.saved_date DESC";
                    
                    ps = con.prepareStatement(query);
                    ps.setString(1, userId); // user_id is now String
                    System.out.println("🔍 Executing wishlist query for user_id: " + userId);
                    System.out.println("🔍 SQL Query: " + query);
                    rs = ps.executeQuery();
                    
                    // Count total results first
                    int totalCount = 0;
                    while (rs.next()) {
                        totalCount++;
                    }
                    System.out.println("🔍 DEBUG: Total wishlist items found: " + totalCount);
                    
                    // Reset ResultSet to beginning
                    rs = ps.executeQuery();
                    
                    boolean hasResults = false;
            %>
                    <div class="wishlist-grid">
            <%
                    while (rs.next()) {
                        hasResults = true;
                        // Only use image from wishlist table
                        String imageName = rs.getString("pro_image");
                        String productName = rs.getString("product_name");
                        double price = rs.getDouble("price");
                        String productId = rs.getString("id");
                        String sellerId = rs.getString("seller_id");
                        
                        System.out.println("🔍 DEBUG: Displaying item - ID: " + productId + ", Name: " + productName + ", Image: " + imageName + ", Price: " + price + ", Seller: " + sellerId);
            %>
                                <div class="wishlist-item" data-product-id="<%=rs.getString("pro_name")%>">
                                    <div class="wishlist-item-checkbox">
                                        <input type="checkbox" id="select-<%=rs.getString("pro_name").replace(" ", "-")%>" 
                                               class="product-checkbox" 
                                               value="<%=rs.getString("pro_name")%>">
                                        <label for="select-<%=rs.getString("pro_name").replace(" ", "-")%>" class="checkbox-label">
                                            <i class="fas fa-check"></i>
                                        </label>
                                    </div>
                                    <%
                                        String imageUrl = (imageName != null && !imageName.trim().isEmpty()) 
                                            ? "product_images/" + imageName 
                                            : "data:image/svg+xml,%3Csvg width='300' height='250' xmlns='http://www.w3.org/2000/svg'%3E%3Crect fill='%23f0f0f0' width='300' height='250'/%3E%3Ctext x='50%25' y='50%25' text-anchor='middle' fill='%23999' font-size='16' font-family='Arial'%3ENo Image%3C/text%3E%3C/svg%3E";
                                    %>
                                    <img src="<%=imageUrl%>" alt="<%=rs.getString("product_name")%>" class="wishlist-item-image">
                                    <div class="wishlist-item-details">
                                        <h3 class="wishlist-item-name"><%=rs.getString("product_name")%></h3>
                                        <div class="wishlist-item-price">₹<%=String.format("%.2f", rs.getDouble("price"))%></div>
                                        <div class="wishlist-item-actions">
                                            <a href="Payment.jsp?buyNow=true&productId=<%=rs.getString("id")%>&sellerId=<%=rs.getString("seller_id") != null ? rs.getString("seller_id") : ""%>" class="buy-now-btn">
                                                <i class="fas fa-bolt"></i> Buy Now
                                            </a>
                                            <div class="action-buttons">
                                                <button class="remove-btn" onclick="removeFromWishlist('<%=rs.getString("pro_name")%>')" title="Remove from Wishlist">
                                                    <i class="fas fa-heart"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
            <%
                    }
                    %>
                    </div>
                    <%
                    
                    if (!hasResults) {
                        System.out.println("📋 No wishlist items found for user: " + username);
                        // Empty wishlist
            %>
                        <div class="empty-wishlist">
                            <i class="fas fa-heart"></i>
                            <h2>Your wishlist is empty</h2>
                            <p>Start adding products you love to your wishlist!</p>
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

        function removeFromWishlist(productId, showConfirm = true) {
            console.log('🔍 DEBUG: Removing product from wishlist:', productId);
            
            if (showConfirm && !confirm('Are you sure you want to remove this item from your wishlist?')) {
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
                            console.log('🔍 DEBUG: Wishlist removal response:', response);
                            
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
                            console.log('🔍 DEBUG: Error parsing response:', e);
                            showNotification('Error removing item', 'error');
                        }
                    } else {
                        console.log('🔍 DEBUG: Server error status:', xhr.status);
                        showNotification('Server error. Please try again.', 'error');
                    }
                }
            };
            
            console.log('🔍 DEBUG: Sending removal request for:', productId);
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

        // Add Multiple Products to Wishlist
        function addMultipleToWishlist(products) {
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'WishlistServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                showNotification(response.message, 'success');
                                // Optionally refresh the page after a delay
                                setTimeout(() => {
                                    location.reload();
                                }, 2000);
                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            showNotification('Error adding products to wishlist', 'error');
                        }
                    } else {
                        showNotification('Server error. Please try again.', 'error');
                    }
                }
            };
            
            xhr.send('action=addMultiple&products=' + encodeURIComponent(products));
        }

        // Sync local wishlist with server
        function syncLocalWishlist() {
            const localWishlist = JSON.parse(localStorage.getItem('wishlist')) || [];
            if (localWishlist.length > 0) {
                // Extract product names and send as multiple
                const productNames = localWishlist.map(item => item.name || item.productName).join(',');
                addMultipleToWishlist(productNames);
            }
        }

        // Sync local wishlist on page load
        document.addEventListener('DOMContentLoaded', function() {
            syncLocalWishlist();
        });
    </script>
</body>
</html>