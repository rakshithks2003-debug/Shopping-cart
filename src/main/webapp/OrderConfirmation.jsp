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
    
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            // Get order details with shipping information
            String orderSql = "SELECT o.order_id, o.created_at as order_date, o.total_amount, o.payment_method, o.status, " +
                            "s.first_name, s.last_name, s.email, s.phone, s.address, s.city, s.zip_code as pincode " +
                            "FROM orders o " +
                            "LEFT JOIN order_shipping s ON o.order_id = s.order_id " +
                            "WHERE o.order_id = ? AND o.user_id = ?";
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
                orderDetails.put("status", orderRs.getString("status"));
                
                // Combine first and last name
                String firstName = orderRs.getString("first_name");
                String lastName = orderRs.getString("last_name");
                String fullName = (firstName != null ? firstName : "") + (lastName != null ? " " + lastName : "");
                orderDetails.put("fullName", fullName.trim());
                
                orderDetails.put("email", orderRs.getString("email"));
                orderDetails.put("phone", orderRs.getString("phone"));
                orderDetails.put("address", orderRs.getString("address"));
                orderDetails.put("city", orderRs.getString("city"));
                orderDetails.put("pincode", orderRs.getString("pincode"));
                
                // Order items section removed - no longer needed
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
        
        .back-to-home-btn-left {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
        }
        
        .back-to-home-btn-left:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
            background: linear-gradient(135deg, #45a049, #3d8b40);
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
        
        /* ========================================
           BACK TO HOME BUTTON STYLES
           ======================================== */
        .back-to-home-btn-left {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
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

        .back-to-home-btn-left:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(76, 175, 80, 0.3);
            transition: all 0.1s ease;
        }

        .back-to-home-btn-left:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3), 0 0 0 3px rgba(76, 175, 80, 0.2);
        }

        /* Icon styling */
        .back-to-home-btn-left i {
            font-size: 16px;
            margin-right: 2px;
            transition: transform 0.3s ease;
        }

        .back-to-home-btn-left:hover i {
            transform: scale(1.1);
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .back-to-home-btn-left {
                top: 15px;
                left: 15px;
                padding: 10px 16px;
                font-size: 13px;
                border-radius: 20px;
            }
            
            .back-to-home-btn-left i {
                font-size: 14px;
            }
        }

        @media (max-width: 480px) {
            .back-to-home-btn-left {
                top: 10px;
                left: 10px;
                padding: 8px 14px;
                font-size: 12px;
                border-radius: 18px;
                gap: 6px;
            }
            
            .back-to-home-btn-left i {
                font-size: 13px;
            }
        }

        /* High contrast mode support */
        @media (prefers-contrast: high) {
            .back-to-home-btn-left {
                border: 2px solid #ffffff;
                background: #4CAF50;
            }
            
            .back-to-home-btn-left:hover {
                background: #45a049;
                border: 2px solid #ffffff;
            }
        }

        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            .back-to-home-btn-left {
                transition: none;
            }
            
            .back-to-home-btn-left:hover {
                transform: none;
                transition: none;
            }
            
            .back-to-home-btn-left i {
                transition: none;
            }
            
            .back-to-home-btn-left:hover i {
                transform: none;
            }
        }

        /* Dark mode support */
        @media (prefers-color-scheme: dark) {
            .back-to-home-btn-left {
                background: linear-gradient(135deg, #45a049, #3d8b40);
                box-shadow: 0 4px 15px rgba(69, 160, 73, 0.4);
            }
            
            .back-to-home-btn-left:hover {
                background: linear-gradient(135deg, #3d8b40, #2e7d32);
                box-shadow: 0 6px 20px rgba(69, 160, 73, 0.5);
            }
        }

        /* Print styles */
        @media print {
            .back-to-home-btn-left {
                display: none !important;
            }
        }

        /* Loading state */
        .back-to-home-btn-left.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .back-to-home-btn-left.loading i::before {
            content: "\f110"; /* fa-spinner */
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Success state */
        .back-to-home-btn-left.success {
            background: linear-gradient(135deg, #28a745, #20c997);
            animation: pulse 0.5s ease;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        /* Error state */
        .back-to-home-btn-left.error {
            background: linear-gradient(135deg, #dc3545, #c82333);
            animation: shake 0.5s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
    </style>
</head>
<body>
    <!-- Back to Home Button -->
   <a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page">
        <i class="fas fa-home"></i> Back 
    </a>

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
            
            <div class="total-amount">
                Total Paid: ₹<%= String.format("%.2f", (Double) orderDetails.get("totalAmount")) %>
            </div>
            
            <div class="action-buttons">
                <a href="Home.jsp" class="btn btn-primary">
                    <i class="fas fa-shopping-bag"></i> Continue Shopping
                </a>
                <a href="Cart.jsp" class="btn btn-secondary">
                    <i class="fas fa-shopping-cart"></i> View Cart
                </a>
                <a href="DeliveryTracking.jsp?order_id=<%= orderDetails.get("orderId") %>" class="btn btn-info">
                    <i class="fas fa-truck"></i> Track Order
                </a>
            </div>
        </div>
    </div>
</body>
</html>
