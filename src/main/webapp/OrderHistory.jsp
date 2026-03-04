<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, java.text.SimpleDateFormat, products.Dbase" %>
<%
    // Check if user is logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("Login.html");
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
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
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
    </script>
</body>
</html>