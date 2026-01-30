
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, products.Dbase" %>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null) {
        response.sendRedirect("Login.html");
        return;
    }
    String SessionId = session.getId();
    out.println("Session ID: " +
    SessionId);
    
    // Get sorting parameters
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
    // Set defaults
    if (sortBy == null) sortBy = "cart_id";
    if (sortOrder == null) sortOrder = "DESC";
    
    // Load cart items from database
    List<Map<String, Object>> cartItems = new ArrayList<>();
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            // Build dynamic SQL query with sorting - join with product table to get brand
            String sql = "SELECT c.product_id, c.price, c.quantity, c.image, p.name as product_name, p.brand as product_brand FROM cart c JOIN product p ON c.product_id = p.id WHERE c.user_id = ? ORDER BY " + sortBy + " " + sortOrder;
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productId", rs.getString("product_id"));
                item.put("productName", rs.getString("product_name"));
                item.put("productBrand", rs.getString("product_brand"));
                item.put("price", rs.getDouble("price"));
                item.put("quantity", rs.getInt("quantity"));
                item.put("image", rs.getString("image"));
                cartItems.add(item);
            }
            
            rs.close();
            stmt.close();
            con.close();
        }
    } catch (Exception e) {
        System.err.println("Error loading cart: " + e.getMessage());
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - Mini Shopping Cart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        /* Header */
        .cart-header {
            background: white;
            border-radius: 12px;
            padding: 25px 30px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .header-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .header-title h1 {
            font-size: 1.8rem;
            color: #2c3e50;
            font-weight: 700;
        }
        
        .header-title i {
            color: #667eea;
            font-size: 1.8rem;
        }
        
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            color: #64748b;
            margin-top: 8px;
        }
        
        .breadcrumb a {
            color: #667eea;
            text-decoration: none;
        }
        
        .breadcrumb a:hover {
            text-decoration: underline;
        }
        
        .nav-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .btn-outline {
            background: white;
            color: #64748b;
            border-color: #e2e8f0;
        }
        
        .btn-outline:hover {
            border-color: #667eea;
            color: #667eea;
            background: #f8f9ff;
        }
        
        /* Main Layout */
        .cart-layout {
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 20px;
        }
        
        /* Cart Items */
        .cart-items-section {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f5f9;
        }
        
        .section-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #2c3e50;
        }
        
        /* Sorting Controls */
        .sorting-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .sort-dropdown {
            padding: 8px 12px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            background: white;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .sort-dropdown:hover {
            border-color: #667eea;
        }
        
        .sort-dropdown:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .sort-btn {
            padding: 8px 12px;
            background: #f8f9ff;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            color: #64748b;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .sort-btn:hover {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .sort-btn.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .item-count {
            background: #f1f5f9;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            color: #64748b;
        }
        
        .cart-item {
            display: grid;
            grid-template-columns: 90px 1fr auto;
            gap: 20px;
            padding: 20px;
            background: #f8fafc;
            border-radius: 10px;
            margin-bottom: 15px;
            border: 2px solid transparent;
            transition: all 0.3s;
        }
        
        .cart-item:hover {
            border-color: #667eea;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
        }
        
        .item-image {
            width: 90px;
            height: 90px;
            object-fit: cover;
            border-radius: 8px;
            background: white;
            border: 1px solid #e2e8f0;
        }
        
        .item-info {
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 6px;
        }
        
        .item-name {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .item-price {
            font-size: 1.3rem;
            font-weight: 700;
            color: #667eea;
        }
        
        .item-actions {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-end;
            gap: 10px;
        }
        
        .quantity-controls {
            display: flex;
            align-items: center;
            background: white;
            border-radius: 8px;
            border: 2px solid #e2e8f0;
            overflow: hidden;
        }
        
        .qty-btn {
            background: white;
            border: none;
            width: 32px;
            height: 32px;
            cursor: pointer;
            color: #64748b;
            font-weight: 700;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .qty-btn:hover {
            background: #667eea;
            color: white;
        }
        
        .quantity {
            font-weight: 600;
            min-width: 35px;
            text-align: center;
            color: #2c3e50;
            border-left: 2px solid #e2e8f0;
            border-right: 2px solid #e2e8f0;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 10px;
        }
        
        .remove-btn {
            background: transparent;
            color: #ef4444;
            border: none;
            padding: 6px 10px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .remove-btn:hover {
            background: #fef2f2;
        }
        
        /* Summary */
        .cart-summary {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            position: sticky;
            top: 20px;
            height: fit-content;
        }
        
        .summary-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f5f9;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 0.95rem;
        }
        
        .summary-row .label {
            color: #64748b;
            font-weight: 500;
        }
        
        .summary-row .value {
            font-weight: 600;
            color: #2c3e50;
        }
        
        .summary-divider {
            height: 2px;
            background: #f1f5f9;
            margin: 18px 0;
        }
        
        .summary-total {
            display: flex;
            justify-content: space-between;
            font-size: 1.4rem;
            font-weight: 700;
            color: #2c3e50;
            margin: 18px 0;
        }
        
        .summary-total .value {
            color: #667eea;
        }
        
        .checkout-btn {
            width: 100%;
            background: #667eea;
            color: white;
            border: none;
            padding: 14px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            margin-top: 15px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .checkout-btn:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .clear-btn {
            width: 100%;
            background: transparent;
            color: #ef4444;
            border: 2px solid #ef4444;
            padding: 10px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        
        .clear-btn:hover {
            background: #ef4444;
            color: white;
        }
        
        .promo-section {
            margin: 18px 0;
            padding: 15px;
            background: #f8fafc;
            border-radius: 8px;
        }
        
        .promo-label {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 0.9rem;
        }
        
        .promo-input {
            display: flex;
            gap: 8px;
        }
        
        .promo-input input {
            flex: 1;
            padding: 8px 12px;
            border: 2px solid #e2e8f0;
            border-radius: 6px;
            font-size: 0.9rem;
            outline: none;
        }
        
        .promo-input input:focus {
            border-color: #667eea;
        }
        
        .promo-input button {
            padding: 8px 16px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            font-size: 0.9rem;
        }
        
        .promo-input button:hover {
            background: #5568d3;
        }
        
        /* Empty Cart */
        .cart-empty {
            text-align: center;
            padding: 60px 20px;
        }
        
        .cart-empty i {
            font-size: 80px;
            color: #cbd5e1;
            margin-bottom: 20px;
        }
        
        .cart-empty h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .cart-empty p {
            font-size: 1rem;
            color: #64748b;
            margin-bottom: 25px;
        }
        
        /* Responsive */
        @media (max-width: 1024px) {
            .cart-layout {
                grid-template-columns: 1fr;
            }
            .cart-summary {
                position: static;
            }
        }
        
        @media (max-width: 768px) {
            .cart-header {
                flex-direction: column;
                align-items: flex-start;
            }
            .cart-item {
                grid-template-columns: 70px 1fr;
                gap: 15px;
            }
            .item-actions {
                grid-column: 1 / -1;
                flex-direction: row;
                justify-content: space-between;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="cart-header">
            <div>
                <div class="header-title">
                    <i class="fas fa-shopping-cart"></i>
                    <h1>Shopping Cart</h1>
                </div>
                <div class="breadcrumb">
                    <a href="Dashboard.jsp"><i class="fas fa-home"></i> Home</a>
                    <span>/</span>
                    <a href="Showproducts.jsp">Products</a>
                    <span>/</span>
                    <span>Cart</span>
                </div>
            </div>
            <div class="nav-actions">
                <a href="Showproducts.jsp" class="btn btn-outline">
                    <i class="fas fa-arrow-left"></i> Continue Shopping
                </a>
                <a href="Dashboard.jsp" class="btn btn-primary">
                    <i class="fas fa-home"></i> Dashboard
                </a>
            </div>
        </div>
        
        <% if (cartItems.isEmpty()) { %>
            <div class="cart-items-section">
                <div class="cart-empty">
                    <i class="fas fa-shopping-cart"></i>
                    <h2>Your cart is empty</h2>
                    <p>Looks like you haven't added anything yet</p>
                    <a href="Showproducts.jsp" class="btn btn-primary">
                        <i class="fas fa-shopping-bag"></i> Start Shopping
                    </a>
                </div>
            </div>
        <% } else { %>
            <div class="cart-layout">
                <div class="cart-items-section">
                    <div class="section-header">
                        <div>
                            <h2 class="section-title">Cart Items</h2>
                            <span class="item-count"><%= cartItems.size() %> <%= cartItems.size() == 1 ? "item" : "items" %></span>
                        </div>
                        <div class="sorting-controls">
                            <select class="sort-dropdown" onchange="window.location.href='Cart.jsp?sortBy=' + this.value + '&sortOrder=<%= sortOrder %>'">
                                <option value="cart_id" <%= "cart_id".equals(sortBy) ? "selected" : "" %>>Sort by Added Time</option>
                                <option value="product_name" <%= "product_name".equals(sortBy) ? "selected" : "" %>>Sort by Name</option>
                                <option value="price" <%= "price".equals(sortBy) ? "selected" : "" %>>Sort by Price</option>
                                <option value="quantity" <%= "quantity".equals(sortBy) ? "selected" : "" %>>Sort by Quantity</option>
                            </select>
                            <a href="Cart.jsp?sortBy=<%= sortBy %>&sortOrder=ASC" class="sort-btn <%= "ASC".equals(sortOrder) ? "active" : "" %>">
                                <i class="fas fa-sort-alpha-down"></i> Asc
                            </a>
                            <a href="Cart.jsp?sortBy=<%= sortBy %>&sortOrder=DESC" class="sort-btn <%= "DESC".equals(sortOrder) ? "active" : "" %>">
                                <i class="fas fa-sort-alpha-down-alt"></i> Desc
                            </a>
                        </div>
                    </div>
                    <%
                    double total = 0;
                    for (Map<String, Object> item : cartItems) {
                        String productId = (String) item.get("productId");
                        String productName = (String) item.get("productName");
                        String productBrand = (String) item.get("productBrand");
                        double price = (Double) item.get("price");
                        int quantity = (Integer) item.get("quantity");
                        String image = (String) item.get("image");
                        
                        total += price * quantity;
                        
                        String imageSrc;
                        String fallbackImage = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik00MCAzMEg2MFY1MEg0MFYzMFoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iNTAiIHk9IjcwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjEyIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+";
                        
                        if (image == null || image.trim().isEmpty()) {
                            imageSrc = fallbackImage;
                        } else {
                            String cleanImage = image.trim().replace(" ", "%20");
                            String contextPath = request.getContextPath();
                            if (contextPath == null || contextPath.equals("")) {
                                contextPath = "";
                            }
                            if (!contextPath.endsWith("/")) {
                                contextPath += "/";
                            }
                            
                            // Try multiple possible paths
                            String[] possiblePaths = {
                                contextPath + "product_images/" + cleanImage,
                                contextPath + "seller_images/" + cleanImage,
                                "product_images/" + cleanImage,
                                "seller_images/" + cleanImage,
                                contextPath + "images/" + cleanImage,
                                "images/" + cleanImage
                            };
                            
                            // Use the first path (primary)
                            imageSrc = possiblePaths[0];
                            
                            // Debug all possible paths
                            System.out.println("=== IMAGE DEBUG INFO ===");
                            System.out.println("Original image: " + image);
                            System.out.println("Clean image: " + cleanImage);
                            System.out.println("Context path: '" + contextPath + "'");
                            System.out.println("Primary path: " + imageSrc);
                            for (int i = 0; i < possiblePaths.length; i++) {
                                System.out.println("Path " + (i+1) + ": " + possiblePaths[i]);
                            }
                            System.out.println("=====================");
                        }
                        
                        int prevQty = quantity - 1;
                        int nextQty = quantity + 1;
                    %>
                    <div class="cart-item">
                        <img src="<%= imageSrc %>" alt="<%= productBrand != null ? productBrand : productName %>" class="item-image" onerror="tryFallbackImage(this, '<%= image %>');">
                        <div class="item-info">
                            <div class="item-name"><%= productBrand != null ? productBrand : (productName != null ? productName : "Unknown Brand") %></div>
                            <div class="item-price">₹<%= String.format("%.2f", price) %></div>
                        </div>
                        <div class="item-actions">
                            <div class="quantity-controls">
                                <button class="qty-btn" data-id="<%= productId %>" data-qty="<%= prevQty %>" onclick="updateQtyData(this)">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <span class="quantity"><%= quantity %></span>
                                <button class="qty-btn" data-id="<%= productId %>" data-qty="<%= nextQty %>" onclick="updateQtyData(this)">
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                            <button class="remove-btn" data-id="<%= productId %>" onclick="removeData(this)">
                                <i class="fas fa-trash-alt"></i> Remove
                            </button>
                        </div>
                    </div>
                    <% } %>
                </div>
                
                <div class="cart-summary">
                    <h2 class="summary-title">Order Summary</h2>
                    
                    <div class="summary-row">
                        <span class="label">Subtotal (<%= cartItems.size() %> items)</span>
                        <span class="value" id="subtotal">₹<%= String.format("%.2f", total) %></span>
                    </div>
                    
                    <div class="summary-row">
                        <span class="label">Shipping Fee</span>
                        <span class="value">₹50.00</span>
                    </div>
                    
                    <div class="promo-section">
                        <div class="promo-label">
                            <i class="fas fa-tag"></i> Promo Code
                        </div>
                        <div class="promo-input">
                            <input type="text" placeholder="Enter code" id="promoCode">
                            <button onclick="applyPromo()">Apply</button>
                        </div>
                    </div>
                    
                    <div class="summary-divider"></div>
                    
                    <div class="summary-total">
                        <span>Total</span>
                        <span class="value" id="total">₹<%= String.format("%.2f", total + 50) %></span>
                    </div>
                    
                    <button class="checkout-btn" onclick="checkout()">
                        <i class="fas fa-lock"></i> Proceed to Checkout
                    </button>
                    
                    <button class="clear-btn" onclick="clearCart()">
                        <i class="fas fa-trash-alt"></i> Clear Cart
                    </button>
                </div>
            </div>
        <% } %>
    </div>
    
    <script>
        function updateQtyData(button) {
            const productId = button.getAttribute('data-id');
            const newQuantity = parseInt(button.getAttribute('data-qty'));
            updateQuantity(productId, newQuantity);
        }
        
        function removeData(button) {
            const productId = button.getAttribute('data-id');
            removeFromCart(productId);
        }
        
        function updateQuantity(productId, newQuantity) {
            if (newQuantity < 1) {
                removeFromCart(productId);
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'CartServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            location.reload();
                        } else {
                            showNotification(response.message, 'error');
                        }
                    } catch (e) {
                        showNotification('Error updating quantity', 'error');
                    }
                }
            };
            xhr.send('action=update&productId=' + encodeURIComponent(productId) + '&quantity=' + newQuantity);
        }
        
        function removeFromCart(productId) {
            if (!confirm('Remove this item from cart?')) return;
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'CartServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            location.reload();
                        } else {
                            showNotification(response.message, 'error');
                        }
                    } catch (e) {
                        showNotification('Error removing item', 'error');
                    }
                }
            };
            xhr.send('action=remove&productId=' + encodeURIComponent(productId));
        }
        
        function clearCart() {
            if (!confirm('Clear all items from cart?')) return;
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'CartServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            location.reload();
                        } else {
                            showNotification(response.message, 'error');
                        }
                    } catch (e) {
                        showNotification('Error clearing cart', 'error');
                    }
                }
            };
            xhr.send('action=clear');
        }
        
        function applyPromo() {
            const code = document.getElementById('promoCode').value;
            if (code.trim() === '') {
                showNotification('Please enter a promo code', 'error');
                return;
            }
            showNotification('Promo code feature coming soon!', 'success');
        }
        
        function checkout() {
            window.location.href = 'Payment.jsp';
        }
        
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 600; z-index: 10000; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            }
            
            notification.textContent = message;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 3000);
        }
        
        // Enhanced fallback image function - tries multiple paths systematically
        function tryFallbackImage(img, fileName) {
            console.log('=== IMAGE FALLBACK START ===');
            console.log('Fallback triggered for:', fileName);
            console.log('Current image src:', img.src);
            
            if (!fileName || fileName.trim() === '') {
                console.log('No filename provided, using placeholder');
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik00MCAzMEg2MFY1MEg0MFYzMFoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iNTAiIHk9IjcwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjEyIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+';
                return;
            }
            
            const cleanFileName = fileName.trim().replace(" ", "%20");
            let attemptCount = 0;
            
            // Define all possible paths to try
            const possiblePaths = [
                img.src.replace(/.*product_images\//, 'product_images/'), // Remove context, try direct
                img.src.replace(/.*seller_images\//, 'seller_images/'), // Remove context, try direct
                img.src.replace(/.*images\//, 'images/'), // Remove context, try direct
                'product_images/' + cleanFileName,
                'seller_images/' + cleanFileName,
                'images/' + cleanFileName,
                '/product_images/' + cleanFileName,
                '/seller_images/' + cleanFileName,
                '/images/' + cleanFileName
            ];
            
            // Try each path
            function tryNextPath() {
                if (attemptCount >= possiblePaths.length) {
                    console.log('All fallback attempts failed, using placeholder');
                    img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik00MCAzMEg2MFY1MEg0MFYzMFoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iNTAiIHk9IjcwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjEyIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+';
                    return;
                }
                
                const nextPath = possiblePaths[attemptCount];
                console.log(`Attempt ${attemptCount + 1}: trying path: ${nextPath}`);
                
                // Create a new image to test the path
                const testImg = new Image();
                testImg.onload = function() {
                    console.log(`SUCCESS: Path ${attemptCount + 1} worked: ${nextPath}`);
                    img.src = nextPath;
                };
                testImg.onerror = function() {
                    console.log(`FAILED: Path ${attemptCount + 1} failed: ${nextPath}`);
                    attemptCount++;
                    tryNextPath();
                };
                testImg.src = nextPath;
            }
            
            // Start trying paths
            tryNextPath();
        }
        
        // Add image loading verification
        function verifyImageLoading() {
            const images = document.querySelectorAll('.item-image');
            console.log('Verifying', images.length, 'cart images...');
            
            images.forEach((img, index) => {
                // Check if image loaded successfully
                if (img.complete && img.naturalHeight !== 0) {
                    console.log(`Image ${index + 1} loaded successfully:`, img.src);
                } else {
                    console.log(`Image ${index + 1} failed to load:`, img.src);
                    // Trigger fallback manually if needed
                    if (img.naturalHeight === 0) {
                        img.onerror();
                    }
                }
            });
        }
        
        // Run verification after page loads
        window.addEventListener('load', function() {
            setTimeout(verifyImageLoading, 1000);
        });
    </script>
</body>
</html>