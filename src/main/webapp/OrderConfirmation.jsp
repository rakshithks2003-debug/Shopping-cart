<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.Dbase, java.util.*, java.util.Map, java.util.HashMap, java.util.List, java.util.ArrayList" %>
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null) {
        response.sendRedirect("Login.html");
        return;
    }
    
    String orderId = request.getParameter("orderId");
    if (orderId == null || orderId.trim().isEmpty()) {
        response.sendRedirect("Showproducts.jsp");
        return;
    }
    
    // Load order details
    Map<String, Object> orderDetails = null;
    List<Map<String, Object>> orderItems = new ArrayList<>();
    
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            // Get order details
            String orderSql = "SELECT * FROM orders WHERE order_id = ? AND user_id = ?";
            PreparedStatement orderStmt = con.prepareStatement(orderSql);
            orderStmt.setString(1, orderId);
            orderStmt.setString(2, username);
            ResultSet orderRs = orderStmt.executeQuery();
            
            if (orderRs.next()) {
                orderDetails = new HashMap<>();
                orderDetails.put("orderId", orderRs.getString("order_id"));
                orderDetails.put("orderDate", orderRs.getString("order_date"));
                orderDetails.put("totalAmount", orderRs.getDouble("total_amount"));
                orderDetails.put("paymentMethod", orderRs.getString("payment_method"));
                orderDetails.put("fullName", orderRs.getString("full_name"));
                orderDetails.put("email", orderRs.getString("email"));
                orderDetails.put("phone", orderRs.getString("phone"));
                orderDetails.put("address", orderRs.getString("address"));
                orderDetails.put("city", orderRs.getString("city"));
                orderDetails.put("pincode", orderRs.getString("pincode"));
                orderDetails.put("status", orderRs.getString("status"));
                
                // Get order items
                String itemsSql = "SELECT * FROM order_items WHERE order_id = ?";
                PreparedStatement itemsStmt = con.prepareStatement(itemsSql);
                itemsStmt.setString(1, orderId);
                ResultSet itemsRs = itemsStmt.executeQuery();
                
                while (itemsRs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("productName", itemsRs.getString("product_name"));
                    item.put("price", itemsRs.getDouble("price"));
                    item.put("quantity", itemsRs.getInt("quantity"));
                    item.put("image", itemsRs.getString("image"));
                    orderItems.add(item);
                }
                
                itemsRs.close();
                itemsStmt.close();
            }
            
            orderRs.close();
            orderStmt.close();
            con.close();
        }
    } catch (Exception e) {
        System.err.println("Error loading order: " + e.getMessage());
        e.printStackTrace();
    }
    
    if (orderDetails == null) {
        response.sendRedirect("Showproducts.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation - Mini Shopping Cart</title>
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
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            max-width: 800px;
            width: 100%;
            padding: 20px;
        }
        
        .confirmation-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
            text-align: center;
        }
        
        .success-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #28a745, #20c997);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            animation: scaleIn 0.5s ease;
        }
        
        .success-icon i {
            font-size: 3rem;
            color: white;
        }
        
        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }
        
        h1 {
            font-size: 2.5rem;
            color: #333;
            margin-bottom: 10px;
            font-weight: 800;
        }
        
        .subtitle {
            color: #666;
            font-size: 1.2rem;
            margin-bottom: 40px;
        }
        
        .order-info {
            background: rgba(102, 126, 234, 0.1);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            text-align: left;
        }
        
        .order-id {
            font-size: 1.3rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 15px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
        }
        
        .info-label {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-weight: 600;
            color: #333;
        }
        
        .order-items {
            margin-bottom: 30px;
            text-align: left;
        }
        
        .order-items h3 {
            margin-bottom: 15px;
            color: #333;
        }
        
        .order-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #e1e8ed;
        }
        
        .order-item:last-child {
            border-bottom: none;
        }
        
        .order-item img {
            width: 50px;
            height: 50px;
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
        
        .total-amount {
            font-size: 1.5rem;
            font-weight: 700;
            color: #667eea;
            text-align: right;
            margin-bottom: 30px;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        
        .btn {
            padding: 15px 30px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .btn-secondary {
            background: #f8f9fa;
            color: #333;
            border: 2px solid #e1e8ed;
        }
        
        .btn-secondary:hover {
            background: #e9ecef;
            transform: translateY(-2px);
        }
        
        @media (max-width: 768px) {
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="confirmation-card">
            <div class="success-icon">
                <i class="fas fa-check"></i>
            </div>
            
            <h1>Order Confirmed!</h1>
            <p class="subtitle">Thank you for your purchase. Your order has been successfully placed.</p>
            
            <div class="order-info">
                <div class="order-id">Order ID: <%= orderDetails.get("orderId") %></div>
                
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Order Date</span>
                        <span class="info-value"><%= orderDetails.get("orderDate") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Payment Method</span>
                        <span class="info-value"><%= orderDetails.get("paymentMethod") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Status</span>
                        <span class="info-value"><%= orderDetails.get("status") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Total Amount</span>
                        <span class="info-value">₹<%= String.format("%.2f", (Double) orderDetails.get("totalAmount")) %></span>
                    </div>
                </div>
                
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Customer Name</span>
                        <span class="info-value"><%= orderDetails.get("fullName") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Email</span>
                        <span class="info-value"><%= orderDetails.get("email") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Phone</span>
                        <span class="info-value"><%= orderDetails.get("phone") %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Delivery Address</span>
                        <span class="info-value"><%= orderDetails.get("address") %>, <%= orderDetails.get("city") %> - <%= orderDetails.get("pincode") %></span>
                    </div>
                </div>
            </div>
            
            <div class="order-items">
                <h3>Order Items</h3>
                <% for (Map<String, Object> item : orderItems) { 
                    String productName = (String) item.get("productName");
                    double price = (Double) item.get("price");
                    int quantity = (Integer) item.get("quantity");
                    String image = (String) item.get("image");
                    
                    String imageSrc;
                    if (image == null || image.isEmpty()) {
                        imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTAiIGhlaWdodD0iNTAiIHZpZXdCb3g9IjAgMCA1MCA1MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjUwIiBoZWlnaHQ9IjUwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNSAxNUgzNVYzNUgxNVYxNVoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iMjUiIHk9IjQwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjgiPk5vIEltYWdlPC90ZXh0Pgo8L3N2Zz4=";
                    } else {
                        imageSrc = request.getContextPath() + "/product_images/" + image;
                    }
                %>
                    <div class="order-item">
                        <img src="<%= imageSrc %>" alt="<%= productName %>" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTAiIGhlaWdodD0iNTAiIHZpZXdCb3g9IjAgMCA1MCA1MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjUwIiBoZWlnaHQ9IjUwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNSAxNUgzNVYzNUgxNVYxNVoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHRleHQgeD0iMjUiIHk9IjQwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5OTk5IiBmb250LXNpemU9IjgiPk5vIEltYWdlPC90ZXh0Pgo8L3N2Zz4=';">
                        <div class="order-item-details">
                            <div class="order-item-name"><%= productName %></div>
                            <div class="order-item-price">₹<%= String.format("%.2f", price) %> × <%= quantity %></div>
                        </div>
                        <div class="order-item-quantity">₹<%= String.format("%.2f", price * quantity) %></div>
                    </div>
                <% } %>
            </div>
            
            <div class="total-amount">
                Total Paid: ₹<%= String.format("%.2f", (Double) orderDetails.get("totalAmount")) %>
            </div>
            
            <div class="action-buttons">
                <a href="Showproducts.jsp" class="btn btn-primary">
                    <i class="fas fa-shopping-bag"></i> Continue Shopping
                </a>
                <a href="Cart.jsp" class="btn btn-secondary">
                    <i class="fas fa-shopping-cart"></i> View Cart
                </a>
            </div>
        </div>
    </div>
</body>
</html>
