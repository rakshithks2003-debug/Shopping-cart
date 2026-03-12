<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, java.text.SimpleDateFormat, products.Dbase" %>
<%
    // Check if user is logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    // Get sorting parameters
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
    // Set defaults
    if (sortBy == null) sortBy = "o.created_at";
    if (sortOrder == null) sortOrder = "DESC";
    
    // Load order history
    List<Map<String, Object>> orderHistory = new ArrayList<>();
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String sql;
            PreparedStatement stmt;
            
            if ("admin".equals(userRole)) {
                // Admin sees all orders
                sql = "SELECT o.order_id, o.user_id, o.total_amount, o.gst, o.delivery_charges, o.status, " +
                      "o.payment_method, o.created_at, o.updated_at, o.tracking_id, o.delivery_address, o.delivery_date " +
                      "FROM orders o " +
                      "ORDER BY " + sortBy + " " + sortOrder;
                stmt = con.prepareStatement(sql);
            } else {
                // Regular users see only their orders
                sql = "SELECT o.order_id, o.user_id, o.total_amount, o.gst, o.delivery_charges, o.status, " +
                      "o.payment_method, o.created_at, o.updated_at, o.tracking_id, o.delivery_address, o.delivery_date " +
                      "FROM orders o " +
                      "WHERE o.user_id = ? " +
                      "ORDER BY " + sortBy + " " + sortOrder;
                stmt = con.prepareStatement(sql);
                stmt.setString(1, username);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> order = new HashMap<>();
                order.put("orderId", rs.getString("order_id"));
                order.put("userId", rs.getString("user_id"));
                order.put("totalAmount", rs.getDouble("total_amount"));
                order.put("gst", rs.getDouble("gst"));
                order.put("deliveryCharges", rs.getDouble("delivery_charges"));
                order.put("status", rs.getString("status"));
                order.put("paymentMethod", rs.getString("payment_method"));
                order.put("orderDate", rs.getTimestamp("created_at"));
                order.put("updatedAt", rs.getTimestamp("updated_at"));
                order.put("trackingId", rs.getString("tracking_id"));
                order.put("deliveryAddress", rs.getString("delivery_address"));
                order.put("deliveryDate", rs.getDate("delivery_date"));
                
                if ("admin".equals(userRole)) {
                    order.put("customerName", rs.getString("user_id")); // Using user_id as customer name for now
                }
                
                orderHistory.add(order);
            }
            
            rs.close();
            stmt.close();
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
    <title>Order History - Mini Shopping Cart</title>
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
        }
        
        .header {
            background: white;
            border-radius: 15px;
            padding: 25px 30px;
            margin-bottom: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .header h1 {
            color: #333;
            font-size: 1.8rem;
        }
        
        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .back-button:hover {
            background: #5a6fd8;
            transform: translateY(-2px);
        }
        
        .order-history-container {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .section-title {
            font-size: 1.5rem;
            color: #333;
            font-weight: 700;
        }
        
        .search-sort-controls {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .search-bar {
            position: relative;
            display: flex;
            align-items: center;
        }
        
        .search-bar i {
            position: absolute;
            left: 12px;
            color: #667eea;
            font-size: 1rem;
        }
        
        .search-bar input {
            padding: 10px 15px 10px 40px;
            border: 2px solid #e1e8ed;
            border-radius: 25px;
            background: white;
            font-size: 0.9rem;
            width: 300px;
            transition: all 0.3s ease;
        }
        
        .search-bar input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .sorting-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .sort-dropdown {
            padding: 8px 12px;
            border: 2px solid #e1e8ed;
            border-radius: 8px;
            background: white;
            font-size: 0.9rem;
        }
        
        .sort-btn {
            padding: 8px 15px;
            background: #f8f9fa;
            border: 2px solid #e1e8ed;
            border-radius: 8px;
            color: #666;
            text-decoration: none;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }
        
        .sort-btn:hover, .sort-btn.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .orders-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #e1e8ed;
        }
        
        .orders-table td {
            padding: 15px;
            border-bottom: 1px solid #e1e8ed;
            color: #555;
        }
        
        .orders-table tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-completed {
            background: #d4edda;
            color: #155724;
        }
        
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
        }
        
        .status-processing {
            background: #cce7ff;
            color: #004085;
        }
        
        .status-shipped {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .status-delivered {
            background: #d4edda;
            color: #155724;
        }
        
        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: #666;
        }
        
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 15px;
            color: #ccc;
        }
        
        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .action-btn {
            padding: 6px 12px;
            border: none;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .view-btn {
            background: #667eea;
            color: white;
        }
        
        .view-btn:hover {
            background: #5a6fd8;
            transform: translateY(-2px);
        }
        
        .return-btn {
            background: #ef4444;
            color: white;
        }
        
        .return-btn:hover {
            background: #dc2626;
            transform: translateY(-2px);
        }
        
        .refund-btn {
            background: #10b981;
            color: white;
        }
        
        .refund-btn:hover {
            background: #059669;
            transform: translateY(-2px);
        }
        
        /* Return Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(5px);
            animation: fadeIn 0.3s ease-out;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .modal-content {
            background: white;
            margin: 5% auto;
            padding: 0;
            border-radius: 15px;
            max-width: 600px;
            max-height: 85vh;
            overflow: visible;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: slideDown 0.3s ease-out;
            display: flex;
            flex-direction: column;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .modal-header {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            padding: 25px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .close-modal {
            font-size: 2rem;
            color: white;
            cursor: pointer;
            background: none;
            border: none;
            transition: transform 0.3s;
            line-height: 1;
        }
        
        .close-modal:hover {
            transform: rotate(90deg);
        }
        
        .modal-body {
            padding: 30px;
            max-height: calc(85vh - 200px);
            overflow-y: auto;
            flex: 1;
        }
        
        .return-form-group {
            margin-bottom: 20px;
        }
        
        .return-form-label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }
        
        .return-form-select,
        .return-form-textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 1rem;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            transition: border-color 0.3s;
        }
        
        .return-form-select:focus,
        .return-form-textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .return-form-textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .return-info-box {
            background: #f0f9ff;
            border-left: 4px solid #667eea;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .return-info-box h4 {
            color: #667eea;
            margin-bottom: 8px;
            font-size: 1rem;
        }
        
        .return-info-box p {
            color: #666;
            font-size: 0.9rem;
            line-height: 1.6;
            margin: 0;
        }
        
        .refund-amount-display {
            background: linear-gradient(135deg, #f0fdf4, #dcfce7);
            border: 2px solid #10b981;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
            text-align: center;
        }
        
        .refund-amount-label {
            font-size: 0.9rem;
            color: #059669;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .refund-amount-value {
            font-size: 2rem;
            color: #10b981;
            font-weight: 700;
        }
        
        .modal-footer {
            padding: 20px 30px;
            background: #f8f9fa;
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            border-top: 1px solid #e5e7eb;
            flex-shrink: 0;
            border-bottom-left-radius: 15px;
            border-bottom-right-radius: 15px;
        }
        
        .modal-btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .modal-btn-cancel {
            background: #e5e7eb;
            color: #666;
        }
        
        .modal-btn-cancel:hover {
            background: #d1d5db;
        }
        
        .modal-btn-submit {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }
        
        .modal-btn-submit:hover {
            background: linear-gradient(135deg, #dc2626, #b91c1c);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(239, 68, 68, 0.3);
        }
        
        .modal-btn-submit.refund-submit {
            background: linear-gradient(135deg, #10b981, #059669) !important;
            color: white !important;
            display: inline-flex !important;
            align-items: center;
            gap: 8px;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .modal-btn-submit.refund-submit:hover {
            background: linear-gradient(135deg, #059669, #047857) !important;
            box-shadow: 0 5px 15px rgba(16, 185, 129, 0.3);
        }
        
        .modal-btn-submit:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        
        .success-message {
            position: fixed;
            top: 20px;
            right: 20px;
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            padding: 20px 25px;
            border-radius: 12px;
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3);
            z-index: 1001;
            animation: slideInRight 0.5s ease-out;
            max-width: 400px;
        }
        
        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(100px);
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
                transform: translateX(100px);
            }
        }
        
        @media (max-width: 768px) {
            .section-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .search-sort-controls {
                width: 100%;
                flex-direction: column;
            }
            
            .search-bar {
                width: 100%;
            }
            
            .search-bar input {
                width: 100%;
            }
            
            .sorting-controls {
                width: 100%;
                justify-content: space-between;
            }
            
            .orders-table {
                font-size: 0.9rem;
            }
            
            .orders-table th,
            .orders-table td {
                padding: 10px 8px;
            }
        }
    </style>
</head>
<body>
    <a href="javascript:history.back()" class="back-button">
        <i class="fas fa-arrow-left"></i> Back
    </a>
    
    <div class="container">
        <div class="header">
            <h1>📦 Order History</h1>
            <div>
                👤 <%= username %> (<%= userRole %>)
            </div>
        </div>
        
        <div class="order-history-container">
            <div class="section-header">
                <h2 class="section-title">Your Orders</h2>
                <div class="search-sort-controls">
                    <div class="search-bar">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Search by Order ID, Status, or Amount..." onkeyup="searchOrders()">
                    </div>
                    <div class="sorting-controls">
                        <select class="sort-dropdown" onchange="window.location.href='OrderHistory.jsp?sortBy=' + this.value + '&sortOrder=<%= sortOrder %>'">
                            <option value="o.created_at" <%= "o.created_at".equals(sortBy) ? "selected" : "" %>>Sort by Date</option>
                            <option value="o.total_amount" <%= "o.total_amount".equals(sortBy) ? "selected" : "" %>>Sort by Amount</option>
                            <option value="o.status" <%= "o.status".equals(sortBy) ? "selected" : "" %>>Sort by Status</option>
                        </select>
                        <a href="OrderHistory.jsp?sortBy=<%= sortBy %>&sortOrder=ASC" class="sort-btn <%= "ASC".equals(sortOrder) ? "active" : "" %>">
                            <i class="fas fa-sort-alpha-down"></i> Asc
                        </a>
                        <a href="OrderHistory.jsp?sortBy=<%= sortBy %>&sortOrder=DESC" class="sort-btn <%= "DESC".equals(sortOrder) ? "active" : "" %>">
                            <i class="fas fa-sort-alpha-down-alt"></i> Desc
                        </a>
                    </div>
                </div>
            </div>
            
            <% if (orderHistory.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-box-open"></i>
                    <h3>No Orders Found</h3>
                    <p>You haven't placed any orders yet.</p>
                </div>
            <% } else { %>
                <table class="orders-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <% if ("admin".equals(userRole)) { %>
                                <th>Customer</th>
                            <% } %>
                            <th>Date</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Payment Method</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                        for (Map<String, Object> order : orderHistory) { 
                            String status = "completed"; // Always show as completed
                            String statusClass = "status-completed";
                        %>
                        <tr>
                            <td><strong>#<%= order.get("orderId") %></strong></td>
                            <% if ("admin".equals(userRole)) { %>
                                <td><%= order.get("customerName") != null ? order.get("customerName") : order.get("userId") %></td>
                            <% } %>
                            <td><%= dateFormat.format(order.get("orderDate")) %></td>
                            <td>₹<%= String.format("%.2f", (Double) order.get("totalAmount")) %></td>
                            <td><span class="status-badge <%= statusClass %>"><%= status %></span></td>
                            <td><%= order.get("paymentMethod") != null ? order.get("paymentMethod").toString().toUpperCase() : "N/A" %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn view-btn" onclick="viewOrderDetails('<%= order.get("orderId") %>')">
                                        <i class="fas fa-eye"></i> View
                                    </button>
                                    <% if ("completed".equals(status) || "delivered".equals(status)) { %>
                                        <button class="action-btn return-btn" onclick="openReturnModal('<%= order.get("orderId") %>', '<%= order.get("userId") %>')">
                                            <i class="fas fa-undo"></i> Return
                                        </button>
                                        <button class="action-btn refund-btn" onclick="openRefundModal('<%= order.get("orderId") %>', '<%= order.get("userId") %>', <%= order.get("totalAmount") %>)">
                                            <i class="fas fa-money-bill-wave"></i> Refund
                                        </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
    
    <!-- Return Order Modal -->
    <div id="returnModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-undo-alt"></i> Return Order</h2>
                <button class="close-modal" onclick="closeReturnModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="return-info-box">
                    <h4><i class="fas fa-info-circle"></i> Return Policy</h4>
                    <p>Returns must be initiated within 7 days of delivery. Products must be unused and in original packaging.</p>
                </div>
                
                <form id="returnForm">
                    <input type="hidden" id="returnOrderId" name="orderId">
                    <input type="hidden" id="returnUserId" name="userId">
                    
                    <div class="return-form-group">
                        <label class="return-form-label">Return Reason *</label>
                        <select id="returnReason" name="returnReason" class="return-form-select" required>
                            <option value="">-- Select a reason --</option>
                            <option value="defective">Product is defective or damaged</option>
                            <option value="wrong_item">Wrong item received</option>
                            <option value="not_as_described">Product not as described</option>
                            <option value="quality">Poor quality</option>
                            <option value="size_fit">Size/fit issues</option>
                            <option value="changed_mind">Changed my mind</option>
                            <option value="other">Other reason</option>
                        </select>
                    </div>
                    
                    <div class="return-form-group">
                        <label class="return-form-label">Additional Comments (Optional)</label>
                        <textarea id="returnComments" name="returnComments" class="return-form-textarea" 
                                  placeholder="Please provide more details about your return request..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="modal-btn modal-btn-cancel" onclick="closeReturnModal()">Cancel</button>
                <button class="modal-btn modal-btn-submit" onclick="submitReturn()">
                    <i class="fas fa-paper-plane"></i> Submit Return Request
                </button>
            </div>
        </div>
    </div>
    
    <!-- Refund Request Modal -->
    <div id="refundModal" class="modal">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #10b981, #059669);">
                <h2><i class="fas fa-money-bill-wave"></i> Request Refund</h2>
                <button class="close-modal" onclick="closeRefundModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="return-info-box" style="background: #f0fdf4; border-left-color: #10b981;">
                    <h4 style="color: #10b981;"><i class="fas fa-info-circle"></i> Refund Policy</h4>
                    <p>Refunds are processed within 5-7 business days after approval. The amount will be credited to your original payment method.</p>
                </div>
                
                <div class="refund-amount-display">
                    <div class="refund-amount-label">Order Amount:</div>
                    <div class="refund-amount-value" id="refundAmountDisplay">₹0.00</div>
                </div>
                
                <form id="refundForm">
                    <input type="hidden" id="refundOrderId" name="orderId">
                    <input type="hidden" id="refundUserId" name="userId">
                    <input type="hidden" id="refundAmount" name="refundAmount">
                    
                    <div class="return-form-group">
                        <label class="return-form-label">Refund Reason *</label>
                        <select id="refundReason" name="refundReason" class="return-form-select" required>
                            <option value="">-- Select a reason --</option>
                            <option value="defective_product">Defective or damaged product</option>
                            <option value="wrong_item">Wrong item delivered</option>
                            <option value="not_received">Order not received</option>
                            <option value="quality_issue">Quality not as expected</option>
                            <option value="duplicate_order">Duplicate order placed</option>
                            <option value="cancelled_order">Order cancelled by seller</option>
                            <option value="overcharged">Overcharged amount</option>
                            <option value="other">Other reason</option>
                        </select>
                    </div>
                    
                    <div class="return-form-group">
                        <label class="return-form-label">Refund Type *</label>
                        <select id="refundType" name="refundType" class="return-form-select" required>
                            <option value="">-- Select refund type --</option>
                            <option value="full">Full Refund</option>
                            <option value="partial">Partial Refund</option>
                        </select>
                    </div>
                    
                    <div class="return-form-group" id="partialAmountGroup" style="display: none;">
                        <label class="return-form-label">Partial Refund Amount (₹) *</label>
                        <input type="number" id="partialRefundAmount" name="partialRefundAmount" 
                               class="return-form-select" min="1" step="0.01" 
                               placeholder="Enter amount to refund">
                    </div>
                    
                    <div class="return-form-group">
                        <label class="return-form-label">Bank Account Details (Optional)</label>
                        <input type="text" id="bankAccount" name="bankAccount" 
                               class="return-form-select" 
                               placeholder="Account number (if different from original payment)">
                    </div>
                    
                    <div class="return-form-group">
                        <label class="return-form-label">Additional Details</label>
                        <textarea id="refundComments" name="refundComments" class="return-form-textarea" 
                                  placeholder="Please provide any additional information about your refund request..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="modal-btn modal-btn-cancel" onclick="closeRefundModal()">Cancel</button>
                <button class="modal-btn modal-btn-submit refund-submit" onclick="submitRefund()">
                    <i class="fas fa-check-circle"></i> Submit Refund Request
                </button>
            </div>
        </div>
    </div>
    
    <script>
        // Search function for orders
        function searchOrders() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toUpperCase();
            const table = document.querySelector('.orders-table');
            const rows = table.getElementsByTagName('tr');
            
            let visibleCount = 0;
            
            // Loop through all table rows (skip header)
            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                const cells = row.getElementsByTagName('td');
                let found = false;
                
                // Search through all cells in the row
                for (let j = 0; j < cells.length; j++) {
                    const cell = cells[j];
                    if (cell) {
                        const textValue = cell.textContent || cell.innerText;
                        if (textValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            }
            
            // Show/hide empty state message
            const emptyState = document.querySelector('.empty-state');
            if (visibleCount === 0 && filter !== '') {
                if (!document.getElementById('noResultsMessage')) {
                    const noResults = document.createElement('div');
                    noResults.id = 'noResultsMessage';
                    noResults.className = 'empty-state';
                    noResults.innerHTML = '<i class="fas fa-search"></i><h3>No Results Found</h3><p>No orders match your search criteria.</p>';
                    table.parentNode.insertBefore(noResults, table.nextSibling);
                }
                table.style.display = 'none';
            } else {
                const noResults = document.getElementById('noResultsMessage');
                if (noResults) {
                    noResults.remove();
                }
                table.style.display = 'table';
            }
        }
        
        // View order details
        function viewOrderDetails(orderId) {
            // Redirect to order details page or show details modal
            window.location.href = 'OrderConfirmation.jsp?orderId=' + orderId;
        }
        
        // Open return modal
        function openReturnModal(orderId, userId) {
            document.getElementById('returnOrderId').value = orderId;
            document.getElementById('returnUserId').value = userId;
            document.getElementById('returnReason').value = '';
            document.getElementById('returnComments').value = '';
            document.getElementById('returnModal').style.display = 'block';
        }
        
        // Close return modal
        function closeReturnModal() {
            document.getElementById('returnModal').style.display = 'none';
        }
        
        // Submit return request
        function submitReturn() {
            const orderId = document.getElementById('returnOrderId').value;
            const userId = document.getElementById('returnUserId').value;
            const reason = document.getElementById('returnReason').value;
            const comments = document.getElementById('returnComments').value;
            
            if (!reason) {
                alert('Please select a return reason');
                document.getElementById('returnReason').focus();
                return;
            }
            
            const reasonText = document.getElementById('returnReason').options[document.getElementById('returnReason').selectedIndex].text;
            const confirmMessage = 'Are you sure you want to initiate a return for Order #' + orderId + '?\n\n' +
                                  'Reason: ' + reasonText + '\n' +
                                  (comments ? 'Comments: ' + comments : '');
            
            if (confirm(confirmMessage)) {
                // Show loading state
                const submitBtn = event.target;
                const originalText = submitBtn.innerHTML;
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                
                // Simulate API call (replace with actual servlet call)
                setTimeout(() => {
                    // Close modal
                    closeReturnModal();
                    
                    // Show success message
                    showSuccessMessage(orderId);
                    
                    // Reset button
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                    
                    // Optionally reload page or update UI
                    // setTimeout(() => location.reload(), 2000);
                }, 1500);
            }
        }
        
        // Show success message
        function showSuccessMessage(orderId) {
            const message = document.createElement('div');
            message.className = 'success-message';
            message.innerHTML = `
                <div style="display: flex; align-items: center; gap: 12px;">
                    <i class="fas fa-check-circle" style="font-size: 1.5rem;"></i>
                    <div>
                        <div style="font-size: 1.1rem; margin-bottom: 5px; font-weight: 600;">Return Request Submitted!</div>
                        <div style="font-size: 0.9rem; opacity: 0.9;">Order #${orderId} - We'll process your return within 24-48 hours.</div>
                    </div>
                </div>
            `;
            document.body.appendChild(message);
            
            // Remove message after 5 seconds
            setTimeout(() => {
                message.style.animation = 'slideOutRight 0.5s ease-out';
                setTimeout(() => {
                    if (document.body.contains(message)) {
                        document.body.removeChild(message);
                    }
                }, 500);
            }, 5000);
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const returnModal = document.getElementById('returnModal');
            const refundModal = document.getElementById('refundModal');
            if (event.target === returnModal) {
                closeReturnModal();
            }
            if (event.target === refundModal) {
                closeRefundModal();
            }
        }
        
        // Open refund modal
        function openRefundModal(orderId, userId, amount) {
            document.getElementById('refundOrderId').value = orderId;
            document.getElementById('refundUserId').value = userId;
            document.getElementById('refundAmount').value = amount;
            document.getElementById('refundAmountDisplay').textContent = '₹' + parseFloat(amount).toFixed(2);
            document.getElementById('refundReason').value = '';
            document.getElementById('refundType').value = '';
            document.getElementById('partialRefundAmount').value = '';
            document.getElementById('bankAccount').value = '';
            document.getElementById('refundComments').value = '';
            document.getElementById('partialAmountGroup').style.display = 'none';
            document.getElementById('refundModal').style.display = 'block';
        }
        
        // Close refund modal
        function closeRefundModal() {
            document.getElementById('refundModal').style.display = 'none';
        }
        
        // Handle refund type change
        document.addEventListener('DOMContentLoaded', function() {
            const refundTypeSelect = document.getElementById('refundType');
            if (refundTypeSelect) {
                refundTypeSelect.addEventListener('change', function() {
                    const partialAmountGroup = document.getElementById('partialAmountGroup');
                    if (this.value === 'partial') {
                        partialAmountGroup.style.display = 'block';
                        document.getElementById('partialRefundAmount').required = true;
                    } else {
                        partialAmountGroup.style.display = 'none';
                        document.getElementById('partialRefundAmount').required = false;
                    }
                });
            }
        });
        
        // Submit refund request
        function submitRefund() {
            const orderId = document.getElementById('refundOrderId').value;
            const userId = document.getElementById('refundUserId').value;
            const reason = document.getElementById('refundReason').value;
            const refundType = document.getElementById('refundType').value;
            const fullAmount = parseFloat(document.getElementById('refundAmount').value);
            const partialAmount = document.getElementById('partialRefundAmount').value;
            const comments = document.getElementById('refundComments').value;
            
            if (!reason) {
                alert('Please select a refund reason');
                document.getElementById('refundReason').focus();
                return;
            }
            
            if (!refundType) {
                alert('Please select a refund type');
                document.getElementById('refundType').focus();
                return;
            }
            
            if (refundType === 'partial') {
                if (!partialAmount || parseFloat(partialAmount) <= 0) {
                    alert('Please enter a valid partial refund amount');
                    document.getElementById('partialRefundAmount').focus();
                    return;
                }
                if (parseFloat(partialAmount) > fullAmount) {
                    alert('Partial refund amount cannot exceed the order amount');
                    document.getElementById('partialRefundAmount').focus();
                    return;
                }
            }
            
            const refundAmount = refundType === 'full' ? fullAmount : parseFloat(partialAmount);
            const reasonText = document.getElementById('refundReason').options[document.getElementById('refundReason').selectedIndex].text;
            
            const confirmMessage = 'Are you sure you want to request a refund for Order #' + orderId + '?\n\n' +
                                  'Refund Type: ' + refundType.toUpperCase() + '\n' +
                                  'Amount: ₹' + refundAmount.toFixed(2) + '\n' +
                                  'Reason: ' + reasonText + '\n' +
                                  (comments ? 'Details: ' + comments : '');
            
            if (confirm(confirmMessage)) {
                // Show loading state
                const submitBtn = event.target;
                const originalText = submitBtn.innerHTML;
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                
                // Simulate API call (replace with actual servlet call)
                setTimeout(() => {
                    // Close modal
                    closeRefundModal();
                    
                    // Show success message
                    showRefundSuccessMessage(orderId, refundAmount);
                    
                    // Reset button
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                    
                    // Optionally reload page or update UI
                    // setTimeout(() => location.reload(), 2000);
                }, 1500);
            }
        }
        
        // Show refund success message
        function showRefundSuccessMessage(orderId, amount) {
            const message = document.createElement('div');
            message.className = 'success-message';
            message.innerHTML = `
                <div style="display: flex; align-items: center; gap: 12px;">
                    <i class="fas fa-check-circle" style="font-size: 1.5rem;"></i>
                    <div>
                        <div style="font-size: 1.1rem; margin-bottom: 5px; font-weight: 600;">Refund Request Submitted!</div>
                        <div style="font-size: 0.9rem; opacity: 0.9;">Order #${orderId} - ₹${amount.toFixed(2)} will be refunded within 5-7 business days.</div>
                    </div>
                </div>
            `;
            document.body.appendChild(message);
            
            // Remove message after exactly 5 seconds
            setTimeout(() => {
                message.style.animation = 'slideOutRight 0.5s ease-out';
                setTimeout(() => {
                    if (document.body.contains(message)) {
                        document.body.removeChild(message);
                    }
                }, 500);
            }, 5000); // Exactly 5 seconds (5000 milliseconds)
        }
    </script>
</body>
</html>