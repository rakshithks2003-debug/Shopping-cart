<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
<title>Show Products - Mini Shopping cart</title>
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
    
    .container {
        max-width: 1200px;
        margin: 0 auto;
    }
    
    header {
        text-align: center;
        padding: 40px 20px;
        color: white;
    }
    
    h1 {
        font-size: 3rem;
        font-weight: 700;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .subtitle {
        font-size: 1.2rem;
        opacity: 0.9;
        margin-bottom: 30px;
    }
    
    .nav-buttons {
        display: flex;
        justify-content: center;
        gap: 15px;
        flex-wrap: wrap;
    }
    
    .nav-btn {
        padding: 12px 25px;
        border: none;
        border-radius: 10px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
        cursor: pointer;
        font-size: 1rem;
    }
    
    .nav-btn.cart {
        background: linear-gradient(135deg, #ff6b6b, #ee5a24);
        color: white;
        position: relative;
    }
    
    .nav-btn.logout {
        background: linear-gradient(135deg, #fa709a, #fee140);
        color: white;
    }
    
    .cart-badge {
        position: absolute;
        top: -8px;
        right: -8px;
        background: #fff;
        color: #ff6b6b;
        border-radius: 50%;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        font-weight: 700;
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }
    
    .nav-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
    }
    
    .products-section {
        background: rgba(255, 255, 255, 0.95);
        border-radius: 20px;
        padding: 40px;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        backdrop-filter: blur(10px);
    }
    
    .section-header {
        text-align: center;
        margin-bottom: 50px;
    }
    
    .section-title {
        font-size: 2.5rem;
        color: #333;
        margin-bottom: 10px;
        font-weight: 700;
    }
    
    .section-subtitle {
        color: #666;
        font-size: 1.1rem;
    }
    
    .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 30px;
        margin-bottom: 40px;
    }
    
    .product-card {
        background: white;
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        position: relative;
        border: 1px solid rgba(0, 0, 0, 0.05);
    }
    
    .product-card:hover {
        transform: translateY(-10px) scale(1.02);
        box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
    }
    
    .product-image-wrapper {
        position: relative;
        overflow: hidden;
        height: 220px;
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
    }
    
    .product-image {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.6s ease;
        cursor: pointer;
    }
    
    .product-card:hover .product-image {
        transform: scale(1.1);
    }
    
    .product-info {
        padding: 25px;
    }
    
    .product-name {
        font-size: 1.4rem;
        font-weight: 600;
        color: #333;
        margin-bottom: 12px;
        line-height: 1.3;
    }
    
    .product-price {
        font-size: 1.8rem;
        font-weight: 700;
        color: #ff6b6b;
        margin-bottom: 20px;
        display: flex;
        align-items: baseline;
    }
    
    .product-price::before {
        content: "₹";
        margin-right: 4px;
        font-size: 1.4rem;
    }
    
    .no-products {
        text-align: center;
        padding: 80px 40px;
        color: #666;
    }
    
    .no-products h3 {
        font-size: 1.8rem;
        margin-bottom: 10px;
        color: #333;
    }
    
    .no-products p {
        font-size: 1.1rem;
        color: #666;
    }
    
    .error-message {
        background: linear-gradient(135deg, #f44336, #d32f2f);
        color: white;
        padding: 20px;
        border-radius: 15px;
        margin: 20px 0;
        text-align: center;
        font-weight: 500;
        box-shadow: 0 10px 25px rgba(244, 67, 54, 0.3);
    }
    
    footer {
        text-align: center;
        color: rgba(255, 255, 255, 0.8);
        margin-top: 50px;
        padding: 30px;
        font-size: 1rem;
    }
    
    @media (max-width: 768px) {
        .products-grid {
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
        }
    }
    
    @media (max-width: 480px) {
        .products-grid {
            grid-template-columns: 1fr;
        }
    }
</style>
</head>
<body>
    <a href="Dashboard.jsp" class="back-button">← Back to Dashboard</a>
    
    <div class="container">
        <header>
            <h1>🛍️ Mini Shopping cart</h1>
            <p class="subtitle">Browse our amazing cuisine</p>
            
            <div class="nav-buttons">
                <a href="Dashboard.jsp" class="nav-btn" style="background: linear-gradient(135deg, #4CAF50, #45a049); color: white;">← Dashboard</a>
                <a href="Cart.jsp" class="nav-btn cart" id="cartButton">
                    🛒 My Cart
                    <span class="cart-badge" id="cartBadge" style="display: none;">0</span>
                </a>
                <% if ("admin".equals(userRole)) { %>
                    <a href="LogoutServlet" class="nav-btn logout">🚪 Logout</a>
                <% } else { %>
                    <a href="LogoutServlet" class="nav-btn logout">🚪 Logout</a>
                <% } %>
            </div>
        </header>
        
        <main>
            <div class="products-section">
                <div class="section-header">
                    <h2 class="section-title">Featured Products</h2>
                    <p class="section-subtitle">Discover our Accurated collection of premium items</p>
                </div>
                
                <div class="products-grid">
<%
String category = request.getParameter("category");

try {
    Dbase db = new Dbase();
    Connection con = null;
    
    try {
        con = db.initailizeDatabase();
    } catch (Exception e) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
    }
    
    if (con == null || con.isClosed()) {
%>
                <div class="error-message">
                    ⚠️ Database connection failed!
                </div>
<%
    } else {
        PreparedStatement ps;
        String sql;
        
        if (category != null && !category.trim().isEmpty()) {
            sql = "SELECT id, name, price, image, description FROM product WHERE category_id = ? ORDER BY id DESC";
            ps = con.prepareStatement(sql);
            ps.setString(1, category);
        } else {
            sql = "SELECT id, name, price, image, description FROM product ORDER BY id DESC";
            ps = con.prepareStatement(sql);
        }
        
        ResultSet rs = ps.executeQuery();
        
        boolean hasProducts = false;
        
        while(rs.next()) {
            hasProducts = true;
%>
                <div class="product-card">
<%
        String imageFileName = rs.getString("image");
        String imageSrc = "";
        
        if (imageFileName != null && !imageFileName.trim().isEmpty()) {
            imageSrc = "product_images/" + imageFileName;
        } else {
            imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+";
        }
%>
                    <div class="product-image-wrapper">
                        <img class="product-image" src="<%=imageSrc%>" alt="<%=rs.getString("name")%>" 
                             onclick="window.location.href='Details.jsp?id=<%=rs.getString("id")%>'"
                             onerror="tryFallbackImage(this, '<%=imageFileName%>')">
                    </div>
                    <div class="product-info">
                        <div class="product-name"><%=rs.getString("name")%></div>
                        <div class="product-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
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
    }
    
} catch (ClassNotFoundException e) {
%>
                <div class="error-message">
                    ⚠️ Database driver not found: <%=e.getMessage()%>
                </div>
<%
} catch (SQLException e) {
%>
                <div class="error-message">
                    ⚠️ Database error: <%=e.getMessage()%>
                </div>
<%
} catch (Exception e) {
%>
                <div class="error-message">
                    ⚠️ Error loading products: <%=e.getMessage()%>
                </div>
<%
}
%>
                </div>
            </div>
        </main>
        
        <footer>
            <p>&copy; 2026 Mini Shopping cart.</p>
        </footer>
    </div>
    
    <script>
        // Fallback image function
        function tryFallbackImage(img, fileName) {
            if (!fileName || fileName.trim() === '') {
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+';
                return;
            }
            
            if (img.src.includes('product_images/')) {
                const newSrc = img.src.replace('product_images/', 'seller_images/');
                console.log('Image fallback: trying', newSrc);
                img.src = newSrc;
            } else {
                img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz=';
            }
        }
    </script>
</body>
</html>
