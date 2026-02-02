<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession, java.sql.*, java.util.*, java.text.SimpleDateFormat, products.Dbase" %>
<%
// Check if user is logged in
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}
	String SessionId = session.getId();
out.println("Session ID: " +
SessionId);


String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Get sorting parameters
String sortBy = request.getParameter("sortBy");
String sortOrder = request.getParameter("sortOrder");

// Set defaults
if (sortBy == null) sortBy = "transaction_date";
if (sortOrder == null) sortOrder = "DESC";

// Load pending sellers for admin approval
List<Map<String, Object>> pendingSellers = new ArrayList<>();
if ("admin".equals(userRole)) {
    try {
        Dbase db = new Dbase();
        Connection con = db.initailizeDatabase();
        
        if (con != null && !con.isClosed()) {
            String sellerSql = "SELECT id, username, email, first_name, last_name, phone, shop_name, business_type, " +
                             "address, city, state, pincode, registration_date, status " +
                             "FROM signupseller WHERE status = 'pending' ORDER BY registration_date DESC";
            
            PreparedStatement sellerStmt = con.prepareStatement(sellerSql);
            ResultSet sellerRs = sellerStmt.executeQuery();
            
            while (sellerRs.next()) {
                Map<String, Object> seller = new HashMap<>();
                seller.put("id", sellerRs.getInt("id"));
                seller.put("username", sellerRs.getString("username"));
                seller.put("email", sellerRs.getString("email"));
                seller.put("firstName", sellerRs.getString("first_name"));
                seller.put("lastName", sellerRs.getString("last_name"));
                seller.put("phone", sellerRs.getString("phone"));
                seller.put("shopName", sellerRs.getString("shop_name"));
                seller.put("businessType", sellerRs.getString("business_type"));
                seller.put("address", sellerRs.getString("address"));
                seller.put("city", sellerRs.getString("city"));
                seller.put("state", sellerRs.getString("state"));
                seller.put("pincode", sellerRs.getString("pincode"));
                seller.put("registrationDate", sellerRs.getString("registration_date"));
                seller.put("status", sellerRs.getString("status"));
                pendingSellers.add(seller);
            }
            
            sellerRs.close();
            sellerStmt.close();
            con.close();
        }
    } catch (Exception e) {
        System.err.println("Error loading pending sellers: " + e.getMessage());
        e.printStackTrace();
    }
}

// Load payment history
List<Map<String, Object>> paymentHistory = new ArrayList<>();
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        String sql = "SELECT pt.transaction_id, pt.order_id, pt.payment_method, pt.amount, pt.status, " +
                    "pt.transaction_date, pt.card_number_masked, pt.billing_email, o.total_amount " +
                    "FROM payment_transactions pt " +
                    "LEFT JOIN orders o ON pt.order_id = o.order_id " +
                    "WHERE pt.user_id = ? " +
                    "ORDER BY " + sortBy + " " + sortOrder;
        
        PreparedStatement stmt = con.prepareStatement(sql);
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> payment = new HashMap<>();
            payment.put("transactionId", rs.getInt("transaction_id"));
            payment.put("orderId", rs.getString("order_id"));
            payment.put("paymentMethod", rs.getString("payment_method"));
            payment.put("amount", rs.getDouble("amount"));
            payment.put("status", rs.getString("status"));
            payment.put("transactionDate", rs.getTimestamp("transaction_date"));
            payment.put("cardNumberMasked", rs.getString("card_number_masked"));
            payment.put("billingEmail", rs.getString("billing_email"));
            paymentHistory.add(payment);
        }
        
        rs.close();
        stmt.close();
        con.close();
        
        System.out.println("Loaded " + paymentHistory.size() + " payment records for user: " + username);
    } else {
        System.out.println("Database connection failed for user: " + username);
    }
} catch (Exception e) {
    System.err.println("Error loading payment history: " + e.getMessage());
    e.printStackTrace();
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mini Shopping cart Dashboard</title>

<style>
/* Reset */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: Arial, sans-serif;
}

/* Body */
body {
    background-color: #f1f3f6;
}

/* Header */
.header {
    background-color: #2874f0;
    color: white;
    padding: 15px 30px;
    font-size: 22px;
    font-weight: bold;
}

/* Layout */
.container {
    display: flex;
}

/* Sidebar */
.sidebar {
    width: 220px;
    height: 100vh;
    background-color: #172337;
    padding-top: 20px;
}

.sidebar a {
    display: block;
    padding: 15px 20px;
    color: white;
    text-decoration: none;
    font-size: 16px;
}

.sidebar a:hover {
    background-color: #2874f0;
}

/* Main Content */
.main {
    flex: 1;
    padding: 30px;
}

/* Dashboard Cards */
.cards {
    display: flex;
    gap: 20px;
    margin-bottom: 30px;
}

.card {
    background-color: white;
    width: 220px;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    text-align: center;
}

.card h2 {
    color: #2874f0;
    margin-bottom: 10px;
}

.card p {
    font-size: 18px;
}

/* Table */
.table-container {
    background-color: white;
    padding: 20px;
    border-radius: 5px;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

th {
    background-color: #2874f0;
    color: white;
}

tr:hover {
    background-color: #f5f5f5;
}

/* Delete Button */
.delete-btn {
    background: #f44336;
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    transition: background 0.3s ease;
}

.delete-btn:hover {
    background: #d32f2f;
}

/* Payment History Styles */
.payment-history {
    background-color: white;
    padding: 20px;
    border-radius: 5px;
    margin-top: 20px;
}

.payment-history h2 {
    color: #2874f0;
    margin-bottom: 20px;
    font-size: 24px;
}

.status-badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
}

.status-completed {
    background: #d4edda;
    color: #155724;
}

.status-pending {
    background: #fff3cd;
    color: #856404;
}

.status-failed {
    background: #f8d7da;
    color: #721c24;
}

.payment-method {
    display: inline-block;
    padding: 2px 8px;
    background: #e9ecef;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 500;
}

.empty-state {
    text-align: center;
    padding: 40px;
    color: #666;
}

.empty-state i {
    font-size: 48px;
    margin-bottom: 15px;
    color: #ccc;
}

/* Seller Approval Styles */
.seller-approval {
    background-color: white;
    padding: 20px;
    border-radius: 5px;
    margin-top: 20px;
}

.seller-approval h2 {
    color: #2874f0;
    margin-bottom: 20px;
    font-size: 24px;
}

.seller-card {
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    background: #f9f9f9;
}

.seller-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    border-bottom: 2px solid #2874f0;
    padding-bottom: 10px;
}

.seller-name {
    font-size: 18px;
    font-weight: 600;
    color: #333;
}

.seller-username {
    color: #666;
    font-size: 14px;
}

.seller-info {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}

.info-item {
    display: flex;
    flex-direction: column;
}

.info-label {
    font-size: 12px;
    color: #666;
    margin-bottom: 2px;
    font-weight: 600;
}

.info-value {
    font-size: 14px;
    color: #333;
}

.seller-actions {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

.approve-btn {
    background: #28a745;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    transition: background 0.3s ease;
}

.approve-btn:hover {
    background: #218838;
}

.reject-btn {
    background: #dc3545;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    transition: background 0.3s ease;
}

.reject-btn:hover {
    background: #c82333;
}

.view-details-btn {
    background: #6c757d;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    transition: background 0.3s ease;
}

.view-details-btn:hover {
    background: #5a6268;
}

.pending-count {
    background: #ffc107;
    color: #333;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    margin-left: 10px;
}

.business-type {
    display: inline-block;
    padding: 2px 8px;
    background: #e9ecef;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 500;
    color: #495057;
}

.status-pending {
    background: #fff3cd;
    color: #856404;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}
</style>

</head>
<body>

<div class="header">
    <div style="float: right; background: rgba(255, 255, 255, 0.9); padding: 8px 16px; border-radius: 20px; font-weight: 600; color: #333; box-shadow: 0 3px 10px rgba(0,0,0,0.1); margin-right: 20px;">
        👤 <%= username != null ? username : "User" %> (<%= userRole != null ? userRole : "Guest" %>)
    </div>
    Mini Shopping cart Dashboard - Welcome, <%= username != null ? username : "User" %>!
</div>

<div class="container">

    <!-- Sidebar -->
    <div class="sidebar">
    	<a href="Home.jsp">🏠 Home</a>
        <a href="#">📊 Dashboard</a>
        <a href="admin.jsp">🔧 Add & Update </a>
        <a href="Deleteproducts.jsp">🗑️ Delete products</a>
<% if ("admin".equals(userRole)) { %>
        
        
     
        <a href="Seller.jsp">👤 Seller</a>
        <a href="Sellerupload.jsp">👤 Sellerupload</a>
        <a href="Showproducts.jsp">🛍️ Products</a>
<% } %>
        
        <a href="#payment-history">💳 Payment History</a>
<% if ("admin".equals(userRole)) { %>
        
<% } %>
        <a href="LogoutServlet">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">

        <!-- Seller Approval Section (Admin Only) -->
        <% if ("admin".equals(userRole)) { %>
        <div class="seller-approval">
            <h2>👥 Seller Approval 
                <% if (!pendingSellers.isEmpty()) { %>
                    <span class="pending-count"><%= pendingSellers.size() %> Pending</span>
                <% } %>
            </h2>
            
            <% if (pendingSellers.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-user-check"></i>
                    <h3>No Pending Seller Approvals</h3>
                    <p>All seller registrations have been reviewed. No pending approvals at this time.</p>
                </div>
            <% } else { %>
                <% for (Map<String, Object> seller : pendingSellers) { %>
                    <div class="seller-card">
                        <div class="seller-header">
                            <div>
                                <div class="seller-name"><%= seller.get("firstName") %> <%= seller.get("lastName") %></div>
                                <div class="seller-username">@<%= seller.get("username") %></div>
                            </div>
                            <div>
                                <span class="status-pending">Pending</span>
                                <span class="business-type"><%= seller.get("businessType") %></span>
                            </div>
                        </div>
                        
                        <div class="seller-info">
                            <div class="info-item">
                                <span class="info-label">Shop Name</span>
                                <span class="info-value"><%= seller.get("shopName") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Email</span>
                                <span class="info-value"><%= seller.get("email") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Phone</span>
                                <span class="info-value"><%= seller.get("phone") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Registration Date</span>
                                <span class="info-value"><%= seller.get("registrationDate") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">City</span>
                                <span class="info-value"><%= seller.get("city") %>, <%= seller.get("state") %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">PIN Code</span>
                                <span class="info-value"><%= seller.get("pincode") %></span>
                            </div>
                        </div>
                        
                        <div class="seller-info" style="margin-bottom: 10px;">
                            <div class="info-item" style="grid-column: 1 / -1;">
                                <span class="info-label">Address</span>
                                <span class="info-value"><%= seller.get("address") %></span>
                            </div>
                        </div>
                        
                        <div class="seller-actions">
                            <button class="view-details-btn" onclick="viewSellerDetails(<%= seller.get("id") %>)">
                                <i class="fas fa-eye"></i> View Details
                            </button>
                            <button class="reject-btn" onclick="rejectSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                <i class="fas fa-times"></i> Reject
                            </button>
                            <button class="approve-btn" onclick="approveSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                <i class="fas fa-check"></i> Approve
                            </button>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
        <% } %>

        <!-- Payment History Section -->
        <div id="payment-history" class="payment-history">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>💳 Payment History</h2>
                <div class="sorting-controls">
                    <select class="sort-dropdown" onchange="window.location.href='Dashboard.jsp#payment-history?sortBy=' + this.value + '&sortOrder=<%= sortOrder %>'">
                        <option value="transaction_date" <%= "transaction_date".equals(sortBy) ? "selected" : "" %>>Sort by Date</option>
                        <option value="transaction_id" <%= "transaction_id".equals(sortBy) ? "selected" : "" %>>Sort by Transaction ID</option>
                        <option value="order_id" <%= "order_id".equals(sortBy) ? "selected" : "" %>>Sort by Order ID</option>
                        <option value="amount" <%= "amount".equals(sortBy) ? "selected" : "" %>>Sort by Amount</option>
                        <option value="payment_method" <%= "payment_method".equals(sortBy) ? "selected" : "" %>>Sort by Payment Method</option>
                    </select>
                    <a href="Dashboard.jsp#payment-history?sortBy=<%= sortBy %>&sortOrder=ASC" class="sort-btn <%= "ASC".equals(sortOrder) ? "active" : "" %>">
                        <i class="fas fa-sort-alpha-down"></i> Asc
                    </a>
                    <a href="Dashboard.jsp#payment-history?sortBy=<%= sortBy %>&sortOrder=DESC" class="sort-btn <%= "DESC".equals(sortOrder) ? "active" : "" %>">
                        <i class="fas fa-sort-alpha-down-alt"></i> Desc
                    </a>
                </div>
            </div>
            
            <% if (paymentHistory.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-credit-card"></i>
                    <h3>No Payment History</h3>
                    <p>You haven't made any payments yet. Start shopping to see your payment history here!</p>
                    <a href="Showproducts.jsp" style="display: inline-block; margin-top: 15px; padding: 10px 20px; background: #2874f0; color: white; text-decoration: none; border-radius: 5px;">
                        Start Shopping
                    </a>
                </div>
            <% } else { %>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Transaction ID</th>
                                <th>Order ID</th>
                                <th>Payment Method</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Date</th>
                                <th>Card/Account</th>
                                <th>Email</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                            for (Map<String, Object> payment : paymentHistory) { 
                                int transactionId = (Integer) payment.get("transactionId");
                                String orderId = (String) payment.get("orderId");
                                String paymentMethod = (String) payment.get("paymentMethod");
                                double amount = (Double) payment.get("amount");
                                String status = (String) payment.get("status");
                                Timestamp transactionDate = (Timestamp) payment.get("transactionDate");
                                String cardNumberMasked = (String) payment.get("cardNumberMasked");
                                String billingEmail = (String) payment.get("billingEmail");
                                 
                                String statusClass = "status-" + status;
                                String displayCard = cardNumberMasked != null && !cardNumberMasked.isEmpty() ? cardNumberMasked : "N/A";
                            %>
                                <tr>
                                    <td>#<%= transactionId %></td>
                                    <td><a href="OrderConfirmation.jsp?orderId=<%= orderId %>" style="color: #2874f0; text-decoration: none;"><%= orderId %></a></td>
                                    <td><span class="payment-method"><%= paymentMethod.toUpperCase() %></span></td>
                                    <td><strong>₹<%= String.format("%.2f", amount) %></strong></td>
                                    <td><span class="status-badge <%= statusClass %>"><%= status %></span></td>
                                    <td><%= dateFormat.format(transactionDate) %></td>
                                    <td><%= displayCard %></td>
                                    <td><%= billingEmail != null ? billingEmail : "N/A" %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
                    <h4>📊 Summary</h4>
                    <div style="display: flex; gap: 30px; margin-top: 10px;">
                        <div>
                            <strong>Total Transactions:</strong> <%= paymentHistory.size() %>
                        </div>
                        <div>
                            <strong>Total Amount:</strong> 
                            ₹<%= String.format("%.2f", paymentHistory.stream().mapToDouble(p -> (Double) p.get("amount")).sum()) %>
                        </div>
                        <div>
                            <strong>Completed:</strong> 
                            <%= paymentHistory.stream().mapToInt(p -> "completed".equals(p.get("status")) ? 1 : 0).sum() %>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>

    </div>

    <script>
        // Seller Approval Functions
        function approveSeller(sellerId, username) {
            if (confirm('Are you sure you want to approve seller "' + username + '"? This will allow them to access the seller dashboard.')) {
                // Create form for approval
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'UpdateSellerStatusServlet';
                
                // Add seller ID
                const sellerIdInput = document.createElement('input');
                sellerIdInput.type = 'hidden';
                sellerIdInput.name = 'sellerId';
                sellerIdInput.value = sellerId;
                form.appendChild(sellerIdInput);
                
                // Add action
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'approve';
                form.appendChild(actionInput);
                
                // Add approved by
                const approvedByInput = document.createElement('input');
                approvedByInput.type = 'hidden';
                approvedByInput.name = 'approvedBy';
                approvedByInput.value = '<%= username %>';
                form.appendChild(approvedByInput);
                
                // Submit form
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function rejectSeller(sellerId, username) {
            const reason = prompt('Please enter reason for rejecting seller "' + username + '":');
            if (reason !== null && reason.trim() !== '') {
                // Create form for rejection
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'UpdateSellerStatusServlet';
                
                // Add seller ID
                const sellerIdInput = document.createElement('input');
                sellerIdInput.type = 'hidden';
                sellerIdInput.name = 'sellerId';
                sellerIdInput.value = sellerId;
                form.appendChild(sellerIdInput);
                
                // Add action
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'reject';
                form.appendChild(actionInput);
                
                // Add rejection reason
                const reasonInput = document.createElement('input');
                reasonInput.type = 'hidden';
                reasonInput.name = 'rejectionReason';
                reasonInput.value = reason;
                form.appendChild(reasonInput);
                
                // Submit form
                document.body.appendChild(form);
                form.submit();
            } else if (reason !== null) {
                alert('Rejection reason is required.');
            }
        }
        
        function viewSellerDetails(sellerId) {
            // Open seller details in a new window or modal
            const url = 'SellerDetails.jsp?sellerId=' + sellerId;
            window.open(url, 'sellerDetails', 'width=800,height=600,scrollbars=yes,resizable=yes');
        }
        
        // Auto-refresh dashboard every 30 seconds to check for new pending sellers
        setInterval(function() {
            if ('<%= userRole %>' === 'admin') {
                // Only refresh for admin users
                // Uncomment the line below if you want auto-refresh
                // window.location.reload();
            }
        }, 30000);
        
        // Show notification for successful actions
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 600; z-index: 10000; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else if (type === 'error') {
                notification.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #ffc107, #e0a800)';
                notification.style.color = '#333';
            }
            
            notification.textContent = message;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 5000);
        }
        
        // Check for URL parameters and show notifications
        window.addEventListener('load', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const message = urlParams.get('message');
            const type = urlParams.get('type');
            
            if (message && type) {
                showNotification(decodeURIComponent(message), type);
                
                // Clean up URL parameters
                const cleanUrl = window.location.pathname + window.location.hash;
                window.history.replaceState({}, document.title, cleanUrl);
            }
        });
    </script>

</body>
</html>
