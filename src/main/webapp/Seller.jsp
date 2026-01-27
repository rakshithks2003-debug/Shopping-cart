<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="products.Dbase" %>
<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);

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
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
        --primary: #4f46e5;
        --primary-hover: #4338ca;
        --success: #22c55e;
        --danger: #ef4444;
        --warning: #f59e0b;
        --bg: #f8fafc;
        --card-bg: #ffffff;
        --text-main: #1e293b;
        --text-muted: #64748b;
        --border: #e2e8f0;
    }

    body { 
        font-family: 'Inter', system-ui, -apple-system, sans-serif; 
        background-color: var(--bg); 
        color: var(--text-main);
        margin: 0;
        padding: 20px; 
        line-height: 1.5;
    }

    .container { 
        max-width: 1200px; 
        margin: 0 auto;
        background-color: var(--card-bg); 
        padding: 30px; 
        border-radius: 12px; 
        box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); 
    }

    header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 1px solid var(--border);
    }

    h1 { 
        margin: 0;
        font-size: 1.875rem;
        font-weight: 700;
        color: var(--text-main);
    }

    .user-info {
        color: var(--text-muted);
        font-size: 0.875rem;
    }

    .stats-grid { 
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 16px;
        margin-bottom: 30px; 
    }

    .stat-card { 
        background: var(--bg);
        padding: 20px; 
        border-radius: 8px;
        border: 1px solid var(--border);
        transition: transform 0.2s;
    }

    .stat-card:hover { transform: translateY(-2px); }

    .stat-icon { font-size: 1.5rem; margin-bottom: 8px; display: block; }

    .stat-number { 
        font-size: 1.5rem; 
        font-weight: 700; 
        color: var(--primary); 
    }

    .stat-label { 
        font-size: 0.75rem;
        font-weight: 600;
        text-transform: uppercase;
        color: var(--text-muted);
        letter-spacing: 0.05em;
    }

    .controls-section { 
        margin-bottom: 24px; 
        display: flex; 
        justify-content: space-between; 
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
    }

    .add-btn { 
        background-color: var(--primary); 
        color: white; 
        padding: 10px 20px; 
        text-decoration: none; 
        border-radius: 6px; 
        font-weight: 600;
        font-size: 0.875rem;
        transition: background 0.2s;
    }

    .add-btn:hover { background-color: var(--primary-hover); }

    .search-filter-group { display: flex; gap: 12px; }

    .search-input, .filter-select { 
        padding: 8px 12px; 
        border: 1px solid var(--border);
        border-radius: 6px;
        font-size: 0.875rem;
        outline: none;
    }

    .search-input:focus, .filter-select:focus { border-color: var(--primary); }

    .table-container { overflow-x: auto; }

    table { 
        width: 100%; 
        border-collapse: collapse; 
        font-size: 0.875rem;
    }

    th { 
        background-color: var(--bg);
        color: var(--text-muted);
        font-weight: 600;
        text-transform: uppercase;
        font-size: 0.75rem;
        letter-spacing: 0.05em;
        padding: 12px 16px;
        text-align: left;
        border-bottom: 2px solid var(--border);
    }

    td { 
        padding: 16px; 
        border-bottom: 1px solid var(--border);
        color: var(--text-main);
    }

    tr:hover { background-color: #f8fafc; }

    .status-badge { 
        padding: 4px 8px; 
        border-radius: 9999px; 
        font-size: 0.75rem; 
        font-weight: 600; 
    }

    .status-pending { background-color: #fef3c7; color: #92400e; }
    .status-approved { background-color: #dcfce7; color: #166534; }
    .status-rejected { background-color: #fee2e2; color: #991b1b; }

    .dropdown { position: relative; display: inline-block; }
    
    .dropdown-btn {
        background: white;
        border: 1px solid var(--border);
        padding: 6px 12px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.75rem;
    }

    .dropdown-content { 
        display: none; 
        position: absolute; 
        right: 0;
        background-color: white; 
        min-width: 180px; 
        box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1); 
        z-index: 10; 
        border: 1px solid var(--border); 
        border-radius: 8px;
        padding: 4px;
    }

    .dropdown-content a { 
        color: var(--text-main); 
        padding: 8px 12px; 
        text-decoration: none; 
        display: block; 
        border-radius: 4px;
        font-size: 0.875rem;
    }

    .dropdown-content a:hover { background-color: var(--bg); color: var(--primary); }
    
    .show { display: block !important; }

    .back-link { margin-top: 30px; text-align: center; }
    .back-link a { color: var(--primary); text-decoration: none; font-weight: 600; }
    .back-link a:hover { text-decoration: underline; }

    @media (max-width: 768px) {
        .controls-section { flex-direction: column; align-items: stretch; }
        .search-filter-group { flex-direction: column; }
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-title">
                <h1><i class="fas fa-store"></i> Seller Management</h1>
            </div>
            <div class="user-info">
                <i class="fas fa-user"></i>
                <%= username != null ? username : "Admin" %> (<%= userRole != null ? userRole : "Guest" %>)
            </div>
        </header>

        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-icon">📊</span>
                <div class="stat-number" id="totalSellers">0</div>
                <div class="stat-label">Total Sellers</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">⏳</span>
                <div class="stat-number" id="pendingSellers">0</div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">✅</span>
                <div class="stat-number" id="approvedSellers">0</div>
                <div class="stat-label">Approved</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">❌</span>
                <div class="stat-number" id="rejectedSellers">0</div>
                <div class="stat-label">Rejected</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">📦</span>
                <div class="stat-number" id="movedSellers">0</div>
                <div class="stat-label">Moved to Products</div>
            </div>
        </div>

        
        <div class="controls-section">
            <a href="Sellerupload.jsp" class="add-btn">
                <i class="fas fa-plus"></i> Add New Seller
            </a>
            <div class="search-filter-group">
                <input type="text" class="search-input" id="searchInput" placeholder="Search sellers..." onkeyup="filterSellers()">
                <select class="filter-select" id="statusFilter" onchange="filterSellers()">
                    <option value="">All Status</option>
                    <option value="pending">Pending</option>
                    <option value="approved">Approved</option>
                    <option value="rejected">Rejected</option>
                    <option value="moved_to_products">Moved to Products</option>
                </select>
            </div>
        </div>

        <div class="table-container">
            <table class="sellers-table" id="sellerTable">
    <thead>
        <tr>
            <th>ID</th>
            <th>Full Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Brand</th>
            <th>Category</th>
            <th>Category ID</th>
            <th>Price</th>
            <th>Image</th>
            <th>Description</th>
            <th>Actions</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody id="sellersTableBody">
        <%
        try {
            Dbase db = new Dbase();
            Connection con = null;
            
            try {
                con = db.initailizeDatabase();
            } catch (Exception e) {
                // Fallback to direct connection if Dbase fails
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            }

            if (con == null || con.isClosed()) {
                out.println("<script>showApprovedSuccess('Database connection failed!');</script>");
                return;
            }

            PreparedStatement ps = con.prepareStatement("SELECT * FROM seller ORDER BY sid DESC");
            ResultSet rs = ps.executeQuery();

            int totalSellers = 0;
            int pendingSellers = 0;
            int approvedSellers = 0;
            int rejectedSellers = 0;
            int movedSellers = 0;

            while (rs.next()) {
                totalSellers++;
        %>
                <tr data-name="<%= rs.getString("full_name").toLowerCase() %>" data-email="<%= rs.getString("email_address").toLowerCase() %>">
                    <td><%= rs.getString("sid") %></td>
                    <td><%= rs.getString("full_name") %></td>
                    <td><%= rs.getString("email_address") %></td>
                    <td><%= rs.getString("phone_number") %></td>
                    <td><%= rs.getString("product_brand") %></td>
                    <td><%= rs.getString("Category") %></td>
                    <td><%= rs.getString("Category_id") %></td>
                    <td><%= rs.getString("price") %></td>
                    <td><% if(rs.getString("image") != null && !rs.getString("image").isEmpty()) { %><img src="seller_images/<%= rs.getString("image") %>" width="50" height="50" style="border-radius: 8px;"><% } else { %>No Image<% } %></td>
                    <td><%= rs.getString("description") != null ? rs.getString("description").substring(0, Math.min(50, rs.getString("description").length())) + (rs.getString("description").length() > 50 ? "..." : "") : "" %></td>
                    <td>
                        <div class="action-buttons">
                            <div class="dropdown">
                                <button class="dropdown-btn" onclick="toggleDropdown('dropdown<%= rs.getString("sid") %>')">
                                    <i class="fas fa-cog"></i> Actions
                                    <i class="fas fa-chevron-down"></i>
                                </button>
                                <!-- Direct delete button for testing -->
                                <button onclick="deleteSellerDirect('<%= rs.getString("sid") %>', 'delete')" style="margin-left: 2px; padding: 4px 8px; background: #dc3545; color: white; border: none; border-radius: 4px; font-size: 10px; cursor: pointer;" title="Delete Seller">🗑️</button>
                                <div class="dropdown-content" id="dropdown<%= rs.getString("sid") %>">
                                    <!-- Quick Actions Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-bolt"></i> Quick Actions
                                        </div>
                                        <a href="#" class="dropdown-item approve-item" onclick="acceptProductWithShowproducts('<%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-check"></i> Accept Product
                                        </a>
                                        <a href="#" class="dropdown-item approve-item" onclick="acceptProductWithShowproducts('<%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-check-circle"></i> Approved
                                        </a>
                                        <a href="#" class="dropdown-item pending-item" onclick="updateSellerStatus('<%= rs.getString("sid") %>', 'pending'); return false;">
                                            <i class="fas fa-clock"></i> Pending
                                        </a>
                                        <a href="#" class="dropdown-item reject-item" onclick="updateSellerStatus('<%= rs.getString("sid") %>', 'rejected'); return false;">
                                            <i class="fas fa-times"></i> Reject
                                        </a>
                                    </div>
                                    
                                    <!-- Advanced Actions Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-cogs"></i> Advanced Actions
                                        </div>
                                        <a href="#" class="dropdown-item move-item" onclick="showApprovedSuccess('Move to Products clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-arrow-right"></i> Move to Products
                                        </a>
                                        <a href="#" class="dropdown-item view-item" onclick="showApprovedSuccess('View clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-eye"></i> View Full Details
                                        </a>
                                    </div>
                                    
                                    <!-- Management Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-tools"></i> Management
                                        </div>
                                        <a href="#" class="dropdown-item delete-item" onclick="deleteSeller('<%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-trash"></i> Delete Seller
                                        </a>
                                        <a href="#" class="dropdown-item duplicate-item" onclick="showApprovedSuccess('Duplicate clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-copy"></i> Duplicate Entry
                                        </a>
                                        <a href="#" class="dropdown-item export-item" onclick="showApprovedSuccess('Export clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-download"></i> Export Data
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <%
                        String sellerStatus = "pending"; // Default status
                        try {
                            // Try to get status from database if status column exists
                            String statusFromDb = rs.getString("status");
                            if (statusFromDb != null && !statusFromDb.isEmpty()) {
                                sellerStatus = statusFromDb;
                            }
                        } catch (Exception e) {
                            // Status column doesn't exist, use default
                        }
                        
                        // Determine status badge class and text
                        String statusBadgeClass = "status-pending";
                        String statusText = "Pending";
                        
                        if ("approved".equals(sellerStatus)) {
                            statusBadgeClass = "status-approved";
                            statusText = "Approved";
                        } else if ("rejected".equals(sellerStatus)) {
                            statusBadgeClass = "status-rejected";
                            statusText = "Rejected";
                        } else if ("moved_to_products".equals(sellerStatus)) {
                            statusBadgeClass = "status-approved";
                            statusText = "Moved to Products";
                        }
                        %>
                        <span id="status-<%= rs.getString("sid") %>" class="status-badge <%= statusBadgeClass %>">
                            <%= statusText %>
                        </span>
                    </td>
                </tr>
        <%
            }
            
            // Set statistics
            request.setAttribute("totalSellers", totalSellers);
            request.setAttribute("pendingSellers", pendingSellers);
            request.setAttribute("approvedSellers", approvedSellers);
            request.setAttribute("rejectedSellers", rejectedSellers);
            request.setAttribute("movedSellers", movedSellers);
            
            con.close();
        } catch (Exception e) {
            out.println("<script>showApprovedSuccess('Error loading seller: " + e.getMessage() + "');</script>");
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
        // Test function for debugging AcceptProductServlet
        function testAcceptProductServlet() {
            console.log('Testing AcceptProductServlet...');
            
            // Try different possible servlet paths
            const possiblePaths = [
                'AcceptProductServlet',
                '/AcceptProductServlet',
                'servlets/AcceptProductServlet',
                '/servlets/AcceptProductServlet'
            ];
            
            let currentIndex = 0;
            
            function tryNextPath() {
                if (currentIndex >= possiblePaths.length) {
                    showApprovedSuccess('All servlet paths failed. Check server logs for servlet deployment issues.');
                    return;
                }
                
                const path = possiblePaths[currentIndex];
                console.log('Trying path:', path);
                
                fetch(path, {
                    method: 'GET'
                }).then(response => {
                    console.log('Response for path', path, '- status:', response.status);
                    if (response.status === 404) {
                        currentIndex++;
                        tryNextPath();
                    } else {
                        return response.text();
                    }
                }).then(text => {
                    if (text) {
                        console.log('Response text:', text);
                        showApprovedSuccess('Success with path ' + path + '!\n\nServlet Response: ' + text);
                        
                        // Update the acceptProduct function to use the working path
                        window.workingServletPath = path;
                        console.log('Set working servlet path to:', path);
                    }
                }).catch(error => {
                    console.error('Error with path', path, ':', error);
                    currentIndex++;
                    tryNextPath();
                });
            }
            
            tryNextPath();
        }

        // Test function for debugging DeleteSellerServlet
        function testDeleteSellerServlet() {
            console.log('Testing DeleteSellerServlet...');
            
            // Try different possible servlet paths
            const possiblePaths = [
                'DeleteSellerServlet',
                '/DeleteSellerServlet',
                'servlets/DeleteSellerServlet',
                '/servlets/DeleteSellerServlet'
            ];
            
            let currentIndex = 0;
            
            function tryNextPath() {
                if (currentIndex >= possiblePaths.length) {
                    showApprovedSuccess('All DeleteSellerServlet paths failed. Check if the servlet is properly deployed in Eclipse.');
                    return;
                }
                
                const path = possiblePaths[currentIndex];
                console.log('Testing DeleteSellerServlet path:', path);
                
                fetch(path, {
                    method: 'GET'
                }).then(response => {
                    console.log('DeleteSellerServlet response for path', path, '- status:', response.status);
                    if (response.status === 404) {
                        currentIndex++;
                        tryNextPath();
                    } else {
                        return response.text();
                    }
                }).then(text => {
                    if (text) {
                        console.log('DeleteSellerServlet response text:', text);
                        showApprovedSuccess('DeleteSellerServlet works with path ' + path + '!\n\nResponse: ' + text);
                        
                        // Update the deleteSellerDirect function to use the working path
                        window.workingDeleteServletPath = path;
                        console.log('Set working DeleteSellerServlet path to:', path);
                    }
                }).catch(error => {
                    console.error('Error with DeleteSellerServlet path', path, ':', error);
                    currentIndex++;
                    tryNextPath();
                });
            }
            
            tryNextPath();
        }

        // Update statistics
        document.addEventListener('DOMContentLoaded', function() {
            const totalSellers = parseInt('<%= request.getAttribute("totalSellers") != null ? request.getAttribute("totalSellers") : 0 %>');
            const pendingSellers = parseInt('<%= request.getAttribute("pendingSellers") != null ? request.getAttribute("pendingSellers") : 0 %>');
            const approvedSellers = parseInt('<%= request.getAttribute("approvedSellers") != null ? request.getAttribute("approvedSellers") : 0 %>');
            const rejectedSellers = parseInt('<%= request.getAttribute("rejectedSellers") != null ? request.getAttribute("rejectedSellers") : 0 %>');
            const movedSellers = parseInt('<%= request.getAttribute("movedSellers") != null ? request.getAttribute("movedSellers") : 0 %>');

            document.getElementById('totalSellers').textContent = totalSellers;
            document.getElementById('pendingSellers').textContent = pendingSellers;
            document.getElementById('approvedSellers').textContent = approvedSellers;
            document.getElementById('rejectedSellers').textContent = rejectedSellers;
            document.getElementById('movedSellers').textContent = movedSellers;
        });

        // Test dropdown function for debugging
        function testDropdown(dropdownId) {
            console.log('Test dropdown called for:', dropdownId);
            var dropdown = document.getElementById(dropdownId);
            if (dropdown) {
                showApprovedSuccess('Dropdown found! Current display: ' + dropdown.style.display + ', Classes: ' + dropdown.className);
                // Force show the dropdown
                dropdown.style.display = 'block';
                dropdown.classList.add('show');
                dropdown.style.background = 'yellow';
                dropdown.style.border = '2px solid red';
                showApprovedSuccess('Dropdown should now be visible with yellow background!');
            } else {
                showApprovedSuccess('Dropdown NOT found: ' + dropdownId);
            }
        }

        // Simple dropdown toggle function
        function toggleDropdown(dropdownId) {
            console.log('Toggle dropdown called for:', dropdownId);
            var dropdown = document.getElementById(dropdownId);
            if (dropdown) {
                // Check current state
                var isHidden = dropdown.style.display === 'none' || !dropdown.style.display;
                console.log('Current visibility:', isHidden ? 'hidden' : 'visible');
                
                // Close all other dropdowns first
                var allDropdowns = document.getElementsByClassName('dropdown-content');
                for (var i = 0; i < allDropdowns.length; i++) {
                    allDropdowns[i].style.display = 'none';
                    allDropdowns[i].classList.remove('show');
                }
                
                // Toggle current dropdown
                if (isHidden) {
                    dropdown.style.display = 'block';
                    dropdown.classList.add('show');
                    console.log('Dropdown shown');
                } else {
                    dropdown.style.display = 'none';
                    dropdown.classList.remove('show');
                    console.log('Dropdown hidden');
                }
            } else {
                console.log('Dropdown not found:', dropdownId);
            }
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.closest('.dropdown-btn') && !event.target.closest('.dropdown-content')) {
                var dropdowns = document.getElementsByClassName('dropdown-content');
                for (var i = 0; i < dropdowns.length; i++) {
                    dropdowns[i].style.display = 'none';
                    dropdowns[i].classList.remove('show');
                }
            }
        });

        // Toggle products table
        function toggleProductsTable(sellerId) {
            const tableId = 'productsTable' + sellerId;
            
            // Close all other tables
            const tables = document.querySelectorAll('.products-table-content');
            tables.forEach(table => {
                if (table.id !== tableId) {
                    table.classList.remove('show');
                }
            });
            
            // Toggle current table
            const currentTable = document.getElementById(tableId);
            if (currentTable) {
                currentTable.classList.toggle('show');
            }
        }

        // Close tables when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.matches('.products-table-btn') && !event.target.closest('.products-table-btn')) {
                const tables = document.querySelectorAll('.products-table-content');
                tables.forEach(table => {
                    table.classList.remove('show');
                });
            }
        });

        // Toggle products dropdown
        function toggleProductsDropdown(dropdownId) {
            // Close all other dropdowns
            const dropdowns = document.querySelectorAll('.products-dropdown-content');
            dropdowns.forEach(dropdown => {
                if (dropdown.id !== dropdownId) {
                    dropdown.classList.remove('show');
                }
            });
            
            // Toggle current dropdown
            const currentDropdown = document.getElementById(dropdownId);
            if (currentDropdown) {
                currentDropdown.classList.toggle('show');
            }
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.matches('.products-dropdown-btn') && !event.target.closest('.products-dropdown-btn')) {
                const dropdowns = document.querySelectorAll('.products-dropdown-content');
                dropdowns.forEach(dropdown => {
                    dropdown.classList.remove('show');
                });
            }
        });

        // Direct delete function for the red delete button
        function deleteSellerDirect(sellerId, action) {
            console.log('deleteSellerDirect called with sellerId:', sellerId, 'and action:', action);
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to delete this seller? This action cannot be undone.')) {
                console.log('User cancelled deletion');
                return;
            }
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting seller...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to working DeleteSellerServlet
            const xhr = new XMLHttpRequest();
            const servletPath = window.workingDeleteServletPath || 'DeleteSellerServlet';
            console.log('Using servlet path:', servletPath);
            xhr.open('POST', servletPath, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            // Log the request data
            const requestData = 'sellerId=' + encodeURIComponent(sellerId) + '&action=' + encodeURIComponent(action);
            console.log('Sending request data to DeleteSellerServlet:', requestData);
            
            xhr.onreadystatechange = function() {
                console.log('XHR state changed:', xhr.readyState, 'status:', xhr.status);
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Response status:', xhr.status);
                    console.log('Response text:', xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Parsed response:', response);
                            
                            if (response.success) {
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Success message displays on same page - no reload needed



                            } else {
                                console.error('Delete failed:', response.message);
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing delete response:', e);
                            console.error('Raw response:', xhr.responseText);
                            showNotification('Error parsing server response. Please try again.', 'error');
                        }
                    } else {
                        console.error('Delete request failed with status:', xhr.status);
                        console.error('Response text:', xhr.responseText);
                        showNotification('Server error: ' + xhr.status + '. Please try again.', 'error');
                    }
                }
            };
            
            xhr.onerror = function() {
                console.error('XHR error occurred');
                if (loadingDiv.parentNode) {
                    document.body.removeChild(loadingDiv);
                }
                showNotification('Network error occurred. Please check your connection.', 'error');
            };
            
            try {
                xhr.send(requestData);
                console.log('Request sent successfully to DeleteSellerServlet');
            } catch (e) {
                console.error('Error sending request:', e);
                if (loadingDiv.parentNode) {
                    document.body.removeChild(loadingDiv);
                }
                showNotification('Error sending request. Please try again.', 'error');
            }
        }

        // Delete Seller function (for dropdown)
        function deleteSeller(sellerId) {
            console.log('deleteSeller called with sellerId:', sellerId);
            
            // Close dropdown
            const dropdown = document.getElementById('dropdown' + sellerId);
            if (dropdown) {
                dropdown.style.display = 'none';
                dropdown.classList.remove('show');
            }
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to delete this seller? This action cannot be undone.')) {
                return;
            }
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting seller...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to delete servlet
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'DeleteSellerServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                console.log('Delete XHR state changed:', xhr.readyState, 'status:', xhr.status);
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Delete response text:', xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Remove the seller row from table
                                const sellerRow = document.querySelector('tr[data-status][data-name] td:first-child');
                                if (sellerRow && sellerRow.textContent.includes(sellerId)) {
                                    sellerRow.closest('tr').remove();
                                }
                                
                                // Success message displays on same page - no reload needed



                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing delete response:', e);
                            showNotification('Error deleting seller. Please try again.', 'error');
                        }
                    } else {
                        console.error('Delete request failed with status:', xhr.status);
                        showNotification('Error deleting seller. Please try again.', 'error');
                    }
                }
            };
            
            xhr.send('sellerId=' + encodeURIComponent(sellerId) + '&action=delete');
        }

        // Show notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 500; z-index: 10000; animation: slideIn 0.3s ease; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #4CAF50, #45a049)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #f44336, #d32f2f)';
            }
            
            notification.textContent = message;
            document.body.appendChild(notification);
            
            // Auto-remove after 5 seconds
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 5000);
        }

        // Show Approved Success function
        function showApprovedSuccess(sellerId) {
            showNotification('Seller ' + sellerId + ' has been approved successfully!', 'success');
        }

        // Update Seller Status function - connects Actions to Status column
        function updateSellerStatus(sellerId, newStatus) {
            console.log('updateSellerStatus called with sellerId:', sellerId, 'newStatus:', newStatus);
            
            // Close dropdown
            const dropdown = document.getElementById('dropdown' + sellerId);
            if (dropdown) {
                dropdown.style.display = 'none';
                dropdown.classList.remove('show');
            }
            
            // Get the status badge element
            const statusBadge = document.getElementById('status-' + sellerId);
            if (!statusBadge) {
                console.error('Status badge not found for seller:', sellerId);
                showNotification('Status badge not found', 'error');
                return;
            }
            
            // Update status badge based on new status
            let statusText = '';
            let statusClass = '';
            
            switch(newStatus) {
                case 'approved':
                    statusText = 'Approved';
                    statusClass = 'status-approved';
                    break;
                case 'rejected':
                    statusText = 'Rejected';
                    statusClass = 'status-rejected';
                    break;
                case 'pending':
                    statusText = 'Pending';
                    statusClass = 'status-pending';
                    break;
                case 'moved_to_products':
                    statusText = 'Moved to Products';
                    statusClass = 'status-approved';
                    break;
                default:
                    statusText = 'Unknown';
                    statusClass = 'status-pending';
            }
            
            // Update the badge
            statusBadge.textContent = statusText;
            statusBadge.className = 'status-badge ' + statusClass;
            
            // Show success notification
            showNotification(`Seller ${sellerId} status updated to ${statusText}`, 'success');
            
            // Update statistics (optional - would need backend integration)
            updateStatistics();
            
            // In a real application, you would also send this to the server
            // For now, we'll just update the UI
            console.log('Status updated locally for seller:', sellerId, 'to:', newStatus);
            console.log('sellerId type:', typeof sellerId);
            console.log('sellerId length:', sellerId ? sellerId.length : 'null/undefined');
            
            // Check if sellerId is valid
            if (!sellerId || sellerId.trim() === '') {
                console.error('ERROR: sellerId is null or empty');
                return;
            }
        }

        // Enhanced Accept Product function with Showproducts.jsp integration
        function acceptProductWithShowproducts(sellerId) {
            console.log('acceptProductWithShowproducts called with sellerId:', sellerId);
            console.log('sellerId type:', typeof sellerId);
            console.log('sellerId length:', sellerId ? sellerId.length : 'null/undefined');
            
            // Check if sellerId is valid
            if (!sellerId || sellerId.trim() === '') {
                console.error('ERROR: sellerId is null or empty');
                alert('Error: Seller ID is missing. Please try again.');
                return;
            }
            
            // Close dropdown
            const dropdown = document.getElementById('dropdown' + sellerId);
            if (dropdown) {
                dropdown.style.display = 'none';
                dropdown.classList.remove('show');
            }
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to accept this product? It will be displayed in Showproducts.jsp')) {
                console.log('User cancelled the action');
                return;
            }
            
            console.log('User confirmed - proceeding with acceptance');
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Moving product to Showproducts.jsp...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to the servlet
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'AcceptProductToProductsServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                console.log('XHR state changed:', xhr.readyState, 'status:', xhr.status);
                
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Response status:', xhr.status);
                    console.log('Response text:', xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Parsed response:', response);
                            
                            if (response.success) {
                                // Update status to "Moved to Products"
                                updateSellerStatus(sellerId, 'moved_to_product');
                                
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Offer to view the product in Showproducts.jsp
                                setTimeout(() => {
                                    if (confirm('Product successfully added! Would you like to view it in Showproducts.jsp?')) {
                                        console.log('Opening Showproducts.jsp');
                                        window.open('Showproducts.jsp', '_blank');
                                    }
                                }, 1000);
                                
                            } else {
                                console.error('Accept failed:', response.message);
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing accept response:', e);
                            console.error('Raw response:', xhr.responseText);
                            showNotification('Error parsing server response. Please try again.', 'error');
                        }
                    } else {
                        console.error('Accept request failed with status:', xhr.status);
                        showNotification('Server error: ' + xhr.status + '. Please try again.', 'error');
                    }
                }
            };
            
            const requestData = 'sellerId=' + encodeURIComponent(sellerId);
            console.log('Sending request data to AcceptProductToProductsServlet:', requestData);
            
            xhr.send(requestData);
            console.log('Request sent to AcceptProductToProductsServlet');
        }

        // Accept Product function

        function acceptProduct(sellerId) {
            console.log('acceptProduct called with sellerId:', sellerId);
            showApprovedSuccess('DEBUG: Accept Product called for seller ID: ' + sellerId);
            
            // Close dropdown
            const dropdown = document.getElementById('dropdown' + sellerId);
            if (dropdown) {
                dropdown.style.display = 'none';
                dropdown.classList.remove('show');
            }
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to accept this product? It will be displayed in Showproducts.jsp')) {
                return;
            }
            
            showApprovedSuccess('DEBUG: User confirmed. Sending AJAX request...');
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Accepting product...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to AcceptProductServlet
            const xhr = new XMLHttpRequest();
            const servletPath = window.workingServletPath || 'AcceptProductServlet';
            console.log('Using servlet path:', servletPath);
            showApprovedSuccess('DEBUG: Using servlet path: ' + servletPath);
            
            xhr.open('POST', servletPath, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                console.log('XHR state changed:', xhr.readyState, 'status:', xhr.status);
                showApprovedSuccess('DEBUG: XHR state: ' + xhr.readyState + ', status: ' + xhr.status);
                
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Response status:', xhr.status);
                    console.log('Response text:', xhr.responseText);
                    showApprovedSuccess('DEBUG: Response status: ' + xhr.status + '\nResponse text: ' + xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Parsed response:', response);
                            showApprovedSuccess('DEBUG: Parsed response: ' + JSON.stringify(response));
                            
                            if (response.success) {
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Success message displays on same page - no reload needed



                            } else {
                                console.error('Accept failed:', response.message);
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing accept response:', e);
                            console.error('Raw response:', xhr.responseText);
                            showNotification('Error parsing server response. Please try again.', 'error');
                        }
                    } else {
                        console.error('Accept request failed with status:', xhr.status);
                        showNotification('Server error: ' + xhr.status + '. Please try again.', 'error');
                    }
                }
            };
            
            const requestData = 'sellerId=' + encodeURIComponent(sellerId) + '&action=accept';
            console.log('Sending request data to AcceptProductServlet:', requestData);
            showApprovedSuccess('DEBUG: Sending data: ' + requestData);
            
            xhr.send(requestData);
            console.log('Request sent to AcceptProductServlet');
        }

        // Test function for AcceptProductToProducts.jsp
        function testAcceptProductJSP() {
            console.log('Testing AcceptProductToProducts.jsp...');
            const sellerId = prompt('Enter seller ID to test:', '1');
            if (sellerId) {
                const loadingDiv = document.createElement('div');
                loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
                loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Testing JSP...';
                document.body.appendChild(loadingDiv);
                
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'AcceptProductToProducts.jsp', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        if (loadingDiv.parentNode) {
                            document.body.removeChild(loadingDiv);
                        }
                        
                        console.log('Test Response Status:', xhr.status);
                        console.log('Test Response Text:', xhr.responseText);
                        
                        if (xhr.status === 200) {
                            try {
                                const response = JSON.parse(xhr.responseText);
                                alert('Test Result:\nSuccess: ' + response.success + '\nMessage: ' + response.message);
                            } catch (e) {
                                alert('Test Result:\nRaw Response: ' + xhr.responseText);
                            }
                        } else {
                            alert('Test Failed with status: ' + xhr.status);
                        }
                    }
                };
                
                xhr.send('sellerId=' + encodeURIComponent(sellerId));
            }
        }

        // Simple test function for debugging
        function testAcceptProduct() {
            console.log('Testing acceptProductWithShowproducts function...');
            const sellerId = prompt('Enter seller ID to test:', '1');
            if (sellerId) {
                acceptProductWithShowproducts(sellerId);
            }
        }

        // Test function for Accept Product
        function testAcceptProductFunction() {
            console.log('Testing acceptProduct function...');
            const sellerId = prompt('Enter seller ID to test:', '1');
            if (sellerId) {
                acceptProduct(sellerId);
            }
        }

        
        // Show notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: bold; z-index: 10000; max-width: 300px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else if (type === 'error') {
                notification.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #ffc107, #e0a800)';
                notification.style.color = '#212529';
            }
            
            notification.innerHTML = '<i class="fas fa-' + (type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle') + '"></i> ' + message;
            document.body.appendChild(notification);
            
            // Auto remove after 3 seconds
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 3000);
        }

        // Filter sellers - Updated for table layout
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

        // Filter by individual status from Actions dropdown
        function filterByStatus(sellerId) {
            const statusFilter = document.getElementById('statusFilter' + sellerId).value;
            const rows = document.querySelectorAll('#sellersTableBody tr');
            
            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                const rowSellerId = row.querySelector('td:first-child').textContent;
                
                // If filtering for a specific seller, only show that seller
                const matchesSeller = !statusFilter || rowSellerId === sellerId;
                const matchesStatus = !statusFilter || status === statusFilter;
                
                row.style.display = matchesSeller && matchesStatus ? '' : 'none';
            });
            
            // Show alert for feedback
            if (statusFilter) {
                showApprovedSuccess('Filtering seller ' + sellerId + ' by status: ' + statusFilter);
            } else {
                showApprovedSuccess('Showing all sellers');
            }
        }

        // Filter by product status
        function filterByProductStatus(productStatus) {
            const rows = document.querySelectorAll('#sellersTableBody tr');
            
            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                let shouldShow = false;
                
                switch(productStatus) {
                    case 'approved':
                        shouldShow = status === 'approved' || status === 'moved_to_products';
                        break;
                    case 'pending':
                        shouldShow = status === 'pending';
                        break;
                    case 'rejected':
                        shouldShow = status === 'rejected';
                        break;
                }
                
                row.style.display = shouldShow ? '' : 'none';
            });
            
            // Update the main status filter to match
            document.getElementById('statusFilter').value = productStatus === 'approved' && rows.length > 0 ? 
                (Array.from(rows).some(row => row.getAttribute('data-status') === 'moved_to_products') ? 'moved_to_products' : 'approved') : 
                productStatus;
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

        // Update statistics function
        function updateStatistics() {
            console.log('Updating statistics...');
            // In a real application, this would fetch fresh data from the server
            // For now, we'll just update the display with existing values
            const totalSellers = document.querySelectorAll('#sellersTableBody tr').length;
            document.getElementById('totalSellers').textContent = totalSellers;
            console.log('Statistics updated - Total sellers:', totalSellers);
        }

        // Simple test function for debugging
        function testAcceptProductFunction() {
            console.log('Testing acceptProductWithShowproducts function...');
            const sellerId = prompt('Enter seller ID to test:', '1');
            if (sellerId) {
                acceptProductWithShowproducts(sellerId);
            }
        }

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