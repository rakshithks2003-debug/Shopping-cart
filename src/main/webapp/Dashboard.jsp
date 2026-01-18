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

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mini Shopping cart Dashboard</title>

<style>
/* Reset */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: Arial, sans-serif;
}

/* Body */
body {
    background-color: #f1f3f6;
}

/* Header */
.header {
    background-color: #2874f0;
    color: white;
    padding: 15px 30px;
    font-size: 22px;
    font-weight: bold;
}

/* Layout */
.container {
    display: flex;
}

/* Sidebar */
.sidebar {
    width: 220px;
    height: 100vh;
    background-color: #172337;
    padding-top: 20px;
}

.sidebar a {
    display: block;
    padding: 15px 20px;
    color: white;
    text-decoration: none;
    font-size: 16px;
}

.sidebar a:hover {
    background-color: #2874f0;
}

/* Main Content */
.main {
    flex: 1;
    padding: 30px;
}

/* Dashboard Cards */
.cards {
    display: flex;
    gap: 20px;
    margin-bottom: 30px;
}

.card {
    background-color: white;
    width: 220px;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    text-align: center;
}

.card h2 {
    color: #2874f0;
    margin-bottom: 10px;
}

.card p {
    font-size: 18px;
}

/* Table */
.table-container {
    background-color: white;
    padding: 20px;
    border-radius: 5px;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

th {
    background-color: #2874f0;
    color: white;
}

tr:hover {
    background-color: #f5f5f5;
}
</style>

</head>
<body>

<div class="header">
    <div style="float: right; background: rgba(255, 255, 255, 0.9); padding: 8px 16px; border-radius: 20px; font-weight: 600; color: #333; box-shadow: 0 3px 10px rgba(0,0,0,0.1); margin-right: 20px;">
        👤 <%= username != null ? username : "User" %> (<%= userRole != null ? userRole : "Guest" %>)
    </div>
    Mini Shopping cart Dashboard - Welcome, <%= username != null ? username : "User" %>!
</div>

<div class="container">

    <!-- Sidebar -->
    <div class="sidebar">
    	<a href="Home.jsp">🏠 Home</a>
        <a href="#">📊 Dashboard</a>
<% if ("admin".equals(userRole)) { %>
        <a href="Showproducts.jsp">🛍️ Products</a>
        
        <a href="admin.jsp">🔧 Add & Update </a>
<% } %>
        <a href="#">📦 Orders</a>
<% if ("admin".equals(userRole)) { %>
        <a href="#">👥 Users</a>
<% } %>
        <a href="LogoutServlet">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">

        <!-- Cards -->
        <div class="cards">
            <div class="card">
                <h2>120</h2>
                <p>Total Products</p>
            </div>

            <div class="card">
                <h2>85</h2>
                <p>Total Orders</p>
            </div>

            <div class="card">
                <h2>60</h2>
                <p>Total Users</p>
            </div>

            <div class="card">
                <h2>₹45,000</h2>
                <p>Total Revenue</p>
            </div>
        </div>

        <!-- Table -->
        <div class="table-container">
            <h2 style="margin-bottom:15px;">Recent Orders</h2>
            <table>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Product</th>
                    <th>Status</th>
                </tr>
                <tr>
                    <td>#101</td>
                    <td>Rahul</td>
                    <td>Mobile</td>
                    <td>Delivered</td>
                </tr>
                <tr>
                    <td>#102</td>
                    <td>Anita</td>
                    <td>Shoes</td>
                    <td>Pending</td>
                </tr>
                <tr>
                    <td>#103</td>
                    <td>Suresh</td>
                    <td>Laptop</td>
                    <td>Shipped</td>
                </tr>
            </table>
        </div>

    </div>
</div>

</body>
</html>
