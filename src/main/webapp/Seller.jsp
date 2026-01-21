<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}

// Check if user has admin role
String userRole = (String) sessionObj.getAttribute("userRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect("users.html");
    return;
}

String username = (String) sessionObj.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Seller Application Management - Mini Shopping Cart</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
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
        color: #1a1a1a;
        overflow-x: hidden;
        position: relative;
    }
    
    body::before {
        content: '';
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="50" cy="50" r="1" fill="%23ffffff" opacity="0.03"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>') repeat;
        pointer-events: none;
        z-index: 1;
    }

    .container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
        position: relative;
        z-index: 2;
    }

    header {
        background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(255,255,255,0.85));
        backdrop-filter: blur(25px);
        padding: 50px 0;
        text-align: center;
        position: relative;
        box-shadow: 0 25px 50px rgba(0,0,0,0.15);
        border-radius: 30px;
        margin-bottom: 50px;
        border: 2px solid rgba(102, 126, 234, 0.2);
        overflow: hidden;
    }
    
    header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 5px;
        background: linear-gradient(90deg, #667eea, #764ba2, #f093fb, #667eea);
        background-size: 300% 100%;
        animation: gradientShift 4s ease-in-out infinite;
    }
    
    @keyframes gradientShift {
        0%, 100% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
    }

    header h1 {
        font-size: 3.5rem;
        font-weight: 900;
        background: linear-gradient(135deg, #667eea, #764ba2, #f093fb);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 20px;
        letter-spacing: -0.03em;
        text-shadow: 0 4px 8px rgba(0,0,0,0.1);
        animation: titleGlow 3s ease-in-out infinite alternate;
    }
    
    @keyframes titleGlow {
        0% { filter: brightness(1); }
        100% { filter: brightness(1.2); }
    }
    
    header .subtitle {
        font-size: 1.3rem;
        color: #666;
        font-weight: 400;
        margin-bottom: 25px;
        opacity: 0.8;
        animation: fadeInUp 1s ease-out;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 0.8;
            transform: translateY(0);
        }
    }

    .user-info {
        position: absolute;
        top: 25px;
        right: 25px;
        background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(255,255,255,0.85));
        padding: 15px 30px;
        border-radius: 35px;
        font-weight: 700;
        color: #333;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        border: 2px solid rgba(102, 126, 234, 0.3);
        backdrop-filter: blur(15px);
        display: flex;
        align-items: center;
        gap: 12px;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        font-size: 1rem;
    }
    
    .user-info:hover {
        transform: translateY(-5px) scale(1.05);
        box-shadow: 0 15px 40px rgba(0,0,0,0.25);
        border-color: rgba(102, 126, 234, 0.5);
    }

    .stats-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 30px;
        margin-bottom: 50px;
        perspective: 1000px;
    }

    .stat-card {
        background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(255,255,255,0.85));
        backdrop-filter: blur(25px);
        padding: 40px;
        border-radius: 30px;
        box-shadow: 0 25px 50px rgba(0,0,0,0.15);
        text-align: center;
        transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        border: 2px solid rgba(102, 126, 234, 0.2);
        position: relative;
        overflow: hidden;
        cursor: pointer;
        transform-style: preserve-3d;
    }
    
    .stat-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 5px;
        background: linear-gradient(90deg, #667eea, #764ba2, #f093fb);
        transform: scaleX(0);
        transition: transform 0.4s ease;
        transform-origin: left;
    }
    
    .stat-card:hover::before {
        transform: scaleX(1);
    }
    
    .stat-card:hover {
        transform: translateY(-12px) rotateX(5deg) scale(1.05);
        box-shadow: 0 40px 80px rgba(0,0,0,0.2);
        border-color: rgba(102, 126, 234, 0.4);
    }
    
    .stat-card::after {
        content: '';
        position: absolute;
        top: -100%;
        left: -100%;
        width: 300%;
        height: 300%;
        background: radial-gradient(circle, rgba(102, 126, 234, 0.15) 0%, transparent 60%);
        opacity: 0;
        transition: opacity 0.4s ease;
        pointer-events: none;
    }
    
    .stat-card:hover::after {
        opacity: 1;
    }

    .stat-icon {
        font-size: 4rem;
        margin-bottom: 25px;
        display: block;
        filter: drop-shadow(0 6px 12px rgba(0,0,0,0.15));
        transition: all 0.4s ease;
        animation: iconFloat 3s ease-in-out infinite;
    }
    
    @keyframes iconFloat {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
    }
    
    .stat-card:hover .stat-icon {
        transform: scale(1.2) rotate(10deg);
        filter: drop-shadow(0 8px 16px rgba(0,0,0,0.25));
    }

    .stat-number {
        font-size: 3.5rem;
        font-weight: 900;
        background: linear-gradient(135deg, #667eea, #764ba2, #f093fb);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 12px;
        text-shadow: 0 4px 8px rgba(0,0,0,0.1);
        animation: numberPulse 2s ease-in-out infinite;
    }
    
    @keyframes numberPulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }

    .stat-label {
        font-size: 1.1rem;
        color: #666;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .table-container {
        background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(255,255,255,0.85));
        backdrop-filter: blur(25px);
        border-radius: 30px;
        padding: 50px;
        box-shadow: 0 25px 50px rgba(0,0,0,0.15);
        margin-bottom: 50px;
        overflow: hidden;
        border: 2px solid rgba(102, 126, 234, 0.2);
        position: relative;
    }
    
    .table-container::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #667eea, #764ba2, #f093fb);
        opacity: 0.6;
    }

    .table-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        flex-wrap: wrap;
        gap: 20px;
    }

    .table-title {
        font-size: 1.8rem;
        font-weight: 800;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .table-title::before {
        content: '📋';
        font-size: 1.5rem;
    }

    .table-controls {
        display: flex;
        align-items: center;
        gap: 20px;
        flex-wrap: wrap;
    }

    .add-seller-btn {
        padding: 12px 24px;
        background: linear-gradient(135deg, #28a745, #20c997);
        color: white;
        text-decoration: none;
        border-radius: 15px;
        font-weight: 700;
        font-size: 1rem;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4);
        display: inline-flex;
        align-items: center;
        gap: 8px;
        position: relative;
        overflow: hidden;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border: none;
        cursor: pointer;
    }
    
    .add-seller-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .add-seller-btn:hover::before {
        left: 100%;
    }
    
    .add-seller-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 8px 25px rgba(40, 167, 69, 0.5);
        background: linear-gradient(135deg, #218838, #1ea085);
    }

    .search-box {
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
    }

    .search-input {
        padding: 12px 20px;
        border: 2px solid #e1e5e9;
        border-radius: 15px;
        font-size: 1rem;
        width: 300px;
        transition: all 0.3s ease;
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(10px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    }
    
    .search-input:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
        transform: translateY(-2px);
        background: white;
    }
    
    .search-input::placeholder {
        color: #999;
        font-style: italic;
    }

    .filter-select {
        padding: 12px 20px;
        border: 2px solid #e1e5e9;
        border-radius: 15px;
        font-size: 1rem;
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(10px);
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        min-width: 150px;
    }
    
    .filter-select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
        transform: translateY(-2px);
        background: white;
    }

    .sellers-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border-radius: 15px;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        text-align: right;
    }

    .sellers-table th {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        padding: 20px 15px;
        font-weight: 700;
        font-size: 0.95rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        position: relative;
        white-space: nowrap;
        vertical-align: middle;
    }
    
    .sellers-table th:nth-child(1) { width: 60px; text-align: center; }
    .sellers-table th:nth-child(2) { width: 180px; text-align: center; }
    .sellers-table th:nth-child(3) { width: 220px; text-align: center; }
    .sellers-table th:nth-child(4) { width: 120px; text-align: center; }
    .sellers-table th:nth-child(5) { width: 200px; text-align: center; }
    .sellers-table th:nth-child(6) { width: 100px; text-align: center; }
    .sellers-table th:nth-child(7) { width: 180px; text-align: center; }
    
    .sellers-table th::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 2px;
        background: rgba(255, 255, 255, 0.3);
    }

    .sellers-table td {
        padding: 20px 15px;
        border-bottom: 1px solid #f0f0f0;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        vertical-align: middle;
    }
    
    .sellers-table td:nth-child(1) { text-align: center; font-weight: 600; }
    .sellers-table td:nth-child(2) { text-align: center; }
    .sellers-table td:nth-child(3) { text-align: center; }
    .sellers-table td:nth-child(4) { text-align: center; }
    .sellers-table td:nth-child(5) { text-align: center; }
    .sellers-table td:nth-child(6) { text-align: center; }
    .sellers-table td:nth-child(7) { text-align: center; }
    
    .sellers-table tr:hover td {
        background: linear-gradient(90deg, #f8f9ff, #f0f4ff);
        transform: scale(1.01);
    }
    
    .sellers-table tbody tr {
        transition: all 0.3s ease;
    }
    
    .sellers-table tbody tr:hover {
        box-shadow: 0 5px 20px rgba(102, 126, 234, 0.1);
        transform: translateY(-2px);
    }

    .status-badge {
        display: inline-block;
        padding: 8px 16px;
        border-radius: 25px;
        font-size: 0.85rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        position: relative;
        overflow: hidden;
        transition: all 0.3s ease;
        border: 2px solid transparent;
    }
    
    .status-badge::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }
    
    .status-badge:hover::before {
        left: 100%;
    }

    .status-pending {
        background: linear-gradient(135deg, #fff3cd, #ffeaa7);
        color: #856404;
        border: 2px solid #ffeaa7;
        box-shadow: 0 4px 15px rgba(255, 193, 7, 0.3);
    }
    
    .status-pending:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(255, 193, 7, 0.4);
    }

    .status-approved {
        background: linear-gradient(135deg, #d4edda, #c3e6cb);
        color: #155724;
        border: 2px solid #c3e6cb;
        box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
    }
    
    .status-approved:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4);
    }

    .status-rejected {
        background: linear-gradient(135deg, #f8d7da, #f5c6cb);
        color: #721c24;
        border: 2px solid #f5c6cb;
        box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3);
    }
    
    .status-rejected:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(220, 53, 69, 0.4);
    }

    .action-buttons {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }

    .action-btn {
        padding: 10px 18px;
        text-decoration: none;
        color: white;
        border-radius: 12px;
        font-size: 0.85rem;
        font-weight: 700;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        position: relative;
        overflow: hidden;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        box-shadow: 0 6px 20px rgba(0,0,0,0.15);
    }
    
    .action-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .action-btn:hover::before {
        left: 100%;
    }

    .approve-btn {
        background: linear-gradient(135deg, #28a745, #20c997);
        box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4);
    }
    
    .approve-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 8px 25px rgba(40, 167, 69, 0.5);
    }

    .reject-btn {
        background: linear-gradient(135deg, #dc3545, #c82333);
        box-shadow: 0 6px 20px rgba(220, 53, 69, 0.4);
    }
    
    .reject-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 8px 25px rgba(220, 53, 69, 0.5);
    }

    .back-link {
        text-align: center;
        margin-top: 40px;
    }

    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1.1rem;
        font-weight: 600;
        padding: 15px 35px;
        border-radius: 30px;
        background: rgba(255,255,255,0.15);
        backdrop-filter: blur(15px);
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        display: inline-block;
        border: 2px solid rgba(255,255,255,0.3);
        box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        position: relative;
        overflow: hidden;
    }
    
    .back-link a::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .back-link a:hover::before {
        left: 100%;
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.25);
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 12px 35px rgba(0,0,0,0.3);
    }

    @media (max-width: 768px) {
        .container {
            padding: 10px;
        }

        header h1 {
            font-size: 2rem;
        }

        .stats-container {
            grid-template-columns: 1fr;
            gap: 15px;
        }

        .table-header {
            flex-direction: column;
            gap: 15px;
            align-items: stretch;
        }

        .table-controls {
            flex-direction: column;
            gap: 15px;
            align-items: stretch;
        }

        .add-seller-btn {
            width: 100%;
            justify-content: center;
            font-size: 1.1rem;
            padding: 15px 20px;
        }

        .search-box {
            flex-direction: column;
        }

        .search-input, .filter-select {
            width: 100%;
        }

        .sellers-table {
            font-size: 0.8rem;
        }

        .sellers-table th,
        .sellers-table td {
            padding: 10px;
        }

        .action-buttons {
            flex-direction: column;
        }
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <div class="user-info">
                👤 <%= username != null ? username : "Admin" %> (<%= userRole != null ? userRole : "Guest" %>)
            </div>
            <h1>🏪 Seller Management</h1>
        </header>

        <div class="stats-container">
            <div class="stat-card">
                <span class="stat-icon">📊</span>
                <div class="stat-number" id="totalSellers">0</div>
                <div class="stat-label">Total Sellers</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">⏳</span>
                <div class="stat-number" id="pendingSellers">0</div>
                <div class="stat-label">Pending Approval</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">✅</span>
                <div class="stat-number" id="approvedSellers">0</div>
                <div class="stat-label">Approved Sellers</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">❌</span>
                <div class="stat-number" id="rejectedSellers">0</div>
                <div class="stat-label">Rejected Sellers</div>
            </div>
        </div>

        
        <div class="table-container">
            <div class="table-header">
                <h2 class="table-title">Seller Applications</h2>
                <div class="table-controls">
                    <a href="Sellerupload.jsp" class="add-seller-btn">
                        ➕ Add New Seller
                    </a>
                    <div class="search-box">
                        <input type="text" class="search-input" id="searchInput" placeholder="Search sellers..." onkeyup="filterSellers()">
                        <select class="filter-select" id="statusFilter" onchange="filterSellers()">
                            <option value="">All Status</option>
                            <option value="pending">Pending</option>
                            <option value="approved">Approved</option>
                            <option value="rejected">Rejected</option>
                        </select>
                    </div>
                </div>
            </div>

            <table class="sellers-table" id="sellerTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Product Brand</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="sellersTableBody">
<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/mscart", "root", "password");

    PreparedStatement ps = con.prepareStatement("SELECT * FROM seller ORDER BY created_at DESC");
    ResultSet rs = ps.executeQuery();

    int totalSellers = 0;
    int pendingSellers = 0;
    int approvedSellers = 0;
    int rejectedSellers = 0;

    while (rs.next()) {
        totalSellers++;
        String status = rs.getString("status");
        if ("pending".equals(status)) {
            pendingSellers++;
        } else if ("approved".equals(status)) {
            approvedSellers++;
        } else if ("rejected".equals(status)) {
            rejectedSellers++;
        }
%>
                    <tr data-status="<%= status %>" data-name="<%= rs.getString("name").toLowerCase() %>" data-email="<%= rs.getString("email").toLowerCase() %>">
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") %></td>
                        <td><%= rs.getString("shop_name") %></td>
                        <td>
                            <span class="status-badge status-<%= status %>">
                                <%= status.toUpperCase() %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <% if ("pending".equals(status)) { %>
                                    <a class="action-btn approve-btn" href="ApproveSellerServlet?id=<%= rs.getInt("id") %>">
                                        ✅ Approve
                                    </a>
                                    <a class="action-btn reject-btn" href="RejectSellerServlet?id=<%= rs.getInt("id") %>">
                                        ❌ Reject
                                    </a>
                                <% } else if ("approved".equals(status)) { %>
                                    <a class="action-btn reject-btn" href="RejectSellerServlet?id=<%= rs.getInt("id") %>">
                                        ❌ Reject
                                    </a>
                                <% } else { %>
                                    <a class="action-btn approve-btn" href="ApproveSellerServlet?id=<%= rs.getInt("id") %>">
                                        ✅ Approve
                                    </a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
<%
    }
    
    // Set statistics
    request.setAttribute("totalSellers", totalSellers);
    request.setAttribute("pendingSellers", pendingSellers);
    request.setAttribute("approvedSellers", approvedSellers);
    request.setAttribute("rejectedSellers", rejectedSellers);
    
    con.close();
} catch (Exception e) {
    out.println("<script>alert('Error loading seller: " + e.getMessage() + "');</script>");
}
%>
                </tbody>
            </table>
        </div>

        <div class="back-link">
            <a href="Dashboard.jsp">← Back to Dashboard</a>
        </div>
    </div>

    <script>
        // Update statistics
        document.addEventListener('DOMContentLoaded', function() {
            const totalSellers = parseInt('<%= request.getAttribute("totalSellers") != null ? request.getAttribute("totalSellers") : 0 %>');
            const pendingSellers = parseInt('<%= request.getAttribute("pendingSellers") != null ? request.getAttribute("pendingSellers") : 0 %>');
            const approvedSellers = parseInt('<%= request.getAttribute("approvedSellers") != null ? request.getAttribute("approvedSellers") : 0 %>');
            const rejectedSellers = parseInt('<%= request.getAttribute("rejectedSellers") != null ? request.getAttribute("rejectedSellers") : 0 %>');

            document.getElementById('totalSellers').textContent = totalSellers;
            document.getElementById('pendingSellers').textContent = pendingSellers;
            document.getElementById('approvedSellers').textContent = approvedSellers;
            document.getElementById('rejectedSellers').textContent = rejectedSellers;
        });

        // Filter sellers
        function filterSellers() {
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const rows = document.querySelectorAll('#sellersTableBody tr');

            rows.forEach(row => {
                const name = row.getAttribute('data-name');
                const email = row.getAttribute('data-email');
                const status = row.getAttribute('data-status');
                
                const matchesSearch = !searchInput || 
                    name.includes(searchInput) || 
                    email.includes(searchInput);
                const matchesStatus = !statusFilter || status === statusFilter;
                
                row.style.display = matchesSearch && matchesStatus ? '' : 'none';
            });
        }

        // Add smooth scroll behavior
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth' });
                }
            });
        });

        // Add loading states for action buttons
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const originalText = this.innerHTML;
                this.innerHTML = '⏳ Processing...';
                this.style.pointerEvents = 'none';
                
                setTimeout(() => {
                    this.innerHTML = originalText;
                    this.style.pointerEvents = 'auto';
                }, 2000);
            });
        });
    </script>
</body>
</html>
