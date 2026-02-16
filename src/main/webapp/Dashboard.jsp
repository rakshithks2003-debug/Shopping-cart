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
        <a href="Adminproduct.jsp">🛍️ Addproduct</a>
        <a href="Updateproduct.jsp">🔧  Update product </a>
        <a href="Deleteproducts.jsp">🗑️ Delete products</a>
        
<% if ("admin".equals(userRole)) { %>
        
        
          <a href="Showproducts.jsp">🛍️ Products</a>
           <a href="SellerApproval.jsp">👥 Seller Approval</a>
           <a href="ApprovedProducts.jsp">📦 Seller Products</a>
        <a href="DeliveryTracking.jsp">🚚 Delivery Tracking</a>
        <a href="OrderHistory.jsp">📦 Order History</a>
        <a href="PaymentHistory.jsp">💳 Payment History</a>
<% } %>
        
        
<% if ("admin".equals(userRole)) { %>
        
<% } %>
        <a href="LogoutServlet">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">

    </div>

    <script>
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