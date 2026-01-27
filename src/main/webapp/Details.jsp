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
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Get product ID from request parameter
String productId = request.getParameter("id");
if (productId == null || productId.trim().isEmpty()) {
    response.sendRedirect("Showproducts.jsp");
    return;
}

// Product details variables
String productName = "";
double productPrice = 0.0;
String productDescription = "";
String productImage = "";
boolean productFound = false;

try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, name, price, description, image FROM product WHERE id = ?");
    ps.setString(1, productId);
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
        productFound = true;
        productName = rs.getString("name");
        productPrice = rs.getDouble("price");
        productDescription = rs.getString("description");
        productImage = rs.getString("image");
    }
    
    rs.close();
    ps.close();
    con.close();
    
} catch (Exception e) {
    e.printStackTrace();
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Details - <%= productName %></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            min-height: 100vh;
            padding: 20px;
            position: relative;
            overflow-x: hidden;
        }
        
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
            pointer-events: none;
            z-index: 1;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 2;
        }
        
        header {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            padding: 30px;
            margin-bottom: 40px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.1);
            text-align: center;
            color: white;
            animation: slideDown 0.6s ease-out;
        }
        
        h1 {
            font-size: 3rem;
            margin-bottom: 15px;
            background: linear-gradient(45deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            font-weight: 700;
        }
        
        .back-link {
            display: inline-block;
            background: rgba(255, 255, 255, 0.15);
            color: white;
            padding: 12px 25px;
            text-decoration: none;
            border-radius: 30px;
            margin-bottom: 10px;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.2);
            font-weight: 500;
            backdrop-filter: blur(5px);
        }
        
        .back-link:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }
        
        .product-detail-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            overflow: hidden;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15);
            display: flex;
            min-height: 600px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: fadeInUp 0.8s ease-out;
        }
        
        .product-image-section {
            flex: 1;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px;
            min-width: 450px;
            position: relative;
        }
        
        .product-image-section::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 20px;
            right: 20px;
            bottom: 20px;
            border: 2px dashed rgba(103, 126, 234, 0.2);
            border-radius: 20px;
            pointer-events: none;
        }
        
        .product-image {
            max-width: 100%;
            max-height: 450px;
            object-fit: contain;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            transition: all 0.5s ease;
            position: relative;
            z-index: 1;
        }
        
        .product-image:hover {
            transform: scale(1.05);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
        }
        
        .product-info-section {
            flex: 1;
            padding: 50px;
            display: flex;
            flex-direction: column;
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(255, 255, 255, 0.95) 100%);
        }
        
        .product-badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 1px;
            animation: pulse 2s infinite;
        }
        
        .product-name {
            font-size: 2.8rem;
            font-weight: 800;
            color: #2c3e50;
            margin-bottom: 25px;
            line-height: 1.2;
            background: linear-gradient(135deg, #2c3e50, #34495e);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .product-price {
            font-size: 2.5rem;
            font-weight: 900;
            color: #e74c3c;
            margin-bottom: 35px;
            display: flex;
            align-items: baseline;
            position: relative;
        }
        
        .product-price::before {
            content: "₹";
            margin-right: 5px;
            font-size: 1.8rem;
            color: #c0392b;
        }
        
        .product-price::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 60px;
            height: 3px;
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            border-radius: 2px;
        }
        
        .product-description {
            color: #5a6c7d;
            line-height: 1.8;
            margin-bottom: 40px;
            flex-grow: 1;
            font-size: 1.15rem;
            white-space: pre-wrap;
          
            padding: 25px;
            
            position: relative;
        }
        
        .product-description::before {
            content: '📝';
            position: absolute;
            top: -10px;
            left: -10px;
            background: #667eea;
            color: white;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        
        .product-actions {
            display: flex;
            gap: 20px;
            margin-top: 20px;
        }
        
        .add-cart-btn {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            border: none;
            padding: 18px 35px;
            border-radius: 15px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            flex: 1;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(46, 204, 113, 0.3);
        }
        
        .add-cart-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }
        
        .add-cart-btn:hover::before {
            left: 100%;
        }
        
        .add-cart-btn:hover {
            background: linear-gradient(135deg, #229954, #27ae60);
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(46, 204, 113, 0.4);
        }
        
        .buy-now-btn {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            border: none;
            padding: 18px 35px;
            border-radius: 15px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            flex: 1;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(231, 76, 60, 0.3);
        }
        
        .buy-now-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }
        
        .buy-now-btn:hover::before {
            left: 100%;
        }
        
        .buy-now-btn:hover {
            background: linear-gradient(135deg, #c0392b, #a93226);
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(231, 76, 60, 0.4);
        }
        
        .error-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 80px 50px;
            text-align: center;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: fadeInUp 0.8s ease-out;
        }
        
        .error-title {
            font-size: 2.5rem;
            color: #e74c3c;
            margin-bottom: 25px;
            font-weight: 700;
        }
        
        .error-message {
            color: #5a6c7d;
            font-size: 1.2rem;
            margin-bottom: 35px;
            line-height: 1.6;
        }
        
        .notification {
            position: fixed;
            top: 30px;
            right: 30px;
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            padding: 18px 25px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(46, 204, 113, 0.3);
            z-index: 1000;
            opacity: 0;
            transform: translateY(-30px) scale(0.9);
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            font-weight: 600;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .notification.show {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }
        
        @media (max-width: 968px) {
            .product-detail-container {
                flex-direction: column;
            }
            
            .product-image-section {
                min-width: auto;
                padding: 30px;
            }
            
            .product-info-section {
                padding: 30px;
            }
            
            .product-name {
                font-size: 2.2rem;
            }
            
            .product-price {
                font-size: 2rem;
            }
            
            h1 {
                font-size: 2.5rem;
            }
        }
        
        @media (max-width: 768px) {
            body {
                padding: 15px;
            }
            
            header {
                padding: 20px;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .product-image-section {
                padding: 20px;
            }
            
            .product-info-section {
                padding: 20px;
            }
            
            .product-name {
                font-size: 1.8rem;
            }
            
            .product-price {
                font-size: 1.6rem;
            }
            
            .product-actions {
                display: flex;
                gap: 20px;
                margin-top: 20px;
            }
            
            .buy-now-btn {
                background: linear-gradient(135deg, #e74c3c, #c0392b);
                color: white;
                border: none;
                padding: 18px 35px;
                border-radius: 15px;
                font-size: 1.1rem;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.3s ease;
                flex: 1;
                position: relative;
                overflow: hidden;
                box-shadow: 0 10px 25px rgba(231, 76, 60, 0.3);
            }
            
            .buy-now-btn::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
                transition: left 0.5s ease;
            }
            
            .buy-now-btn:hover::before {
                left: 100%;
            }
            
            .buy-now-btn:hover {
                background: linear-gradient(135deg, #c0392b, #a93226);
                transform: translateY(-3px);
                box-shadow: 0 15px 35px rgba(231, 76, 60, 0.4);
            }
            
            .error-container {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                border-radius: 30px;
                padding: 80px 50px;
                text-align: center;
                box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15);
                border: 1px solid rgba(255, 255, 255, 0.3);
                animation: fadeInUp 0.8s ease-out;
            }
            
            .error-title {
                font-size: 2.5rem;
                color: #e74c3c;
                margin-bottom: 25px;
                font-weight: 700;
            }
            
            .error-message {
                color: #5a6c7d;
                font-size: 1.2rem;
                margin-bottom: 35px;
                line-height: 1.6;
            }
            
            .notification {
                position: fixed;
                top: 30px;
                right: 30px;
                background: linear-gradient(135deg, #27ae60, #2ecc71);
                color: white;
                padding: 18px 25px;
                border-radius: 15px;
                box-shadow: 0 15px 35px rgba(46, 204, 113, 0.3);
                z-index: 1000;
                opacity: 0;
                transform: translateY(-30px) scale(0.9);
                transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
                font-weight: 600;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.2);
            }
            
            .notification.show {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
            
            @keyframes slideDown {
                from {
                    opacity: 0;
                    transform: translateY(-50px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(50px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            @keyframes pulse {
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.05);
                }
            }
            
            @media (max-width: 968px) {
                .product-detail-container {
                    flex-direction: column;
                }
                
                .product-image-section {
                    min-width: auto;
                    padding: 30px;
                }
                
                .product-info-section {
                    padding: 30px;
                }
                
                .product-name {
                    font-size: 2.2rem;
                }
                
                .product-price {
                    font-size: 2rem;
                }
                
                h1 {
                    font-size: 2.5rem;
                }
            }
            
            @media (max-width: 768px) {
                body {
                    padding: 15px;
                }
                
                header {
                    padding: 20px;
                }
                
                h1 {
                    font-size: 2rem;
                }
                
                .product-image-section {
                    padding: 20px;
                }
                
                .product-info-section {
                    padding: 20px;
                }
                
                .product-name {
                    font-size: 1.8rem;
                }
                
                .product-price {
                    font-size: 1.6rem;
                }
                
                .product-actions {
                    flex-direction: column;
                }
                
                .add-cart-btn, .buy-now-btn {
                    width: 100%;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <header>
                <h1>🛍️ Product Details</h1>
                <a href="Showproducts.jsp" class="back-link">← Back to Products</a>
            </header>
            
    <%
    if (productFound) {
    %>
            <div class="product-detail-container">
                <div class="product-image-section">
    <%
        if (productImage != null && !productImage.trim().isEmpty()) {
    %>
                    <img src="product_images/<%=productImage%>" alt="<%=productName%>" class="product-image" 
                         onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgdmlld0JveD0iMCAwIDQwMCA0MDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iNDAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNTAgMTUwSDI1MFYyNTBIMTUwVjE1MFoiIGZpbGw9IiNDQ0NDQ0QiLz4KPHA+PC9wPgo8dGV4dCB4PSIyMDAiIHk9IjMyMCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxOCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4='">
    <%
        } else {
    %>
                    <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgdmlld0JveD0iMCAwIDQwMCA0MDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iNDAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNTAgMTUwSDI1MFYyNTBIMTUwVjE1MFoiIGZpbGw9IiNDQ0NDQ0QiLz4KPHA+PC9wPgo8dGV4dCB4PSIyMDAiIHk9IjMyMCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxOCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4=" alt="<%=productName%>" class="product-image">
    <%
        }
    %>
                </div>
                <div class="product-info-section">
                    <h2 class="product-name"><%=productName%></h2>
                    <div class="product-price"><%=String.format("%.2f", productPrice)%></div>
                    <div class="product-description"><%=productDescription != null ? productDescription : "No description available."%></div>
                    <div class="product-actions">
                        <button class="add-cart-btn" onclick="addToCart()">🛒 Add to Cart</button>
                        <button class="buy-now-btn" onclick="buyNow()">⚡ Buy Now</button>
                    </div>
                </div>
            </div>
    <%
    } else {
    %>
            <div class="error-container">
                <h2 class="error-title">📦 Product Not Found</h2>
                <p class="error-message">The product you're looking for doesn't exist or has been removed.</p>
                <a href="Showproducts.jsp" class="back-link">← Back to Products</a>
            </div>
    <%
    }
    %>
        </div>
        
        <!-- Notification -->
        <div class="notification" id="notification"></div>
        
        <script>
            function addToCart() {
                const productId = '<%=productId%>';
                const button = event.target;
                const originalText = button.innerHTML;
                
                // Show loading state
                button.innerHTML = '⏳ Adding...';
                button.disabled = true;
                
                // Send AJAX request to AddToCart.jsp
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'AddToCart.jsp', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        // Reset button
                        button.innerHTML = originalText;
                        button.disabled = false;
                        
                        if (xhr.status === 200) {
                            try {
                                const response = JSON.parse(xhr.responseText);
                                if (response.success) {
                                    showNotification(response.message, 'success');
                                } else {
                                    showNotification(response.message, 'error');
                                }
                            } catch (e) {
                                showNotification('Error adding to cart', 'error');
                            }
                        } else {
                            showNotification('Server error. Please try again.', 'error');
                        }
                    }
                };
                
                xhr.send('productId=' + encodeURIComponent(productId));
            }
            
            function showNotification(message, type) {
                const notification = document.getElementById('notification');
                notification.textContent = message;
                notification.style.display = 'block';
                notification.style.opacity = '1';
                
                // Set background color based on type
                if (type === 'success') {
                    notification.style.background = 'linear-gradient(135deg, #27ae60, #2ecc71)';
                } else {
                    notification.style.background = 'linear-gradient(135deg, #e74c3c, #c0392b)';
                }
                
                setTimeout(() => {
                    notification.style.opacity = '0';
                    setTimeout(() => {
                        notification.style.display = 'none';
                    }, 300);
                }, 3000);
            }
            
            function buyNow() {
                // Add to cart first, then redirect to cart
                addToCart();
                
                setTimeout(() => {
                    showNotification('Redirecting to cart...', 'success');
                    setTimeout(() => {
                        window.location.href = 'Cart.jsp';
                    }, 1000);
                }, 1000);
            }
        </script>
    </body>
    </html>