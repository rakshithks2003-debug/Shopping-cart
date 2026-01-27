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
        
        <div id="cartItems"></div>
        
        <div class="cart-summary">
            <h2>Cart Summary</h2>
            <div class="total-price">Total: ₹0.00</div>
            <button class="checkout-btn">Checkout</button>
        </div>
        
        <div class="notification" id="notification"></div>
        
        <script>
            function showNotification(message, type) {
                const notification = document.getElementById('notification');
                notification.textContent = message;
                notification.className = 'notification show';
                if (type === 'error') {
                    notification.classList.add('error');
                } else {
                    notification.classList.add('success');
                    }
                }
            }
                        xhr.send('cartId=' + encodeURIComponent(cartId)+'&quantity='+newQuantity);

        
        function updateItemTotal(cartId) {
            const itemElement = document.getElementById('cart-item-' + cartId);
            const priceText = itemElement.querySelector('.cart-item-price').textContent;
            const price = parseFloat(priceText.replace('₹', ''));
            const quantity = parseInt(document.getElementById('quantity-' + cartId).textContent);
            const total = price * quantity;
            
            document.getElementById('total-' + cartId.textContent = '₹' + total.toFixed(2)onst xr = new XMLHttpqut();xr.pen('RmovFomCart.jp',true);xhr.setRequestHeader(,);xhr.onreadystatechange=function(){if (xhr.reaSte == 4 && xh.satus === 200) {        try {            cost JSON.pas(xhr.reText;response        gtEmenByI('tem-' +                                                                 response                response        } )        
                    }
                };
            
            xhr.send('cartId=' + encodeURIComponent(cartId)Amount+cnst rtItemsConaner = dcumetgtEementByI'cartItems'  cartItemsContainer.innerHTML=`
<dvlass="mpty-ar"><3>🛒 Yr carsmpty</h3><p>Addsomemazing pdcsettarted</p><ahre="Sprdu.j"las="v-bpriay">Str Shoppng</a></v>
`cns rSummary = dcumetquerSeto(.c-summry'    if(cartSummary)    tSmmy.emov}}}funcon chckshowN('Rdrecgtochcko...','ucc)alert'Checku unliy wul bimplee he!'1