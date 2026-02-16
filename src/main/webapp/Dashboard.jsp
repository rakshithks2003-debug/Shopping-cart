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

// Load payment data for graph
List<Map<String, Object>> paymentHistory = new ArrayList<>();
Map<String, Object> paymentStats = new HashMap<>();

try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        // Get payment statistics
        String statsSql = "SELECT " +
                       "COUNT(*) as total_transactions, " +
                       "SUM(amount) as total_amount, " +
                       "AVG(amount) as avg_amount, " +
                       "MIN(amount) as min_amount, " +
                       "MAX(amount) as max_amount, " +
                       "COUNT(DISTINCT user_id) as unique_customers " +
                       "FROM payment_transactions " +
                       "WHERE status = 'completed'";
        
        PreparedStatement statsStmt = con.prepareStatement(statsSql);
        ResultSet statsRs = statsStmt.executeQuery();
        
        if (statsRs.next()) {
            paymentStats.put("totalTransactions", statsRs.getInt("total_transactions"));
            paymentStats.put("totalAmount", statsRs.getDouble("total_amount"));
            paymentStats.put("avgAmount", statsRs.getDouble("avg_amount"));
            paymentStats.put("minAmount", statsRs.getDouble("min_amount"));
            paymentStats.put("maxAmount", statsRs.getDouble("max_amount"));
            paymentStats.put("uniqueCustomers", statsRs.getInt("unique_customers"));
        }
        statsRs.close();
        statsStmt.close();
        
        // Get monthly payment data for graph
        String monthlySql = "SELECT " +
                          "DATE_FORMAT(transaction_date, '%Y-%m') as month, " +
                          "SUM(amount) as monthly_amount, " +
                          "COUNT(*) as monthly_count " +
                          "FROM payment_transactions " +
                          "WHERE status = 'completed' " +
                          "AND transaction_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                          "GROUP BY DATE_FORMAT(transaction_date, '%Y-%m') " +
                          "ORDER BY month ASC";
        
        PreparedStatement monthlyStmt = con.prepareStatement(monthlySql);
        ResultSet monthlyRs = monthlyStmt.executeQuery();
        
        while (monthlyRs.next()) {
            Map<String, Object> monthData = new HashMap<>();
            monthData.put("month", monthlyRs.getString("month"));
            monthData.put("amount", monthlyRs.getDouble("monthly_amount"));
            monthData.put("count", monthlyRs.getInt("monthly_count"));
            paymentHistory.add(monthData);
        }
        monthlyRs.close();
        monthlyStmt.close();
        con.close();
    }
} catch (Exception e) {
    System.err.println("Error loading payment data: " + e.getMessage());
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mini Shopping cart Dashboard</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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

/* Payment Dashboard Styles */
.payment-dashboard {
    background-color: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    margin-bottom: 30px;
}

.payment-dashboard h2 {
    color: #2874f0;
    margin-bottom: 25px;
    font-size: 28px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 10px;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.stat-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 25px;
    border-radius: 15px;
    text-align: center;
    box-shadow: 0 8px 30px rgba(102, 126, 234, 0.3);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 40px rgba(102, 126, 234, 0.4);
}

.stat-icon {
    font-size: 36px;
    margin-bottom: 15px;
}

.stat-info {
    display: flex;
    flex-direction: column;
    gap: 5px;
}

.stat-number {
    font-size: 32px;
    font-weight: 700;
    margin-bottom: 5px;
}

.stat-label {
    font-size: 14px;
    opacity: 0.9;
    font-weight: 500;
}

.chart-container {
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.chart-container h3 {
    color: #2874f0;
    margin-bottom: 20px;
    font-size: 20px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 10px;
}

.chart-wrapper {
    position: relative;
    height: 300px;
    background: #f8f9fa;
    border-radius: 10px;
    padding: 20px;
    border: 1px solid #e9ecef;
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
        <!-- Payment Statistics Dashboard -->
        <div class="payment-dashboard">
            <h2>💳 Payment Analytics Dashboard</h2>
            
            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">📊</div>
                    <div class="stat-info">
                        <div class="stat-number"><%= paymentStats.get("totalTransactions") != null ? paymentStats.get("totalTransactions") : "0" %></div>
                        <div class="stat-label">Total Transactions</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">💰</div>
                    <div class="stat-info">
                        <div class="stat-number">₹<%= String.format("%.2f", paymentStats.get("totalAmount") != null ? (Double)paymentStats.get("totalAmount") : 0.0) %></div>
                        <div class="stat-label">Total Revenue</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">📈</div>
                    <div class="stat-info">
                        <div class="stat-number">₹<%= String.format("%.2f", paymentStats.get("avgAmount") != null ? (Double)paymentStats.get("avgAmount") : 0.0) %></div>
                        <div class="stat-label">Average Transaction</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-info">
                        <div class="stat-number"><%= paymentStats.get("uniqueCustomers") != null ? paymentStats.get("uniqueCustomers") : "0" %></div>
                        <div class="stat-label">Unique Customers</div>
                    </div>
                </div>
            </div>
            
            <!-- Chart Section -->
            <div class="chart-container">
                <h3>📈 Monthly Payment Trends (Last 6 Months)</h3>
                <div class="chart-wrapper">
                    <canvas id="paymentChart" width="400" height="200"></canvas>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Payment Chart Data
        const paymentData = [
            <% for (Map<String, Object> month : paymentHistory) { %>
                {
                    month: '<%= month.get("month") %>',
                    amount: <%= month.get("amount") %>,
                    count: <%= month.get("count") %>
                },
            <% } %>
        ];

        // Initialize Chart
        const ctx = document.getElementById('paymentChart').getContext('2d');
        
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: paymentData.map(item => {
                    const date = new Date(item.month + '-01');
                    return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' });
                }),
                datasets: [{
                    label: 'Monthly Revenue (₹)',
                    data: paymentData.map(item => item.amount),
                    borderColor: '#4f46e5',
                    backgroundColor: 'rgba(79, 70, 229, 0.1)',
                    borderWidth: 4,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 6,
                    pointHoverRadius: 8,
                    pointBackgroundColor: '#4f46e5',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointHoverBackgroundColor: '#4338ca',
                    pointHoverBorderColor: '#fff',
                    pointHoverBorderWidth: 3
                }, {
                    label: 'Transaction Count',
                    data: paymentData.map(item => item.count),
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 4,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 6,
                    pointHoverRadius: 8,
                    pointBackgroundColor: '#10b981',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointHoverBackgroundColor: '#059669',
                    pointHoverBorderColor: '#fff',
                    pointHoverBorderWidth: 3,
                    yAxisID: 'y1'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            usePointStyle: true,
                            padding: 20,
                            font: {
                                size: 14,
                                weight: '600',
                                family: 'Arial, sans-serif'
                            },
                            generateLabels: function(chart) {
                                return chart.data.datasets.map(function(dataset, i) {
                                    return {
                                        text: dataset.label,
                                        fillStyle: dataset.backgroundColor,
                                        strokeStyle: dataset.borderColor,
                                        lineWidth: dataset.borderWidth,
                                        pointStyle: 'circle',
                                        hidden: !chart.isDatasetVisible(i),
                                        index: i
                                    };
                                });
                            }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(255, 255, 255, 0.95)',
                        titleColor: '#1f2937',
                        bodyColor: '#4b5563',
                        borderColor: '#e5e7eb',
                        borderWidth: 1,
                        padding: 12,
                        displayColors: true,
                        boxPadding: 8,
                        usePointStyle: true,
                        callbacks: {
                            label: function(context) {
                                let label = context.dataset.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                if (context.parsed.y !== null) {
                                    if (context.datasetIndex === 0) {
                                        label += '₹' + context.parsed.y.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                    } else {
                                        label += context.parsed.y + ' transactions';
                                    }
                                }
                                return label;
                            },
                            title: function(context) {
                                return 'Month: ' + context[0].label;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        display: true,
                        title: {
                            display: true,
                            text: 'Month',
                            color: '#6b7280',
                            font: {
                                size: 14,
                                weight: '600',
                                family: 'Arial, sans-serif'
                            }
                        },
                        grid: {
                            display: true,
                            color: 'rgba(229, 231, 235, 0.5)',
                            drawBorder: false
                        },
                        ticks: {
                            color: '#6b7280',
                            font: {
                                size: 12,
                                family: 'Arial, sans-serif'
                            }
                        }
                    },
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        title: {
                            display: true,
                            text: 'Revenue (₹)',
                            color: '#6b7280',
                            font: {
                                size: 14,
                                weight: '600',
                                family: 'Arial, sans-serif'
                            }
                        },
                        grid: {
                            display: true,
                            color: 'rgba(229, 231, 235, 0.5)',
                            drawBorder: false
                        },
                        ticks: {
                            color: '#6b7280',
                            font: {
                                size: 12,
                                family: 'Arial, sans-serif'
                            },
                            callback: function(value) {
                                return '₹' + value.toLocaleString('en-IN');
                            }
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        title: {
                            display: true,
                            text: 'Transactions',
                            color: '#6b7280',
                            font: {
                                size: 14,
                                weight: '600',
                                family: 'Arial, sans-serif'
                            }
                        },
                        grid: {
                            drawOnChartArea: false
                        },
                        ticks: {
                            color: '#6b7280',
                            font: {
                                size: 12,
                                family: 'Arial, sans-serif'
                            },
                            callback: function(value) {
                                return value.toLocaleString();
                            }
                        }
                    }
                }
            }
        });

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