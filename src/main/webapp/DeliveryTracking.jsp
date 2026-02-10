<%@ page language="java" contentType="text/html; charset=
UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, products.Dbase" %>
<%
    String orderId = request.getParameter("order_id");
    String trackingId = request.getParameter("trackingId");
    
    List<Map<String, Object>> deliveryDetails = new ArrayList<>();
    
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            // Get delivery details from delivery table
            String deliverySql = "SELECT d.id, d.order_id, d.user_id, d.delivery_status, d.delivery_address, " +
                                "d.delivery_person_name, d.delivery_phone, d.delivery_time, " +
                                "d.actual_delivery_time, d.total_amount, d.created_at, d.updated_at " +
                                "FROM delivery d ORDER BY d.id DESC";
            PreparedStatement deliveryStmt = con.prepareStatement(deliverySql);
            ResultSet deliveryRs = deliveryStmt.executeQuery();
            
            while (deliveryRs.next()) {
                Map<String, Object> delivery = new HashMap<>();
                delivery.put("id", deliveryRs.getInt("id"));
                delivery.put("orderId", deliveryRs.getString("order_id"));
                delivery.put("userId", deliveryRs.getString("user_id"));
                delivery.put("status", deliveryRs.getString("delivery_status"));
                delivery.put("deliveryAddress", deliveryRs.getString("delivery_address"));
                delivery.put("deliveryPerson", deliveryRs.getString("delivery_person_name"));
                delivery.put("deliveryPhone", deliveryRs.getString("delivery_phone"));
                delivery.put("deliveryTime", deliveryRs.getString("delivery_time"));
                delivery.put("actualDeliveryTime", deliveryRs.getString("actual_delivery_time"));
                delivery.put("totalAmount", deliveryRs.getDouble("total_amount"));
                delivery.put("createdAt", deliveryRs.getString("created_at"));
                delivery.put("updatedAt", deliveryRs.getString("updated_at"));
                deliveryDetails.add(delivery);
            }
            
            deliveryRs.close();
            deliveryStmt.close();
            con.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Tracking - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }

        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .back-button:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .header h1 {
            font-size: 2.5rem;
            margin: 0;
        }

        .search-section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        .search-form {
            display: flex;
            gap: 15px;
            max-width: 600px;
            margin: 0 auto;
        }

        .search-input {
            flex: 1;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
        }

        .search-btn {
            padding: 15px 30px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            cursor: pointer;
            transition: background 0.3s;
        }

        .search-btn:hover {
            background: #5a6fd8;
        }

        .delivery-dashboard {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        .delivery-details {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }

        .order-id {
            font-size: 1.5rem;
            font-weight: 600;
            color: #333;
        }

        .order-status {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            text-transform: uppercase;
        }

        .status-pending { background: #fef3c7; color: #92400e; }
        .status-confirmed { background: #dbeafe; color: #1e40af; }
        .status-preparing { background: #e0e7ff; color: #3730a3; }
        .status-ready { background: #dcfce7; color: #166534; }
        .status-in_transit { background: #fbbf24; color: #92400e; }
        .status-delivered { background: #10b981; color: white; }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }

        .info-item {
            padding: 15px;
            background: #f8f9fa;
            border-radius: 10px;
        }

        .info-label {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 5px;
        }

        .info-value {
            font-size: 1.1rem;
            font-weight: 600;
            color: #333;
        }

        .timeline {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }

        .timeline h3 {
            margin-bottom: 25px;
            color: #333;
        }

        .timeline-item {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
            position: relative;
        }

        .timeline-item:not(:last-child)::after {
            content: '';
            position: absolute;
            left: 15px;
            top: 40px;
            width: 2px;
            height: 40px;
            background: #e0e0e0;
        }

        .timeline-icon {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            flex-shrink: 0;
        }

        .timeline-item.completed .timeline-icon {
            background: #10b981;
            color: white;
        }

        .timeline-item.active .timeline-icon {
            background: #667eea;
            color: white;
            animation: pulse 2s ease-in-out infinite;
        }

        .timeline-item.pending .timeline-icon {
            background: #e5e7eb;
            color: #9ca3af;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.05); opacity: 0.8; }
        }

        .timeline-content {
            flex: 1;
        }

        .timeline-title {
            font-weight: 600;
            margin-bottom: 5px;
            color: #333;
        }

        .timeline-time {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 5px;
        }

        .timeline-description {
            font-size: 0.9rem;
            color: #666;
        }

        .delivery-person {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        .delivery-person-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 20px;
        }

        .delivery-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 1.5rem;
        }

        .contact-buttons {
            display: flex;
            gap: 15px;
        }

        .contact-btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background 0.3s;
        }

        .contact-btn.call {
            background: #10b981;
            color: white;
        }

        .contact-btn.message {
            background: #667eea;
            color: white;
        }

        .contact-btn:hover {
            opacity: 0.9;
        }

        .no-deliveries {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .no-deliveries i {
            font-size: 4rem;
            color: #64748b;
            margin-bottom: 1rem;
        }

        .no-deliveries h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: #1e293b;
        }

        .no-deliveries p {
            color: #64748b;
            margin-bottom: 1.5rem;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5a6fd8;
            transform: translateY(-2px);
        }

        @media (max-width: 768px) {
            .delivery-dashboard { grid-template-columns: 1fr; }
            .search-form { flex-direction: column; }
            .info-grid { grid-template-columns: 1fr; }
            
            .header-top {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .back-button {
                align-self: flex-start;
            }
            
            .header h1 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-top">
                <a href="javascript:history.back()" class="back-button">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <h1><i class="fas fa-truck"></i> Delivery Tracking</h1>
            </div>
            <p>Track your orders and delivery status</p>
        </div>

        <div class="search-section">
            <form class="search-form" onsubmit="trackDelivery(event)">
                <input type="text" class="search-input" id="orderIdInput" 
                       placeholder="Enter your Order ID (e.g., ORD001, ORD002, ORD003, ORD004)" required>
                <button type="submit" class="search-btn">
                    <i class="fas fa-search"></i> Track Delivery
                </button>
            </form>
        </div>

        <% if (deliveryDetails.isEmpty()) { %>
            <div class="no-deliveries">
                <i class="fas fa-box-open"></i>
                <h3>No Deliveries Found</h3>
                <p>No delivery records found. Complete a payment to see delivery tracking.</p>
                <a href="Showproducts.jsp" class="btn btn-primary">
                    <i class="fas fa-shopping-bag"></i> Start Shopping
                </a>
            </div>
        <% } else { %>
            <% for (Map<String, Object> delivery : deliveryDetails) { %>
                <% if (orderId == null || orderId.equals((String)delivery.get("orderId"))) { %>
                    <div class="delivery-dashboard">
                        <!-- Delivery Details -->
                        <div class="delivery-details">
                            <div class="order-header">
                                <div class="order-id">Order #<%= delivery.get("orderId") %></div>
                                <div class="order-status status-<%= ((String)delivery.get("status")).toLowerCase() %>">
                                    <%= delivery.get("status") %>
                                </div>
                            </div>

                            <div class="info-grid">
                                <div class="info-item">
                                    <div class="info-label">Customer</div>
                                    <div class="info-value"><%= delivery.get("userId") %></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Total Amount</div>
                                    <div class="info-value">₹<%= String.format("%.2f", (Double)delivery.get("totalAmount")) %></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Order Date</div>
                                    <div class="info-value"><%= delivery.get("createdAt") %></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Delivery Address</div>
                                    <div class="info-value"><%= delivery.get("deliveryAddress") %></div>
                                </div>
                            </div>
                        </div>

                        <!-- Timeline -->
                        <div class="timeline">
                            <h3>Delivery Timeline</h3>
                            <div class="timeline-item completed">
                                <div class="timeline-icon">
                                    <i class="fas fa-check"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Order Placed</div>
                                    <div class="timeline-time"><%= delivery.get("createdAt") %></div>
                                    <div class="timeline-description">Your order has been received</div>
                                </div>
                            </div>
                            <div class="timeline-item <%= "confirmed".equals(delivery.get("status")) || "preparing".equals(delivery.get("status")) || "ready".equals(delivery.get("status")) || "in_transit".equals(delivery.get("status")) || "delivered".equals(delivery.get("status")) ? "completed" : "pending" %>">
                                <div class="timeline-icon">
                                    <i class="fas fa-check"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Order Confirmed</div>
                                    <div class="timeline-time"><%= delivery.get("createdAt") %></div>
                                    <div class="timeline-description">Payment successful, order confirmed</div>
                                </div>
                            </div>
                            <div class="timeline-item <%= "preparing".equals(delivery.get("status")) || "ready".equals(delivery.get("status")) || "in_transit".equals(delivery.get("status")) || "delivered".equals(delivery.get("status")) ? "completed" : "pending" %>">
                                <div class="timeline-icon">
                                    <i class="fas fa-check"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Preparing</div>
                                    <div class="timeline-time"><%= delivery.get("createdAt") %></div>
                                    <div class="timeline-description">Your order is being prepared</div>
                                </div>
                            </div>
                            <div class="timeline-item <%= "in_transit".equals(delivery.get("status")) ? "active" : ("delivered".equals(delivery.get("status")) ? "completed" : "pending") %>">
                                <div class="timeline-icon">
                                    <i class="fas fa-truck"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Out for Delivery</div>
                                    <div class="timeline-time"><%= delivery.get("actualDeliveryTime") != null ? delivery.get("actualDeliveryTime") : "--:--" %></div>
                                    <div class="timeline-description">Delivery person is on the way</div>
                                </div>
                            </div>
                            <div class="timeline-item <%= "delivered".equals(delivery.get("status")) ? "completed" : "pending" %>">
                                <div class="timeline-icon">
                                    <i class="fas fa-check-circle"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Delivered</div>
                                    <div class="timeline-time"><%= "delivered".equals(delivery.get("status")) && delivery.get("actualDeliveryTime") != null ? delivery.get("actualDeliveryTime") : "--:--" %></div>
                                    <div class="timeline-description">Order successfully delivered</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Delivery Person Information -->
                    <div class="delivery-person">
                        <div class="delivery-person-header">
                            <div class="delivery-avatar">
                                <i class="fas fa-user"></i>
                            </div>
                            <div class="delivery-info">
                                <h3><%= delivery.get("deliveryPerson") %></h3>
                                <p>Delivery Partner</p>
                            </div>
                        </div>
                        <div class="contact-buttons">
                            <button class="contact-btn call" onclick="callDeliveryPerson('<%= delivery.get("deliveryPhone") %>')">
                                <i class="fas fa-phone"></i> Call
                            </button>
                            <button class="contact-btn message" onclick="messageDeliveryPerson()">
                                <i class="fas fa-comment"></i> Message
                            </button>
                        </div>
                    </div>
                <% } %>
            <% } %>
        <% } %>
    </div>

    <script>
        function trackDelivery(event) {
            event.preventDefault();
            const orderId = document.getElementById('orderIdInput').value;
            if (orderId) {
                window.location.href = 'DeliveryTracking.jsp?order_id=' + orderId;
            }
        }

        function callDeliveryPerson(phoneNumber) {
            if (phoneNumber && phoneNumber !== 'Not Available' && phoneNumber !== 'NULL') {
                window.open('tel:' + phoneNumber);
            } else {
                alert('Delivery person phone number not available');
            }
        }

        function messageDeliveryPerson() {
            alert('Messaging feature coming soon!');
        }

        // Automatic Timeline Animation
        function animateDeliveryTimeline() {
            const timelineItems = document.querySelectorAll('.timeline-item');
            let currentIndex = 0;
            const orderId = '<%= deliveryDetails.isEmpty() ? "" : (String)deliveryDetails.get(0).get("orderId") %>';
            
            // Reset all items to pending initially
            timelineItems.forEach(item => {
                item.classList.remove('completed', 'active');
                item.classList.add('pending');
                const icon = item.querySelector('.timeline-icon');
                icon.innerHTML = '<i class="fas fa-clock"></i>';
            });
            
            // Start animation
            const interval = setInterval(() => {
                if (currentIndex < timelineItems.length) {
                    const currentItem = timelineItems[currentIndex];
                    
                    // Remove pending and add completed
                    currentItem.classList.remove('pending');
                    currentItem.classList.add('completed');
                    
                    // Update icon to checkmark
                    const icon = currentItem.querySelector('.timeline-icon');
                    icon.innerHTML = '<i class="fas fa-check"></i>';
                    
                    // Update time to current time
                    const timeElement = currentItem.querySelector('.timeline-time');
                    const currentTime = new Date().toLocaleTimeString('en-US', { 
                        hour: '2-digit', 
                        minute: '2-digit' 
                    });
                    timeElement.textContent = currentTime;
                    
                    // Add completion animation
                    currentItem.style.animation = 'slideIn 0.5s ease-out';
                    
                    currentIndex++;
                    
                    // If this is the last item (delivered), delete the delivery record
                    if (currentIndex >= timelineItems.length) {
                        clearInterval(interval);
                        
                        // Show completion message first
                        showCompletionMessage();
                        
                        // Delete delivery record after 2 seconds
                        setTimeout(() => {
                            deleteDeliveryRecord(orderId);
                        }, 2000);
                    }
                }
            }, 5000); // Every 5 seconds
        }
        
        function deleteDeliveryRecord(orderId) {
            if (!orderId) {
                showBlankPage();
                return;
            }
            
            // Send request to delete delivery record
            fetch('DeleteDeliveryServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'orderId=' + encodeURIComponent(orderId)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    console.log('Delivery record deleted successfully');
                    showBlankPage();
                } else {
                    console.error('Failed to delete delivery record:', data.message);
                    // Still show blank page even if deletion fails
                    showBlankPage();
                }
            })
            .catch(error => {
                console.error('Error deleting delivery record:', error);
                // Still show blank page even if there's an error
                showBlankPage();
            });
        }
        
        function showBlankPage() {
            // Clear the entire page content
            document.body.innerHTML = `
                <div style="
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    font-family: 'Inter', sans-serif;
                    color: white;
                    text-align: center;
                ">
                    <div style="
                        background: rgba(255, 255, 255, 0.1);
                        padding: 3rem;
                        border-radius: 20px;
                        backdrop-filter: blur(10px);
                        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                        max-width: 500px;
                    ">
                        <div style="
                            font-size: 4rem;
                            margin-bottom: 1rem;
                            animation: bounce 2s infinite;
                        ">
                            📦✅
                        </div>
                        <h1 style="
                            font-size: 2rem;
                            margin-bottom: 1rem;
                            font-weight: 700;
                        ">
                            Order Delivered Successfully!
                        </h1>
                        <p style="
                            font-size: 1.1rem;
                            margin-bottom: 2rem;
                            opacity: 0.9;
                        ">
                            Your order has been delivered and the tracking record has been removed.
                        </p>
                        <button onclick="location.href='Showproducts.jsp'" style="
                            background: white;
                            color: #667eea;
                            border: none;
                            padding: 12px 24px;
                            border-radius: 8px;
                            font-size: 1rem;
                            font-weight: 600;
                            cursor: pointer;
                            transition: all 0.3s ease;
                        ">
                            Continue Shopping
                        </button>
                    </div>
                </div>
                <style>
                    @keyframes bounce {
                        0%, 20%, 50%, 80%, 100% {
                            transform: translateY(0);
                        }
                        40% {
                            transform: translateY(-20px);
                        }
                        60% {
                            transform: translateY(-10px);
                        }
                    }
                </style>
            `;
        }
        
        function showCompletionMessage() {
            const message = document.createElement('div');
            message.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #10b981;
                color: white;
                padding: 15px 20px;
                border-radius: 10px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                z-index: 1000;
                animation: slideInRight 0.5s ease-out;
                font-weight: 600;
            `;
            message.innerHTML = '<i class="fas fa-check-circle"></i> Delivery Completed Successfully!';
            document.body.appendChild(message);
            
            // Remove message after 5 seconds
            setTimeout(() => {
                message.style.animation = 'slideOutRight 0.5s ease-out';
                setTimeout(() => {
                    document.body.removeChild(message);
                }, 500);
            }, 5000);
        }
        
        // Add CSS animations
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateX(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }
            
            @keyframes slideInRight {
                from {
                    opacity: 0;
                    transform: translateX(20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }
            
            @keyframes slideOutRight {
                from {
                    opacity: 1;
                    transform: translateX(0);
                }
                to {
                    opacity: 0;
                    transform: translateX(20px);
                }
            }
            
            .timeline-item.pending .timeline-icon {
                background: #e5e7eb;
                color: #9ca3af;
                animation: none;
            }
            
            .timeline-item.completed .timeline-icon {
                background: #10b981;
                color: white;
                animation: checkmark 0.5s ease-out;
            }
            
            @keyframes checkmark {
                0% {
                    transform: scale(0);
                }
                50% {
                    transform: scale(1.2);
                }
                100% {
                    transform: scale(1);
                }
            }
        `;
        document.head.appendChild(style);
        
        // Start animation when page loads
        window.addEventListener('load', () => {
            setTimeout(() => {
                animateDeliveryTimeline();
            }, 1000); // Start after 1 second
        });
    </script>
</body>
</html>