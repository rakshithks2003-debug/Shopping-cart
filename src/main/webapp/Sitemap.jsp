<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
String username = null;
String userRole = null;
boolean isLoggedIn = false;

if (sessionObj != null && sessionObj.getAttribute("isLoggedIn") != null) {
    isLoggedIn = (Boolean) sessionObj.getAttribute("isLoggedIn");
    username = (String) sessionObj.getAttribute("username");
    userRole = (String) sessionObj.getAttribute("userRole");
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sitemap - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        /* Header */
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 0;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border-radius: 20px;
            margin-bottom: 40px;
        }

        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .header p {
            font-size: 1.1rem;
            opacity: 0.95;
        }

        .back-btn {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 12px 24px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            transition: all 0.3s;
            z-index: 1000;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
            color: white;
        }

        /* Container */
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* Sitemap Tree */
        .sitemap-tree {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }

        .tree-node {
            margin: 20px 0;
        }

        .node-content {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.2);
            transition: all 0.3s;
            cursor: pointer;
            position: relative;
        }

        .node-content:hover {
            transform: translateX(5px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
        }

        .node-content i {
            font-size: 1.3rem;
        }

        .node-children {
            margin-left: 40px;
            margin-top: 15px;
            border-left: 3px solid #e5e7eb;
            padding-left: 20px;
        }

        .child-node {
            margin: 12px 0;
            position: relative;
        }

        .child-node::before {
            content: '';
            position: absolute;
            left: -23px;
            top: 50%;
            width: 20px;
            height: 2px;
            background: #e5e7eb;
        }

        .child-link {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 18px;
            background: #f8f9fa;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            text-decoration: none;
            color: #333;
            font-weight: 500;
            transition: all 0.3s;
            font-size: 0.95rem;
        }

        .child-link:hover {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            border-color: #667eea;
            color: #667eea;
            transform: translateX(5px);
        }

        .child-link i {
            font-size: 1rem;
            color: #667eea;
        }

        .section-title {
            font-size: 1.8rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .badge {
            display: inline-block;
            padding: 4px 12px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-left: 10px;
        }

        .restricted {
            opacity: 0.6;
            pointer-events: none;
        }

        .restricted .child-link {
            background: #f5f5f5;
            border-color: #ddd;
            color: #999;
        }

        /* Stats */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            text-align: center;
            transition: all 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 15px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: white;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 800;
            color: #333;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .header h1 {
                font-size: 1.8rem;
            }

            .sitemap-tree {
                padding: 25px;
            }

            .node-children {
                margin-left: 20px;
                padding-left: 15px;
            }

            .back-btn {
                position: static;
                margin-bottom: 20px;
                display: inline-flex;
            }
        }
    </style>
</head>
<body>
    <a href="<%= isLoggedIn ? "Home.jsp" : "Login.html" %>" class="back-btn">
        <i class="fas fa-arrow-left"></i> Back
    </a>

    <div class="header">
        <div class="header-content">
            <h1><i class="fas fa-sitemap"></i> Site Navigation Map</h1>
            <p>Complete overview of Mini Shopping Cart application structure</p>
        </div>
    </div>

    <div class="container">
        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-layer-group"></i>
                </div>
                <div class="stat-value">7</div>
                <div class="stat-label">Main Sections</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stat-value">30+</div>
                <div class="stat-label">Total Pages</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-value">3</div>
                <div class="stat-label">User Roles</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <div class="stat-value">Secure</div>
                <div class="stat-label">Authentication</div>
            </div>
        </div>

        <!-- Sitemap Tree -->
        <div class="sitemap-tree">
            <h2 class="section-title">
                <i class="fas fa-home"></i> 
                <% if ("admin".equals(userRole)) { %>
                    Admin Dashboard
                <% } else if ("seller".equals(userRole)) { %>
                    Seller Dashboard
                <% } else { %>
                    User Navigation
                <% } %>
            </h2>

            <% if ("admin".equals(userRole)) { %>
                <!-- Admin View -->
                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-user-shield"></i>
                        <span>Admin Controls</span>
                        <span class="badge">ADMIN</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node">
                            <a href="Dashboard.jsp" class="child-link">
                                <i class="fas fa-chart-line"></i>
                                <span>Admin Dashboard</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Profile.jsp" class="child-link">
                                <i class="fas fa-user-circle"></i>
                                <span>Profile</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Adminproduct.jsp" class="child-link">
                                <i class="fas fa-plus-circle"></i>
                                <span>Add Product</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Updateproduct.jsp" class="child-link">
                                <i class="fas fa-edit"></i>
                                <span>Update Product</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Deleteproducts.jsp" class="child-link">
                                <i class="fas fa-trash"></i>
                                <span>Delete Product</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="SellerApproval.jsp" class="child-link">
                                <i class="fas fa-user-check"></i>
                                <span>Seller Approval</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="ApprovedProducts.jsp" class="child-link">
                                <i class="fas fa-check-double"></i>
                                <span>Approve Products</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-users-cog"></i>
                        <span>User Management</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node">
                            <a href="PaymentHistory.jsp" class="child-link">
                                <i class="fas fa-clipboard-list"></i>
                                <span>All Orders</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="DeliveryTracking.jsp" class="child-link">
                                <i class="fas fa-shipping-fast"></i>
                                <span>Delivery Management</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-eye"></i>
                        <span>View Website</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node">
                            <a href="Home.jsp" class="child-link">
                                <i class="fas fa-home"></i>
                                <span>User View</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Showproducts.jsp" class="child-link">
                                <i class="fas fa-shopping-bag"></i>
                                <span>All Products</span>
                            </a>
                        </div>
                    </div>
                </div>

            <% } else if ("seller".equals(userRole)) { %>
                <!-- Seller View -->
                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-store"></i>
                        <span>Seller Dashboard</span>
                        <span class="badge">SELLER</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node">
                            <a href="SellerDashboard.jsp" class="child-link">
                                <i class="fas fa-tachometer-alt"></i>
                                <span>Seller Dashboard</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="AddProduct.jsp" class="child-link">
                                <i class="fas fa-plus-circle"></i>
                                <span>Add Product</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Updateproduct.jsp" class="child-link">
                                <i class="fas fa-edit"></i>
                                <span>Update Product</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Deleteproducts.jsp" class="child-link">
                                <i class="fas fa-trash"></i>
                                <span>Delete Product</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="PaymentHistory.jsp" class="child-link">
                                <i class="fas fa-credit-card"></i>
                                <span>Payment History</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Profile.jsp" class="child-link">
                                <i class="fas fa-user-circle"></i>
                                <span>Profile</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-chart-line"></i>
                        <span>Sales Analytics</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node">
                            <a href="PaymentHistory.jsp" class="child-link">
                                <i class="fas fa-rupee-sign"></i>
                                <span>Revenue Overview</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="SellerDashboard.jsp" class="child-link">
                                <i class="fas fa-shopping-cart"></i>
                                <span>Order Management</span>
                            </a>
                        </div>
                    </div>
                </div>

            <% } else { %>
                <!-- Regular User View -->
                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-shopping-cart"></i>
                        <span>Shopping</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node">
                            <a href="Home.jsp" class="child-link">
                                <i class="fas fa-home"></i>
                                <span>Home</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Profile.jsp" class="child-link">
                                <i class="fas fa-user-circle"></i>
                                <span>Profile</span>
                            </a>
                            <% if (!isLoggedIn) { %>
                                <div class="restricted-badge">Login Required</div>
                            <% } %>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Showproducts.jsp?category=Mo" class="child-link">
                                <i class="fas fa-mobile-alt"></i>
                                <span>Mobile Phones</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Showproducts.jsp?category=Ms" class="child-link">
                                <i class="fas fa-shoe-prints"></i>
                                <span>Men's Shoes</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Showproducts.jsp?category=Lp" class="child-link">
                                <i class="fas fa-laptop"></i>
                                <span>Laptops</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Showproducts.jsp?category=Wo" class="child-link">
                                <i class="fas fa-tshirt"></i>
                                <span>Fashion</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Showproducts.jsp" class="child-link">
                                <i class="fas fa-th-large"></i>
                                <span>All Products</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-user"></i>
                        <span>My Account</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Cart.jsp" class="child-link">
                                <i class="fas fa-shopping-cart"></i>
                                <span>Shopping Cart</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Wishlist.jsp" class="child-link">
                                <i class="fas fa-heart"></i>
                                <span>Wishlist</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="OrderHistory.jsp" class="child-link">
                                <i class="fas fa-history"></i>
                                <span>Order History</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="DeliveryTracking.jsp" class="child-link">
                                <i class="fas fa-truck"></i>
                                <span>Track Order</span>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="tree-node">
                    <div class="node-content">
                        <i class="fas fa-credit-card"></i>
                        <span>Payment</span>
                    </div>
                    <div class="node-children">
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="Payment.jsp" class="child-link">
                                <i class="fas fa-credit-card"></i>
                                <span>Make Payment</span>
                            </a>
                        </div>
                        <div class="child-node <%= !isLoggedIn ? "restricted" : "" %>">
                            <a href="PaymentHistory.jsp" class="child-link">
                                <i class="fas fa-file-invoice-dollar"></i>
                                <span>Payment History</span>
                            </a>
                        </div>
                    </div>
                </div>

                <% if ("seller".equals(userRole)) { %>
                    <div class="tree-node">
                        <div class="node-content">
                            <i class="fas fa-store"></i>
                            <span>Seller Dashboard</span>
                            <span class="badge">SELLER</span>
                        </div>
                        <div class="node-children">
                            <div class="child-node">
                                <a href="SellerDashboard.jsp" class="child-link">
                                    <i class="fas fa-tachometer-alt"></i>
                                    <span>Seller Dashboard</span>
                                </a>
                            </div>
                            <div class="child-node">
                                <a href="AddProduct.jsp" class="child-link">
                                    <i class="fas fa-plus-circle"></i>
                                    <span>Add Product</span>
                                </a>
                            </div>
                            <div class="child-node">
                                <a href="Updateproduct.jsp" class="child-link">
                                    <i class="fas fa-edit"></i>
                                    <span>Update Product</span>
                                </a>
                            </div>
                            <div class="child-node">
                                <a href="Deleteproducts.jsp" class="child-link">
                                    <i class="fas fa-trash"></i>
                                    <span>Delete Product</span>
                                </a>
                            </div>
                            <div class="child-node">
                                <a href="PaymentHistory.jsp" class="child-link">
                                    <i class="fas fa-credit-card"></i>
                                    <span>Payment History</span>
                                </a>
                            </div>
                            <div class="child-node">
                                <a href="Profile.jsp" class="child-link">
                                    <i class="fas fa-user-circle"></i>
                                    <span>Profile</span>
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>

            <% } %>

            <!-- Common Authentication Section -->
            <div class="tree-node">
                <div class="node-content">
                    <i class="fas fa-lock"></i>
                    <span>Authentication</span>
                </div>
                <div class="node-children">
                    <% if (!isLoggedIn) { %>
                        <div class="child-node">
                            <a href="Login.html" class="child-link">
                                <i class="fas fa-sign-in-alt"></i>
                                <span>Login</span>
                            </a>
                        </div>
                        <div class="child-node">
                            <a href="Signup.jsp" class="child-link">
                                <i class="fas fa-user-plus"></i>
                                <span>Signup</span>
                            </a>
                        </div>
                    <% } else { %>
                        <div class="child-node">
                            <a href="LogoutServlet" class="child-link">
                                <i class="fas fa-sign-out-alt"></i>
                                <span>Logout</span>
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
