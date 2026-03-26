<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%
// Check if user is logged in
String username = (String) session.getAttribute("username");

if (username == null) {
    response.sendRedirect("Login.jsp");
    return;
}

// Get form parameters
String productId = request.getParameter("productId");
String productName = request.getParameter("productName");
String ratingStr = request.getParameter("rating");
String reviewText = request.getParameter("reviewText");

// Validate input
if (productId == null || ratingStr == null) {
    response.sendRedirect("Details.jsp?id=" + productId + "&error=invalid_rating");
    return;
}

int rating = 0;
try {
    rating = Integer.parseInt(ratingStr);
    if (rating < 1 || rating > 5) {
        response.sendRedirect("Details.jsp?id=" + productId + "&error=invalid_rating");
        return;
    }
} catch (NumberFormatException e) {
    response.sendRedirect("Details.jsp?id=" + productId + "&error=invalid_rating");
    return;
}

try {
    Dbase db = new Dbase();
    Connection con = db.initailizeDatabase();
    
    // Get user_id
    PreparedStatement userPs = con.prepareStatement("SELECT user_id FROM users WHERE username = ?");
    userPs.setString(1, username);
    ResultSet userRs = userPs.executeQuery();
    
    if (userRs.next()) {
        String userId = userRs.getString("user_id");
        
        // Check if user has already rated this product
        PreparedStatement checkPs = con.prepareStatement(
            "SELECT id FROM reviews WHERE product_id = ? AND user_id = ?");
        checkPs.setString(1, productId);
        checkPs.setString(2, userId);
        ResultSet checkRs = checkPs.executeQuery();
        
        if (checkRs.next()) {
            // Update existing rating
            PreparedStatement updatePs = con.prepareStatement(
                "UPDATE reviews SET rating = ?, review_text = ?, updated_at = CURRENT_TIMESTAMP " +
                "WHERE product_id = ? AND user_id = ?");
            updatePs.setInt(1, rating);
            updatePs.setString(2, reviewText);
            updatePs.setString(3, productId);
            updatePs.setString(4, userId);
            updatePs.executeUpdate();
            updatePs.close();
        } else {
            // Insert new rating
            PreparedStatement insertPs = con.prepareStatement(
                "INSERT INTO reviews (product_id, user_id, username, rating, review_text) " +
                "VALUES (?, ?, ?, ?, ?)");
            insertPs.setString(1, productId);
            insertPs.setString(2, userId);
            insertPs.setString(3, username);
            insertPs.setInt(4, rating);
            insertPs.setString(5, reviewText);
            insertPs.executeUpdate();
            insertPs.close();
        }
        
        checkRs.close();
        checkPs.close();
    }
    
    userRs.close();
    userPs.close();
    con.close();
    
    // Redirect back to product details with success message
    response.sendRedirect("Details.jsp?id=" + productId + "&success=rating_submitted");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("Details.jsp?id=" + productId + "&error=rating_failed");
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submitting Rating...</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .loading {
            text-align: center;
            padding: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .spinner {
            font-size: 2rem;
            margin-bottom: 20px;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="loading">
        <div class="spinner">⭐</div>
        <h2>Submitting your rating...</h2>
        <p>You will be redirected back to the product page.</p>
    </div>
</body>
</html>
