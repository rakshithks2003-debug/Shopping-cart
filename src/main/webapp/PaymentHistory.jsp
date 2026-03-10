<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession, java.sql.*, java.util.*, java.text.SimpleDateFormat, products.Dbase" %>
<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.jsp");
    return;
}

String username = (String) sessionObj.getAttribute("username");
String userRole = (String) sessionObj.getAttribute("userRole");

// Get sorting parameters
String sortBy = request.getParameter("sortBy");
String sortOrder = request.getParameter("sortOrder");

// Set defaults
if (sortBy == null) sortBy = "transaction_date";
if (sortOrder == null) sortOrder = "DESC";

// Get seller_id if user is a seller
String sellerId = null;
if ("seller".equals(userRole)) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection sellerCon = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
        String sellerQuery = "SELECT seller_id FROM users WHERE username = ?";
        PreparedStatement sellerStmt = sellerCon.prepareStatement(sellerQuery);
        sellerStmt.setString(1, username);
        ResultSet sellerRs = sellerStmt.executeQuery();
        
        if (sellerRs.next()) {
            sellerId = sellerRs.getString("seller_id");
        }
        sellerRs.close();
        sellerStmt.close();
        sellerCon.close();
    } catch (Exception e) {
        // Error fetching seller_id
    }
}

// Load payment history from payment_transactions table
List<Map<String, Object>> paymentHistory = new ArrayList<>();

try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        // Build query to get payment records
        String orderDirection = "DESC".equals(sortOrder) ? "DESC" : "ASC";
        String sql;
        PreparedStatement stmt;
        
        if (sellerId != null) {
            // Seller view: show only their sales
            sql = "SELECT * FROM payment_transactions WHERE Seller_id = ? ORDER BY " + sortBy + " " + orderDirection;
            stmt = con.prepareStatement(sql);
            stmt.setString(1, sellerId);
        } else {
            // Buyer/Admin view: show all records
            sql = "SELECT * FROM payment_transactions ORDER BY " + sortBy + " " + orderDirection;
            stmt = con.prepareStatement(sql);
        }
        
        if (sellerId != null) {
        }
        
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> payment = new HashMap<>();
            
            // Get metadata to handle flexible column structure
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            
            // Extract data dynamically - handle all possible columns
            for (int i = 1; i <= columnCount; i++) {
                String columnName = metaData.getColumnName(i);
                Object value = rs.getObject(i);
                payment.put(columnName, value);
            }
            
            paymentHistory.add(payment);
        }
        
        rs.close();
        stmt.close();
        con.close();
        
    } else {
        // Database connection failed
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
    <title><%= "seller".equals(userRole) ? "My Sales History" : "Payment History" %> - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #667eea;
            --primary-dark: #5a6fd8;
            --secondary: #764ba2;
            --accent: #8b5cf6;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #0f172a;
            --light: #f1f5f9;
            --white: #ffffff;
            --gray: #64748b;
            --border: #e2e8f0;
            --bg-light: #f8fafc;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            color: var(--dark);
            line-height: 1.6;
            margin: 0;
            padding: 20px;
        }

        /* Header */
        .header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 24px 0;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 24px;
        }

        .header-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-title i {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 1.8rem;
        }

        .header-actions {
            display: flex;
            gap: 12px;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 500;
            font-size: 0.875rem;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: var(--primary);
            color: var(--white);
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        /* Container */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 32px 24px;
        }

        /* Stats Section */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid var(--border);
            text-align: center;
            transition: all 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            font-size: 1.25rem;
        }

        .stat-icon.green {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: var(--white);
        }

        .stat-icon.blue {
            background: linear-gradient(135deg, #3b82f6, #60a5fa);
            color: var(--white);
        }

        .stat-icon.purple {
            background: linear-gradient(135deg, #8b5cf6, #a78bfa);
            color: var(--white);
        }

        .stat-icon.orange {
            background: linear-gradient(135deg, #f59e0b, #fbbf24);
            color: var(--white);
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 0.875rem;
            color: var(--gray);
            font-weight: 500;
        }

        /* Main Content */
        .main-content {
            background: white;
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid var(--border);
            overflow: hidden;
        }

        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .content-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .content-title i {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .filter-controls {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .select {
            padding: 10px 16px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 0.875rem;
            background: white;
            color: var(--dark);
            cursor: pointer;
            transition: all 0.2s;
        }

        .select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .filter-btn {
            padding: 10px 16px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 0.875rem;
            background: white;
            color: var(--dark);
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .filter-btn:hover {
            background: var(--bg-light);
            border-color: var(--primary);
        }

        .filter-btn.active {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border-color: var(--primary);
        }

        /* Search Box Styles */
        .search-container {
            margin-bottom: 24px;
            margin-top: 60px;
        }

        .search-box {
            display: flex;
            gap: 10px;
            max-width: 600px;
            margin: 0 auto;
        }

        .search-input {
            flex: 1;
            padding: 12px 20px;
            border: 2px solid var(--border);
            border-radius: 10px;
            font-family: 'Inter', sans-serif;
            font-size: 0.95rem;
            background: white;
            color: var(--dark);
            transition: all 0.3s;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .search-input::placeholder {
            color: var(--gray);
        }

        .search-btn {
            padding: 12px 24px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }

        .search-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        .clear-search-btn {
            padding: 12px 20px;
            background: white;
            color: var(--primary);
            border: 2px solid var(--primary);
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: none;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }

        .clear-search-btn.show {
            display: flex;
        }

        .clear-search-btn:hover {
            background: var(--primary);
            color: white;
        }

        .search-info {
            text-align: center;
            margin-top: 12px;
            color: var(--gray);
            font-size: 0.9rem;
            display: none;
        }

        .search-info.show {
            display: block;
        }

        .search-info strong {
            color: var(--primary);
            font-weight: 600;
        }

        /* Table */
        .table-wrapper {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid var(--border);
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        .data-table th {
            background: var(--bg-light);
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: var(--dark);
            border-bottom: 2px solid var(--border);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 0.75rem;
        }

        .data-table tbody tr {
            border-bottom: 1px solid var(--border);
            transition: all 0.2s;
        }

        .data-table tbody tr:hover {
            background: var(--bg-light);
        }

        .data-table td {
            padding: 16px;
            font-weight: 400;
        }

        /* Table Cell Styles */
        .tx-id {
            font-weight: 600;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-family: monospace;
        }

        .amount {
            font-weight: 600;
            font-size: 1rem;
            color: var(--success);
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-completed {
            background: var(--success);
            color: var(--white);
        }

        .status-pending {
            background: var(--warning);
            color: var(--white);
        }

        .status-failed {
            background: var(--danger);
            color: var(--white);
        }

        .payment-method {
            display: inline-block;
            padding: 4px 8px;
            background: var(--light);
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 500;
            color: var(--dark);
        }

        .user-cell {
            font-weight: 500;
            color: var(--dark);
        }

        .date-cell {
            color: var(--gray);
            font-size: 0.85rem;
        }

        .card-cell {
            font-family: monospace;
            color: var(--gray);
            font-size: 0.85rem;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 80px 32px;
        }

        .empty-icon {
            width: 120px;
            height: 120px;
            margin: 0 auto 24px;
            background: var(--light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            color: var(--gray);
        }

        .empty-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 12px;
        }

        .empty-description {
            font-size: 1rem;
            color: var(--gray);
            margin-bottom: 32px;
            max-width: 400px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.6;
        }

        .btn-primary {
            display: inline-block;
            padding: 12px 24px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            font-size: 0.875rem;
            transition: all 0.2s;
            box-shadow: 0 4px 12px rgba(16,185,129,0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        /* Back button left alignment */
        .header-actions .btn-primary:first-child {
            position: fixed !important;
            top: 60px !important;
            left: 20px !important;
            background: linear-gradient(135deg, #667eea, #764ba2) !important;
            color: white !important;
            padding: 12px 20px !important;
            text-decoration: none !important;
            border-radius: 25px !important;
            font-weight: 600 !important;
            font-size: 14px !important;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3) !important;
            transition: all 0.3s ease !important;
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            border: 2px solid rgba(255, 255, 255, 0.3) !important;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
            cursor: pointer !important;
            white-space: nowrap !important;
            text-transform: none !important;
            letter-spacing: 0.5px !important;
            z-index: 1000 !important;
            position: relative !important;
            overflow: hidden !important;
        }

        /* Additional specific selector */
        body .header-actions .btn-primary:first-child {
            position: fixed !important;
            top: 60px !important;
            left: 20px !important;
            z-index: 1000 !important;
        }

        .header-actions .btn-primary:first-child::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }

        .header-actions .btn-primary:first-child:hover::before {
            left: 100%;
        }

        .header-actions .btn-primary:first-child:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            border-color: rgba(255, 255, 255, 0.5);
            text-decoration: none;
            color: white;
        }

        .header-actions .btn-primary:first-child i {
            font-size: 1.1rem;
            transition: transform 0.3s ease;
        }

        .header-actions .btn-primary:first-child:hover i {
            transform: translateX(-3px);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 16px;
                align-items: stretch;
            }

            .header-title {
                font-size: 1.5rem;
            }

            .stats-grid {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .content-header {
                flex-direction: column;
                align-items: stretch;
                gap: 12px;
            }

            .filter-controls {
                flex-direction: column;
                width: 100%;
            }

            .search-box {
                flex-direction: column;
            }

            .search-btn, .clear-search-btn {
                width: 100%;
                justify-content: center;
            }

            .select {
                width: 100%;
            }

            .data-table {
                font-size: 0.8rem;
            }

            .data-table th,
            .data-table td {
                padding: 12px 8px;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 20px 16px;
            }

            .stat-card {
                padding: 20px;
            }

            .data-table {
                font-size: 0.75rem;
            }

            .data-table th,
            .data-table td {
                padding: 8px 6px;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <div class="header-content">
            <div class="header-left">
                <h1>
                    <i class="fas fa-<%= "seller".equals(userRole) ? "shopping-cart" : "credit-card" %>"></i>
                    <%= "seller".equals(userRole) ? "My Sales History" : "Payment History" %>
                </h1>
                <p><%= "seller".equals(userRole) ? "View and manage all your sales transactions" : "View and manage all payment transactions" %></p>
            </div>
            <div class="header-actions">
                <a href="javascript:history.back()" class="btn btn-primary">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <a href="Home.jsp" class="btn btn-primary">
                    <i class="fas fa-home"></i> Home
                </a>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <% if (paymentHistory.isEmpty()) { %>
            <!-- Empty State -->
            <div class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-receipt"></i>
                </div>
                <h2 class="empty-title"><%= "seller".equals(userRole) ? "No Sales Found" : "No Payment History Found" %></h2>
                <p class="empty-description">
                    <%= "seller".equals(userRole) ? 
                        "No sales transactions found. Your products haven't been sold yet." : 
                        "No payment transactions found in the system. The payment table might be empty or doesn't exist yet." %>
                </p>
                <a href="Showproducts.jsp" class="btn-primary">
                    <i class="fas fa-shopping-cart"></i> Start Shopping
                </a>
            </div>
        <% } else { %>
            <!-- Stats Section -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon green">
                            <i class="fas fa-receipt"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= paymentHistory.size() %></div>
                    <div class="stat-label">Total Transactions</div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon blue">
                            <i class="fas fa-rupee-sign"></i>
                        </div>
                    </div>
                    <div class="stat-value">
                        <% 
                            double totalAmount = 0;
                            for (Map<String, Object> payment : paymentHistory) {
                                Object amountObj = payment.get("amount");
                                if (amountObj != null) {
                                    totalAmount += ((Number) amountObj).doubleValue();
                                }
                            }
                        %>
                        ₹<%= String.format("%.2f", totalAmount) %>
                    </div>
                    <div class="stat-label">Total Amount</div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon purple">
                            <i class="fas fa-check-circle"></i>
                        </div>
                    </div>
                    <div class="stat-value">
                        <% 
                            int completedCount = 0;
                            for (Map<String, Object> payment : paymentHistory) {
                                Object statusObj = payment.get("status");
                                if (statusObj != null && "completed".equals(statusObj.toString().toLowerCase())) {
                                    completedCount++;
                                }
                            }
                        %>
                        <%= completedCount %>
                    </div>
                    <div class="stat-label">Completed</div>
                </div>
            </div>

            <!-- Search Container -->
            <div class="search-container">
                <div class="search-box">
                    <input type="text" 
                           class="search-input" 
                           id="searchInput" 
                           placeholder="Search by Order ID, Amount, Status, User, or Method..." 
                           onkeypress="handleSearchKeyPress(event)">
                    <button class="search-btn" onclick="performSearch()">
                        <i class="fas fa-search"></i> Search
                    </button>
                    <button class="clear-search-btn" id="clearSearchBtn" onclick="clearSearch()">
                        <i class="fas fa-times"></i> Clear
                    </button>
                </div>
                <div class="search-info" id="searchInfo"></div>
            </div>

            <!-- Content Header -->
            <div class="content-header">
                <h2 class="content-title">
                    <i class="fas fa-list"></i>
                    Transaction Records
                </h2>
                <div class="filter-controls">
                    <select class="select" onchange="window.location.href='PaymentHistory.jsp?sortBy=' + this.value + '&sortOrder=<%= sortOrder %>'">
                        <option value="transaction_date" <%= "transaction_date".equals(sortBy) ? "selected" : "" %>>Sort by Date</option>
                        <option value="id" <%= "id".equals(sortBy) ? "selected" : "" %>>Sort by ID</option>
                        <option value="order_id" <%= "order_id".equals(sortBy) ? "selected" : "" %>>Sort by Order ID</option>
                        <option value="amount" <%= "amount".equals(sortBy) ? "selected" : "" %>>Sort by Amount</option>
                    </select>
                    <a href="PaymentHistory.jsp?sortBy=<%= sortBy %>&sortOrder=ASC" class="filter-btn <%= "ASC".equals(sortOrder) ? "active" : "" %>">
                        <i class="fas fa-sort-amount-up"></i> Asc
                    </a>
                    <a href="PaymentHistory.jsp?sortBy=<%= sortBy %>&sortOrder=DESC" class="filter-btn <%= "DESC".equals(sortOrder) ? "active" : "" %>">
                        <i class="fas fa-sort-amount-down"></i> Desc
                    </a>
                </div>
            </div>

            <!-- Table -->
            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Order ID</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Method</th>
                            <th>User</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                            for (Map<String, Object> payment : paymentHistory) { 
                                // Try multiple possible column names for ID
                                Object idObj = payment.get("id");
                                if (idObj == null) idObj = payment.get("transaction_id");
                                if (idObj == null) idObj = payment.get("transactionid");
                                if (idObj == null) idObj = payment.get("payment_id");
                                
                                // Try multiple possible column names for Order ID
                                Object orderIdObj = payment.get("order_id");
                                if (orderIdObj == null) orderIdObj = payment.get("orderid");
                                if (orderIdObj == null) orderIdObj = payment.get("order_id");
                                
                                // Try multiple possible column names for Amount
                                Object amountObj = payment.get("amount");
                                if (amountObj == null) amountObj = payment.get("total");
                                if (amountObj == null) amountObj = payment.get("price");
                                
                                // Try multiple possible column names for Status
                                Object statusObj = payment.get("status");
                                if (statusObj == null) statusObj = payment.get("payment_status");
                                if (statusObj == null) statusObj = payment.get("transaction_status");
                                
                                // Try multiple possible column names for Date
                                Object dateObj = payment.get("transaction_date");
                                if (dateObj == null) dateObj = payment.get("date");
                                if (dateObj == null) dateObj = payment.get("created_at");
                                if (dateObj == null) dateObj = payment.get("payment_date");
                                
                                // Try multiple possible column names for Method
                                Object methodObj = payment.get("payment_method");
                                if (methodObj == null) methodObj = payment.get("method");
                                if (methodObj == null) methodObj = payment.get("payment_type");
                                
                                // Try multiple possible column names for User
                                Object userObj = payment.get("user_id");
                                if (userObj == null) userObj = payment.get("username");
                                if (userObj == null) userObj = payment.get("user");
                                if (userObj == null) userObj = payment.get("user_name");
                                if (userObj == null) userObj = payment.get("customer");
                                if (userObj == null) userObj = payment.get("email");
                                if (userObj == null) userObj = payment.get("customer_name");
                                if (userObj == null) userObj = payment.get("customer_email");
                                if (userObj == null) userObj = payment.get("buyer");
                                if (userObj == null) userObj = payment.get("payer");
                                if (userObj == null) userObj = payment.get("account_holder");
                                if (userObj == null) userObj = payment.get("name");
                                if (userObj == null) userObj = payment.get("full_name");
                                
                                String id = idObj != null ? idObj.toString() : "N/A";
                                String orderId = orderIdObj != null ? orderIdObj.toString() : "N/A";
                                String amount = "N/A";
                                if (amountObj != null) {
                                    try {
                                        amount = "₹" + String.format("%.2f", ((Number) amountObj).doubleValue());
                                    } catch (Exception e) {
                                        amount = amountObj.toString();
                                    }
                                }
                                String status = statusObj != null ? statusObj.toString() : "unknown";
                                String date = "N/A";
                                if (dateObj != null) {
                                    try {
                                        if (dateObj instanceof java.util.Date) {
                                            date = dateFormat.format((java.util.Date) dateObj);
                                        } else if (dateObj instanceof java.sql.Timestamp) {
                                            date = dateFormat.format((java.sql.Timestamp) dateObj);
                                        } else {
                                            date = dateObj.toString();
                                        }
                                    } catch (Exception e) {
                                        date = dateObj.toString();
                                    }
                                }
                                String method = methodObj != null ? methodObj.toString() : "N/A";
                                String user = userObj != null ? userObj.toString() : "N/A";
                                
                                String statusClass = "status-badge";
                                if ("completed".equals(status.toLowerCase())) {
                                    statusClass += " status-completed";
                                } else if ("pending".equals(status.toLowerCase())) {
                                    statusClass += " status-pending";
                                } else {
                                    statusClass += " status-failed";
                                }
                            %>
                            <tr>
                                <td><span class="tx-id"><%= id %></span></td>
                                <td><span class="user-cell"><%= orderId %></span></td>
                                <td><span class="amount"><%= amount %></span></td>
                                <td><span class="badge <%= statusClass %>"><%= status %></span></td>
                                <td><span class="date-cell"><%= date %></span></td>
                                <td><span class="payment-method"><%= method %></span></td>
                                <td><span class="user-cell"><%= user %></span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </div>

    <script>
        // Search functionality
        let allRows = [];
        
        // Store all table rows on page load
        document.addEventListener('DOMContentLoaded', function() {
            const tableBody = document.querySelector('.data-table tbody');
            if (tableBody) {
                allRows = Array.from(tableBody.querySelectorAll('tr'));
            }
        });
        
        // Perform search
        function performSearch() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
            
            if (searchTerm === '') {
                showAllRows();
                return;
            }
            
            let visibleCount = 0;
            
            allRows.forEach(row => {
                const cells = row.querySelectorAll('td');
                let rowText = '';
                
                // Concatenate all cell text
                cells.forEach(cell => {
                    rowText += cell.textContent.toLowerCase() + ' ';
                });
                
                // Check if search term matches
                if (rowText.includes(searchTerm)) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });
            
            // Show clear button and search info
            document.getElementById('clearSearchBtn').classList.add('show');
            showSearchInfo(visibleCount, allRows.length, searchTerm);
        }
        
        // Handle Enter key press
        function handleSearchKeyPress(event) {
            if (event.key === 'Enter') {
                performSearch();
            }
        }
        
        // Clear search
        function clearSearch() {
            document.getElementById('searchInput').value = '';
            showAllRows();
            document.getElementById('clearSearchBtn').classList.remove('show');
            hideSearchInfo();
        }
        
        // Show all rows
        function showAllRows() {
            allRows.forEach(row => {
                row.style.display = '';
            });
        }
        
        // Show search info
        function showSearchInfo(visibleCount, totalCount, searchTerm) {
            const searchInfo = document.getElementById('searchInfo');
            if (visibleCount === 0) {
                searchInfo.innerHTML = '<i class="fas fa-exclamation-circle"></i> No transactions found matching "<strong>' + searchTerm + '</strong>"';
                searchInfo.style.color = 'var(--danger)';
            } else {
                searchInfo.innerHTML = 'Showing <strong>' + visibleCount + '</strong> of <strong>' + totalCount + '</strong> transactions';
                searchInfo.style.color = 'var(--gray)';
            }
            searchInfo.classList.add('show');
        }
        
        // Hide search info
        function hideSearchInfo() {
            const searchInfo = document.getElementById('searchInfo');
            searchInfo.classList.remove('show');
        }
        
        // Real-time search (optional - uncomment to enable)
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    // Uncomment the line below for real-time search as you type
                    // performSearch();
                });
            }
        });
    </script>
</body>
</html>

