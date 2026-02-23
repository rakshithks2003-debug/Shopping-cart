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

// Load payment history for graph
List<Map<String, Object>> paymentHistory = new ArrayList<>();
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        // Get seller's payment transactions
        String paymentSql = "SELECT * FROM payment_transactions WHERE Seller_id = ? ORDER BY transaction_date DESC LIMIT 30";
        PreparedStatement paymentStmt = con.prepareStatement(paymentSql);
        paymentStmt.setString(1, sellerId);
        ResultSet paymentRs = paymentStmt.executeQuery();
        
        while (paymentRs.next()) {
            Map<String, Object> payment = new HashMap<>();
            payment.put("transaction_id", paymentRs.getString("transaction_id"));
            payment.put("amount", paymentRs.getDouble("amount"));
            payment.put("transaction_date", paymentRs.getString("transaction_date"));
            payment.put("payment_method", paymentRs.getString("payment_method"));
            payment.put("status", paymentRs.getString("status"));
            paymentHistory.add(payment);
        }
        
        paymentRs.close();
        paymentStmt.close();
        con.close();
    }
} catch (Exception e) {
    System.err.println("Error loading payment history: " + e.getMessage());
}

// Prepare payment data for JavaScript
StringBuilder paymentJson = new StringBuilder();
paymentJson.append("[");
for (int i = 0; i < paymentHistory.size(); i++) {
    Map<String, Object> payment = paymentHistory.get(i);
    String date = (String) payment.get("transaction_date");
    Double amount = (Double) payment.get("amount");
    String method = (String) payment.get("payment_method");
    String status = (String) payment.get("status");
    
    // Escape strings for JSON
    date = date != null ? date.replace("\"", "\\\"") : "";
    method = method != null ? method.replace("\"", "\\\"") : "";
    status = status != null ? status.replace("\"", "\\\"") : "";
    
    paymentJson.append("{")
                .append("\"date\":\"").append(date).append("\",")
                .append("\"amount\":").append(amount != null ? amount : 0).append(",")
                .append("\"method\":\"").append(method).append("\",")
                .append("\"status\":\"").append(status).append("\"")
                .append("}");
    if (i < paymentHistory.size() - 1) {
        paymentJson.append(",");
    }
}
paymentJson.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - <%= sellerInfo.get("shopName") %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

        /* Graph Section */
        .graph-section {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .graph-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .graph-title {
            font-size: 20px;
            font-weight: 600;
            color: #333;
        }

        .graph-period {
            display: flex;
            gap: 10px;
        }

        .period-btn {
            padding: 8px 16px;
            border: 1px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
        }

        .period-btn:hover, .period-btn.active {
            background: #667eea;
            color: white;
        }

        .chart-container {
            position: relative;
            height: 300px;
            margin-bottom: 20px;
        }

        .graph-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }

        .graph-stat {
            text-align: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .graph-stat-value {
            font-size: 18px;
            font-weight: 600;
            color: #667eea;
        }

        .graph-stat-label {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }

        /* Footer */
        .footer {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 40px 0 20px;
            margin-top: 40px;
            border-radius: 15px 15px 0 0;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 30px;
            padding: 0 30px;
        }

        .footer-section h4 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            color: white;
            border-bottom: 2px solid rgba(255, 255, 255, 0.3);
            padding-bottom: 8px;
        }

        .footer-link {
            display: block;
            color: rgba(255, 255, 255, 0.9);
            text-decoration: none;
            padding: 8px 0;
            transition: all 0.3s ease;
            border-radius: 5px;
            font-weight: 500;
        }

        .footer-link:hover {
            color: white;
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(5px);
            padding-left: 10px;
        }

        .footer-link i {
            margin-right: 10px;
            width: 16px;
            text-align: center;
        }

        .footer-bottom {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
            color: rgba(255, 255, 255, 0.8);
        }

        .footer-bottom p {
            margin: 5px 0;
            font-size: 14px;
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

            <!-- Revenue Graph -->
            <div class="graph-section">
                <div class="graph-header">
                    <h2 class="graph-title">
                        <i class="fas fa-chart-line"></i> Revenue Analytics
                    </h2>
                    <div class="graph-period">
                        <button class="period-btn" onclick="updateGraph('7d')">7 Days</button>
                        <button class="period-btn active" onclick="updateGraph('30d')">30 Days</button>
                        <button class="period-btn" onclick="updateGraph('90d')">90 Days</button>
                    </div>
                </div>
                
                <div class="chart-container">
                    <canvas id="revenueChart"></canvas>
                </div>
                
                <div class="graph-stats">
                    <div class="graph-stat">
                        <div class="graph-stat-value" id="totalRevenue">₹0</div>
                        <div class="graph-stat-label">Total Revenue</div>
                    </div>
                    <div class="graph-stat">
                        <div class="graph-stat-value" id="avgRevenue">₹0</div>
                        <div class="graph-stat-label">Average Revenue</div>
                    </div>
                    <div class="graph-stat">
                        <div class="graph-stat-value" id="totalTransactions">0</div>
                        <div class="graph-stat-label">Total Transactions</div>
                    </div>
                    <div class="graph-stat">
                        <div class="graph-stat-value" id="growthRate">0%</div>
                        <div class="graph-stat-label">Growth Rate</div>
                    </div>
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

                    </div>
    </div>

    <script>
        // Payment history data from server
        const paymentData = <%= paymentJson.toString() %>;

        // Chart initialization
        let revenueChart;
        let currentPeriod = '30d';

        function initChart() {
            const ctx = document.getElementById('revenueChart').getContext('2d');
            
            const chartData = prepareChartData(currentPeriod);
            
            revenueChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: chartData.labels,
                    datasets: [{
                        label: 'Revenue',
                        data: chartData.data,
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#667eea',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2,
                        pointRadius: 5,
                        pointHoverRadius: 7
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0, 0, 0, 0.8)',
                            padding: 12,
                            titleColor: '#fff',
                            bodyColor: '#fff',
                            borderColor: '#667eea',
                            borderWidth: 1,
                            displayColors: false,
                            callbacks: {
                                label: function(context) {
                                    return 'Revenue: ₹' + context.parsed.y.toLocaleString();
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)'
                            },
                            ticks: {
                                callback: function(value) {
                                    return '₹' + value.toLocaleString();
                                },
                                color: '#666'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                color: '#666'
                            }
                        }
                    }
                }
            });
            
            updateStats(chartData.data);
        }

        function prepareChartData(period) {
            const days = period === '7d' ? 7 : period === '30d' ? 30 : 90;
            const endDate = new Date();
            const startDate = new Date();
            startDate.setDate(endDate.getDate() - days);
            
            // Create date labels
            const labels = [];
            const data = [];
            
            for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
                const dateStr = d.toISOString().split('T')[0];
                labels.push(d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }));
                
                // Calculate revenue for this date
                const dayRevenue = paymentData
                    .filter(p => p.date.startsWith(dateStr) && p.status === 'completed')
                    .reduce((sum, p) => sum + p.amount, 0);
                
                data.push(dayRevenue);
            }
            
            return { labels, data };
        }

        function updateStats(data) {
            const totalRevenue = data.reduce((sum, val) => sum + val, 0);
            const avgRevenue = data.length > 0 ? totalRevenue / data.filter(val => val > 0).length : 0;
            const totalTransactions = paymentData.filter(p => p.status === 'completed').length;
            
            // Calculate growth rate (simplified - compare first half vs second half)
            const midpoint = Math.floor(data.length / 2);
            const firstHalf = data.slice(0, midpoint).reduce((sum, val) => sum + val, 0);
            const secondHalf = data.slice(midpoint).reduce((sum, val) => sum + val, 0);
            const growthRate = firstHalf > 0 ? ((secondHalf - firstHalf) / firstHalf * 100) : 0;
            
            document.getElementById('totalRevenue').textContent = '₹' + totalRevenue.toLocaleString();
            document.getElementById('avgRevenue').textContent = '₹' + Math.round(avgRevenue).toLocaleString();
            document.getElementById('totalTransactions').textContent = totalTransactions;
            document.getElementById('growthRate').textContent = (growthRate >= 0 ? '+' : '') + growthRate.toFixed(1) + '%';
        }

        function updateGraph(period) {
            currentPeriod = period;
            
            // Update button states
            document.querySelectorAll('.period-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
            
            // Update chart data
            const chartData = prepareChartData(period);
            revenueChart.data.labels = chartData.labels;
            revenueChart.data.datasets[0].data = chartData.data;
            revenueChart.update();
            
            updateStats(chartData.data);
        }

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
            
            // Initialize chart after page load
            initChart();
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

    <!-- Footer with Sitemap -->
    <footer class="footer">
        <div class="footer-content">
            <a href="Sitemap.jsp" class="footer-link">
                <i class="fas fa-sitemap"></i> Sitemap
            </a>
        </div>
        
        <div class="footer-bottom">
            <p>&copy; 2024 Mini Shopping Cart - Seller Dashboard</p>
            <p>Developed with ❤️ for seamless seller experience</p>
        </div>
    </footer>
</body>
</html>
