<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // Check if user is logged in
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
        !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
        response.sendRedirect("Login.html");
        return;
    }
    
    // Get restaurant parameter from request or session
    String restaurantId = request.getParameter("restaurant");
    
    // For restaurant users, get restaurantId from session
    String userRole = (String) sessionObj.getAttribute("userRole");
    if ("restaurant".equals(userRole)) {
        restaurantId = (String) sessionObj.getAttribute("restaurantId");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Items - YummyHub</title>
    <style>
        .back-btn {
            position: fixed;
            top: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            padding: 10px 20px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            z-index: 1000;
        }
        .back-btn:hover {
            background: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .reverse-btn {
            position: fixed;
            top: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.9);
            color: #ff6b6b;
            padding: 10px 20px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .reverse-btn:hover {
            background: white;
            color: #ff6b6b;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(255,107,107,0.4);
        }
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
        }
        
        .category-tabs {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        
        .category-tab {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            padding: 10px 20px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .category-tab:hover, .category-tab.active {
            background: white;
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .item-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .item-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }
        
        .item-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            background: #f0f0f0;
            display: block;
        }
        
        .item-info {
            padding: 20px;
        }
        
        .item-name {
            font-size: 1.3rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        .item-description {
            color: #555;
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 15px;
        }
        
        .item-price {
            font-size: 1.5rem;
            font-weight: bold;
            color: #ff6b6b;
            margin-bottom: 15px;
        }
        
        .item-price::before {
            content: "₹";
            margin-right: 2px;
        }
        
        .item-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        
        .update-btn {
            background: #ff9800;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .update-btn:hover {
            background: #f57c00;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 152, 0, 0.3);
        }
        
        .no-items {
            text-align: center;
            color: white;
            font-size: 1.2rem;
            margin: 60px 0;
        }
        
        .error-message {
            background: #f44336;
            color: white;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        
        .success-message {
            background: #4CAF50;
            color: white;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        
        .update-form-container {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            grid-column: 1 / -1;
        }
        
        .update-form-container h2 {
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: 600;
        }
        
        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e6ed;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 20px;
        }
        
        .btn-submit {
            background: #ff9800;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: background 0.3s ease;
        }
        
        .btn-submit:hover {
            background: #f57c00;
        }
        
        .btn-cancel {
            background: #6c757d;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: background 0.3s ease;
        }
        
        .btn-cancel:hover {
            background: #5a6268;
        }
        
        footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
   <%--  <div style="position: fixed; top: 10px; left: 10px; background: rgba(255,255,255,0.9); padding: 8px 12px; border-radius: 5px; font-size: 12px; color: #333; z-index: 1000; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
        Session ID: <%= session.getId() %>
    </div>--%>
    <a href="javascript:history.back()" class="reverse-btn" style="top: 60px; left: 20px;"><i class="fas fa-undo"></i> Back</a>
    <div class="container">
        <header>
            <h1>📝 Update product</h1>
            <p class="subtitle">Edit items in your Mini Shopping cart catalog</p>
        </header>
        
        <div class="filter-section" style="background: rgba(255,255,255,0.1); padding: 20px; border-radius: 15px; margin-bottom: 30px;">
            <div class="filter-group" style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
                <label style="color: white; font-weight: 600;">Search Items:</label>
                <input type="text" id="searchInput" placeholder="Search by name or description..." 
                       onkeyup="searchItems()" 
                       style="padding: 8px 15px; border-radius: 8px; border: none; background: white; color: #333; font-weight: 500; min-width: 250px;">
                
                <button type="button" onclick="clearSearch()" 
                        style="padding: 8px 15px; border-radius: 8px; border: none; background: #ff6b6b; color: white; font-weight: 500; cursor: pointer;">
                    Clear Search
                </button>
            </div>
        </div>
        
        <main>
            <div class="items-grid">
<%
    // Get item ID for updating
    String updateItemId = request.getParameter("updateId");
    
    // Check for update success message
    String updateMessage = request.getParameter("message");
    if (updateMessage != null && updateMessage.equals("success")) {
%>
                <div class="success-message" style="grid-column: 1 / -1;">
                    ✅ product updated successfully!
                </div>
<%
    }
    
    // If updateItemId is provided, show the update form
    if (updateItemId != null && !updateItemId.trim().isEmpty()) {
        try {
            Dbase db = new Dbase();
            Connection  con = db.initailizeDatabase();
            PreparedStatement ps = con.prepareStatement("SELECT id, pid, product_name, price, description, image FROM product WHERE id=?");
            ps.setString(1, updateItemId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
%>
                <div class="update-form-container">
                    <h2>📝 Update product</h2>
                    <form action="UpdateServlet" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="<%=rs.getString("id")%>">
                        <input type="hidden" name="restaurant" value="<%=restaurantId%>">
                        
                        <div class="form-group">
                            <label for="name">Product Name:</label>
                            <input type="text" id="name" name="name" value="<%=rs.getString("product_name")%>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="pid">PID:</label>
                            <input type="text" id="pid" name="pid" value="<%=rs.getString("pid")%>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="price">Price (₹):</label>
                            <input type="number" id="price" name="price" value="<%=rs.getDouble("price")%>" step="0.01" min="0" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="description">Description:</label>
                            <textarea id="description" name="description" rows="4"><%=rs.getString("description") != null ? rs.getString("description") : ""%></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="image">Update Images (up to 5 images):</label>
                            <input type="file" id="image" name="image" accept="image/*" multiple>
                            <small style="color: #666; font-size: 0.85rem; margin-top: 5px; display: block;">
                                Select up to 5 images. Leave empty to keep current images. Supported formats: JPG, PNG, GIF, WebP
                            </small>
<%
        String currentImage = rs.getString("image");
        if (currentImage != null && !currentImage.trim().isEmpty()) {
            String[] currentImages = currentImage.split(",");
%>
                            <div style="margin-top: 10px;">
                                <strong>Current Images:</strong><br>
<%
            for (int i = 0; i < currentImages.length && i < 5; i++) {
                String img = currentImages[i].trim();
                if (!img.isEmpty()) {
%>
                                <img src="product_images/<%=img%>" alt="Current image <%=i+1%>" style="max-width: 150px; max-height: 120px; border: 2px solid #e0e6ed; border-radius: 8px; margin: 5px;">
<%
                }
            }
%>
                            </div>
<%
        } else {
%>
                            <div style="margin-top: 10px; color: #666; font-size: 0.9rem;">
                                <em>No current images</em>
                            </div>
<%
        }
%>
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn-submit">💾 Update product</button>
                            <button type="button" class="btn-cancel" onclick="cancelUpdate()">❌ Cancel</button>
                        </div>
                    </form>
                </div>
<%
            }
            
            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
%>
                <div class="error-message" style="grid-column: 1 / -1;">
                    ⚠️ Error loading item for update: <%=e.getMessage()%>
                </div>
<%
        }
    }
    
try {
    Dbase db = new Dbase();
    Connection  con = db.initailizeDatabase();
    PreparedStatement ps;
    String query = "SELECT id, product_name, price, image, description FROM product ORDER BY id DESC";
    ps = con.prepareStatement(query);
    
    ResultSet rs = ps.executeQuery();
    
    boolean hasItems = false;
    while(rs.next()) {
        hasItems = true;
%>
                <div class="item-card">
<%
        String imageFileName = rs.getString("image");
        String imageSrc = "";
        
        if (imageFileName != null && !imageFileName.trim().isEmpty()) {
            String[] images = imageFileName.split(",");
            if (images.length > 0 && !images[0].trim().isEmpty()) {
                imageSrc = "product_images/" + images[0].trim();
            }
        }
        
        if (imageSrc.isEmpty()) {
            imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4=";
        }
%>
                    <img class="item-image" src="<%=imageSrc%>" alt="<%=rs.getString("product_name")%>">
                    <div class="item-info">
                        <div class="item-product_name"><%=rs.getString("product_name")%></div>
<%
        String description = rs.getString("description");
        if (description != null && !description.trim().isEmpty()) {
            // Limit description length for better display
            if (description.length() > 100) {
                description = description.substring(0, 97) + "...";
            }
%>
                        <div class="item-description"><%=description.replace("\n", "<br>")%></div>
<%
        }
%>
                        <div class="item-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
                        <div class="item-actions">
                            <form action="Updateproduct.jsp" method="get" style="display: inline;">
                                <input type="hidden" name="updateId" value="<%=rs.getString("id")%>">
                                <input type="hidden" name="restaurant" value="<%=restaurantId%>">
                                <button type="submit" class="update-btn">📝 Update Item</button>
                            </form>
                        </div>
                    </div>
                </div>
<%
    }
    
    if (!hasItems) {
%>
                <div class="no-items">
                    <h3>📦 No items found</h3>
                    <p>No items available in this restaurant.</p>
                </div>
<%
    }
    
    rs.close();
    ps.close();
    con.close();
    
} catch (Exception e) {
%>
                <div class="error-message">
                    ⚠️ Error loading items: <%=e.getMessage()%>
                </div>
<%
}
%>
            </div>
        </main>
        
        <footer>
            <p>&copy; 2026 Mini Shopping Cart.</p>
        </footer>
    </div>
    
    <script>
        function searchItems() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const itemCards = document.querySelectorAll('.item-card');
            
            itemCards.forEach(card => {
                const itemName = card.querySelector('.item-product_name').textContent.toLowerCase();
                const itemDescription = card.querySelector('.item-description');
                const descriptionText = itemDescription ? itemDescription.textContent.toLowerCase() : '';
                
                if (itemName.includes(searchTerm) || descriptionText.includes(searchTerm)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }
        
        function clearSearch() {
            document.getElementById('searchInput').value = '';
            searchItems(); // This will show all items since search term is empty
        }
        
        function cancelUpdate() {
            window.location.href = 'Updateproduct.jsp';
        }
    </script>
</body>
</html>