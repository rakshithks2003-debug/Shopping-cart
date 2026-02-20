<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession, java.sql.*, java.util.*, java.text.SimpleDateFormat, products.Dbase" %>
<%
// Check if user is logged in and is a seller
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}
String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Check if user is a seller
if (!"seller".equals(userRole)) {
    response.sendRedirect("Home.jsp");
    return;
}

// Fetch seller_id from users table for seller role
String sellerId = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
    String sellerQuery = "SELECT seller_id FROM users WHERE username = ?";
    PreparedStatement sellerStmt = con.prepareStatement(sellerQuery);
    sellerStmt.setString(1, username);
    ResultSet rs = sellerStmt.executeQuery();
    
    if (rs.next()) {
        sellerId = rs.getString("seller_id");
    }
    rs.close();
    sellerStmt.close();
    con.close();
} catch (Exception e) {
    System.err.println("Error fetching seller_id: " + e.getMessage());
}

// Load seller information
Map<String, Object> sellerInfo = new HashMap<>();
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        String sellerSql = "SELECT * FROM signupseller WHERE username = ?";
        PreparedStatement sellerStmt = con.prepareStatement(sellerSql);
        sellerStmt.setString(1, username);
        ResultSet sellerRs = sellerStmt.executeQuery();
        
        if (sellerRs.next()) {
            sellerInfo.put("id", sellerRs.getInt("id"));
            sellerInfo.put("firstName", sellerRs.getString("first_name"));
            sellerInfo.put("lastName", sellerRs.getString("last_name"));
            sellerInfo.put("email", sellerRs.getString("email"));
            sellerInfo.put("phone", sellerRs.getString("phone"));
            sellerInfo.put("shopName", sellerRs.getString("shop_name"));
            sellerInfo.put("businessType", sellerRs.getString("business_type"));
            sellerInfo.put("gstNumber", sellerRs.getString("gst_number"));
            sellerInfo.put("address", sellerRs.getString("address"));
            sellerInfo.put("city", sellerRs.getString("city"));
            sellerInfo.put("state", sellerRs.getString("state"));
            sellerInfo.put("pincode", sellerRs.getString("pincode"));
            sellerInfo.put("registrationDate", sellerRs.getString("registration_date"));
            sellerInfo.put("status", sellerRs.getString("status"));
        }
        
        sellerRs.close();
        sellerStmt.close();
        con.close();
    }
} catch (Exception e) {
    System.err.println("Error loading seller info: " + e.getMessage());
}

// Load seller statistics
Map<String, Object> stats = new HashMap<>();
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        // Count seller's products
        String productCountSql = "SELECT COUNT(*) as count FROM product WHERE seller_username = ?";
        PreparedStatement productStmt = con.prepareStatement(productCountSql);
        productStmt.setString(1, username);
        ResultSet productRs = productStmt.executeQuery();
        if (productRs.next()) {
            stats.put("productCount", productRs.getInt("count"));
        }
        productRs.close();
        productStmt.close();
        
        // Count seller's orders
        String orderCountSql = "SELECT COUNT(*) as count FROM orders WHERE seller_username = ?";
        PreparedStatement orderStmt = con.prepareStatement(orderCountSql);
        orderStmt.setString(1, username);
        ResultSet orderRs = orderStmt.executeQuery();
        if (orderRs.next()) {
            stats.put("orderCount", orderRs.getInt("count"));
        }
        orderRs.close();
        orderStmt.close();
        
        // Calculate total revenue
        String revenueSql = "SELECT SUM(total_amount) as revenue FROM orders WHERE seller_username = ? AND status = 'completed'";
        PreparedStatement revenueStmt = con.prepareStatement(revenueSql);
        revenueStmt.setString(1, username);
        ResultSet revenueRs = revenueStmt.executeQuery();
        if (revenueRs.next()) {
            stats.put("totalRevenue", revenueRs.getDouble("revenue"));
        }
        revenueRs.close();
        revenueStmt.close();
        
        con.close();
    }
} catch (Exception e) {
    System.err.println("Error loading seller stats: " + e.getMessage());
}

// Load recent orders
List<Map<String, Object>> recentOrders = new ArrayList<>();
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        String ordersSql = "SELECT * FROM orders WHERE seller_username = ? ORDER BY order_date DESC LIMIT 5";
        PreparedStatement ordersStmt = con.prepareStatement(ordersSql);
        ordersStmt.setString(1, username);
        ResultSet ordersRs = ordersStmt.executeQuery();
        
        while (ordersRs.next()) {
            Map<String, Object> order = new HashMap<>();
            order.put("orderId", ordersRs.getString("order_id"));
            order.put("customerName", ordersRs.getString("customer_name"));
            order.put("totalAmount", ordersRs.getDouble("total_amount"));
            order.put("status", ordersRs.getString("status"));
            order.put("orderDate", ordersRs.getString("order_date"));
            recentOrders.add(order);
        }
        
        ordersRs.close();
        ordersStmt.close();
        con.close();
    }
} catch (Exception e) {
    System.err.println("Error loading recent orders: " + e.getMessage());
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - <%= sellerInfo.get("shopName") %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
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
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            padding: 20px;
            text-align: center;
            color: #333;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .header .subtitle {
            color: #666;
            font-size: 14px;
        }

        .header .user-info {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(255, 255, 255, 0.9);
            padding: 10px 20px;
            border-radius: 20px;
            font-weight: 600;
            color: #333;
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }

        .container {
            display: flex;
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Sidebar */
        .sidebar {
            width: 250px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 20px;
            margin-right: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            height: fit-content;
        }

        .sidebar h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 18px;
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }

        .sidebar a {
            display: block;
            padding: 12px 15px;
            color: #333;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 8px;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .sidebar a:hover, .sidebar a.active {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transform: translateX(5px);
        }

        .sidebar a i {
            margin-right: 10px;
            width: 20px;
        }

        /* Main Content */
        .main {
            flex: 1;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }

        /* Stats Cards */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card i {
            font-size: 36px;
            margin-bottom: 15px;
            opacity: 0.9;
        }

        .stat-card h3 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 700;
        }

        .stat-card p {
            font-size: 14px;
            opacity: 0.9;
        }

        /* Shop Info Card */
        .shop-info {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            border-left: 5px solid #667eea;
        }

        .shop-info h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
        }

        .shop-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }

        .shop-detail {
            display: flex;
            align-items: center;
            padding: 10px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .shop-detail i {
            color: #667eea;
            margin-right: 15px;
            font-size: 18px;
            width: 20px;
        }

        .shop-detail .label {
            font-size: 12px;
            color: #666;
            margin-bottom: 2px;
        }

        .shop-detail .value {
            font-size: 14px;
            color: #333;
            font-weight: 600;
        }

        /* Recent Orders */
        .recent-orders {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .recent-orders h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
        }

        .order-table {
            width: 100%;
            border-collapse: collapse;
        }

        .order-table th {
            background: #f8f9fa;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #667eea;
        }

        .order-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }

        .order-table tr:hover {
            background: #f8f9fa;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
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

        .status-processing {
            background: #cce5ff;
            color: #004085;
        }

        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
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

        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }

        .action-btn {
            background: white;
            border: 2px solid #667eea;
            color: #667eea;
            padding: 20px;
            border-radius: 12px;
            text-decoration: none;
            text-align: center;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .action-btn:hover {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }

        .action-btn i {
            font-size: 24px;
            margin-bottom: 10px;
            display: block;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                margin-right: 0;
                margin-bottom: 20px;
            }
            
            .stats-container {
                grid-template-columns: 1fr;
            }
            
            .shop-details {
                grid-template-columns: 1fr;
            }
            
            .quick-actions {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="user-info">
            <a href="Profile.jsp" style="text-decoration: none; color: inherit;">
                👤 <%= username %> (Seller)
            </a>
        </div>
        <h1>🏪 Seller Dashboard</h1>
        <div class="subtitle"><%= sellerInfo.get("shopName") %></div>
    </div>

    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <h3>📊 Dashboard</h3>
            <a href="SellerDashboard.jsp" class="active">
                <i class="fas fa-tachometer-alt"></i> Overview
            </a>
            
            <a href="AddProduct.jsp">
                <i class="fas fa-plus"></i> Add Product
            </a>
            <a href="Updateproduct.jsp">
                <i class="fas fa-box"></i> Update product
            </a>
            <a href="Deleteproducts.jsp">
                <i class="fas fa-plus"></i> delete product
            </a>
           
            <a href="PaymentHistory.jsp">
                <i class="fas fa-credit-card"></i> Payment History
            </a>
            
            <a href="LogoutServlet">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>

        <!-- Main Content -->
        <div class="main">
            <!-- Quick Actions -->
            <div class="quick-actions">
                <a href="AddProduct.jsp" class="action-btn">
                    <i class="fas fa-plus-circle"></i>
                    Add New Product
                </a>
           
                <a href="PaymentHistory.jsp" class="action-btn">
                    <i class="fas fa-shopping-cart"></i>
                    View Payment
                </a>
                <a href="Profile.jsp" class="action-btn">
                    <i class="fas fa-edit"></i>
                    Edit Profile
                </a>
            </div>

            <!-- Stats Cards -->
            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-box"></i>
                    <h3><%= stats.getOrDefault("productCount", 0) %></h3>
                    <p>Total Products</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-shopping-cart"></i>
                    <h3><%= stats.getOrDefault("orderCount", 0) %></h3>
                    <p>Total Orders</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-rupee-sign"></i>
                    <h3>₹<%= String.format("%.2f", (Double) stats.getOrDefault("totalRevenue", 0.0)) %></h3>
                    <p>Total Revenue</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle"></i>
                    <h3><%= "approved".equals(sellerInfo.get("status")) ? "✅" : "⏳" %></h3>
                    <p>Account Status</p>
                </div>
            </div>

            <!-- Shop Information -->
            <div class="shop-info">
                <h2>🏪 Shop Information</h2>
                <div class="shop-details">
                    <div class="shop-detail">
                        <i class="fas fa-store"></i>
                        <div>
                            <div class="label">Shop Name</div>
                            <div class="value"><%= sellerInfo.get("shopName") %></div>
                        </div>
                    </div>
                    <div class="shop-detail">
                        <i class="fas fa-briefcase"></i>
                        <div>
                            <div class="label">Business Type</div>
                            <div class="value"><%= sellerInfo.get("businessType") %></div>
                        </div>
                    </div>
                    <div class="shop-detail">
                        <i class="fas fa-envelope"></i>
                        <div>
                            <div class="label">Email</div>
                            <div class="value"><%= sellerInfo.get("email") %></div>
                        </div>
                    </div>
                    <div class="shop-detail">
                        <i class="fas fa-phone"></i>
                        <div>
                            <div class="label">Phone</div>
                            <div class="value"><%= sellerInfo.get("phone") %></div>
                        </div>
                    </div>
                    <div class="shop-detail">
                        <i class="fas fa-map-marker-alt"></i>
                        <div>
                            <div class="label">Location</div>
                            <div class="value"><%= sellerInfo.get("city") %>, <%= sellerInfo.get("state") %></div>
                        </div>
                    </div>
                    <div class="shop-detail">
                        <i class="fas fa-calendar"></i>
                        <div>
                            <div class="label">Member Since</div>
                            <div class="value"><%= sellerInfo.get("registrationDate") %></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Orders -->
            <div class="recent-orders">
                <h2>📦 Recent Orders</h2>
                <% if (recentOrders.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-shopping-cart"></i>
                        <h3>No Orders Yet</h3>
                        <p>When customers place orders, they will appear here.</p>
                    </div>
                <% } else { %>
                    <table class="order-table">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> order : recentOrders) { %>
                                <tr>
                                    <td><%= order.get("orderId") %></td>
                                    <td><%= order.get("customerName") %></td>
                                    <td>₹<%= String.format("%.2f", (Double) order.get("totalAmount")) %></td>
                                    <td>
                                        <span class="status-badge status-<%= order.get("status") %>">
                                            <%= order.get("status") %>
                                        </span>
                                    </td>
                                    <td><%= order.get("orderDate") %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Auto-refresh dashboard every 30 seconds
        setInterval(function() {
            // Uncomment below to enable auto-refresh
            // window.location.reload();
        }, 30000);

        // Show notification for account status
        window.addEventListener('load', function() {
            const status = '<%= sellerInfo.get("status") %>';
            if (status === 'pending') {
                showNotification('Your seller account is pending approval. Some features may be limited.', 'warning');
            } else if (status === 'rejected') {
                showNotification('Your seller account has been rejected. Please contact support.', 'error');
            }
        });

        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 600; z-index: 10000; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else if (type === 'error') {
                notification.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            } else if (type === 'warning') {
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
    </script>
</body>
</html>
