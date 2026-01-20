<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Seller List</title>

<style>
body {
    font-family: Arial;
    background: #f4f6f9;
}

table {
    width: 90%;
    margin: 30px auto;
    border-collapse: collapse;
    background: white;
}

th, td {
    padding: 12px;
    text-align: center;
    border: 1px solid #ddd;
}

th {
    background: #2874f0;
    color: white;
}

tr:hover {
    background: #f1f1f1;
}

.action-btn {
    padding: 6px 12px;
    text-decoration: none;
    color: white;
    border-radius: 4px;
}

.approve {
    background: green;
}

.reject {
    background: red;
}
</style>
</head>

<body>

<h2 style="text-align:center;">Seller Management</h2>

<table>
<tr>
    <th>ID</th>
    <th>Name</th>
    <th>Email</th>
    <th>Phone</th>
    <th>Shop Name</th>
    <th>Status</th>
    <th>Action</th>
</tr>

<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/shopping", "root", "password");

    PreparedStatement ps = con.prepareStatement("SELECT * FROM sellers");
    ResultSet rs = ps.executeQuery();

    while (rs.next()) {
%>

<tr>
    <td><%= rs.getInt("seller_id") %></td>
    <td><%= rs.getString("name") %></td>
    <td><%= rs.getString("email") %></td>
    <td><%= rs.getString("phone") %></td>
    <td><%= rs.getString("shop_name") %></td>
    <td><%= rs.getString("status") %></td>
    <td>
        <a class="action-btn approve"
           href="ApproveSellerServlet?id=<%= rs.getInt("seller_id") %>">
           Approve
        </a>
        <a class="action-btn reject"
           href="RejectSellerServlet?id=<%= rs.getInt("seller_id") %>">
           Reject
        </a>
    </td>
</tr>

<%
    }
    con.close();
} catch (Exception e) {
    out.println(e);
}
%>

</table>

</body>
</html>
