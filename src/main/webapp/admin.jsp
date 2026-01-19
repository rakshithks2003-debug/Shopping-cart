es<%@ page language="java" contentType="text/html; charset=UTF-8"
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

String username = (String) session.getAttribute("username");
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
    
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 20px;
    }
    
    .container {
        max-width: 800px;
        margin: 0 auto;
    }
    
    header {
        text-align: center;
        margin-bottom: 40px;
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
        margin-bottom: 30px;
    }
    
    .admin-options {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 40px;
    }
    
    .admin-card {
        background: white;
        padding: 30px;
        border-radius: 15px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        text-align: center;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    .admin-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 35px rgba(0,0,0,0.15);
    }
    
    .admin-card h3 {
        color: #333;
        margin-bottom: 15px;
        font-size: 1.3rem;
    }
    
    .admin-card p {
        color: #666;
        margin-bottom: 20px;
        font-size: 0.95rem;
    }
    
    .admin-btn {
        display: inline-block;
        background: #4CAF50;
        color: white;
        padding: 12px 24px;
        text-decoration: none;
        border-radius: 25px;
        transition: all 0.3s ease;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        font-weight: 600;
    }
    
    .admin-btn:hover {
        background: #45a049;
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    }
    
    .update-btn {
        background: #2196F3;
    }
    
    .update-btn:hover {
        background: #1976D2;
    }
    
    .back-link {
        text-align: center;
        margin-top: 30px;
    }
    
    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1.1rem;
        padding: 12px 24px;
        border-radius: 25px;
        background: rgba(255,255,255,0.1);
        transition: all 0.3s ease;
        display: inline-block;
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
    }
    
    .update-section {
        background: white;
        padding: 40px;
        border-radius: 15px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        margin-bottom: 30px;
    }
    
    .form-group {
        margin-bottom: 20px;
    }
    
    label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        font-size: 1rem;
    }
    
    input[type="text"],
    input[type="number"],
    select,
    textarea {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 1rem;
        transition: border-color 0.3s ease;
        background: #f8f9fa;
    }
    
    input[type="text"]:focus,
    input[type="number"]:focus,
    select:focus,
    textarea:focus {
        outline: none;
        border-color: #2196F3;
        background: white;
    }
    
    .submit-btn {
        background: #2196F3;
        color: white;
        border: none;
        padding: 14px 28px;
        border-radius: 8px;
        font-size: 1.1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .submit-btn:hover {
        background: #1976D2;
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    }
    
    .products-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
    }
    
    .products-table th,
    .products-table td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }
    
    .products-table th {
        background: #f8f9fa;
        font-weight: 600;
        color: #333;
    }
    
    .products-table tr:hover {
        background: #f8f9fa;
    }
    
    .select-btn {
        background: #2196F3;
        color: white;
        border: none;
        padding: 6px 12px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.9rem;
    }
    
    .select-btn:hover {
        background: #1976D2;
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🔧 Admin Panel</h1>
            <p class="subtitle">Welcome, <%= username != null ? username : "Admin" %>! Manage your shopping cart inventory</p>
            <div style="text-align: center; margin-bottom: 20px;">
                <a href="LogoutServlet" class="admin-btn" style="background: #f44336; text-decoration: none; padding: 10px 20px; border-radius: 5px; color: white;">🚪 Logout</a>
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
            
            <div class="form-group">
                <label for="categoryFilter">Filter by Category:</label>
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
            
            <div class="form-group">
                <label for="productSelect">Select Product to Update:</label>
                <select id="productSelect" onchange="loadProductDetails()">
                    <option value="">-- Choose a product --</option>
<%
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, name, price, description, category_id FROM product ORDER BY name");
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
            
            <form id="updateForm" action="UpdateServlet" method="post" enctype="multipart/form-data" style="display: none;">
                <input type="hidden" id="originalId" name="originalId">
                
                <div class="form-group">
                    <label for="updateId">Product ID:</label>
                    <input type="text" id="updateId" name="id" pattern="[A-Za-z0-9]+" title="Only alphabetic characters allowed" required>
                </div>
                
                <div class="form-group">
                    <label for="updateName">Product Name:</label>
                    <input type="text" id="updateName" name="name" required>
                </div>
                
                <div class="form-group">
                    <label for="updatePrice">Price (₹):</label>
                    <input type="number" id="updatePrice" name="price" step="0.01" min="0" required>
                </div>
                
                <div class="form-group">
                    <label for="updateDescription">Description:</label>
                    <textarea id="updateDescription" name="description" rows="4"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="updateImage">Product Image (leave empty to keep current):</label>
                    <input type="file" id="updateImage" name="image" accept="image/*">
                    <small style="color: #666;">Current image will be kept if no new image is selected</small>
                </div>
                
                <button type="submit" class="submit-btn">🔄 Update Product</button>
            </form>
        </div>
        
        <div class="back-link">
            <a href="Showproducts.jsp">← Back to Products</a>
        </div>
    </div>
    
    <script>
        function filterProducts() {
            const categoryFilter = document.getElementById('categoryFilter').value;
            const productSelect = document.getElementById('productSelect');
            const options = productSelect.getElementsByTagName('option');
            
            // Reset product selection when category changes
            productSelect.value = '';
            document.getElementById('updateForm').style.display = 'none';
            
            for (let i = 1; i < options.length; i++) { // Skip first option (placeholder)
                const option = options[i];
                const optionCategory = option.getAttribute('data-category');
                
                if (categoryFilter === '' || optionCategory === categoryFilter) {
                    option.style.display = 'block';
                } else {
                    option.style.display = 'none';
                }
            }
        }
        
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
