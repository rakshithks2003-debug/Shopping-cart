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

/* Delete Button */
.delete-btn {
    background: #f44336;
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    transition: background 0.3s ease;
}

.delete-btn:hover {
    background: #d32f2f;
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
        <a href="Deleteproducts.jsp">🗑️ Delete products</a>
<% if ("admin".equals(userRole)) { %>
        <a href="Showproducts.jsp">🛍️ Products</a>
        
        <a href="admin.jsp">🔧 Add & Update </a>
        <a href="Seller.jsp">👤 Seller</a>
        <a href="Sellerupload.jsp">👤 Sellerupload</a>
<% } %>
        <a href="#">📦 Orders</a>
<% if ("admin".equals(userRole)) { %>
        <a href="#">👥 Users</a>
<% } %>
        <a href="LogoutServlet">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">

       
</div>

</body>
</html>
