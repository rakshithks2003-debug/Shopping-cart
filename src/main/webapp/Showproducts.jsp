<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
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
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);

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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            margin-bottom: 50px;
            color: white;
            position: relative;
        }
        
        .header-content {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }
        
        h1 {
            font-size: 3.5rem;
            margin-bottom: 15px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            background: linear-gradient(45deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .subtitle {
            font-size: 1.3rem;
            opacity: 0.9;
            margin-bottom: 30px;
            color: rgba(255, 255, 255, 0.9);
        }
        
        .nav-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .nav-btn {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 12px 25px;
            text-decoration: none;
            border-radius: 30px;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
            font-weight: 500;
            backdrop-filter: blur(5px);
        }
        
        .nav-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }
        
        .nav-btn.primary {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            border-color: transparent;
        }
        
        .nav-btn.primary:hover {
            background: linear-gradient(135deg, #45a049, #3d8b40);
        }
        
        .nav-btn.admin {
            background: linear-gradient(135deg, #2196F3, #1976D2);
            border-color: transparent;
        }
        
        .nav-btn.admin:hover {
            background: linear-gradient(135deg, #1976D2, #1565C0);
        }
        
        .nav-btn.logout {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            border-color: transparent;
        }
        
        .nav-btn.logout:hover {
            background: linear-gradient(135deg, #d32f2f, #c62828);
        }
        
        .products-section {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 25px;
            padding: 40px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .section-header {
            text-align: center;
            margin-bottom: 40px;
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
        
        .product-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }
        
        .product-card:hover::before {
            transform: scaleX(1);
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
        
        .product-actions {
            display: flex;
            gap: 12px;
        }
        
        .no-products {
            text-align: center;
            padding: 80px 40px;
            color: #666;
        }
        
        .no-products-icon {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
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
            h1 {
                font-size: 2.5rem;
            }
            
            .header-content {
                padding: 25px;
            }
            
            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 20px;
            }
            
            .products-section {
                padding: 25px;
            }
            
            .section-title {
                font-size: 2rem;
            }
            
            .product-name {
                font-size: 1.2rem;
            }
            
            .product-price {
                font-size: 1.5rem;
            }
        }
        
        @media (max-width: 480px) {
            .products-grid {
                grid-template-columns: 1fr;
            }
            
            .nav-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .nav-btn {
                width: 200px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-content">
                <h1>🛍️ Mini Shopping cart</h1>
                <p class="subtitle">Browse our amazing cuisine</p>
                
                <div class="nav-buttons">
                    <a href="Addproducts.jsp" class="nav-btn primary">➕ Add New Product</a>
                    <% if ("admin".equals(userRole)) { %>
                        <a href="admin.jsp" class="nav-btn admin">🔧 Admin Panel</a>
                        
                    <% } else { %>
                        <a href="LogoutServlet" class="nav-btn logout">🚪 Logout</a>
                    <% } %>
                </div>
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
// Get category parameter from URL
String category = request.getParameter("category");

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
%>
                <div class="error-message">
                    ⚠️ Database connection failed!
                </div>
<%
    } else {
        PreparedStatement ps;
        String sql;
        
        if (category != null && !category.trim().isEmpty()) {
            // Filter by category
            sql = "SELECT id, name, price, image, description FROM product WHERE category_id = ? ORDER BY id DESC";
            ps = con.prepareStatement(sql);
            ps.setString(1, category);
        } else {
            // Show all products
            sql = "SELECT id, name, price, image, description FROM product ORDER BY id DESC";
            ps = con.prepareStatement(sql);
        }
        
        ResultSet rs = ps.executeQuery();
        
        // Fix NULL IDs by updating the database
        if (!rs.next()) {
            // No products, try to fix the table structure
            try {
                // First, let's try to add an auto-increment primary key if it doesn't exist
                PreparedStatement checkTable = con.prepareStatement("SHOW COLUMNS FROM product WHERE Field = 'id' AND Extra = 'auto_increment'");
                ResultSet checkRs = checkTable.executeQuery();
                
                if (!checkRs.next()) {
                    // Add auto_increment to id column
                    PreparedStatement alterTable = con.prepareStatement("ALTER TABLE product MODIFY id INT AUTO_INCREMENT PRIMARY KEY");
                    alterTable.executeUpdate();
                    System.out.println("Showproducts: Added auto_increment to id column");
                }
                checkRs.close();
                
                // Update NULL IDs to sequential values
                PreparedStatement updateIds = con.prepareStatement("SET @row_number = 0; UPDATE product SET id = (@row_number := @row_number + 1) WHERE id IS NULL ORDER BY sid");
                int updatedRows = updateIds.executeUpdate();
                System.out.println("Showproducts: Updated " + updatedRows + " NULL IDs to sequential values");
                
                // Re-run the query to get the updated data
                rs = ps.executeQuery();
            } catch (Exception e) {
                System.out.println("Showproducts: Error fixing table structure: " + e.getMessage());
            }
        }
        
        boolean hasProducts = false;
        while(rs.next()) {
            hasProducts = true;
%>
                <div class="product-card">
<%
        String imageFileName = rs.getString("image");
        String imageSrc = "";
        
        // Debug image information
        System.out.println("Showproducts: Product ID: " + rs.getString("id") + ", Image file: " + imageFileName);
        
        if (imageFileName != null && !imageFileName.trim().isEmpty()) {
            // Use direct path assignment
            imageSrc = "seller_images/" + imageFileName;
            System.out.println("Showproducts: Using image path: " + imageSrc);
        } else {
            // Use a placeholder image if no image available
            imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5ObyBJbWFnZTwvdGV4dD4KPC9zdmc+";
            System.out.println("Showproducts: No image file, using placeholder");
        }
%>
                    <div class="product-image-wrapper">
                        <img class="product-image" src="<%=imageSrc%>" alt="<%=rs.getString("name")%>" 
                             onclick="window.location.href='Details.jsp?id=<%=rs.getString("id")%>'"
                             onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz=';">
                    </div>
                    <div class="product-info">
                        <div class="product-name"><%=rs.getString("name")%></div>
                        <div class="product-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
                        <div class="product-description"><%=rs.getString("description") != null ? rs.getString("description") : "No description available"%></div>
                        <div class="product-actions">
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
        </main>
        
        <footer>
            <p>&copy; 2026 Mini Shopping cart.</p>
        </footer>
    </div>
    
    <script>
    </script>
</body>
</html>