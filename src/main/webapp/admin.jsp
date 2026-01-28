<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in
HttpSession sessionObg = request.getSession(false);
if (session == null || session.getAttribute("isLoggedIn") == null || 
    !(Boolean) session.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}

// Check if user has admin role
String userRole = (String) session.getAttribute("userRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect("users.html");
    return;
}
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);

String username = (String) session.getAttribute("username");

// Get sorting parameters
String sortBy = request.getParameter("sortBy");
String sortOrder = request.getParameter("sortOrder");

// Set defaults
if (sortBy == null) sortBy = "name";
if (sortOrder == null) sortOrder = "ASC";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Panel - Mini Shopping cart</title>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    .back-button {
        position: fixed;
        top: 20px;
        left: 20px;
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        padding: 10px 20px;
        border-radius: 25px;
        text-decoration: none;
        font-weight: 600;
        font-size: 14px;
        box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
        transition: all 0.3s ease;
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 5px;
    }
    
    .back-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
        background: linear-gradient(135deg, #45a049, #3d8b40);
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
    
    header {
        text-align: center;
        margin-bottom: 30px;
        color: white;
    }
    
    h1 {
        font-size: 2.5rem;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .subtitle {
        font-size: 1.1rem;
        opacity: 0.9;
        margin-bottom: 20px;
    }
    
    .admin-options {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .admin-card {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        padding: 30px;
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.3);
        text-align: center;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
        overflow: hidden;
    }
    
    .admin-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 4px;
        height: 100%;
        background: linear-gradient(135deg, #667eea, #764ba2);
        transition: width 0.3s ease;
    }
    
    .admin-card:hover::before {
        width: 6px;
    }
    
    .admin-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 40px rgba(0,0,0,0.15);
    }
    
    .admin-card h3 {
        color: #333;
        margin-bottom: 15px;
        font-size: 1.3rem;
        font-weight: 600;
    }
    
    .admin-card p {
        color: #666;
        margin-bottom: 20px;
        font-size: 0.95rem;
        line-height: 1.5;
    }
    
    .admin-btn {
        display: inline-block;
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        padding: 12px 24px;
        text-decoration: none;
        border-radius: 25px;
        transition: all 0.3s ease;
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
        font-weight: 600;
        position: relative;
        overflow: hidden;
    }
    
    .admin-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }
    
    .admin-btn:hover::before {
        left: 100%;
    }
    
    .admin-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(76, 175, 80, 0.4);
    }
    
    .update-btn {
        background: linear-gradient(135deg, #2196F3, #1976D2);
    }
    
    .update-btn:hover {
        box-shadow: 0 10px 30px rgba(33, 150, 243, 0.4);
    }
    
    .back-link {
        text-align: center;
        margin-top: 20px;
    }
    
    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1rem;
        padding: 12px 25px;
        border-radius: 25px;
        background: rgba(255,255,255,0.1);
        backdrop-filter: blur(10px);
        transition: all 0.3s ease;
        display: inline-block;
        border: 1px solid rgba(255,255,255,0.2);
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
    }
    
    .update-section {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 40px;
        margin-bottom: 30px;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }
    
    /* Sorting Controls */
    .sorting-controls {
        display: flex;
        justify-content: center;
        gap: 15px;
        margin-bottom: 30px;
        flex-wrap: wrap;
    }
    
    .sort-dropdown {
        padding: 10px 15px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-radius: 10px;
        background: rgba(255, 255, 255, 0.1);
        color: white;
        font-size: 1rem;
        cursor: pointer;
        transition: all 0.3s ease;
        min-width: 180px;
        backdrop-filter: blur(5px);
    }
    
    .sort-dropdown:hover {
        border-color: rgba(255, 255, 255, 0.5);
        background: rgba(255, 255, 255, 0.2);
    }
    
    .sort-dropdown:focus {
        outline: none;
        border-color: rgba(255, 255, 255, 0.7);
        box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
    }
    
    .sort-dropdown option {
        background: #333;
        color: white;
    }
    
    .sort-btn {
        padding: 10px 15px;
        background: rgba(255, 255, 255, 0.1);
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-radius: 10px;
        color: white;
        cursor: pointer;
        font-size: 1rem;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        backdrop-filter: blur(5px);
    }
    
    .sort-btn:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: translateY(-2px);
    }
    
    .sort-btn.active {
        background: rgba(255, 255, 255, 0.4);
        border-color: rgba(255, 255, 255, 0.6);
    }
    
    .products-section {
        backdrop-filter: blur(20px);
        padding: 30px;
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.3);
        margin-bottom: 30px;
        max-height: calc(100vh - 300px);
        overflow-y: auto;
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }
    
    .form-field {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        padding: 20px;
        border-radius: 12px;
        border: 1px solid rgba(33, 150, 243, 0.1);
        transition: all 0.3s ease;
        position: relative;
    }
    
    .form-field::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 3px;
        height: 100%;
        background: linear-gradient(135deg, #2196F3, #1976D2);
        transition: width 0.3s ease;
    }
    
    .form-field:hover::before {
        width: 5px;
    }
    
    .form-field:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(33, 150, 243, 0.15);
        border-color: rgba(33, 150, 243, 0.3);
    }
    
    .form-field-full {
        grid-column: 1 / -1;
    }
    
    .field-header {
        font-size: 0.85rem;
        font-weight: 600;
        color: #2196F3;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .field-icon {
        font-size: 1.1rem;
    }
    
    .form-group {
        margin-bottom: 0;
    }
    
    label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 6px;
        font-size: 0.9rem;
    }
    
    input[type="text"],
    input[type="number"],
    input[type="file"],
    select,
    textarea {
        width: 100%;
        padding: 10px 14px;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: white;
        font-family: inherit;
    }
    
    input[type="text"]:focus,
    input[type="number"]:focus,
    input[type="file"]:focus,
    select:focus,
    textarea:focus {
        outline: none;
        border-color: #2196F3;
        box-shadow: 0 0 0 3px rgba(33, 150, 243, 0.1);
        transform: translateY(-1px);
    }
    
    textarea {
        resize: vertical;
        min-height: 80px;
    }
    
    .submit-btn {
        background: linear-gradient(135deg, #2196F3, #1976D2);
        color: white;
        border: none;
        padding: 15px 30px;
        border-radius: 12px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
        box-shadow: 0 6px 20px rgba(33, 150, 243, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .submit-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }
    
    .submit-btn:hover::before {
        left: 100%;
    }
    
    .submit-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(33, 150, 243, 0.4);
    }
    
    @media (max-width: 768px) {
        .admin-options {
            grid-template-columns: 1fr;
            gap: 15px;
        }
        
        .form-grid {
            grid-template-columns: 1fr;
            gap: 15px;
        }
        
        .admin-card,
        .update-section {
            padding: 20px;
        }
        
        .update-section {
            max-height: none;
        }
        
        h1 {
            font-size: 2rem;
        }
    }
    
    @media (max-width: 480px) {
        .container {
            padding: 10px;
        }
        
        .admin-card,
        .update-section {
            padding: 15px;
        }
        
        h1 {
            font-size: 1.5rem;
        }
    }
</style>
</head>
<body>
    <a href="Dashboard.jsp" class="back-button">← Back to Dashboard</a>
    
    <div class="container">
        <header>
            <h1>🔧  Add & Update Products</h1>
            <p class="subtitle">Welcome, <%= username != null ? username : "Admin" %>! Manage your shopping cart inventory</p>
            <div style="text-align: center; margin-bottom: 20px;">
                
            </div>
        </header>
        
        <div class="admin-options">
            <div class="admin-card">
                <h3>➕ Add Products</h3>
                <p>Add new items to your product catalog</p>
                <a href="Addproducts.jsp" class="admin-btn">Add Products</a>
            </div>
            
            <div class="admin-card">
                <h3>🔄 Update Items</h3>
                <p>Modify existing product details</p>
                <a href="#update-section" class="admin-btn update-btn">Update Items</a>
            </div>
        </div>
        
        <div id="update-section" class="update-section">
            <h2 style="color: #2196F3; margin-bottom: 20px;">🔄 Update Product Items</h2>
            
            <!-- Sorting Controls -->
            <div class="sorting-controls">
                <select class="sort-dropdown" onchange="window.location.href='admin.jsp#update-section?sortBy=' + this.value + '&sortOrder=<%= sortOrder %>'">
                    <option value="name" <%= "name".equals(sortBy) ? "selected" : "" %>>Sort by Name</option>
                    <option value="id" <%= "id".equals(sortBy) ? "selected" : "" %>>Sort by ID</option>
                    <option value="price" <%= "price".equals(sortBy) ? "selected" : "" %>>Sort by Price</option>
                    <option value="category_id" <%= "category_id".equals(sortBy) ? "selected" : "" %>>Sort by Category</option>
                </select>
                <a href="admin.jsp#update-section?sortBy=<%= sortBy %>&sortOrder=ASC" class="sort-btn <%= "ASC".equals(sortOrder) ? "active" : "" %>">
                    <i class="fas fa-sort-alpha-down"></i> Asc
                </a>
                <a href="admin.jsp#update-section?sortBy=<%= sortBy %>&sortOrder=DESC" class="sort-btn <%= "DESC".equals(sortOrder) ? "active" : "" %>">
                    <i class="fas fa-sort-alpha-down-alt"></i> Desc
                </a>
            </div>
            
            <div class="form-grid">
                <div class="form-field">
                    <div class="field-header">
                        <span class="field-icon">📂</span>
                        Filter by Category
                    </div>
                    <div class="form-group">
                        <select id="categoryFilter" onchange="filterProducts()">
                            <option value="">All Categories</option>
                            <option value="Mo">📱 Mobile</option>
                            <option value="Ms">👞 Men Shoe</option>
                            <option value="Lp">💻 Laptop</option>
                            <option value="Wt">⌚ Watch</option>
                            <option value="Hp">🎧 Headphones</option>
                            <option value="Ca">📷 Camera</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-field">
                    <div class="field-header">
                        <span class="field-icon">📦</span>
                        Select Product
                    </div>
                    <div class="form-group">
                        <select id="productSelect" onchange="loadProductDetails()">
                            <option value="">-- Choose a product --</option>
<%
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, name, price, description, category_id FROM product ORDER BY " + sortBy + " " + sortOrder);
    ResultSet rs = ps.executeQuery();
    
    while(rs.next()) {
%>
                            <option value="<%=rs.getString("id")%>" data-category="<%=rs.getString("category_id")%>"><%=rs.getString("name")%> (ID: <%=rs.getString("id")%>)</option>
<%
    }
    
    rs.close();
    ps.close();
    con.close();
    
} catch (Exception e) {
%>
                            <option value="">Error loading products</option>
<%
}
%>
                        </select>
                    </div>
                </div>
            </div>
            
            <form id="updateForm" action="UpdateServlet" method="post" enctype="multipart/form-data" style="display: none;">
                <input type="hidden" id="originalId" name="originalId">
                
                <div class="form-grid">
                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🆔</span>
                            Product ID
                        </div>
                        <div class="form-group">
                            <input type="text" id="updateId" name="id" pattern="[A-Za-z0-9]+" title="Only alphabetic characters allowed" required>
                        </div>
                    </div>
                    
                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">📝</span>
                            Product Name
                        </div>
                        <div class="form-group">
                            <input type="text" id="updateName" name="name" required>
                        </div>
                    </div>
                </div>
                
                <div class="form-grid">
                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">💰</span>
                            Price
                        </div>
                        <div class="form-group">
                            <input type="number" id="updatePrice" name="price" step="0.01" min="0" required>
                        </div>
                    </div>
                    
                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🖼️</span>
                            Product Image
                        </div>
                        <div class="form-group">
                            <input type="file" id="updateImage" name="image" accept="image/*">
                            <small style="color: #666; font-size: 0.8rem;">Current image will be kept if no new image is selected</small>
                        </div>
                    </div>
                </div>
                
                <div class="form-grid">
                    <div class="form-field form-field-full">
                        <div class="field-header">
                            <span class="field-icon">📄</span>
                            Description
                        </div>
                        <div class="form-group">
                            <textarea id="updateDescription" name="description" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                
                <button type="submit" class="submit-btn">🔄 Update Product</button>
            </form>
        </div>
        
        <div class="back-link">
            <a href="Showproducts.jsp">← Back to Products</a>
        </div>
    </div>
    
    <script>
        function loadProductDetails() {
            const select = document.getElementById('productSelect');
            const form = document.getElementById('updateForm');
            const selectedId = select.value;
            
            if (selectedId === '') {
                form.style.display = 'none';
                return;
            }
            
            // Show loading state
            form.style.display = 'block';
            document.getElementById('originalId').value = selectedId;
            
            // Load product details via AJAX or fetch
            fetch('GetProductDetails?id=' + selectedId)
                .then(response => response.json())
                .then(data => {
                    if (data) {
                        document.getElementById('updateId').value = data.id;
                        document.getElementById('updateName').value = data.name;
                        document.getElementById('updatePrice').value = data.price;
                        document.getElementById('updateDescription').value = data.description || '';
                    }
                })
                .catch(error => {
                    console.error('Error loading product details:', error);
                    // Fallback: populate with basic info
                    document.getElementById('updateId').value = selectedId;
                });
        }
        
        // Smooth scroll to update section
        document.querySelector('.update-btn').addEventListener('click', function(e) {
            e.preventDefault();
            document.getElementById('update-section').scrollIntoView({ behavior: 'smooth' });
        });
    </script>
</body>
</html>
