<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.Dbase" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("role");
    
    if (username == null || username.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - Mini Shopping Cart</title>
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
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            padding: 30px;
            margin-bottom: 40px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.1);
            text-align: center;
            color: white;
        }

        h1 {
            font-size: 3rem;
            margin-bottom: 15px;
            background: linear-gradient(45deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 20px;
        }

        .nav-btn {
            padding: 12px 25px;
            text-decoration: none;
            border-radius: 30px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .nav-btn.back {
            background: rgba(255, 255, 255, 0.15);
            color: white;
            border-color: rgba(255, 255, 255, 0.2);
        }

        .nav-btn.back:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-3px);
        }

        .nav-btn.primary {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            box-shadow: 0 10px 25px rgba(231, 76, 60, 0.3);
        }

        .nav-btn.primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(231, 76, 60, 0.4);
        }

        main {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 40px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .cart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }

        .cart-title {
            font-size: 2.5rem;
            color: #2c3e50;
            font-weight: 700;
        }

        .cart-count {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
        }

        .cart-items {
            margin-bottom: 30px;
        }

        .cart-item {
            display: grid;
            grid-template-columns: 100px 1fr auto auto auto;
            gap: 20px;
            align-items: center;
            padding: 20px;
            margin-bottom: 15px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .cart-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }

        .cart-item-image {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .cart-item-details {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .cart-item-name {
            font-size: 1.2rem;
            font-weight: 600;
            color: #2c3e50;
        }

        .cart-item-price {
            font-size: 1.1rem;
            color: #e74c3c;
            font-weight: 600;
        }

        .cart-item-quantity {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #f8f9fa;
            padding: 8px 15px;
            border-radius: 25px;
        }

        .quantity-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 1.2rem;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .quantity-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .quantity-display {
            font-weight: 600;
            min-width: 30px;
            text-align: center;
        }

        .cart-item-total {
            font-size: 1.2rem;
            font-weight: 700;
            color: #27ae60;
            min-width: 100px;
            text-align: right;
        }

        .remove-btn {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 1.5rem;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .remove-btn:hover {
            transform: scale(1.1) rotate(90deg);
            box-shadow: 0 5px 15px rgba(231, 76, 60, 0.4);
        }

        .empty-cart {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
        }

        .empty-cart h3 {
            font-size: 2rem;
            margin-bottom: 15px;
            color: #95a5a6;
        }

        .empty-cart p {
            font-size: 1.1rem;
            margin-bottom: 25px;
        }

        .cart-summary {
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            padding: 30px;
            border-radius: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 30px;
        }

        .total-price {
            font-size: 2rem;
            font-weight: 700;
            color: #2c3e50;
        }

        .checkout-btn {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            border: none;
            padding: 18px 40px;
            border-radius: 30px;
            font-size: 1.2rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 10px 25px rgba(46, 204, 113, 0.3);
        }

        .checkout-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(46, 204, 113, 0.4);
        }

        .notification {
            position: fixed;
            top: 30px;
            right: 30px;
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            padding: 18px 25px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(46, 204, 113, 0.3);
            z-index: 1000;
            opacity: 0;
            transform: translateY(-30px) scale(0.9);
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            font-weight: 600;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .notification.show {
            opacity: 1;
            transform: translateY(0) scale(1);
        }

        .notification.error {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            box-shadow: 0 15px 35px rgba(231, 76, 60, 0.3);
        }

        @media (max-width: 768px) {
            .cart-item {
                grid-template-columns: 80px 1fr;
                gap: 15px;
            }
            
            .cart-item-quantity,
            .cart-item-total,
            .remove-btn {
                grid-column: 2;
                justify-self: end;
            }
            
            .cart-summary {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .cart-title {
                font-size: 1.8rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🛒 My Shopping Cart</h1>
            <div class="nav-buttons">
                <a href="Showproducts.jsp" class="nav-btn back">← Continue Shopping</a>
                <% if ("admin".equals(userRole)) { %>
                    <a href="admin.jsp" class="nav-btn primary">🔧 Admin Panel</a>
                <% } %>
                <a href="LogoutServlet" class="nav-btn primary">🚪 Logout</a>
            </div>
        </header>
        
        <main>
            <div class="cart-section">
                <div class="cart-header">
                    <h2 class="cart-title">Your Cart</h2>
                    <div class="cart-count" id="cartCount">0 items</div>
                </div>
                
                <div class="cart-items" id="cartItems">
<%
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con == null || con.isClosed()) {
%>
                    <div class="empty-cart">
                        <h3>⚠️ Database Error</h3>
                        <p>Unable to connect to database</p>
                    </div>
<%
        } else {
            String sql = "SELECT id, product_id, product_name, price, quantity, image FROM cart WHERE user_id = ? ORDER BY created_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            
            boolean hasItems = false;
            double totalAmount = 0.0;
            int totalItems = 0;
            
            while(rs.next()) {
                hasItems = true;
                String cartId = rs.getString("id");
                totalItems += rs.getInt("quantity");
                totalAmount += (rs.getDouble("price") * rs.getInt("quantity"));
                
                String imageFileName = rs.getString("image");
                String imageSrc = "";
                
                if (imageFileName != null && !imageFileName.trim().isEmpty()) {
                    imageSrc = "product_images/" + imageFileName;
                } else {
                    imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAiIGhlaWdodD0iODAiIHZpZXdCb3g9IjAgMCA4MCA4MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjgwIiBoZWlnaHQ9IjgwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0zMCAzMkg1MFY0OEgzMlYzMloiIGZpbGw9IiNDQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0zNiA0MEw0MCA0NEw0NCA0MEg0OFY0OEgzMlY0MEgzNloiIGZpbGw9IiNDQ0NDQ0NDIi8+Cjx0ZXh0IHg9IjQwIiB5PSI2NSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxMCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWc8L3RleHQ+Cjwvc3ZnPg==";
                }
%>
                    <div class="cart-item" id="cart-item-<%=cartId%>">
                        <img class="cart-item-image" src="<%=imageSrc%>" alt="<%=rs.getString("product_name")%>">
                        <div class="cart-item-details">
                            <div class="cart-item-name"><%=rs.getString("product_name")%></div>
                            <div class="cart-item-price">₹<%=String.format("%.2f", rs.getDouble("price"))%></div>
                        </div>
                        <div class="cart-item-quantity">
                            <button class="quantity-btn" onclick="updateQuantity('<%=cartId%>', -1)">−</button>
                            <span class="quantity-display" id="quantity-<%=cartId%>"><%=rs.getInt("quantity")%></span>
                            <button class="quantity-btn" onclick="updateQuantity('<%=cartId%>', 1)">+</button>
                        </div>
                        <div class="cart-item-total" id="total-<%=cartId%>">₹<%=String.format("%.2f", rs.getDouble("price") * rs.getInt("quantity"))%></div>
                        <button class="remove-btn" onclick="removeFromCart('<%=cartId%>')">×</button>
                    </div>
<%
            }
            
            rs.close();
            ps.close();
            con.close();
            
            if (!hasItems) {
%>
                    <div class="empty-cart">
                        <h3>🛒 Your cart is empty</h3>
                        <p>Add some amazing products to get started!</p>
                        <a href="Showproducts.jsp" class="nav-btn primary">Start Shopping</a>
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
                out.println("<script>document.getElementById('cartCount').textContent = '" + totalItems + " items';</script>");
            }
        }
    } catch (Exception e) {
%>
                    <div class="empty-cart">
                        <h3>⚠️ Error Loading Cart</h3>
                        <p><%=e.getMessage()%></p>
                    </div>
<%
    }
%>
            </div>
        </main>
    </div>
    
    <div class="notification" id="notification"></div>
    
    <script>
        function showNotification(message, type) {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification show';
            if (type === 'error') {
                notification.classList.add('error');
            }
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }
        
        function updateQuantity(cartId, change) {
            const quantityElement = document.getElementById('quantity-' + cartId);
            const currentQuantity = parseInt(quantityElement.textContent);
            const newQuantity = currentQuantity + change;
            
            if (newQuantity < 1) {
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
                            quantityElement.textContent = newQuantity;
                            updateItemTotal(cartId);
                            updateCartTotals();
                            showNotification(response.message, 'success');
                        } else {
                            showNotification(response.message, 'error');
                        }
                    } catch (e) {
                        showNotification('Error updating quantity', 'error');
                    }
                }
            };
            
            xhr.send('cartId=' + encodeURIComponent(cartId) + '&quantity=' + newQuantity);
        }
        
        function updateItemTotal(cartId) {
            const itemElement = document.getElementById('cart-item-' + cartId);
            const priceText = itemElement.querySelector('.cart-item-price').textContent;
            const price = parseFloat(priceText.replace('₹', ''));
            const quantity = parseInt(document.getElementById('quantity-' + cartId).textContent);
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
                            const itemElement = document.getElementById('cart-item-' + cartId);
                            itemElement.style.transition = 'opacity 0.3s ease';
                            itemElement.style.opacity = '0';
                            setTimeout(() => {
                                itemElement.remove();
                                updateCartTotals();
                                checkEmptyCart();
                            }, 300);
                            showNotification(response.message, 'success');
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
        
        function updateCartTotals() {
            const cartItems = document.querySelectorAll('.cart-item');
            let totalAmount = 0;
            let totalItems = 0;
            
            cartItems.forEach(item => {
                const priceText = item.querySelector('.cart-item-price').textContent;
                const price = parseFloat(priceText.replace('₹', ''));
                const quantity = parseInt(item.querySelector('.quantity-display').textContent);
                totalAmount += price * quantity;
                totalItems += quantity;
            });
            
            const totalElement = document.querySelector('.total-price');
            if (totalElement) {
                totalElement.textContent = 'Total: ₹' + totalAmount.toFixed(2);
            }
            
            document.getElementById('cartCount').textContent = totalItems + ' items';
        }
        
        function checkEmptyCart() {
            const cartItems = document.querySelectorAll('.cart-item');
            if (cartItems.length === 0) {
                const cartItemsContainer = document.getElementById('cartItems');
                cartItemsContainer.innerHTML = `
                    <div class="empty-cart">
                        <h3>🛒 Your cart is empty</h3>
                        <p>Add some amazing products to get started!</p>
                        <a href="Showproducts.jsp" class="nav-btn primary">Start Shopping</a>
                    </div>
                `;
                
                const cartSummary = document.querySelector('.cart-summary');
                if (cartSummary) {
                    cartSummary.remove();
                }
            }
        }
        
        function checkout() {
            showNotification('Redirecting to checkout...', 'success');
            setTimeout(() => {
                alert('Checkout functionality would be implemented here!');
            }, 1000);
        }
    </script>
</body>
</html>
