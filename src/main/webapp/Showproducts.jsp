<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Product Categories</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: white;
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            margin-bottom: 40px;
            padding: 30px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        
        h1 {
            font-size: 2.5rem;
            color: #2c3e50;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        
        .subtitle {
            color: #7f8c8d;
            font-size: 1.2rem;
            margin-bottom: 20px;
        }
        
        .add-product-btn {
            display: inline-block;
            background: linear-gradient(45deg, #4CAF50, #45a049);
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: bold;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(76,175,80,0.3);
        }
        
        .add-product-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(76,175,80,0.4);
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .product-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            position: relative;
        }
        
        .product-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
        }
        
        .product-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            border-radius: 15px 15px 0 0;
        }
        
        .product-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-bottom: 3px solid #f8f9fa;
        }
        
        .product-info {
            padding: 25px;
        }
        
        .product-name {
            font-size: 1.4rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
            text-transform: capitalize;
        }
        
        .product-description {
            color: #666;
            font-size: 0.95rem;
            margin-bottom: 15px;
            line-height: 1.5;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            background: #f8f9fa;
            padding: 10px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .product-price {
            font-size: 1.6rem;
            font-weight: bold;
            color: #27ae60;
            margin-bottom: 20px;
            text-shadow: 1px 1px 2px rgba(39,174,96,0.2);
        }
        
        .product-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .delete-btn {
            background: linear-gradient(45deg, #e74c3c, #c0392b);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
            flex: 1;
            font-size: 0.9rem;
        }
        
        .delete-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(231,76,60,0.3);
        }
        
        .cart-btn {
            background: linear-gradient(45deg, #f39c12, #e67e22);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
            flex: 1;
            font-size: 0.9rem;
        }
        
        .cart-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(243,156,18,0.3);
        }
        
        .no-products {
            text-align: center;
            color: #7f8c8d;
            font-size: 1.3rem;
            margin: 60px 0;
            padding: 50px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .no-products h3 {
            font-size: 2.5rem;
            margin-bottom: 20px;
            color: #2c3e50;
        }
        
        .error-message {
            background: linear-gradient(45deg, #e74c3c, #c0392b);
            color: white;
            padding: 25px;
            border-radius: 15px;
            margin: 20px 0;
            text-align: center;
            font-size: 1.1rem;
            box-shadow: 0 5px 20px rgba(231,76,60,0.3);
        }
        
        footer {
            text-align: center;
            color: white;
            margin-top: 50px;
            padding: 30px;
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }
            
            .product-image {
                height: 180px;
            }
        }
        
        @media (max-width: 480px) {
            .products-grid {
                grid-template-columns: 1fr;
            }
            
            .product-image {
                height: 200px;
            }
            
            .product-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Product  categories</h1>
            <p class="subtitle">Browse our amazing collection</p>
            <a href="Addproducts.jsp" class="add-product-btn">➕ Add New Product</a>
        </header>
        <main>
            <div class="products-grid">
<%
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, name, price, description, image FROM product ORDER BY id DESC");
    ResultSet rs = ps.executeQuery();
    
    boolean hasProducts = false;
    while(rs.next()) {
        hasProducts = true;
%>
                <div class="product-card">
<%
        String imageFileName = null;
        try {
            imageFileName = rs.getString("image");
            if (rs.wasNull()) {
                imageFileName = null;
            }
        } catch (Exception e) {
            imageFileName = null;
        }
        String imageSrc = "product_images/" + (imageFileName != null && !imageFileName.isEmpty() ? imageFileName : "");
%>
                    <img class="product-image" src="<%=imageSrc%>" alt="<%=rs.getString("name")%>" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xMjUgNzVIMTc1VjEyNUgxMjVWNzVaIiBmaWxsPSIjQ0NDQ0NDIi8+CjxwYXRoIGQ9Ik0xMzcuNSA5My43NUwxNTAgMTA2LjI1TDE2Mi41IDkzLjc1TDE3NSAxMTIuNUgxNTBIMTI1TDEzNy41IDkzLjc1WiIgZmlsbD0iI0NDQ0NDQyIvPgo8dGV4dCB4PSIxNTAiIHk9IjE2MCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxNCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4='">
                    <div class="product-info">
                        <div class="product-name"><%=rs.getString("name")%></div>
                       
                        <div class="product-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
                        <div class="product-actions">
                            <form action="Deleteproducts" method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this product?')">
                                <input type="hidden" name="id" value="<%=rs.getString("id")%>">
                                <input type="hidden" name="imageFileName" value="<%=imageFileName != null ? imageFileName : ""%>">
                                <button type="submit" class="delete-btn">🗑️ Delete</button>
                            </form>
                            <button class="cart-btn" onclick="addToCart('<%=rs.getString("id")%>', '<%=rs.getString("name").replace("'", "\\'")%>', <%=rs.getDouble("price")%>, '<%=imageFileName != null ? imageFileName.replace("'", "\\'") : ""%>')">🛒 Add to Cart</button>
                        </div>
                    </div>
                </div>
<%
    }
    
    if (!hasProducts) {
%>
                <div class="no-products">
                    <h3>📦 No Products Yet</h3>
                    <p>Start by adding your first product to gallery!</p>
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
            <p>&copy; 2026 Product Gallery. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>