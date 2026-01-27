<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String username = (String) session.getAttribute("username");
    
    if (username == null || username.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Shopping Cart</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .nav-buttons {
            margin-bottom: 20px;
            text-align: center;
        }
        .nav-buttons a {
            margin: 0 10px;
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .cart-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border: 1px solid #ddd;
            margin-bottom: 10px;
            border-radius: 5px;
        }
        .cart-item img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            margin-right: 15px;
            border-radius: 5px;
        }
        .item-details {
            flex: 1;
        }
        .item-name {
            font-weight: bold;
            margin-bottom: 5px;
        }
        .item-price {
            color: #e74c3c;
            font-weight: bold;
        }
        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0 15px;
        }
        .quantity-btn {
            background: #007bff;
            color: white;
            border: none;
            width: 25px;
            height: 25px;
            border-radius: 3px;
            cursor: pointer;
        }
        .quantity-display {
            font-weight: bold;
            min-width: 30px;
            text-align: center;
        }
        .item-total {
            font-weight: bold;
            color: #27ae60;
            margin: 0 15px;
            min-width: 80px;
        }
        .remove-btn {
            background: #dc3545;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 3px;
            cursor: pointer;
            font-weight: bold;
        }
        .remove-btn:hover {
            background: #c82333;
        }
        .empty-cart {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        .cart-summary {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 20px;
        }
        .total-price {
            font-size: 20px;
            font-weight: bold;
        }
        .checkout-btn {
            background: #28a745;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 5px;
            color: white;
            font-weight: bold;
            z-index: 1000;
            display: none;
        }
        .notification.success {
            background: #28a745;
        }
        .notification.error {
            background: #dc3545;
        }
        .notification.show {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛒 My Shopping Cart</h1>
            <div class="nav-buttons">
                <a href="Showproducts.jsp">← Continue Shopping</a>
                <a href="LogoutServlet">Logout</a>
            </div>
        </div>
        
        <div id="cartItems">
<%
    Connection con = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
        
        String sql = "SELECT id, product_id, product_name, price, quantity, image FROM cart WHERE user_id = ? ORDER BY created_at DESC";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        
        boolean hasItems = false;
        double totalAmount = 0.0;
        
        while(rs.next()) {
            hasItems = true;
            String cartId = rs.getString("id");
            double price = rs.getDouble("price");
            int quantity = rs.getInt("quantity");
            totalAmount += (price * quantity);
            
            String imageFileName = rs.getString("image");
            String imageSrc = "";
            
            if (imageFileName != null && !imageFileName.trim().isEmpty()) {
                imageSrc = "product_images/" + imageFileName;
            } else {
                imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0yMCAyMEg0MFY0MEgyMFYyMFoiIGZpbGw9IiNDQ0NDQ0NDIi8+Cjx0ZXh0IHg9IjMwIiB5PSI0NSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxMCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWc8L3RleHQ+Cjwvc3ZnPg==";
            }
%>
            <div class="cart-item" id="item-<%=cartId%>">
                <img src="<%=imageSrc%>" alt="<%=rs.getString("product_name")%>">
                <div class="item-details">
                    <div class="item-name"><%=rs.getString("product_name")%></div>
                    <div class="item-price">₹<%=String.format("%.2f", price)%></div>
                </div>
                <div class="quantity-controls">
                    <button class="quantity-btn" onclick="updateQuantity('<%=cartId%>', -1)">−</button>
                    <span class="quantity-display" id="qty-<%=cartId%>"><%=quantity%></span>
                    <button class="quantity-btn" onclick="updateQuantity('<%=cartId%>', 1)">+</button>
                </div>
                <div class="item-total" id="total-<%=cartId%>">₹<%=String.format("%.2f", price * quantity)%></div>
                <button class="remove-btn" onclick="removeFromCart('<%=cartId%>')">×</button>
            </div>
<%
        }
        
        rs.close();
        ps.close();
        
        if (!hasItems) {
%>
            <div class="empty-cart">
                <h3>🛒 Your cart is empty</h3>
                <p>Add some products to get started!</p>
                <a href="Showproducts.jsp" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Start Shopping</a>
            </div>
<%
        } else {
%>
        </div>
        
        <div class="cart-summary">
            <div class="total-price">Total: ₹<%=String.format("%.2f", totalAmount)%></div>
            <button class="checkout-btn" onclick="checkout()">Proceed to Checkout</button>
        </div>
<%
        }
    } catch (Exception e) {
%>
        <div class="empty-cart">
            <h3>⚠️ Error Loading Cart</h3>
            <p><%=e.getMessage()%></p>
        </div>
<%
    } finally {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
            }
        } catch (Exception e) {
            // Ignore
        }
    }
%>
    </div>
    
    <div class="notification" id="notification"></div>
    
    <script>
        function showNotification(message, type) {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification show ' + type;
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }
        
        function updateQuantity(cartId, change) {
            const qtyElement = document.getElementById('qty-' + cartId);
            const currentQty = parseInt(qtyElement.textContent);
            const newQty = currentQty + change;
            
            if (newQty < 1) {
                removeFromCart(cartId);
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'UpdateCartQuantity.jsp', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            qtyElement.textContent = newQty;
                            updateItemTotal(cartId);
                            updateCartTotal();
                            showNotification('Quantity updated', 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    } catch (e) {
                        showNotification('Error updating quantity', 'error');
                    }
                }
            };
            
            xhr.send('cartId=' + encodeURIComponent(cartId) + '&quantity=' + newQty);
        }
        
        function updateItemTotal(cartId) {
            const item = document.getElementById('item-' + cartId);
            const priceText = item.querySelector('.item-price').textContent;
            const price = parseFloat(priceText.replace('₹', ''));
            const quantity = parseInt(document.getElementById('qty-' + cartId).textContent);
            const total = price * quantity;
            
            document.getElementById('total-' + cartId).textContent = '₹' + total.toFixed(2);
        }
        
        function removeFromCart(cartId) {
            if (!confirm('Are you sure you want to remove this item?')) {
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'RemoveFromCart.jsp', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            const item = document.getElementById('item-' + cartId);
                            item.style.opacity = '0.5';
                            setTimeout(() => {
                                item.remove();
                                updateCartTotal();
                                checkEmptyCart();
                            }, 300);
                            showNotification('Item removed from cart', 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    } catch (e) {
                        showNotification('Error removing item', 'error');
                    }
                }
            };
            
            xhr.send('cartId=' + encodeURIComponent(cartId));
        }
        
        function updateCartTotal() {
            const items = document.querySelectorAll('.cart-item');
            let total = 0;
            
            items.forEach(item => {
                const totalText = item.querySelector('.item-total').textContent;
                total += parseFloat(totalText.replace('₹', ''));
            });
            
            const totalElement = document.querySelector('.total-price');
            if (totalElement) {
                totalElement.textContent = 'Total: ₹' + total.toFixed(2);
            }
        }
        
        function checkEmptyCart() {
            const items = document.querySelectorAll('.cart-item');
            if (items.length === 0) {
                document.getElementById('cartItems').innerHTML = `
                    <div class="empty-cart">
                        <h3>🛒 Your cart is empty</h3>
                        <p>Add some products to get started!</p>
                        <a href="Showproducts.jsp" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Start Shopping</a>
                    </div>
                `;
                
                const summary = document.querySelector('.cart-summary');
                if (summary) {
                    summary.remove();
                }
            }
        }
        
        function checkout() {
            showNotification('Checkout coming soon!', 'success');
        }
    </script>
</body>
</html>
