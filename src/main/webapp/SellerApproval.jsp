<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession, java.sql.*, java.util.*, java.text.SimpleDateFormat, products.Dbase" %>
<%
// Check if user is logged in and is admin
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.jsp");
    return;
}

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Check if user is admin
if (!"admin".equals(userRole)) {
    response.sendRedirect("Home.jsp");
    return;
}

// Load all sellers for admin approval with status filtering
List<Map<String, Object>> pendingSellers = new ArrayList<>();
List<Map<String, Object>> approvedSellers = new ArrayList<>();
List<Map<String, Object>> rejectedSellers = new ArrayList<>();

try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        String sellerSql = "SELECT id, username, email, first_name, last_name, phone, shop_name, business_type, " +
                         "address, city, state, pincode, registration_date, status, rejection_reason, approved_by, approved_date " +
                         "FROM signupseller ORDER BY registration_date DESC";
        
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
            seller.put("rejectionReason", sellerRs.getString("rejection_reason"));
            seller.put("approvedBy", sellerRs.getString("approved_by"));
            seller.put("approvedDate", sellerRs.getString("approved_date"));
            
            // Categorize sellers by status
            String status = sellerRs.getString("status");
            if ("pending".equals(status)) {
                pendingSellers.add(seller);
            } else if ("approved".equals(status)) {
                approvedSellers.add(seller);
            } else if ("rejected".equals(status)) {
                rejectedSellers.add(seller);
            }
        }
        
        sellerRs.close();
        sellerStmt.close();
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
    <title>Seller Approval - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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

        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 20px 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .header-left h1 {
            font-size: 28px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
        }

        .header-left .icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }

        .header-actions {
            display: flex;
            gap: 15px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: #f8f9fa;
            color: #6b7280;
            border: 1px solid #e5e7eb;
        }

        .btn-secondary:hover {
            background: #e9ecef;
            color: #495057;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 30px;
        }

        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-number {
            font-size: 36px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 8px;
        }

        .stat-label {
            font-size: 14px;
            color: #6b7280;
            font-weight: 500;
        }

        .seller-approval {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .pending-count {
            background: #f59e0b;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .seller-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 25px;
        }

        .seller-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            border: 1px solid #f1f3f6;
        }

        .seller-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
            border-color: #667eea;
        }

        .seller-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f3f6;
        }

        .seller-info {
            flex: 1;
        }

        .seller-name {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 4px;
        }

        .seller-username {
            font-size: 14px;
            color: #6b7280;
            margin-bottom: 8px;
        }

        .seller-badges {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-pending {
            background: #fef3c7;
            color: #d97706;
        }

        .badge-business {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-approved {
            background: #d1fae5;
            color: #065f46;
        }

        .badge-rejected {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Tab Styles */
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 0;
        }

        .tab-btn {
            background: none;
            border: none;
            padding: 15px 20px;
            font-size: 14px;
            font-weight: 600;
            color: #6b7280;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            border-radius: 8px 8px 0 0;
        }

        .tab-btn:hover {
            background: #f9fafb;
            color: #374151;
        }

        .tab-btn.active {
            color: #667eea;
            border-bottom-color: #667eea;
            background: #f0f4ff;
        }

        .tab-content {
            position: relative;
        }

        .tab-pane {
            display: none;
            animation: fadeIn 0.3s ease-in-out;
        }

        .tab-pane.active {
            display: block;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .seller-details {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .detail-label {
            font-size: 12px;
            color: #6b7280;
            font-weight: 600;
            text-transform: uppercase;
        }

        .detail-value {
            font-size: 14px;
            color: #374151;
            font-weight: 500;
        }

        .seller-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
        }

        .btn-approve {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .btn-approve:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3);
        }

        .btn-reject {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }

        .btn-reject:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(239, 68, 68, 0.3);
        }

        .btn-delete {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }

        .btn-delete:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(239, 68, 68, 0.3);
        }

        .btn-view {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }

        .btn-view:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(107, 114, 128, 0.3);
        }

        .empty-state {
            text-align: center;
            padding: 80px 40px;
            color: #6b7280;
        }

        .empty-icon {
            font-size: 64px;
            margin-bottom: 20px;
            color: #d1d5db;
        }

        .empty-title {
            font-size: 24px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 12px;
        }

        .empty-description {
            font-size: 16px;
            color: #6b7280;
            max-width: 500px;
            margin: 0 auto;
        }

        /* Back button left alignment */
        .header-actions .btn-secondary {
            position: fixed !important;
            top: 20px !important;
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

        .header-actions .btn-secondary::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }

        .header-actions .btn-secondary:hover::before {
            left: 100%;
        }

        .header-actions .btn-secondary:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(102, 126, 234, 0.3);
            transition: all 0.1s ease;
        }

        .header-actions .btn-secondary:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3), 0 0 0 3px rgba(102, 126, 234, 0.2);
        }

        .header-actions .btn-secondary i {
            font-size: 1.1rem;
            transition: transform 0.3s ease;
            color: #FFFFFF;
        }

        .header-actions .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            border-color: rgba(255, 255, 255, 0.5);
            text-decoration: none;
            color: white;
        }

        .header-actions .btn-secondary:hover i {
            transform: translateX(-3px);
        }

        /* Additional specific selector for back button */
        body .header-actions .btn-secondary {
            position: fixed !important;
            top: 20px !important;
            left: 20px !important;
            z-index: 1000 !important;
        }

        @media (max-width: 768px) {
            .container {
                padding: 20px 15px;
            }
            
            .seller-grid {
                grid-template-columns: 1fr;
            }
            
            .seller-details {
                grid-template-columns: 1fr;
            }
            
            .header-content {
                flex-direction: column;
                gap: 20px;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <div class="header-content">
            <div class="header-left">
                <div class="icon">
                    <i class="fas fa-user-check"></i>
                </div>
                <h1>Seller Approval</h1>
            </div>
            <div class="header-actions">
                <a href="Dashboard.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i>
                    Back 
                </a>
                <a href="Home.jsp" class="btn btn-primary">
                    <i class="fas fa-home"></i>
                    Home
                </a>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <!-- Statistics -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-number"><%= pendingSellers.size() %></div>
                <div class="stat-label">Pending Sellers</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= approvedSellers.size() %></div>
                <div class="stat-label">Approved Sellers</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= rejectedSellers.size() %></div>
                <div class="stat-label">Rejected Sellers</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= pendingSellers.size() + approvedSellers.size() + rejectedSellers.size() %></div>
                <div class="stat-label">Total Sellers</div>
            </div>
        </div>

        <!-- Seller Approval Section with Tabs -->
        <div class="seller-approval">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-users"></i>
                    Seller Management
                </h2>
            </div>
            
            <!-- Tabs -->
            <div class="tabs">
                <button class="tab-btn active" onclick="showTab('pending')">
                    <i class="fas fa-clock"></i>
                    Pending (<%= pendingSellers.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('approved')">
                    <i class="fas fa-check-circle"></i>
                    Approved (<%= approvedSellers.size() %>)
                </button>
                <button class="tab-btn" onclick="showTab('rejected')">
                    <i class="fas fa-times-circle"></i>
                    Rejected (<%= rejectedSellers.size() %>)
                </button>
            </div>
            
            <!-- Tab Content -->
            <div class="tab-content">
                <!-- Pending Sellers Tab -->
                <div id="pending-tab" class="tab-pane active">
                    <% if (pendingSellers.isEmpty()) { %>
                        <!-- Empty State -->
                        <div class="empty-state">
                            <div class="empty-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <h3 class="empty-title">No Pending Sellers</h3>
                            <p class="empty-description">
                                All seller registrations have been processed. No pending approvals at this time.
                            </p>
                        </div>
                    <% } else { %>
                        <!-- Pending Seller Cards -->
                        <div class="seller-grid">
                            <% for (Map<String, Object> seller : pendingSellers) { %>
                                <div class="seller-card">
                                    <div class="seller-header">
                                        <div class="seller-info">
                                            <div class="seller-name"><%= seller.get("firstName") %> <%= seller.get("lastName") %></div>
                                            <div class="seller-username">@<%= seller.get("username") %></div>
                                        </div>
                                        <div class="seller-badges">
                                            <span class="badge badge-pending">Pending</span>
                                            <span class="badge badge-business"><%= seller.get("businessType") %></span>
                                        </div>
                                    </div>
                                    
                                    <div class="seller-details">
                                        <div class="detail-item">
                                            <span class="detail-label">Shop Name</span>
                                            <span class="detail-value"><%= seller.get("shopName") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Email</span>
                                            <span class="detail-value"><%= seller.get("email") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Phone</span>
                                            <span class="detail-value"><%= seller.get("phone") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Registration Date</span>
                                            <span class="detail-value"><%= seller.get("registrationDate") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">City</span>
                                            <span class="detail-value"><%= seller.get("city") %>, <%= seller.get("state") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">PIN Code</span>
                                            <span class="detail-value"><%= seller.get("pincode") %></span>
                                        </div>
                                    </div>
                                    
                                    <div class="detail-item" style="grid-column: 1 / -1;">
                                        <span class="detail-label">Address</span>
                                        <span class="detail-value"><%= seller.get("address") %></span>
                                    </div>
                                    
                                    <div class="seller-actions">
                                                                                <button class="btn btn-reject" onclick="rejectSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                            <i class="fas fa-times"></i>
                                            Reject
                                        </button>
                                        <button class="btn btn-approve" onclick="approveSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                            <i class="fas fa-check"></i>
                                            Approve
                                        </button>
                                        <button class="btn btn-delete" onclick="deleteSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                            <i class="fas fa-trash"></i>
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                
                <!-- Approved Sellers Tab -->
                <div id="approved-tab" class="tab-pane">
                    <% if (approvedSellers.isEmpty()) { %>
                        <!-- Empty State -->
                        <div class="empty-state">
                            <div class="empty-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <h3 class="empty-title">No Approved Sellers</h3>
                            <p class="empty-description">
                                No sellers have been approved yet. Pending sellers will appear here after approval.
                            </p>
                        </div>
                    <% } else { %>
                        <!-- Approved Seller Cards -->
                        <div class="seller-grid">
                            <% for (Map<String, Object> seller : approvedSellers) { %>
                                <div class="seller-card">
                                    <div class="seller-header">
                                        <div class="seller-info">
                                            <div class="seller-name"><%= seller.get("firstName") %> <%= seller.get("lastName") %></div>
                                            <div class="seller-username">@<%= seller.get("username") %></div>
                                        </div>
                                        <div class="seller-badges">
                                            <span class="badge badge-approved">Approved</span>
                                            <span class="badge badge-business"><%= seller.get("businessType") %></span>
                                        </div>
                                    </div>
                                    
                                    <div class="seller-details">
                                        <div class="detail-item">
                                            <span class="detail-label">Shop Name</span>
                                            <span class="detail-value"><%= seller.get("shopName") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Email</span>
                                            <span class="detail-value"><%= seller.get("email") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Phone</span>
                                            <span class="detail-value"><%= seller.get("phone") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Approved Date</span>
                                            <span class="detail-value"><%= seller.get("approvedDate") != null ? seller.get("approvedDate") : "N/A" %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Approved By</span>
                                            <span class="detail-value"><%= seller.get("approvedBy") != null ? seller.get("approvedBy") : "N/A" %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">City</span>
                                            <span class="detail-value"><%= seller.get("city") %>, <%= seller.get("state") %></span>
                                        </div>
                                    </div>
                                    
                                    <div class="detail-item" style="grid-column: 1 / -1;">
                                        <span class="detail-label">Address</span>
                                        <span class="detail-value"><%= seller.get("address") %></span>
                                    </div>
                                    
                                    <div class="seller-actions">
                                                                                <button class="btn btn-delete" onclick="deleteSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                            <i class="fas fa-trash"></i>
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                
                <!-- Rejected Sellers Tab -->
                <div id="rejected-tab" class="tab-pane">
                    <% if (rejectedSellers.isEmpty()) { %>
                        <!-- Empty State -->
                        <div class="empty-state">
                            <div class="empty-icon">
                                <i class="fas fa-times-circle"></i>
                            </div>
                            <h3 class="empty-title">No Rejected Sellers</h3>
                            <p class="empty-description">
                                No sellers have been rejected. Rejected sellers will appear here with rejection reasons.
                            </p>
                        </div>
                    <% } else { %>
                        <!-- Rejected Seller Cards -->
                        <div class="seller-grid">
                            <% for (Map<String, Object> seller : rejectedSellers) { %>
                                <div class="seller-card">
                                    <div class="seller-header">
                                        <div class="seller-info">
                                            <div class="seller-name"><%= seller.get("firstName") %> <%= seller.get("lastName") %></div>
                                            <div class="seller-username">@<%= seller.get("username") %></div>
                                        </div>
                                        <div class="seller-badges">
                                            <span class="badge badge-rejected">Rejected</span>
                                            <span class="badge badge-business"><%= seller.get("businessType") %></span>
                                        </div>
                                    </div>
                                    
                                    <div class="seller-details">
                                        <div class="detail-item">
                                            <span class="detail-label">Shop Name</span>
                                            <span class="detail-value"><%= seller.get("shopName") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Email</span>
                                            <span class="detail-value"><%= seller.get("email") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Phone</span>
                                            <span class="detail-value"><%= seller.get("phone") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">Registration Date</span>
                                            <span class="detail-value"><%= seller.get("registrationDate") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">City</span>
                                            <span class="detail-value"><%= seller.get("city") %>, <%= seller.get("state") %></span>
                                        </div>
                                        <div class="detail-item">
                                            <span class="detail-label">PIN Code</span>
                                            <span class="detail-value"><%= seller.get("pincode") %></span>
                                        </div>
                                    </div>
                                    
                                    <div class="detail-item" style="grid-column: 1 / -1;">
                                        <span class="detail-label">Address</span>
                                        <span class="detail-value"><%= seller.get("address") %></span>
                                    </div>
                                    
                                    <% if (seller.get("rejectionReason") != null && !seller.get("rejectionReason").toString().trim().isEmpty()) { %>
                                        <div class="detail-item" style="grid-column: 1 / -1;">
                                            <span class="detail-label">Rejection Reason</span>
                                            <span class="detail-value" style="color: #dc2626; font-weight: 500;">
                                                <%= seller.get("rejectionReason") %>
                                            </span>
                                        </div>
                                    <% } %>
                                    
                                    <div class="seller-actions">
                                                                                <button class="btn btn-delete" onclick="deleteSeller(<%= seller.get("id") %>, '<%= seller.get("username") %>')">
                                            <i class="fas fa-trash"></i>
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Tab switching function
        function showTab(tabName) {
            // Hide all tab panes
            const tabPanes = document.querySelectorAll('.tab-pane');
            tabPanes.forEach(pane => {
                pane.classList.remove('active');
            });
            
            // Remove active class from all tab buttons
            const tabButtons = document.querySelectorAll('.tab-btn');
            tabButtons.forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Show selected tab pane
            const selectedPane = document.getElementById(tabName + '-tab');
            if (selectedPane) {
                selectedPane.classList.add('active');
            }
            
            // Add active class to clicked button
            const clickedButton = document.querySelector(`.tab-btn[onclick="showTab('${tabName}')"]`);
            if (clickedButton) {
                clickedButton.classList.add('active');
            }
        }
        
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
        
        function deleteSeller(sellerId, username) {
            if (confirm('Are you sure you want to permanently delete seller "' + username + '"? This action cannot be undone and will remove all seller data including their products and orders.')) {
                // Create form for deletion
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'DeleteSellerServlet';
                
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
                actionInput.value = 'delete';
                form.appendChild(actionInput);
                
                // Add deleted by
                const deletedByInput = document.createElement('input');
                deletedByInput.type = 'hidden';
                deletedByInput.name = 'deletedBy';
                deletedByInput.value = '<%= username %>';
                form.appendChild(deletedByInput);
                
                // Submit form
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function viewSellerDetails(sellerId) {
            // Open seller details in a new window
            const url = 'SellerDetails.jsp?sellerId=' + sellerId;
            window.open(url, 'sellerDetails', 'width=900,height=700,scrollbars=yes,resizable=yes');
        }
        
        // Show notification for successful actions
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 600; z-index: 10000; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #10b981, #059669)';
            } else if (type === 'error') {
                notification.style.background = 'linear-gradient(135deg, #ef4444, #dc2626)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #f59e0b, #d97706)';
                notification.style.color = '#374151';
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
                const cleanUrl = window.location.pathname;
                window.history.replaceState({}, document.title, cleanUrl);
            }
        });
    </script>
</body>
</html>
