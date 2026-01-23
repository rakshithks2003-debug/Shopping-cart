<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
<title>Mini Shopping Cart - Home</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #1a1a1a;
            overflow-x: hidden;
        }

        header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            padding: 30px 0;
            text-align: center;
            position: relative;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }

        header h1 {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            letter-spacing: -0.02em;
        }

        header h1.institution-name {
            font-size: 2.5rem;
            font-weight: 800;
            background: blue;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 5px;
            letter-spacing: 0.02em;
            text-transform: uppercase;
            position: relative;
            animation: institutionGlow 3s ease-in-out infinite alternate;
        }

        @keyframes institutionGlow {
            0% {
                filter: drop-shadow(0px 0px 10px rgba(255, 107, 107, 0.3));
                transform: scale(1);
            }
            100% {
                filter: drop-shadow(0px 0px 20px rgba(78, 205, 196, 0.5));
                transform: scale(1.02);
            }
        }

        header p {
            color: #666;
            font-size: 1.2rem;
            font-weight: 500;
        }

        nav {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        nav a {
            color: #1a1a1a;
            margin: 0 20px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            padding: 12px 24px;
            border-radius: 25px;
            transition: all 0.3s ease;
            display: inline-block;
        }

        nav a:hover {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }

        .hero {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            color: #1a1a1a;
            padding: 60px 40px;
            text-align: center;
            margin: 40px 20px;
            border-radius: 30px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            position: relative;
            overflow: hidden;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #667eea);
            background-size: 200% 100%;
            animation: shimmer 3s linear infinite;
        }

        @keyframes shimmer {
            0% { background-position: -200% 0; }
            100% { background-position: 200% 0; }
        }

        .hero h1 {
            font-size: 2.5rem;
            font-weight: 800;
            color: #1a1a1a;
            margin-bottom: 15px;
        }

        .hero p {
            color: #666;
            font-size: 1.3rem;
            font-weight: 400;
        }

        .slider-container {
            width: 100%;
            max-width: 1400px;
            height: 500px;
            overflow: hidden;
            position: relative;
            margin: 40px auto;
            border-radius: 30px;
            box-shadow: 0 30px 60px rgba(0,0,0,0.2);
        }

        .slider {
            display: flex;
            animation: slide 20s infinite;
            width: 500%;
            height: 100%;
        }

        .slide {
            width: 20%;
            height: 100%;
            position: relative;
        }

        .slide img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        @keyframes slide {
            0% { transform: translateX(0); }
            16.66% { transform: translateX(0); }
            20% { transform: translateX(-20%); }
            36.66% { transform: translateX(-20%); }
            40% { transform: translateX(-40%); }
            56.66% { transform: translateX(-40%); }
            60% { transform: translateX(-60%); }
            76.66% { transform: translateX(-60%); }
            80% { transform: translateX(-80%); }
            96.66% { transform: translateX(-80%); }
            100% { transform: translateX(0); }
        }

        .slider-text {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            text-align: center;
            font-size: 3rem;
            font-weight: 900;
            text-shadow: 3px 3px 6px rgba(0,0,0,0.7);
            background: rgba(0,0,0,0.3);
            padding: 20px 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }

        .products {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
            padding: 40px 20px;
            max-width: 1400px;
            margin: 0 auto;
        }

        .product-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            cursor: pointer;
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            overflow: hidden;
        }

        .product-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .product-card:hover::before {
            transform: scaleX(1);
        }

        .product-card:hover {
            transform: translateY(-10px) scale(1.05);
            box-shadow: 0 25px 50px rgba(0,0,0,0.15);
            border-color: rgba(102, 126, 234, 0.5);
        }

        .product-card img {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border-radius: 15px;
            margin-bottom: 20px;
            transition: transform 0.3s ease;
        }

        .product-card:hover img {
            transform: scale(1.1);
        }

        .product-card h3 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1a1a1a;
            margin: 0;
        }

        .product-card button {
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        @media (max-width: 768px) {
            header h1 {
                font-size: 2.5rem;
            }
            
            .hero {
                margin: 20px 10px;
                padding: 40px 20px;
            }
            
            .hero h1 {
                font-size: 2rem;
            }
            
            .slider-container {
                height: 300px;
                margin: 20px 10px;
            }
            
            .slider-text {
                font-size: 1.8rem;
                padding: 15px 25px;
            }
            
            .products {
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                padding: 20px 10px;
            }
            
            .product-card {
                padding: 20px;
            }
            
            nav a {
                margin: 0 10px;
                padding: 10px 20px;
                font-size: 0.9rem;
            }
        }

        @media (max-width: 480px) {
            header h1 {
                font-size: 2rem;
            }
            
            .hero h1 {
                font-size: 1.8rem;
            }
            
            .slider-text {
                font-size: 1.4rem;
            }
            
            .products {
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                gap: 15px;
            }
            
            .product-card img {
                width: 80px;
                height: 80px;
            }
            
            .product-card h3 {
                font-size: 1.1rem;
            }
        }
    </style>
</head>

<body>

<header>
    <div style="position: absolute; top: 20px; right: 20px; background: rgba(255, 255, 255, 0.9); padding: 10px 20px; border-radius: 25px; font-weight: 600; color: #333; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
        👤 <%= username != null ? username : "User" %> (<%= userRole != null ? userRole : "Guest" %>)
    </div>
    <h2 class="institution-name">Cauvery Polytechnic Gonikoppal</h2>
    <h2>Online Shopping System</h2>
    <h1>Mini Shopping Cart</h1>
    <p>Welcome, <%= username != null ? username : "User" %>! Shop Smart, Shop Easy</p>
</header>

<nav>
    <a href=".jsp">cart</a>
<% if ("admin".equals(userRole)) { %>
  
    <a href="Dashboard.jsp">🔧 Admin Panel</a>
<% } %>
    <a href="LogoutServlet">🚪 Logout</a>
</nav>

<div class="hero">
    <h1>Welcome to Our Store</h1>
    <p>Best products at affordable prices</p>
</div>

<!-- Mobile & Shoes Image Slider -->
<div class="slider-container">
    <div class="slider">
        <div class="slide">
            <img src="https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1600&h=500&fit=crop" alt="Latest Mobiles">
            <div class="slider-text">Latest Mobiles</div>
        </div>
        <div class="slide">
            <img src="https://images.unsplash.com/photo-1549298916-b41d501d3772?w=1600&h=500&fit=crop" alt="Premium Shoes">
            <div class="slider-text">Premium Shoes</div>
        </div>
        <div class="slide">
            <img src="https://images.unsplash.com/photo-1605462863863-10d9e47e15ee?w=1600&h=500&fit=crop" alt="Mobile Fusion">
            <div class="slider-text">Mobile Fusion</div>
        </div>
        <div class="slide">
            <img src="https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1600&h=500&fit=crop" alt="Sports Shoes">
            <div class="slider-text">Sports Shoes</div>
        </div>
        <div class="slide">
            <img src="https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=1600&h=500&fit=crop" alt="Smart Mobiles">
            <div class="slider-text">Smart Mobiles</div>
        </div>
    </div>
</div>

<section class="products">
    <div class="product-card">
        <button href="Showproducts.jsp?category=Mo" onclick="window.location.href='Showproducts.jsp?category=Mo'">
            <img src="https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=120&h=120&fit=crop" alt="Mobile">
            <h3>Mobile</h3>
        </button>
    </div>
    <div class="product-card">
        <button href="Showproducts.jsp?category=Ms" onclick="window.location.href='Showproducts.jsp?category=Ms'">
            <img src="https://images.unsplash.com/photo-1549298916-b41d501d3772?w=120&h=120&fit=crop" alt="Men Shoe">
            <h3>Men Shoe</h3>
        </button>
    </div>
    <div class="product-card">
        <button onclick="window.location.href='Products.html'">
            <img src="https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=120&h=120&fit=crop" alt="Laptop">
            <h3>Laptop</h3>
        </button>
    </div>
  
</section>
<footer align="center">Developed and Designed by Rakshith.k.S,Saajida.A.M,Prajwal.B.R,Mohammed Adil</footer>
</body>
</html>