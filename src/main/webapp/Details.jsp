<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in
String username = (String) session.getAttribute("username");
String userRole = (String) session.getAttribute("userRole");

if (username == null) {
    response.sendRedirect("Login.jsp");
    return;
}
//String SessionId = session.getId();
//out.println("Session ID: " +
//SessionId);

// Get product ID from request parameter
String productId = request.getParameter("id");
if (productId == null || productId.trim().isEmpty()) {
    response.sendRedirect("Showproducts.jsp");
    return;
}

// Product details variables
String productName = "";
String productBrand = "";
double productPrice = 0.0;
String productDescription = "";
String productImage = "";
String sellerId = "";
String[] productImages = new String[0]; // Array to hold multiple images
boolean productFound = false;

try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    PreparedStatement ps = con.prepareStatement("SELECT id, product_name, brand, price, description, image, seller_id FROM product WHERE id = ?");
    ps.setString(1, productId);
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
        productFound = true;
        productName = rs.getString("product_name");
        productBrand = rs.getString("brand");
        productPrice = rs.getDouble("price");
        productDescription = rs.getString("description");
        productImage = rs.getString("image");
        sellerId = rs.getString("seller_id");
        
        // Handle multiple images for slider
        if (productImage != null && !productImage.trim().isEmpty()) {
            if (productImage.contains(",")) {
                productImages = productImage.split(",");
                for (int i = 0; i < productImages.length; i++) {
                    productImages[i] = productImages[i].trim();
                }
            } else {
                productImages = new String[]{productImage.trim()};
            }
        } else {
            // No image found
        }
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

        .header-actions {
            margin-top: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 15px;
        }

        .wishlist-btn {
            background: linear-gradient(135deg, #e91e63, #c2185b);
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 16px;
            box-shadow: 0 4px 15px rgba(233, 30, 99, 0.3);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            cursor: pointer;
            white-space: nowrap;
            text-transform: none;
            letter-spacing: 0.5px;
        }

        .wishlist-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(233, 30, 99, 0.4);
            background: linear-gradient(135deg, #c2185b, #ad1457);
            border-color: rgba(255, 255, 255, 0.1);
            text-decoration: none;
            color: white;
        }

        .wishlist-btn i {
            transition: transform 0.3s ease;
        }

        .wishlist-btn:hover i {
            transform: scale(1.1);
        }
        
        .cart-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 16px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            cursor: pointer;
            white-space: nowrap;
            text-transform: none;
            letter-spacing: 0.5px;
            position: relative;
            overflow: hidden;
        }

        .cart-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            border-color: rgba(255, 255, 255, 0.1);
            text-decoration: none;
            color: white;
        }

        .cart-btn i {
            transition: transform 0.3s ease;
        }

        .cart-btn:hover i {
            transform: scale(1.1);
        }

        .cart-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }

        .cart-btn:hover::before {
            left: 100%;
        }

        /* Cart Badge for Item Count */
        .cart-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #e74c3c;
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            font-size: 12px;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid white;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
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
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 14px 28px;
            text-decoration: none;
            border-radius: 50px;
            margin-bottom: 20px;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
            font-weight: 600;
            font-size: 1rem;
            backdrop-filter: blur(10px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
        }
        
        .back-link::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }
        
        .back-link:hover::before {
            left: 100%;
        }
        
        .back-link:hover {
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            transform: translateY(-3px) translateX(-5px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
        }
        
        .back-link i {
            font-size: 1.1rem;
            transition: transform 0.3s ease;
        }
        
        .back-link:hover i {
            transform: translateX(-3px);
        }
        
        /* FORCE HORIZONTAL LAYOUT - OVERRIDE ALL */
        .product-detail-container {
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: nowrap !important;
        }
        
        @media (max-width: 480px) {
            .product-detail-container {
                flex-wrap: wrap !important;
            }
            
            .product-image-section {
                flex: 1 1 100% !important;
                min-width: 100% !important;
                padding: 15px !important;
            }
            
            .product-info-section {
                flex: 1 1 100% !important;
                padding: 15px !important;
            }
        }
        
        .product-detail-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            overflow: hidden;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.15);
            min-height: 600px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: fadeInUp 0.8s ease-out;
        }
        
        .product-image-section {
            flex: 1.2;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px;
            min-width: 400px;
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
        
        /* Image Slider Styles */
        .image-slider-container {
            position: relative;
            width: 100%;
            max-width: 450px;
            margin: 0 auto;
        }
        
        .image-slider {
            position: relative;
            width: 100%;
            height: 450px;
            overflow: hidden;
            border-radius: 20px;
        }
        
        .slider-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: contain;
            opacity: 0;
            transition: opacity 0.5s ease-in-out;
        }
        
        .slider-image.active {
            opacity: 1;
        }
        
        .slider-controls {
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 10px;
            z-index: 10;
        }
        
        .slider-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.8);
        }
        
        .slider-dot.active {
            background: white;
            transform: scale(1.2);
        }
        
        .slider-nav {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 24px;
            font-weight: bold;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
            z-index: 10;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        
        .slider-nav:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-50%) scale(1.1);
        }
        
        .slider-nav.prev {
            left: 15px;
        }
        
        .slider-nav.next {
            right: 15px;
        }
        
        .image-counter {
            position: absolute;
            top: 15px;
            right: 15px;
            background: rgba(0, 0, 0, 0.6);
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            backdrop-filter: blur(10px);
            z-index: 10;
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
            flex-wrap: wrap;
            align-items: center;
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
            .container {
                max-width: 100%;
                padding: 0 20px;
            }
            
            .product-detail-container {
                flex-direction: row !important;
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
            
            .product-detail-container {
                flex-direction: row !important;
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
                .container {
                    max-width: 100%;
                    padding: 0 20px;
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
            
            @media (max-width: 480px) {
                .product-detail-container {
                    flex-direction: row !important;
                    flex-wrap: wrap;
                }
                
                .product-image-section {
                    flex: 1 1 100%;
                    min-width: 100%;
                    padding: 15px;
                }
                
                .product-info-section {
                    flex: 1 1 100%;
                    padding: 15px;
                }
            }
        
        /* ========================================
           BACK BUTTON DEDICATED STYLESHEET
           ======================================== */
        
        /* Back Button Base Styles */
        .back-button-container {
            position: fixed;
            top: 60px;
            left: 20px;
            z-index: 1000;
        }
        
        .back-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            color: white;
            padding: 14px 24px;
            border: none;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
            backdrop-filter: blur(15px);
            border: 2px solid rgba(255, 255, 255, 0.3);
            overflow: hidden;
            position: relative;
            min-width: 120px;
            justify-content: center;
        }
        
        /* Back Button Icon Styles */
        .back-button i {
            font-size: 1.1rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            color: #FFFFFF;
            position: relative;
            z-index: 3;
            display: block;
        }
        
        /* Back Button Text Styles */
        .back-button span {
            font-weight: 600;
            letter-spacing: 0.5px;
            position: relative;
            z-index: 3;
            transition: all 0.3s ease;
        }
        
        /* Back Button Hover Effects */
        .back-button:hover {
            transform: translateY(-4px) translateX(-6px) scale(1.08);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.6);
            background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 50%, #e074f7 100%);
            border-color: rgba(255, 255, 255, 0.5);
            color: white;
        }
        
        .back-button:hover i {
            transform: translateX(-4px) scale(1.2) rotate(-8deg);
            color: #FFFFFF;
        }
        
        .back-button:hover span {
            transform: translateX(-2px);
            letter-spacing: 1px;
        }
        
        /* Back Button Active State */
        .back-button:active {
            transform: translateY(-2px) translateX(-3px) scale(1.05);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
            transition: all 0.1s ease;
        }
        
        /* Back Button Focus State */
        .back-button:focus {
            outline: none;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4), 0 0 0 4px rgba(102, 126, 234, 0.3);
        }
        
        /* Back Button Shine Effect */
        .back-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            transition: left 0.6s ease;
            z-index: 2;
        }
        
        .back-button:hover::before {
            left: 100%;
        }
        
        /* Back Button Ripple Effect */
        .back-button::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.3) 0%, transparent 70%);
            transform: translate(-50%, -50%);
            transition: width 0.8s ease, height 0.8s ease;
            z-index: 1;
        }
        
        .back-button:hover::after {
            width: 120%;
            height: 120%;
        }
        
        /* Back Button Particle Effect */
        .back-button .particle {
            position: absolute;
            width: 4px;
            height: 4px;
            background: rgba(255, 255, 255, 0.8);
            border-radius: 50%;
            opacity: 0;
            transition: all 0.6s ease;
            z-index: 4;
        }
        
        .back-button:hover .particle:nth-child(1) {
            transform: translate(-20px, -10px);
            opacity: 1;
            transition-delay: 0.1s;
        }
        
        .back-button:hover .particle:nth-child(2) {
            transform: translate(15px, -15px);
            opacity: 1;
            transition-delay: 0.2s;
        }
        
        .back-button:hover .particle:nth-child(3) {
            transform: translate(-10px, 15px);
            opacity: 1;
            transition-delay: 0.3s;
        }
        
        /* Back Button Glow Effect */
        .back-button .glow {
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            background: linear-gradient(45deg, #667eea, #764ba2, #f093fb, #667eea);
            border-radius: 50px;
            opacity: 0;
            z-index: -1;
            transition: opacity 0.3s ease;
            animation: glowRotate 3s linear infinite;
        }
        
        .back-button:hover .glow {
            opacity: 0.7;
        }
        
        @keyframes glowRotate {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Back Button Pulse Effect */
        .back-button .pulse {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 100%;
            height: 100%;
            border: 2px solid rgba(255, 255, 255, 0.5);
            border-radius: 50px;
            transform: translate(-50%, -50%);
            opacity: 0;
            z-index: 0;
        }
        
        .back-button:hover .pulse {
            animation: pulseEffect 1.5s ease-out infinite;
        }
        
        @keyframes pulseEffect {
            0% {
                transform: translate(-50%, -50%) scale(1);
                opacity: 0.8;
            }
            100% {
                transform: translate(-50%, -50%) scale(1.3);
                opacity: 0;
            }
        }
        
        /* ========================================
           BACK BUTTON COLOR STYLESHEET
           ======================================== */
        
        /* Primary Color Theme - Default */
        .back-button.color-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }
        
        .back-button.color-primary:hover {
            background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 50%, #e074f7 100%);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.6);
        }
        
        .back-button.color-primary .glow {
            background: linear-gradient(45deg, #667eea, #764ba2, #f093fb, #667eea);
        }
        
        /* Success Color Theme */
        .back-button.color-success {
            background: linear-gradient(135deg, #22c55e 0%, #16a34a 50%, #10b981 100%);
            box-shadow: 0 8px 25px rgba(34, 197, 94, 0.4);
        }
        
        .back-button.color-success:hover {
            background: linear-gradient(135deg, #16a34a 0%, #15803d 50%, #059669 100%);
            box-shadow: 0 15px 40px rgba(34, 197, 94, 0.6);
        }
        
        .back-button.color-success .glow {
            background: linear-gradient(45deg, #22c55e, #16a34a, #10b981, #22c55e);
        }
        
        /* Warning Color Theme */
        .back-button.color-warning {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 50%, #ea580c 100%);
            box-shadow: 0 8px 25px rgba(245, 158, 11, 0.4);
        }
        
        .back-button.color-warning:hover {
            background: linear-gradient(135deg, #d97706 0%, #b45309 50%, #c2410c 100%);
            box-shadow: 0 15px 40px rgba(245, 158, 11, 0.6);
        }
        
        .back-button.color-warning .glow {
            background: linear-gradient(45deg, #f59e0b, #d97706, #ea580c, #f59e0b);
        }
        
        /* Danger Color Theme */
        .back-button.color-danger {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 50%, #b91c1c 100%);
            box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
        }
        
        .back-button.color-danger:hover {
            background: linear-gradient(135deg, #dc2626 0%, #b91c1c 50%, #991b1b 100%);
            box-shadow: 0 15px 40px rgba(239, 68, 68, 0.6);
        }
        
        .back-button.color-danger .glow {
            background: linear-gradient(45deg, #ef4444, #dc2626, #b91c1c, #ef4444);
        }
        
        /* Info Color Theme */
        .back-button.color-info {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 50%, #1d4ed8 100%);
            box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
        }
        
        .back-button.color-info:hover {
            background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 50%, #1e40af 100%);
            box-shadow: 0 15px 40px rgba(59, 130, 246, 0.6);
        }
        
        .back-button.color-info .glow {
            background: linear-gradient(45deg, #3b82f6, #2563eb, #1d4ed8, #3b82f6);
        }
        
        /* Dark Color Theme */
        .back-button.color-dark {
            background: linear-gradient(135deg, #1f2937 0%, #111827 50%, #030712 100%);
            box-shadow: 0 8px 25px rgba(31, 41, 55, 0.4);
        }
        
        .back-button.color-dark:hover {
            background: linear-gradient(135deg, #111827 0%, #030712 50%, #000000 100%);
            box-shadow: 0 15px 40px rgba(31, 41, 55, 0.6);
        }
        
        .back-button.color-dark .glow {
            background: linear-gradient(45deg, #1f2937, #111827, #030712, #1f2937);
        }
        
        /* Light Color Theme */
        .back-button.color-light {
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #cbd5e1 100%);
            color: #1e293b;
            box-shadow: 0 8px 25px rgba(248, 250, 252, 0.4);
        }
        
        .back-button.color-light:hover {
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 50%, #94a3b8 100%);
            box-shadow: 0 15px 40px rgba(248, 250, 252, 0.6);
        }
        
        .back-button.color-light .glow {
            background: linear-gradient(45deg, #f8fafc, #e2e8f0, #cbd5e1, #f8fafc);
        }
        
        /* Purple Color Theme */
        .back-button.color-purple {
            background: linear-gradient(135deg, #9333ea 0%, #7c3aed 50%, #6d28d9 100%);
            box-shadow: 0 8px 25px rgba(147, 51, 234, 0.4);
        }
        
        .back-button.color-purple:hover {
            background: linear-gradient(135deg, #7c3aed 0%, #6d28d9 50%, #5b21b6 100%);
            box-shadow: 0 15px 40px rgba(147, 51, 234, 0.6);
        }
        
        .back-button.color-purple .glow {
            background: linear-gradient(45deg, #9333ea, #7c3aed, #6d28d9, #9333ea);
        }
        
        /* Pink Color Theme */
        .back-button.color-pink {
            background: linear-gradient(135deg, #ec4899 0%, #db2777 50%, #be185d 100%);
            box-shadow: 0 8px 25px rgba(236, 72, 153, 0.4);
        }
        
        .back-button.color-pink:hover {
            background: linear-gradient(135deg, #db2777 0%, #be185d 50%, #9f1239 100%);
            box-shadow: 0 15px 40px rgba(236, 72, 153, 0.6);
        }
        
        .back-button.color-pink .glow {
            background: linear-gradient(45deg, #ec4899, #db2777, #be185d, #ec4899);
        }
        
        /* Teal Color Theme */
        .back-button.color-teal {
            background: linear-gradient(135deg, #14b8a6 0%, #0d9488 50%, #0f766e 100%);
            box-shadow: 0 8px 25px rgba(20, 184, 166, 0.4);
        }
        
        .back-button.color-teal:hover {
            background: linear-gradient(135deg, #0d9488 0%, #0f766e 50%, #115e59 100%);
            box-shadow: 0 15px 40px rgba(20, 184, 166, 0.6);
        }
        
        .back-button.color-teal .glow {
            background: linear-gradient(45deg, #14b8a6, #0d9488, #0f766e, #14b8a6);
        }
        
        /* Indigo Color Theme */
        .back-button.color-indigo {
            background: linear-gradient(135deg, #6366f1 0%, #4f46e5 50%, #4338ca 100%);
            box-shadow: 0 8px 25px rgba(99, 102, 241, 0.4);
        }
        
        .back-button.color-indigo:hover {
            background: linear-gradient(135deg, #4f46e5 0%, #4338ca 50%, #3730a3 100%);
            box-shadow: 0 15px 40px rgba(99, 102, 241, 0.6);
        }
        
        .back-button.color-indigo .glow {
            background: linear-gradient(45deg, #6366f1, #4f46e5, #4338ca, #6366f1);
        }
        
        /* Rose Color Theme */
        .back-button.color-rose {
            background: linear-gradient(135deg, #f43f5e 0%, #e11d48 50%, #be123c 100%);
            box-shadow: 0 8px 25px rgba(244, 63, 94, 0.4);
        }
        
        .back-button.color-rose:hover {
            background: linear-gradient(135deg, #e11d48 0%, #be123c 50%, #9f1239 100%);
            box-shadow: 0 15px 40px rgba(244, 63, 94, 0.6);
        }
        
        .back-button.color-rose .glow {
            background: linear-gradient(45deg, #f43f5e, #e11d48, #be123c, #f43f5e);
        }
        
        /* Emerald Color Theme */
        .back-button.color-emerald {
            background: linear-gradient(135deg, #10b981 0%, #059669 50%, #047857 100%);
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.4);
        }
        
        .back-button.color-emerald:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 50%, #065f46 100%);
            box-shadow: 0 15px 40px rgba(16, 185, 129, 0.6);
        }
        
        .back-button.color-emerald .glow {
            background: linear-gradient(45deg, #10b981, #059669, #047857, #10b981);
        }
        
        /* Amber Color Theme */
        .back-button.color-amber {
            background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 50%, #d97706 100%);
            box-shadow: 0 8px 25px rgba(251, 191, 36, 0.4);
        }
        
        .back-button.color-amber:hover {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 50%, #b45309 100%);
            box-shadow: 0 15px 40px rgba(251, 191, 36, 0.6);
        }
        
        .back-button.color-amber .glow {
            background: linear-gradient(45deg, #fbbf24, #f59e0b, #d97706, #fbbf24);
        }
        
        /* Cyan Color Theme */
        .back-button.color-cyan {
            background: linear-gradient(135deg, #06b6d4 0%, #0891b2 50%, #0e7490 100%);
            box-shadow: 0 8px 25px rgba(6, 182, 212, 0.4);
        }
        
        .back-button.color-cyan:hover {
            background: linear-gradient(135deg, #0891b2 0%, #0e7490 50%, #155e75 100%);
            box-shadow: 0 15px 40px rgba(6, 182, 212, 0.6);
        }
        
        .back-button.color-cyan .glow {
            background: linear-gradient(45deg, #06b6d4, #0891b2, #0e7490, #06b6d4);
        }
        
        /* Slate Color Theme */
        .back-button.color-slate {
            background: linear-gradient(135deg, #64748b 0%, #475569 50%, #334155 100%);
            box-shadow: 0 8px 25px rgba(100, 116, 139, 0.4);
        }
        
        .back-button.color-slate:hover {
            background: linear-gradient(135deg, #475569 0%, #334155 50%, #1e293b 100%);
            box-shadow: 0 15px 40px rgba(100, 116, 139, 0.6);
        }
        
        .back-button.color-slate .glow {
            background: linear-gradient(45deg, #64748b, #475569, #334155, #64748b);
        }
        
        /* ========================================
           BACK BUTTON GRADIENT VARIATIONS
           ======================================== */
        
        /* Sunset Gradient */
        .back-button.gradient-sunset {
            background: linear-gradient(135deg, #ff6b6b 0%, #feca57 50%, #ff9ff3 100%);
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
        }
        
        .back-button.gradient-sunset:hover {
            background: linear-gradient(135deg, #ee5a52 0%, #feca57 50%, #ff6b9d 100%);
            box-shadow: 0 15px 40px rgba(255, 107, 107, 0.6);
        }
        
        .back-button.gradient-sunset .glow {
            background: linear-gradient(45deg, #ff6b6b, #feca57, #ff9ff3, #ff6b6b);
        }
        
        /* Ocean Gradient */
        .back-button.gradient-ocean {
            background: linear-gradient(135deg, #0077be 0%, #00a8cc 50%, #74c0fc 100%);
            box-shadow: 0 8px 25px rgba(0, 119, 190, 0.4);
        }
        
        .back-button.gradient-ocean:hover {
            background: linear-gradient(135deg, #005a8b 0%, #0088aa 50%, #5a9fd4 100%);
            box-shadow: 0 15px 40px rgba(0, 119, 190, 0.6);
        }
        
        .back-button.gradient-ocean .glow {
            background: linear-gradient(45deg, #0077be, #00a8cc, #74c0fc, #0077be);
        }
        
        /* Forest Gradient */
        .back-button.gradient-forest {
            background: linear-gradient(135deg, #2d5016 0%, #73a942 50%, #aad576 100%);
            box-shadow: 0 8px 25px rgba(45, 80, 22, 0.4);
        }
        
        .back-button.gradient-forest:hover {
            background: linear-gradient(135deg, #1a2f0a 0%, #5a8c2a 50%, #8bc34a 100%);
            box-shadow: 0 15px 40px rgba(45, 80, 22, 0.6);
        }
        
        .back-button.gradient-forest .glow {
            background: linear-gradient(45deg, #2d5016, #73a942, #aad576, #2d5016);
        }
        
        /* Galaxy Gradient */
        .back-button.gradient-galaxy {
            background: linear-gradient(135deg, #2e1065 0%, #7c3aed 50%, #a78bfa 100%);
            box-shadow: 0 8px 25px rgba(46, 16, 101, 0.4);
        }
        
        .back-button.gradient-galaxy:hover {
            background: linear-gradient(135deg, #1e0a3c 0%, #6d28d9 50%, #8b5cf6 100%);
            box-shadow: 0 15px 40px rgba(46, 16, 101, 0.6);
        }
        
        .back-button.gradient-galaxy .glow {
            background: linear-gradient(45deg, #2e1065, #7c3aed, #a78bfa, #2e1065);
        }
        
        /* Candy Gradient */
        .back-button.gradient-candy {
            background: linear-gradient(135deg, #ff006e 0%, #ffbe0b 50%, #fb5607 100%);
            box-shadow: 0 8px 25px rgba(255, 0, 110, 0.4);
        }
        
        .back-button.gradient-candy:hover {
            background: linear-gradient(135deg, #e6005c 0%, #ffb700 50%, #fa4d0a 100%);
            box-shadow: 0 15px 40px rgba(255, 0, 110, 0.6);
        }
        
        .back-button.gradient-candy .glow {
            background: linear-gradient(45deg, #ff006e, #ffbe0b, #fb5607, #ff006e);
        }
        
        /* ========================================
           BACK BUTTON COLOR RESPONSIVE STYLES
           ======================================== */
        
        /* Tablet Responsive */
        @media (max-width: 768px) {
            .back-button-container {
                top: 15px;
                left: 15px;
            }
            
            .back-button {
                padding: 12px 20px;
                font-size: 0.9rem;
                min-width: 100px;
            }
            
            .back-button i {
                font-size: 1rem;
            }
            
            .back-button:hover {
                transform: translateY(-3px) translateX(-4px) scale(1.06);
            }
            
            .back-button:hover i {
                transform: translateX(-3px) scale(1.15) rotate(-6deg);
            }
        }
        
        /* Mobile Responsive */
        @media (max-width: 480px) {
            .back-button-container {
                top: 10px;
                left: 10px;
            }
            
            .back-button {
                padding: 10px 18px;
                font-size: 0.85rem;
                min-width: 90px;
                gap: 6px;
            }
            
            .back-button i {
                font-size: 0.9rem;
            }
            
            .back-button:hover {
                transform: translateY(-2px) translateX(-3px) scale(1.04);
            }
            
            .back-button:hover i {
                transform: translateX(-2px) scale(1.1) rotate(-4deg);
            }
            
            .back-button span {
                font-weight: 500;
            }
        }
        
        /* Small Mobile Responsive */
        @media (max-width: 360px) {
            .back-button-container {
                top: 8px;
                left: 8px;
            }
            
            .back-button {
                padding: 8px 16px;
                font-size: 0.8rem;
                min-width: 80px;
            }
            
            .back-button i {
                font-size: 0.85rem;
            }
        }
        
        /* ========================================
           LEGACY BACK BUTTON STYLES (FOR COMPATIBILITY)
           ======================================== */
        
        .reverse-btn {
            position: fixed;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 14px 24px;
            border: none;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 1000;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.2);
            overflow: hidden;
            position: relative;
        }
        
        .reverse-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }

        .reverse-btn:hover::before {
            left: 100%;
        }

        .reverse-btn:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(102, 126, 234, 0.4);
            transition: all 0.1s ease;
        }

        .reverse-btn:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4), 0 0 0 3px rgba(102, 126, 234, 0.2);
        }

        .reverse-btn i {
            font-size: 1.1rem;
            transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            color: #FFFFFF;
            position: relative;
            z-index: 2;
        }

        .reverse-btn:hover i {
            transform: translateX(-3px) scale(1.15) rotate(-5deg);
        }

        .reverse-btn:hover {
            transform: translateY(-3px) translateX(-5px) scale(1.05);
            box-shadow: 0 12px 35px rgba(102, 126, 234, 0.5);
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            border-color: rgba(255, 255, 255, 0.4);
            color: white;
        }

        .reverse-btn::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.3);
            transform: translate(-50%, -50%);
            transition: width 0.6s ease, height 0.6s ease;
        }

        .reverse-btn:hover::after {
            width: 100%;
            height: 100%;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .reverse-btn {
                top: 15px;
                left: 15px;
                padding: 12px 20px;
                font-size: 0.9rem;
            }
            
            .reverse-btn i {
                font-size: 1rem;
            }
        }

        @media (max-width: 480px) {
            .reverse-btn {
                top: 10px;
                left: 10px;
                padding: 10px 18px;
                font-size: 0.85rem;
                gap: 6px;
            }
            
            .reverse-btn i {
                font-size: 0.9rem;
            }
        }
        
        /* ========================================
           BACK TO HOME BUTTON STYLES
                font-size: 13px;
            }
        }
        
        /* ========================================
           BACK TO HOME BUTTON STYLES
           ======================================== */
        .back-to-home-btn-left {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            cursor: pointer;
            white-space: nowrap;
            text-transform: none;
            letter-spacing: 0.5px;
        }

        .back-to-home-btn-left:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
            background: linear-gradient(135deg, #45a049, #3d8b40);
            border-color: rgba(255, 255, 255, 0.1);
            text-decoration: none;
            color: white;
        }

        .back-to-home-btn-left:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(76, 175, 80, 0.3);
            transition: all 0.1s ease;
        }

        .back-to-home-btn-left:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3), 0 0 0 3px rgba(76, 175, 80, 0.2);
        }

        /* Icon styling */
        .back-to-home-btn-left i {
            font-size: 16px;
            margin-right: 2px;
            transition: transform 0.3s ease;
        }

        .back-to-home-btn-left:hover i {
            transform: scale(1.1);
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .back-to-home-btn-left {
                top: 15px;
                left: 15px;
                padding: 10px 16px;
                font-size: 13px;
                border-radius: 20px;
            }
            
            .back-to-home-btn-left i {
                font-size: 14px;
            }
        }

        @media (max-width: 480px) {
            .back-to-home-btn-left {
                top: 10px;
                left: 10px;
                padding: 8px 14px;
                font-size: 12px;
                border-radius: 18px;
                gap: 6px;
            }
            
            .back-to-home-btn-left i {
                font-size: 13px;
            }
        }

        /* High contrast mode support */
        @media (prefers-contrast: high) {
            .back-to-home-btn-left {
                border: 2px solid #ffffff;
                background: #4CAF50;
            }
            
            .back-to-home-btn-left:hover {
                background: #45a049;
                border: 2px solid #ffffff;
            }
        }

        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            .back-to-home-btn-left {
                transition: none;
            }
            
            .back-to-home-btn-left:hover {
                transform: none;
                transition: none;
            }
            
            .back-to-home-btn-left i {
                transition: none;
            }
            
            .back-to-home-btn-left:hover i {
                transform: none;
            }
        }

        /* Dark mode support */
        @media (prefers-color-scheme: dark) {
            .back-to-home-btn-left {
                background: linear-gradient(135deg, #45a049, #3d8b40);
                box-shadow: 0 4px 15px rgba(69, 160, 73, 0.4);
            }
            
            .back-to-home-btn-left:hover {
                background: linear-gradient(135deg, #3d8b40, #2e7d32);
                box-shadow: 0 6px 20px rgba(69, 160, 73, 0.5);
            }
        }

        /* Print styles */
        @media print {
            .back-to-home-btn-left {
                display: none !important;
            }
        }

        /* Loading state */
        .back-to-home-btn-left.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .back-to-home-btn-left.loading i::before {
            content: "\f110"; /* fa-spinner */
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Success state */
        .back-to-home-btn-left.success {
            background: linear-gradient(135deg, #28a745, #20c997);
            animation: pulse 0.5s ease;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        /* Error state */
        .back-to-home-btn-left.error {
            background: linear-gradient(135deg, #dc3545, #c82333);
            animation: shake 0.5s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
        
        /* ========================================
           BACK TO HOME BUTTON STYLES
           ======================================== */
        .back-to-home-btn-left {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            cursor: pointer;
            white-space: nowrap;
            text-transform: none;
            letter-spacing: 0.5px;
        }

        .back-to-home-btn-left:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
            background: linear-gradient(135deg, #45a049, #3d8b40);
            border-color: rgba(255, 255, 255, 0.1);
            text-decoration: none;
            color: white;
        }

        .back-to-home-btn-left:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(76, 175, 80, 0.3);
            transition: all 0.1s ease;
        }

        .back-to-home-btn-left:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3), 0 0 0 3px rgba(76, 175, 80, 0.2);
        }

        /* Icon styling */
        .back-to-home-btn-left i {
            font-size: 16px;
            margin-right: 2px;
            transition: transform 0.3s ease;
        }

        .back-to-home-btn-left:hover i {
            transform: scale(1.1);
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .back-to-home-btn-left {
                top: 15px;
                left: 15px;
                padding: 10px 16px;
                font-size: 13px;
                border-radius: 20px;
            }
            
            .back-to-home-btn-left i {
                font-size: 14px;
            }
        }

        @media (max-width: 480px) {
            .back-to-home-btn-left {
                top: 10px;
                left: 10px;
                padding: 8px 14px;
                font-size: 12px;
                border-radius: 18px;
                gap: 6px;
            }
            
            .back-to-home-btn-left i {
                font-size: 13px;
            }
        }

        /* High contrast mode support */
        @media (prefers-contrast: high) {
            .back-to-home-btn-left {
                border: 2px solid #ffffff;
                background: #4CAF50;
            }
            
            .back-to-home-btn-left:hover {
                background: #45a049;
                border: 2px solid #ffffff;
            }
        }

        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            .back-to-home-btn-left {
                transition: none;
            }
            
            .back-to-home-btn-left:hover {
                transform: none;
                transition: none;
            }
            
            .back-to-home-btn-left i {
                transition: none;
            }
            
            .back-to-home-btn-left:hover i {
                transform: none;
            }
        }

        /* Dark mode support */
        @media (prefers-color-scheme: dark) {
            .back-to-home-btn-left {
                background: linear-gradient(135deg, #45a049, #3d8b40);
                box-shadow: 0 4px 15px rgba(69, 160, 73, 0.4);
            }
            
            .back-to-home-btn-left:hover {
                background: linear-gradient(135deg, #3d8b40, #2e7d32);
                box-shadow: 0 6px 20px rgba(69, 160, 73, 0.5);
            }
        }

        /* Print styles */
        @media print {
            .back-to-home-btn-left {
                display: none !important;
            }
        }

        /* Loading state */
        .back-to-home-btn-left.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .back-to-home-btn-left.loading i::before {
            content: "\f110"; /* fa-spinner */
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Success state */
        .back-to-home-btn-left.success {
            background: linear-gradient(135deg, #28a745, #20c997);
            animation: pulse 0.5s ease;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        /* Error state */
        .back-to-home-btn-left.error {
            background: linear-gradient(135deg, #dc3545, #c82333);
            animation: shake 0.5s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
        
        /* ========================================
           WISHLIST HEART BUTTON STYLES
           ======================================== */
        .wishlist-heart {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.9);
            border: none;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            color: #e74c3c;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            transition: all 0.3s ease;
            z-index: 100;
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .wishlist-heart:hover {
            transform: scale(1.1);
            box-shadow: 0 12px 35px rgba(231, 76, 60, 0.3);
            background: rgba(255, 255, 255, 1);
        }
        
        .wishlist-heart:active {
            transform: scale(0.95);
        }
        
        .wishlist-heart.active {
            color: #e74c3c;
            background: rgba(231, 76, 60, 0.1);
            border-color: #e74c3c;
        }
        
        .wishlist-heart.active .heart-icon {
            content: '❤️';
            animation: heartBeat 0.6s ease;
        }
        
        .wishlist-heart .heart-icon {
            font-size: 30px;
            transition: all 0.3s ease;
        }
        
        .wishlist-heart:not(.active):hover .heart-icon {
            content: '❤️';
            opacity: 0.7;
        }
        
        @keyframes heartBeat {
            0% { transform: scale(1); }
            25% { transform: scale(1.3); }
            50% { transform: scale(1.1); }
            75% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
        
        .wishlist-tooltip {
            position: absolute;
            top: 60px;
            right: 0;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 8px 12px;
            border-radius: 8px;
            font-size: 12px;
            white-space: nowrap;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease;
            backdrop-filter: blur(10px);
        }
        
        .wishlist-heart:hover .wishlist-tooltip {
            opacity: 1;
        }
        
        /* Responsive wishlist button */
        @media (max-width: 768px) {
            .wishlist-heart {
                width: 55px;
                height: 55px;
                font-size: 26px;
                top: 15px;
                right: 15px;
            }
            
            .wishlist-heart .heart-icon {
                font-size: 26px;
            }
        }
        
        @media (max-width: 480px) {
            .wishlist-heart {
                width: 50px;
                height: 50px;
                font-size: 24px;
                top: 10px;
                right: 10px;
            }
            
            .wishlist-heart .heart-icon {
                font-size: 24px;
            }
        }
        
        /* ========================================
           WISHLIST LINK BUTTON STYLES
           ======================================== */
        .wishlist-link-btn {
            position: fixed;
            top: 60px;
            left: 160px;
            background: linear-gradient(135deg, #e91e63, #c2185b);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 15px rgba(233, 30, 99, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
            letter-spacing: 0.5px;
        }
        
        .wishlist-link-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(233, 30, 99, 0.4);
            background: linear-gradient(135deg, #c2185b, #ad1457);
            color: white;
        }
        
        .wishlist-link-btn:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(233, 30, 99, 0.3);
            transition: all 0.1s ease;
        }
        
        .wishlist-link-btn:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(233, 30, 99, 0.3), 0 0 0 3px rgba(233, 30, 99, 0.2);
        }
        
        .wishlist-link-btn i {
            font-size: 16px;
            transition: transform 0.3s ease;
        }
        
        .wishlist-link-btn:hover i {
            transform: scale(1.1);
        }
        
        @media (max-width: 768px) {
            .wishlist-link-btn {
                top: 15px;
                left: 15px;
                padding: 10px 16px;
                font-size: 13px;
                border-radius: 20px;
            }
            
            .wishlist-link-btn i {
                font-size: 14px;
            }
        }
        
        @media (max-width: 480px) {
            .wishlist-link-btn {
                top: 10px;
                left: 10px;
                padding: 8px 14px;
                font-size: 12px;
                gap: 6px;
            }
            
            .wishlist-link-btn i {
                font-size: 13px;
            }
            
        }

        /* ========================================
           ENHANCED BACK BUTTON STYLES - OVERRIDE
           ======================================== */
        
        /* Enhanced Back Button with Purple Theme */
        .back-to-home-btn-left {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%) !important;
            padding: 14px 24px !important;
            border-radius: 50px !important;
            font-weight: 700 !important;
            font-size: 16px !important;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4) !important;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1) !important;
            gap: 10px !important;
            border: 2px solid rgba(255, 255, 255, 0.3) !important;
            letter-spacing: 0.8px !important;
            backdrop-filter: blur(15px) !important;
            overflow: hidden !important;
            position: relative !important;
            min-width: 130px !important;
            justify-content: center !important;
        }

        /* Enhanced Shine Effect */
        .back-to-home-btn-left::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            transition: left 0.6s ease;
            z-index: 2;
        }

        .back-to-home-btn-left:hover::before {
            left: 100%;
        }

        /* Enhanced Hover Effects */
        .back-to-home-btn-left:hover {
            transform: translateY(-4px) translateX(-6px) scale(1.08) !important;
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.6) !important;
            background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 50%, #e074f7 100%) !important;
            border-color: rgba(255, 255, 255, 0.5) !important;
            text-decoration: none !important;
            color: white !important;
        }

        /* Enhanced Icon Animation */
        .back-to-home-btn-left i {
            font-size: 18px !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            color: #FFFFFF !important;
            position: relative !important;
            z-index: 3 !important;
        }

        .back-to-home-btn-left:hover i {
            transform: translateX(-4px) scale(1.2) rotate(-8deg) !important;
            color: #FFFFFF !important;
        }

        /* Enhanced Active State */
        .back-to-home-btn-left:active {
            transform: translateY(-2px) translateX(-3px) scale(1.05) !important;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4) !important;
            transition: all 0.1s ease !important;
        }

        /* Enhanced Focus State */
        .back-to-home-btn-left:focus {
            outline: none !important;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4), 0 0 0 4px rgba(102, 126, 234, 0.3) !important;
        }

        /* Enhanced Responsive Design */
        @media (max-width: 768px) {
            .back-to-home-btn-left {
                top: 15px !important;
                left: 15px !important;
                padding: 12px 20px !important;
                font-size: 15px !important;
                min-width: 110px !important;
            }
            
            .back-to-home-btn-left i {
                font-size: 16px !important;
            }

            .back-to-home-btn-left:hover {
                transform: translateY(-3px) translateX(-4px) scale(1.06) !important;
            }
        }

        @media (max-width: 480px) {
            .back-to-home-btn-left {
                top: 10px !important;
                left: 10px !important;
                padding: 10px 18px !important;
                font-size: 14px !important;
                gap: 8px !important;
                min-width: 100px !important;
            }
            
            .back-to-home-btn-left i {
                font-size: 15px !important;
            }

            .back-to-home-btn-left:hover {
                transform: translateY(-2px) translateX(-3px) scale(1.04) !important;
            }
        }

        @media (max-width: 360px) {
            .back-to-home-btn-left {
                top: 8px !important;
                left: 8px !important;
                padding: 8px 16px !important;
                font-size: 13px !important;
                min-width: 90px !important;
            }
            
            .back-to-home-btn-left i {
                font-size: 14px !important;
            }
        }
        
        /* Quantity Selector Responsive Styles */
        @media (max-width: 768px) {
            .product-actions {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }
            
            .quantity-selector {
                align-self: flex-start;
                margin-bottom: 10px;
            }
            
            .quantity-controls {
                width: fit-content;
            }
        }
        
        @media (max-width: 480px) {
            .quantity-selector {
                margin-bottom: 15px;
            }
            
            .qty-btn {
                width: 35px;
                height: 35px;
                font-size: 16px;
            }
            
            #quantity {
                width: 50px;
                height: 35px;
                font-size: 14px;
            }
        }
        
        @media (max-width: 360px) {
            .quantity-controls {
                transform: scale(0.9);
            }
        }
        </style>
    </head>
    <body>
       
        
              <a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page"><i class="fas fa-home"></i> Back </a>

       
        
        <div class="container">
            <header>
                <h1>🛍️ Product Details</h1>
                <div class="header-actions">
                    <a href="Cart.jsp" class="cart-btn" id="cartBtn">
                        <i class="fas fa-shopping-cart"></i> My Cart
                        <span class="cart-badge" id="cartBadge" style="display: none;">0</span>
                    </a>
                    <a href="Wishlist.jsp" class="wishlist-btn">
                        <i class="fas fa-heart"></i> My Wishlist
                    </a>
                </div>
            </header>
            
    <%
    if (productFound) {
    %>
            <div class="product-detail-container">
                <div class="product-image-section">
    <%
        // Check if we have multiple images for slider
        if (productImages.length > 1) {
            // Multiple images - show slider
    %>
                    <div class="image-slider-container" id="sliderData" data-total-slides="<%=productImages.length%>">
                        <!-- Wishlist Heart Button -->
                        <button class="wishlist-heart" id="wishlistHeart" onclick="toggleWishlist()" title="Add to Wishlist">
                            <span class="heart-icon">🤍</span>
                        </button>
                        
                        <div class="image-slider" id="imageSlider">
    <%
            for (int i = 0; i < productImages.length; i++) {
                String imgSrc = "product_images/" + productImages[i].trim();
                String activeClass = (i == 0) ? "active" : "";
    %>
                            <img src="<%=imgSrc%>" alt="<%=productName%> - Image <%=i+1%>" 
                                 class="slider-image <%=activeClass%>" 
                                 onerror="tryFallbackImage(this, '<%=productImages[i].trim()%>')">
    <%
            }
    %>
                        </div>
                        
                        <!-- Navigation arrows -->
                        <button class="slider-nav prev" id="prevBtn">❮</button>
                        <button class="slider-nav next" id="nextBtn">❯</button>
                        
                        <!-- Image counter -->
                        <div class="image-counter" id="imageCounter">1 / <%=productImages.length%></div>
                        
                        <!-- Dot indicators -->
                        <div class="slider-controls" id="sliderControls">
    <%
            for (int i = 0; i < productImages.length; i++) {
                String activeClass = (i == 0) ? "active" : "";
    %>
                            <span class="slider-dot <%=activeClass%>" data-slide="<%=i%>"></span>
    <%
            }
    %>
                        </div>
                    </div>
    <%
        } else {
            // Single image - show normal image
            String imageSrc = "";
            if (productImage != null && !productImage.trim().isEmpty()) {
                // Try product_images first (for Addproducts.jsp uploads)
                imageSrc = "product_images/" + productImage;
            } else {
                imageSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgdmlld0JveD0iMCAwIDQwMCA0MDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iNDAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNTAgMTUwSDI1MFYyNTBIMTUwVjE1MFoiIGZpbGw9IiNDQ0NDQ0QiLz4KPHA+PC9wPgo8dGV4dCB4PSIyMDAiIHk9IjMyMCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxOCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pjo8L3N2Zz4=";
            }
    %>
                    <div class="product-image-section">
                        <!-- Wishlist Heart Button -->
                        <button class="wishlist-heart" id="wishlistHeart" onclick="toggleWishlist()" title="Add to Wishlist">
                            <span class="heart-icon">🤍</span>
                        </button>
                        
                        <img src="<%=imageSrc%>" alt="<%=productName%>" class="product-image" 
                             onerror="tryFallbackImage(this, '<%=productImage%>')">
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
                <a href="Showproducts.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Products</a>
            </div>
    <%
    }
    %>
        </div>
        
        <!-- Notification -->
        <div class="notification" id="notification"></div>
        
        <script>
            // Image Slider Functions
            let currentSlideIndex = 0;
            // Get total slides from data attribute to avoid JSP expression in JS
            const totalSlides = parseInt(document.getElementById('sliderData').dataset.totalSlides) || 1;
            
            function changeSlide(direction) {
                let newSlideIndex = currentSlideIndex + direction;
                
                // Add circular navigation (wrap-around)
                if (newSlideIndex < 0) {
                    newSlideIndex = totalSlides - 1;
                } else if (newSlideIndex >= totalSlides) {
                    newSlideIndex = 0;
                }
                
                currentSlide(newSlideIndex);
            }
            
            function currentSlide(slideIndex) {
                // Update current slide index
                currentSlideIndex = slideIndex;
                
                // Update images
                const images = document.querySelectorAll('.slider-image');
                images.forEach((img, index) => {
                    if (index === slideIndex) {
                        img.classList.add('active');
                    } else {
                        img.classList.remove('active');
                    }
                });
                
                // Update dots
                const dots = document.querySelectorAll('.slider-dot');
                dots.forEach((dot, index) => {
                    if (index === slideIndex) {
                        dot.classList.add('active');
                    } else {
                        dot.classList.remove('active');
                    }
                });
                
                // Update counter
                const counter = document.getElementById('imageCounter');
                if (counter) {
                    counter.textContent = (slideIndex + 1) + ' / ' + totalSlides;
                }
            }
            
            // Add event listeners when DOM is loaded
            document.addEventListener('DOMContentLoaded', function() {
                // Add click event listeners to navigation buttons
                const prevBtn = document.getElementById('prevBtn');
                const nextBtn = document.getElementById('nextBtn');
                
                if (prevBtn) {
                    prevBtn.addEventListener('click', function() {
                        changeSlide(-1);
                    });
                }
                
                if (nextBtn) {
                    nextBtn.addEventListener('click', function() {
                        changeSlide(1);
                    });
                }
                
                // Add click event listeners to dots
                const dots = document.querySelectorAll('.slider-dot');
                dots.forEach((dot, index) => {
                    dot.addEventListener('click', function() {
                        currentSlide(index);
                    });
                });
                
                // Add keyboard navigation support
                document.addEventListener('keydown', function(event) {
                    if (event.key === 'ArrowLeft') {
                        changeSlide(-1);
                    } else if (event.key === 'ArrowRight') {
                        changeSlide(1);
                    }
                });
                
                // Add touch/swipe support for mobile
                let touchStartX = 0;
                let touchEndX = 0;
                
                const sliderContainer = document.querySelector('.image-slider-container');
                if (sliderContainer) {
                    sliderContainer.addEventListener('touchstart', function(event) {
                        touchStartX = event.changedTouches[0].screenX;
                    }, false);
                    
                    sliderContainer.addEventListener('touchend', function(event) {
                        touchEndX = event.changedTouches[0].screenX;
                        handleSwipe();
                    }, false);
                }
                
                function handleSwipe() {
                    const swipeThreshold = 50;
                    const diff = touchStartX - touchEndX;
                    
                    if (Math.abs(diff) > swipeThreshold) {
                        if (diff > 0) {
                            // Swipe left - go to next slide
                            changeSlide(1);
                        } else {
                            // Swipe right - go to previous slide
                            changeSlide(-1);
                        }
                    }
                }
            });
            
            function addToCart() {
                const productId = '<%=productId%>';
                const quantity = 1;
                const button = event.target;
                const originalText = button.innerHTML;
                
                // Show loading state
                button.innerHTML = '⏳ Adding...';
                button.disabled = true;
                
                // Send AJAX request to CartServlet
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'CartServlet', true);
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
                                    showNotification('Added to cart successfully!', 'success');
                                    // Update cart count after successful addition
                                    updateCartCount();
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
                
                xhr.send('action=addToCart&productId=' + encodeURIComponent(productId));
            }
            
            // Function to update cart count badge
            function updateCartCount() {
                const xhr = new XMLHttpRequest();
                xhr.open('GET', 'CartServlet', true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success && response.items) {
                                const cartBadge = document.getElementById('cartBadge');
                                const totalItems = response.items.reduce((sum, item) => sum + item.quantity, 0);
                                
                                if (totalItems > 0) {
                                    cartBadge.textContent = totalItems > 99 ? '99+' : totalItems;
                                    cartBadge.style.display = 'flex';
                                } else {
                                    cartBadge.style.display = 'none';
                                }
                            }
                        } catch (e) {
                            console.error('Error updating cart count:', e);
                        }
                    }
                };
                xhr.send();
            }
            
            // Load cart count on page load
            document.addEventListener('DOMContentLoaded', function() {
                updateCartCount();
            });
            
            
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
                // Get current product details
                const productId = '<%=productId%>';
                const productName = '<%=productName%>';
                const price = <%=productPrice%>;
                const productImage = '<%=productImage%>';
                const sellerId = '<%=sellerId%>';
                
                // Store single product for direct purchase
                const buyNowProduct = {
                    id: productId,
                    name: productName,
                    price: price,
                    image: productImage,
                    sellerId: sellerId,
                    quantity: 1
                };
                
                // Store in sessionStorage for Payment.jsp
                sessionStorage.setItem('buyNowProduct', JSON.stringify(buyNowProduct));
                
                showNotification('Redirecting to payment...', 'success');
                setTimeout(() => {
                    window.location.href = 'Payment.jsp?buyNow=true&productId=' + productId + '&sellerId=' + sellerId;
                }, 1000);
            }
            
            // Fallback image function - tries seller_images if product_images fails
            function tryFallbackImage(img, fileName) {
                if (!fileName || fileName.trim() === '') {
                    img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgdmlld0JveD0iMCAwIDQwMCA0MDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iNDAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNTAgMTUwSDI1MFYyNTBIMTUwVjE1MFoiIGZpbGw9IiNDQ0NDQ0QiLz4KPHA+PC9wPgo8dGV4dCB4PSIyMDAiIHk9IjMyMCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxOCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4=';
                    return;
                }
                
                // If current src is product_images, try seller_images
                if (img.src.includes('product_images/')) {
                    const newSrc = img.src.replace('product_images/', 'seller_images/');
                    img.src = newSrc;
                } else {
                    // If seller_images also fails, use placeholder
                    img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgdmlld0JveD0iMCAwIDQwMCA0MDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iNDAwIiBmaWxsPSIjRjBGMEYwIi8+CjxwYXRoIGQ9Ik0xNTAgMTUwSDI1MFYyNTBIMTUwVjE1MFoiIGZpbGw9IiNDQ0NDQ0QiLz4KPHA+PC9wPgo8dGV4dCB4PSIyMDAiIHk9IjMyMCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZmlsbD0iIzk5OTk5OSIgZm9udC1zaXplPSIxOCIgZm9udC1mYW1pbHk9IkFyaWFsIj5JbWFnZSBOb3QgQXZhaWxhYmxlPC90ZXh0Pgo8L3N2Zz4=';
                }
            }
            
            // Wishlist functionality
            function toggleWishlist() {
                const wishlistHeart = document.getElementById('wishlistHeart');
                const heartIcon = wishlistHeart.querySelector('.heart-icon');
                const productId = '<%=productId%>';
                const productName = '<%=productName%>';
                const productPrice = <%=productPrice%>;
                const productImage = '<%=productImage%>';
                
                // Check if product is already in wishlist
                const isInWishlist = wishlistHeart.classList.contains('active');
                
                if (isInWishlist) {
                    // Remove from wishlist
                    removeFromWishlist(productId);
                    wishlistHeart.classList.remove('active');
                    heartIcon.textContent = '🤍';
                    showNotification('Removing from wishlist...', 'success');
                } else {
                    // Add to wishlist
                    addToWishlist(productId);
                    wishlistHeart.classList.add('active');
                    heartIcon.textContent = '❤️';
                    showNotification('Adding to wishlist...', 'success');
                }
            }
            
            function addToWishlist(productId) {
                // Send AJAX request to WishlistServlet
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'WishlistServlet', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        if (xhr.status === 200) {
                            try {
                                const response = JSON.parse(xhr.responseText);
                                if (response.success) {
                                    showNotification(response.message, 'success');
                                } else {
                                    // Revert UI if failed
                                    const wishlistHeart = document.getElementById('wishlistHeart');
                                    const heartIcon = wishlistHeart.querySelector('.heart-icon');
                                    wishlistHeart.classList.remove('active');
                                    heartIcon.textContent = '🤍';
                                    showNotification(response.message, 'error');
                                }
                            } catch (e) {
                                showNotification('Error adding to wishlist', 'error');
                            }
                        } else {
                            showNotification('Server error. Please try again.', 'error');
                        }
                    }
                };
                
                xhr.send('action=add&productId=' + encodeURIComponent(productId));
            }
            
            function removeFromWishlist(productId) {
                // Send AJAX request to WishlistServlet
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'WishlistServlet', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        if (xhr.status === 200) {
                            try {
                                const response = JSON.parse(xhr.responseText);
                                if (response.success) {
                                    showNotification(response.message, 'success');
                                } else {
                                    // Revert UI if failed
                                    const wishlistHeart = document.getElementById('wishlistHeart');
                                    const heartIcon = wishlistHeart.querySelector('.heart-icon');
                                    wishlistHeart.classList.add('active');
                                    heartIcon.textContent = '❤️';
                                    showNotification(response.message, 'error');
                                }
                            } catch (e) {
                                showNotification('Error removing from wishlist', 'error');
                            }
                        } else {
                            showNotification('Server error. Please try again.', 'error');
                        }
                    }
                };
                
                xhr.send('action=remove&productId=' + encodeURIComponent(productId));
            }
            
            // Check if product is already in wishlist on page load
            document.addEventListener('DOMContentLoaded', function() {
                const wishlistHeart = document.getElementById('wishlistHeart');
                const heartIcon = wishlistHeart.querySelector('.heart-icon');
                const productId = '<%=productId%>';
                
                // Check if product is in wishlist via AJAX
                const xhr = new XMLHttpRequest();
                xhr.open('POST', 'WishlistServlet', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        if (xhr.status === 200) {
                            try {
                                const response = JSON.parse(xhr.responseText);
                                if (response.success && response.inWishlist) {
                                    wishlistHeart.classList.add('active');
                                    heartIcon.textContent = '❤️';
                                } else {
                                    heartIcon.textContent = '🤍';
                                }
                            } catch (e) {
                                heartIcon.textContent = '🤍';
                            }
                        } else {
                            heartIcon.textContent = '🤍';
                        }
                    }
                };
                
                xhr.send('action=check&productId=' + encodeURIComponent(productId));
            });
        </script>
    </body>
    </html>