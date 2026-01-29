<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, products.Dbase" %>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null) {
        response.sendRedirect("Login.html");
        return;
    }
    
    // Load cart items from database
    List<Map<String, Object>> cartItems = new ArrayList<>();
    double total = 0.0;
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String sql = "SELECT product_id, product_name, price, quantity, image FROM cart WHERE user_id = ? ORDER BY cart_id DESC";
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                String productId = rs.getString("product_id");
                String productName = rs.getString("product_name");
                double price = rs.getDouble("price");
                int quantity = rs.getInt("quantity");
                String image = rs.getString("image");
                
                item.put("productId", productId);
                item.put("productName", productName);
                item.put("price", price);
                item.put("quantity", quantity);
                item.put("image", image);
                cartItems.add(item);
                
                total += price * quantity;
            }
            
            rs.close();
            stmt.close();
            con.close();
        }
    } catch (Exception e) {
        System.err.println("Error loading cart: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Calculate final amount with shipping
    double shipping = total > 0 ? 50.0 : 0.0;
    double finalAmount = total + shipping;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - Mini Shopping Cart</title>
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
            font-size: 2.5rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
            font-weight: 800;
        }
        
        .payment-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .payment-section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        
        .section-title {
            font-size: 1.8rem;
            color: #333;
            margin-bottom: 25px;
            font-weight: 700;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #555;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e8ed;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .payment-methods {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 25px;
        }
        
        .payment-method {
            padding: 15px;
            border: 2px solid #e1e8ed;
            border-radius: 10px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .payment-method:hover {
            border-color: #667eea;
            transform: translateY(-2px);
        }
        
        .payment-method.selected {
            border-color: #667eea;
            background: rgba(102, 126, 234, 0.1);
        }
        
        .payment-method i {
            font-size: 2rem;
            margin-bottom: 8px;
            color: #667eea;
        }
        
        .order-summary {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        
        .order-item {
            display: flex;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid #e1e8ed;
        }
        
        .order-item img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 15px;
        }
        
        .order-item-details {
            flex: 1;
        }
        
        .order-item-name {
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .order-item-price {
            color: #666;
            font-size: 0.9rem;
        }
        
        .order-item-quantity {
            font-weight: 600;
            color: #667eea;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            font-size: 1.1rem;
        }
        
        .summary-row.total {
            border-top: 2px solid #e1e8ed;
            margin-top: 15px;
            padding-top: 15px;
            font-weight: 700;
            font-size: 1.3rem;
            color: #667eea;
        }
        
        .pay-btn {
            width: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 18px;
            border-radius: 12px;
            font-size: 1.2rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 25px;
        }
        
        .pay-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .pay-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        
        .back-link {
            display: inline-flex;
            align-items: center;
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }
        
        .back-link:hover {
            transform: translateX(-5px);
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 600;
            z-index: 10000;
            max-width: 400px;
            display: none;
            animation: slideIn 0.3s ease;
        }
        
        .notification.success {
            background: linear-gradient(135deg, #28a745, #20c997);
        }
        
        .notification.error {
            background: linear-gradient(135deg, #dc3545, #c82333);
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @media (max-width: 768px) {
            .payment-container {
                grid-template-columns: 1fr;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .payment-methods {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-content">
                <a href="Cart.jsp" class="back-link">
                    <i class="fas fa-arrow-left"></i> Back to Cart
                </a>
                <h1>💳 Secure Payment</h1>
                <p>Complete your order securely</p>
            </div>
        </header>
        
        <div class="payment-container">
            <div class="payment-section">
                <h2 class="section-title">Payment Information</h2>
                
                <form id="paymentForm">
                    <div class="form-group">
                        <label>Payment Method</label>
                        <div class="payment-methods">
                            <div class="payment-method selected" data-method="card">
                                <i class="fas fa-credit-card"></i>
                                <div>Credit Card</div>
                            </div>
                            <div class="payment-method" data-method="debit">
                                <i class="fas fa-credit-card"></i>
                                <div>Debit Card</div>
                            </div>
                            <div class="payment-method" data-method="upi">
                                <i class="fas fa-mobile-alt"></i>
                                <div>UPI</div>
                            </div>
                            <div class="payment-method" data-method="cod">
                                <i class="fas fa-money-bill-wave"></i>
                                <div>Cash on Delivery</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="cardNumber">Card Number</label>
                        <input type="text" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19">
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="expiry">Expiry Date</label>
                            <input type="text" id="expiry" placeholder="MM/YY" maxlength="5">
                        </div>
                        <div class="form-group">
                            <label for="cvv">CVV</label>
                            <input type="text" id="cvv" placeholder="123" maxlength="3">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="cardName">Cardholder Name</label>
                        <input type="text" id="cardName" placeholder="John Doe">
                    </div>
                    
                    <h3 class="section-title">Billing Address</h3>
                    
                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" placeholder="John Doe" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" placeholder="john@example.com" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" placeholder="+91 98765 43210" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="address">Street Address</label>
                        <input type="text" id="address" name="address" placeholder="123 Main Street" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city" placeholder="Bangalore" required>
                        </div>
                        <div class="form-group">
                            <label for="pincode">PIN Code</label>
                            <input type="text" id="pincode" name="pincode" placeholder="560001" required>
                        </div>
                    </div>
                </form>
            </div>
            
            <div class="order-summary">
                <h2 class="section-title">Order Summary</h2>
                
                <% if (cartItems.isEmpty()) { %>
                    <div style="text-align: center; padding: 40px; color: #666;">
                        <i class="fas fa-shopping-cart" style="font-size: 3rem; margin-bottom: 15px;"></i>
                        <p>Your cart is empty</p>
                        <a href="Showproducts.jsp" style="color: #667eea; text-decoration: none; font-weight: 600;">Continue Shopping</a>
                    </div>
                <% } else { %>
                    <% for (Map<String, Object> item : cartItems) { 
                        String productId = (String) item.get("productId");
                        String productName = (String) item.get("productName");
                        double price = (Double) item.get("price");
                        int quantity = (Integer) item.get("quantity");
                        String image = (String) item.get("image");
                        
                        String imageSrc;
                        if (image == null || image.isEmpty()) {
                            imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0yMCAyMEg0MFY0MEgyMFYyMFoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iMzAiIHk9IjQ1IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjEwIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+";
                        } else {
                            imageSrc = request.getContextPath() + "/product_images/" + image;
                        }
                    %>
                        <div class="order-item">
                            <img src="<%= imageSrc %>" alt="<%= productName %>" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0yMCAyMEg0MFY0MEgyMFYyMFoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iMzAiIHk9IjQ1IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjEwIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+';">
                            <div class="order-item-details">
                                <div class="order-item-name"><%= productName %></div>
                                <div class="order-item-price">₹<%= String.format("%.2f", price) %> × <%= quantity %></div>
                            </div>
                            <div class="order-item-quantity">₹<%= String.format("%.2f", price * quantity) %></div>
                        </div>
                    <% } %>
                    
                    <div style="margin-top: 30px;">
                        <div class="summary-row">
                            <span>Subtotal</span>
                            <span>₹<%= String.format("%.2f", total) %></span>
                        </div>
                        <div class="summary-row">
                            <span>Shipping</span>
                            <span>₹<%= String.format("%.2f", shipping) %></span>
                        </div>
                        <div class="summary-row total">
                            <span>Total Amount</span>
                            <span>₹<%= String.format("%.2f", finalAmount) %></span>
                        </div>
                    </div>
                    
                    <button class="pay-btn" onclick="processPayment()">
                        <i class="fas fa-lock"></i> Pay ₹<%= String.format("%.2f", finalAmount) %>
                    </button>
                <% } %>
            </div>
        </div>
    </div>
    
    <div class="notification" id="notification"></div>
    
    <script>
        // Payment method selection
        document.querySelectorAll('.payment-method').forEach(method => {
            method.addEventListener('click', function() {
                document.querySelectorAll('.payment-method').forEach(m => m.classList.remove('selected'));
                this.classList.add('selected');
                
                // Show/hide card fields based on payment method
                const selectedMethod = this.dataset.method;
                const cardFields = document.querySelectorAll('#cardNumber, #expiry, #cvv, #cardName');
                
                if (selectedMethod === 'cod' || selectedMethod === 'upi') {
                    cardFields.forEach(field => field.parentElement.style.display = 'none');
                } else {
                    cardFields.forEach(field => field.parentElement.style.display = 'block');
                }
            });
        });
        
        // Card number formatting
        document.getElementById('cardNumber').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '');
            let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formattedValue;
        });
        
        // Expiry date formatting
        document.getElementById('expiry').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.slice(0, 2) + '/' + value.slice(2, 4);
            }
            e.target.value = value;
        });
        
        // CVV validation (numbers only)
        document.getElementById('cvv').addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '');
        });
        
        // Process payment
        function processPayment() {
            const selectedMethod = document.querySelector('.payment-method.selected').dataset.method;
            
            // Basic validation
            if (selectedMethod !== 'cod' && selectedMethod !== 'upi') {
                const cardNumber = document.getElementById('cardNumber').value;
                const expiry = document.getElementById('expiry').value;
                const cvv = document.getElementById('cvv').value;
                const cardName = document.getElementById('cardName').value;
                
                if (!cardNumber || !expiry || !cvv || !cardName) {
                    showNotification('Please fill in all card details', 'error');
                    return;
                }
            }
            
            const fullName = document.getElementById('fullName').value;
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const address = document.getElementById('address').value;
            const city = document.getElementById('city').value;
            const pincode = document.getElementById('pincode').value;
            
            if (!fullName || !email || !phone || !address || !city || !pincode) {
                showNotification('Please fill in all billing details', 'error');
                return;
            }
            
            // Show processing state
            const payBtn = document.querySelector('.pay-btn');
            const originalText = payBtn.innerHTML;
            payBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            payBtn.disabled = true;
            
            // Simulate payment processing
            setTimeout(() => {
                // Create order in database
                createOrder();
            }, 2000);
        }
        
        function createOrder() {
            const selectedMethod = document.querySelector('.payment-method.selected').dataset.method;
            const fullName = document.getElementById('fullName').value;
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const address = document.getElementById('address').value;
            const city = document.getElementById('city').value;
            const pincode = document.getElementById('pincode').value;
            
            // Debug: Log values to console
            console.log('Payment Method:', selectedMethod);
            console.log('Full Name:', fullName);
            console.log('Email:', email);
            console.log('Phone:', phone);
            console.log('Address:', address);
            console.log('City:', city);
            console.log('Pincode:', pincode);
            console.log('Total Amount:', '<%= finalAmount %>');
            
            // Send order data to server
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'OrderServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    const payBtn = document.querySelector('.pay-btn');
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Server Response:', response);
                            if (response.success) {
                                // Create payment transaction record
                                createPaymentTransaction(response.orderId, selectedMethod, fullName, email, phone, address, city, pincode);
                            } else {
                                showNotification(response.message || 'Payment failed', 'error');
                                payBtn.innerHTML = '<i class="fas fa-lock"></i> Pay ₹<%= String.format("%.2f", finalAmount) %>';
                                payBtn.disabled = false;
                            }
                        } catch (e) {
                            console.log('JSON Parse Error:', e);
                            showNotification('Payment processing failed', 'error');
                            payBtn.innerHTML = '<i class="fas fa-lock"></i> Pay ₹<%= String.format("%.2f", finalAmount) %>';
                            payBtn.disabled = false;
                        }
                    } else {
                        console.log('HTTP Error:', xhr.status);
                        showNotification('Server error. Please try again.', 'error');
                        payBtn.innerHTML = '<i class="fas fa-lock"></i> Pay ₹<%= String.format("%.2f", finalAmount) %>';
                        payBtn.disabled = false;
                    }
                }
            };
            
            // Build data string inside the function where variables exist
            const data = 'paymentMethod=' + encodeURIComponent(selectedMethod) +
                        '&fullName=' + encodeURIComponent(fullName) +
                        '&email=' + encodeURIComponent(email) +
                        '&phone=' + encodeURIComponent(phone) +
                        '&address=' + encodeURIComponent(address) +
                        '&city=' + encodeURIComponent(city) +
                        '&pincode=' + encodeURIComponent(pincode) +
                        '&totalAmount=' + encodeURIComponent('<%= finalAmount %>');
            
            console.log('Sending data:', data);
            xhr.send(data);
        }
        
        function createPaymentTransaction(orderId, paymentMethod, fullName, email, phone, address, city, pincode) {
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'PaymentTransactionServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Payment Transaction Response:', response);
                            if (response.success) {
                                showNotification('Payment recorded successfully! Redirecting...', 'success');
                                setTimeout(() => {
                                    window.location.href = 'OrderConfirmation.jsp?orderId=' + orderId;
                                }, 2000);
                            } else {
                                showNotification('Order created but payment recording failed: ' + response.message, 'error');
                                setTimeout(() => {
                                    window.location.href = 'OrderConfirmation.jsp?orderId=' + orderId;
                                }, 3000);
                            }
                        } catch (e) {
                            console.log('Payment Transaction JSON Parse Error:', e);
                            showNotification('Order created! Redirecting...', 'success');
                            setTimeout(() => {
                                window.location.href = 'OrderConfirmation.jsp?orderId=' + orderId;
                            }, 2000);
                        }
                    } else {
                        console.log('Payment Transaction HTTP Error:', xhr.status);
                        showNotification('Order created! Redirecting...', 'success');
                        setTimeout(() => {
                            window.location.href = 'OrderConfirmation.jsp?orderId=' + orderId;
                        }, 2000);
                    }
                }
            };
            
            const cardNumber = document.getElementById('cardNumber').value;
            const cardName = document.getElementById('cardName').value;
            
            // Mask card number (show only last 4 digits)
            let maskedCardNumber = '';
            if (cardNumber && cardNumber.length > 4) {
                maskedCardNumber = '****-****-****-' + cardNumber.replace(/\s/g, '').slice(-4);
            }
            
            const data = 'orderId=' + encodeURIComponent(orderId) +
                        '&paymentMethod=' + encodeURIComponent(paymentMethod) +
                        '&amount=' + encodeURIComponent('<%= finalAmount %>') +
                        '&cardNumber=' + encodeURIComponent(maskedCardNumber) +
                        '&cardholderName=' + encodeURIComponent(cardName) +
                        '&billingEmail=' + encodeURIComponent(email) +
                        '&billingPhone=' + encodeURIComponent(phone) +
                        '&billingAddress=' + encodeURIComponent(address) +
                        '&billingCity=' + encodeURIComponent(city) +
                        '&billingPincode=' + encodeURIComponent(pincode);
            
            console.log('Sending payment transaction data:', data);
            xhr.send(data);
        }
        
        function showNotification(message, type) {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification ' + type;
            notification.style.display = 'block';
            
            setTimeout(() => {
                notification.style.display = 'none';
            }, 5000);
        }
    </script>
</body>
</html>
