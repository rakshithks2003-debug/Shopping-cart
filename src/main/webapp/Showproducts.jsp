<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Product Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            text-align: center;
            margin-bottom: 40px;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        h1 {
            font-size: 2.5rem;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #7f8c8d;
            font-size: 1.1rem;
            margin-bottom: 20px;
        }
        
        .add-product-btn {
            display: inline-block;
            background: #3498db;
            color: white;
            padding: 12px 25px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            transition: background-color 0.3s;
        }
        
        .add-product-btn:hover {
            background: #2980b9;
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .product-card {
            background: white;
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .product-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-bottom: 1px solid #eee;
        }
        
        .product-info {
            padding: 20px;
        }
        
        .product-name {
            font-size: 1.3rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .product-id {
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 10px;
        }
        
        .product-price {
            font-size: 1.5rem;
            font-weight: bold;
            color: #3498db;
            margin-bottom: 15px;
        }
        
        .product-actions {
            display: flex;
            gap: 10px;
        }
        
        .delete-btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: background-color 0.3s;
        }
        
        .delete-btn:hover {
            background: #c0392b;
        }
        
        .no-products {
            text-align: center;
            color: #7f8c8d;
            font-size: 1.2rem;
            margin: 60px 0;
            padding: 40px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .no-products h3 {
            font-size: 2rem;
            margin-bottom: 15px;
            color: #2c3e50;
        }
        
        .error-message {
            background: #e74c3c;
            color: white;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: center;
        }
        
        footer {
            text-align: center;
            color: #7f8c8d;
            margin-top: 40px;
            padding: 20px;
            border-top: 1px solid #ddd;
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
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Product Management</h1>
            <p class="subtitle">Browse our amazing collection</p>
            <a href="Addproducts.jsp" class="add-product-btn">➕ Add New Product</a>
        </header>
        <main>
            <div class="products-grid">
<%
try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, name, price, image FROM product ORDER BY id DESC");
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
                       
                        <div class="product-price"><%=String.format("%.2f", rs.getDouble("price"))%></div>
                        <div class="product-actions">
                            <form action="DeleteProduct" method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this product?')">
                                <input type="hidden" name="id" value="<%=rs.getInt("id")%>">
                                <input type="hidden" name="imageFileName" value="<%=imageFileName != null ? imageFileName : ""%>">
                                <button type="submit" class="delete-btn">🗑️ Delete</button>
                            </form>
                        </div>
                    </div>
                </div>
<%
    }
    
    if (!hasProducts) {
%>
                <div class="no-products">
                    <h3>📦 No Products Yet</h3>
                    <p>Start by adding your first product to the gallery!</p>
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