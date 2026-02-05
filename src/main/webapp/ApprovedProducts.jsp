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

// Check if user has admin role
String userRole = (String) sessionObj.getAttribute("userRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect("users.html");
    return;
}

String username = (String) sessionObj.getAttribute("username");

// Load approved products from Sproduct table
java.util.List<java.util.Map<String, Object>> approvedProducts = new java.util.ArrayList<>();
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    if (con != null && !con.isClosed()) {
        String productSql = "SELECT id, brand, price, description, image, Category, product_name " +
                           "FROM Sproduct ORDER BY id DESC";
        
        PreparedStatement productStmt = con.prepareStatement(productSql);
        ResultSet productRs = productStmt.executeQuery();
        
        while (productRs.next()) {
            java.util.Map<String, Object> product = new java.util.HashMap<>();
            product.put("id", productRs.getString("id"));
            product.put("brand", productRs.getString("brand"));
            product.put("price", productRs.getDouble("price"));
            product.put("description", productRs.getString("description"));
            product.put("image", productRs.getString("image"));
            product.put("category", productRs.getString("Category"));
            product.put("productName", productRs.getString("product_name"));
            approvedProducts.add(product);
        }
        
        productRs.close();
        productStmt.close();
        con.close();
    }
} catch (Exception e) {
    e.printStackTrace();
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Approved Products - Mini Shopping Cart</title>
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

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Inter', sans-serif;
        background: var(--bg);
        color: var(--text-main);
        line-height: 1.6;
    }

    .container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
    }

    .header {
        background: linear-gradient(135deg, var(--primary), var(--primary-hover));
        color: white;
        padding: 2rem 0;
        margin-bottom: 2rem;
        border-radius: 12px;
        text-align: center;
    }

    .header h1 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
    }

    .header p {
        font-size: 1.1rem;
        opacity: 0.9;
    }

    .back-button {
        position: fixed;
        top: 20px;
        left: 20px;
        background: var(--primary);
        color: white;
        padding: 10px 20px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.3s ease;
        z-index: 1000;
    }

    .back-button:hover {
        background: var(--primary-hover);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 1.5rem;
        margin-bottom: 2rem;
    }

    .stat-card {
        background: var(--card-bg);
        padding: 1.5rem;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        text-align: center;
        transition: transform 0.3s ease;
    }

    .stat-card:hover {
        transform: translateY(-4px);
    }

    .stat-number {
        font-size: 2.5rem;
        font-weight: 700;
        color: var(--primary);
        margin-bottom: 0.5rem;
    }

    .stat-label {
        color: var(--text-muted);
        font-weight: 600;
    }

    .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 2rem;
        margin-top: 2rem;
    }

    .product-card {
        background: var(--card-bg);
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
    }

    .product-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    }

    .product-image {
        width: 100%;
        height: 200px;
        object-fit: cover;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 3rem;
    }

    .product-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .product-details {
        padding: 1.5rem;
    }

    .product-id {
        background: var(--primary);
        color: white;
        padding: 0.25rem 0.75rem;
        border-radius: 20px;
        font-size: 0.875rem;
        font-weight: 600;
        display: inline-block;
        margin-bottom: 0.75rem;
    }

    .product-name {
        font-size: 1.25rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
        color: var(--text-main);
    }

    .product-brand {
        color: var(--text-muted);
        font-size: 0.875rem;
        margin-bottom: 0.75rem;
    }

    .product-category {
        background: var(--bg);
        color: var(--text-muted);
        padding: 0.25rem 0.75rem;
        border-radius: 6px;
        font-size: 0.875rem;
        display: inline-block;
        margin-bottom: 0.75rem;
    }

    .product-price {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--success);
        margin-bottom: 0.75rem;
    }

    .product-description {
        color: var(--text-muted);
        font-size: 0.875rem;
        line-height: 1.5;
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .btn-approve, .btn-details {
        padding: 8px 16px;
        border: none;
        border-radius: 6px;
        font-size: 0.875rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }

    .btn-approve {
        background: var(--success);
        color: white;
    }

    .btn-approve:hover {
        background: #16a34a;
        transform: translateY(-2px);
    }

    .btn-details {
        background: var(--primary);
        color: white;
    }

    .btn-details:hover {
        background: var(--primary-hover);
        transform: translateY(-2px);
    }

    .no-products {
        text-align: center;
        padding: 4rem 2rem;
        background: var(--card-bg);
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .no-products i {
        font-size: 4rem;
        color: var(--text-muted);
        margin-bottom: 1rem;
    }

    .no-products h3 {
        font-size: 1.5rem;
        margin-bottom: 0.5rem;
        color: var(--text-main);
    }

    .no-products p {
        color: var(--text-muted);
        margin-bottom: 1.5rem;
    }

    @media (max-width: 768px) {
        .container {
            padding: 10px;
        }
        
        .header h1 {
            font-size: 2rem;
        }
        
        .products-grid {
            grid-template-columns: 1fr;
            gap: 1rem;
        }
        
        .back-button {
            position: relative;
            top: auto;
            left: auto;
            margin-bottom: 1rem;
            display: inline-block;
        }
    }
</style>
</head>
<body>
    <a href="Dashboard.jsp" class="back-button">
        <i class="fas fa-arrow-left"></i> Back to Dashboard
    </a>

    <div class="container">
        <div class="header">
            <h1><i class="fas fa-check-circle"></i> Approved Products</h1>
            <p>View all approved products from Sproduct table</p>
        </div>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number"><%= approvedProducts.size() %></div>
                <div class="stat-label">Total Approved Products</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">
                    <%= approvedProducts.stream().mapToDouble(p -> (Double)p.get("price")).sum() %>
                </div>
                <div class="stat-label">Total Value</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">
                    <%= approvedProducts.isEmpty() ? 0 : 
                       approvedProducts.stream().mapToDouble(p -> (Double)p.get("price")).average().orElse(0) %>
                </div>
                <div class="stat-label">Average Price</div>
            </div>
        </div>

        <!-- Products Grid -->
        <% if (approvedProducts.isEmpty()) { %>
            <div class="no-products">
                <i class="fas fa-box-open"></i>
                <h3>No Approved Products Found</h3>
                <p>There are no approved products in the Sproduct table yet.</p>
                <a href="Seller.jsp" style="display: inline-block; padding: 12px 24px; background: var(--primary); color: white; text-decoration: none; border-radius: 8px; font-weight: 600;">
                    <i class="fas fa-plus"></i> Approve Products
                </a>
            </div>
        <% } else { %>
            <div class="products-grid">
                <% for (java.util.Map<String, Object> product : approvedProducts) { %>
                    <div class="product-card">
                        <div class="product-image">
                            <% 
                            String image = (String) product.get("image");
                            if (image != null && !image.isEmpty() && !image.equals("default.jpg")) {
                                String[] imageArray = image.split(",");
                                if (imageArray.length > 0) { %>
                                    <img src="product_images/<%= imageArray[0] %>" alt="<%= product.get("productName") %>">
                            <% } else { %>
                                <i class="fas fa-image"></i>
                            <% } 
                            } else { %>
                                <i class="fas fa-image"></i>
                            <% } %>
                        </div>
                        <div class="product-details">
                            <div class="product-id">ID: <%= product.get("id") %></div>
                            <div class="product-name"><%= product.get("productName") %></div>
                            <div class="product-brand"><i class="fas fa-tag"></i> <%= product.get("brand") %></div>
                            <div class="product-category"><i class="fas fa-folder"></i> <%= product.get("category") %></div>
                            <div class="product-price">₹<%= String.format("%.2f", (Double)product.get("price")) %></div>
                            <div class="product-description">
                                <%= ((String)product.get("description")).length() > 100 ? 
                                   ((String)product.get("description")).substring(0, 100) + "..." : 
                                   product.get("description") %>
                            </div>
                            <div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
                                <button onclick="approveProduct('<%= product.get("id") %>')" 
                                        class="btn-approve" title="Approve and move to main store">
                                    <i class="fas fa-check"></i> Approve
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
    
    <script>
        function approveProduct(productId) {
            // Find the product name from the card
            var productCard = event.target.closest('.product-card');
            var productName = productCard.querySelector('.product-name').textContent;
            
            if (confirm('Are you sure you want to approve "' + productName + '" and move it to the main store?')) {
                // Create AJAX request to approve product
                var xhr = new XMLHttpRequest();
                xhr.open('POST', 'ApproveSproductServlet', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        if (xhr.status === 200) {
                            try {
                                var response = JSON.parse(xhr.responseText);
                                if (response.success) {
                                    alert('Product approved successfully! It has been moved to the main store with ID: ' + response.message.split(': ')[1]);
                                    location.reload(); // Refresh the page to show updated list
                                } else {
                                    alert('Error approving product: ' + response.message);
                                }
                            } catch (e) {
                                alert('Error processing response. Please try again.');
                            }
                        } else {
                            alert('Error communicating with server. Please try again.');
                        }
                    }
                };
                
                xhr.send('productId=' + encodeURIComponent(productId) + '&productName=' + encodeURIComponent(productName));
            }
        }
    </script>
</body>
</html>
