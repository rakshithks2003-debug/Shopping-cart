<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Gallery</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: white;
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
            color: blue;
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
        
        .add-product-btn {
            display: inline-block;
            background: #4CAF50;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 25px;
            margin-bottom: 30px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .add-product-btn:hover {
            background: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .product-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }
        
        .product-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            background: #f0f0f0;
            display: block;
        }
        
        .product-info {
            padding: 20px;
        }
        
        .product-name {
            font-size: 1.3rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        .product-id {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 10px;
        }
        
        .product-description {
            color: #555;
           /* font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 15px;
            padding: 12px 15px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); 
            border-radius: 8px;
            border-left: 4px solid #007bff;
            border: 1px solid #e0e6ed;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            position: relative;
            overflow: hidden;*/
        }
        
        .product-description::before {
            content: "📝";
            position: absolute;
            top: 8px;
            left: 8px;
            font-size: 0.8rem;
            opacity: 0.3;
        }
        
        .product-price {
            font-size: 1.5rem;
            font-weight: bold;
            color: #ff6b6b;
            margin-bottom: 15px;
        }
        
        .product-price::before {
            content: "₹";
            margin-right: 2px;
        }
        
        .product-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        
        .delete-btn {
            background: #f44336;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background 0.3s ease;
        }
        
        .delete-btn:hover {
            background: #d32f2f;
        }
        
        .cart-btn {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background 0.3s ease;
        }
        
        .cart-btn:hover {
            background: #45a049;
        }
        
        .cart-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #4CAF50;
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 1000;
            opacity: 0;
            transform: translateY(-20px);
            transition: all 0.3s ease;
        }
        
        .cart-notification.show {
            opacity: 1;
            transform: translateY(0);
        }
        
        .cart-counter {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #ff6b6b;
            color: white;
            padding: 10px 15px;
            border-radius: 25px;
            font-weight: bold;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 999;
        }
        
        .no-products {
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
        
        footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🛍️ Mini Shopping cart</h1>
            <p class="subtitle">Browse our amazing cuisine</p>
            <div style="margin-bottom: 20px;">
                <a href="Addproducts.jsp" class="add-product-btn">➕ Add New Product</a>
<% if ("admin".equals(userRole)) { %>
                <a href="admin.jsp" class="add-product-btn" style="background: #2196F3; margin-left: 10px;">🔧 Admin Panel</a>
                <a href="LogoutServlet" class="add-product-btn" style="background: #f44336; margin-left: 10px;">🚪 Logout</a>
<% } else { %>
                <a href="LogoutServlet" class="add-product-btn" style="background: #f44336; margin-left: 10px;">🚪 Logout</a>
<% } %>
            </div>
        </header>
        
        
        <main>
            <div class="products-grid">
<%
try {
	Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, name, price, image, description FROM product ORDER BY id DESC");
    ResultSet rs = ps.executeQuery();
    
    boolean hasProducts = false;
    while(rs.next()) {
        hasProducts = true;
%>
                <div class="product-card">
<%
        String imageFileName = rs.getString("image");
        String imageSrc = "product_images/" + (imageFileName != null ? imageFileName : "");
%>
                    <img class="product-image" src="<%=imageSrc%>" alt="<%=rs.getString("name")%>" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4='">
                    <div class="product-info">
                        <div class="product-name"><%=rs.getString("name")%></div>
                       
<%
        String description = rs.getString("description");
        if (description != null && !description.trim().isEmpty()) {
            // Limit description length for better display
            if (description.length() > 150) {
                description = description.substring(0, 147) + "...";
            }
%>
                        <div class="product-description"><%=description.replace("\n", "<br>")%></div>
<%
        }
%>
                       
                        <div class="product-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
                        <div class="product-actions">
                            <form action="Deleteproducts" method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this product?')">
                                <input type="hidden" name="id" value="<%=rs.getString("id")%>">
                                <input type="hidden" name="imageFileName" value="<%=imageFileName != null ? imageFileName : ""%>">
                                <button type="submit" class="delete-btn">🗑️ Delete</button>
                            </form>
                            <button class="cart-btn" onclick="addToCart(this)" 
                                    data-id="<%=rs.getString("id")%>" 
                                    data-name="<%=rs.getString("name").replace("\"", "&quot;")%>" 
                                    data-price="<%=rs.getDouble("price")%>" 
                                    data-image="<%=imageFileName != null ? imageFileName.replace("\"", "&quot;") : ""%>">🛒 Add to Cart</button>
                        </div>
                    </div>
                </div>
<%
    }
    
    if (!hasProducts) {
%>
                <div class="no-products">
                    <h3>📦 No items Yet</h3>
                    <p>Start by adding your first item to the gallery!</p>
                </div>
<%
    }
    
    rs.close();
    ps.close();
    con.close();
    
} catch (Exception e) {
%>
                <div class="error-message">
                    ⚠️ Error loading products: <%=e.getMessage()%>
                </div>
<%
}
%>
            </div>
        </main>
        
        <footer>
            <p>&copy; 2026 Mini Shopping cart.</p>
        </footer>
    </div>
    
    <!-- Cart Counter -->
    <div class="cart-counter" id="cartCounter">🛒 Cart (0)</div>
    
    <!-- Cart Notification -->
    <div class="cart-notification" id="cartNotification"></div>
    
    <script>
        // Initialize cart from localStorage
        let cart = JSON.parse(localStorage.getItem('MiniShoppingCart')) || [];
        
        // Update cart counter on page load
        updateCartCounter();
        
        function addToCart(button) {
            // Get data from button attributes
            const id = button.getAttribute('data-id');
            const name = button.getAttribute('data-name');
            const price = parseFloat(button.getAttribute('data-price'));
            const image = button.getAttribute('data-image');
            
            // Check if item already exists in cart
            const existingItem = cart.find(item => item.id === id);
            
            if (existingItem) {
                // Increment quantity if item exists
                existingItem.quantity += 1;
            } else {
                // Add new item to cart
                cart.push({
                    id: id,
                    name: name,
                    price: price,
                    image: image,
                    quantity: 1
                });
            }
            
            // Save cart to localStorage
            localStorage.setItem('MiniShoppingCart', JSON.stringify(cart));
            
            // Update cart counter
            updateCartCounter();
            
            // Show notification
            showNotification(name + ' added to cart!');
        }
        
        function updateCartCounter() {
            const totalItems = cart.reduce((total, item) => total + item.quantity, 0);
            const counter = document.getElementById('cartCounter');
            if (counter) {
                counter.textContent = '🛒 Cart (' + totalItems + ')';
            }
        }
        
        function showNotification(message) {
            const notification = document.getElementById('cartNotification');
            if (notification) {
                notification.textContent = message;
                notification.classList.add('show');
                
                // Hide notification after 3 seconds
                setTimeout(() => {
                    notification.classList.remove('show');
                }, 3000);
            }
        }
        
        // View cart function
        function viewCart() {
            window.location.href = 'cart.jsp';
        }
        
        // Make cart counter clickable
        document.addEventListener('DOMContentLoaded', function() {
            const counter = document.getElementById('cartCounter');
            if (counter) {
                counter.style.cursor = 'pointer';
                counter.onclick = viewCart;
            }
        });
    </script>
</body>
</html>