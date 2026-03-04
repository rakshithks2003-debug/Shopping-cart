<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.Dbase" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}

String username = (String) sessionObj.getAttribute("username");
String userRole = (String) sessionObj.getAttribute("userRole");
String userId = null;
String email = null;
String phone = null;
String address = null;
String sellerId = null;
String registrationDate = null;

// Fetch user details from database
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
    
    PreparedStatement ps = con.prepareStatement("SELECT user_id, username, email, phone, address, role, seller_id, created_at FROM users WHERE username = ?");
    ps.setString(1, username);
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
        userId = rs.getString("user_id");
        email = rs.getString("email");
        phone = rs.getString("phone");
        address = rs.getString("address");
        sellerId = rs.getString("seller_id");
        registrationDate = rs.getString("created_at");
    }
    
    rs.close();
    ps.close();
    con.close();
} catch (Exception e) {
    e.printStackTrace();
}

// Handle profile update
String updateMessage = "";
String messageType = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String newEmail = request.getParameter("email");
    String newPhone = request.getParameter("phone");
    String newAddress = request.getParameter("address");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
        
        PreparedStatement updatePs = con.prepareStatement("UPDATE users SET email = ?, phone = ?, address = ? WHERE username = ?");
        updatePs.setString(1, newEmail);
        updatePs.setString(2, newPhone);
        updatePs.setString(3, newAddress);
        updatePs.setString(4, username);
        
        int result = updatePs.executeUpdate();
        updatePs.close();
        con.close();
        
        if (result > 0) {
            updateMessage = "Profile updated successfully!";
            messageType = "success";
            // Update local variables
            email = newEmail;
            phone = newPhone;
            address = newAddress;
        } else {
            updateMessage = "Failed to update profile!";
            messageType = "error";
        }
    } catch (Exception e) {
        updateMessage = "Error updating profile: " + e.getMessage();
        messageType = "error";
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Mini Shopping Cart</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #8b5cf6;
            --primary-light: #a78bfa;
            --secondary: #ec4899;
            --accent: #14b8a6;
            --success: #22c55e;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #1e293b;
            --light: #f1f5f9;
            --white: #ffffff;
            --gray: #64748b;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: var(--dark);
            line-height: 1.6;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
            z-index: 0;
            pointer-events: none;
        }

        .page-wrapper {
            position: relative;
            z-index: 1;
        }

        /* Top Navigation */
        .top-nav {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 12px 28px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
        }

        .back-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.5);
        }

        .user-badge {
            display: flex;
            align-items: center;
            gap: 12px;
            background: var(--light);
            padding: 10px 20px;
            border-radius: 50px;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.1rem;
        }

        .user-details {
            display: flex;
            flex-direction: column;
        }

        .user-name {
            font-weight: 600;
            color: var(--dark);
            font-size: 0.95rem;
        }

        .user-role {
            font-size: 0.75rem;
            color: var(--gray);
            text-transform: capitalize;
        }

        /* Container */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 30px 60px;
        }

        /* Page Header */
        .page-header {
            text-align: center;
            padding: 60px 20px 40px;
            color: white;
        }

        .page-header h1 {
            font-size: 3.5rem;
            font-weight: 900;
            margin-bottom: 15px;
            text-shadow: 0 4px 20px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 20px;
        }

        .page-header p {
            font-size: 1.3rem;
            opacity: 0.95;
            font-weight: 400;
        }

        /* Alert Messages */
        .alert {
            padding: 20px 25px;
            border-radius: 20px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
            font-weight: 500;
            animation: slideIn 0.5s ease;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .alert-success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }

        .alert-error {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
        }

        .alert i {
            font-size: 1.8rem;
        }

        /* Profile Layout */
        .profile-layout {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 40px;
            margin-bottom: 40px;
        }

        /* Profile Card */
        .profile-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            height: fit-content;
        }

        .profile-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 800;
            font-size: 3rem;
            margin: 0 auto 20px;
            box-shadow: 0 10px 30px rgba(139, 92, 246, 0.4);
        }

        .profile-name {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--dark);
            margin-bottom: 5px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .profile-role {
            display: inline-block;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 8px 20px;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: capitalize;
        }

        .profile-info {
            margin-top: 30px;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid var(--light);
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: var(--gray);
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-label i {
            color: var(--primary);
        }

        .info-value {
            font-weight: 600;
            color: var(--dark);
            text-align: right;
        }

        /* Edit Form */
        .edit-form {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        }

        .form-title {
            font-size: 2rem;
            font-weight: 800;
            text-align: center;
            margin-bottom: 40px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 10px;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-label i {
            color: var(--primary);
        }

        .form-input {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid var(--light);
            border-radius: 15px;
            font-size: 1rem;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s;
            background: white;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1);
        }

        .form-textarea {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid var(--light);
            border-radius: 15px;
            font-size: 1rem;
            font-family: 'Poppins', sans-serif;
            transition: all 0.3s;
            background: white;
            resize: vertical;
            min-height: 120px;
        }

        .form-textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1);
        }

        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 16px 40px;
            border: none;
            border-radius: 50px;
            font-size: 1.05rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            font-family: 'Poppins', sans-serif;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(139, 92, 246, 0.6);
        }

        .btn-secondary {
            background: var(--gray);
            color: white;
        }

        .btn-secondary:hover {
            background: var(--dark);
            transform: translateY(-3px);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .top-nav {
                padding: 15px 20px;
                flex-direction: column;
                gap: 15px;
            }

            .page-header h1 {
                font-size: 2.5rem;
                flex-direction: column;
                gap: 10px;
            }

            .profile-layout {
                grid-template-columns: 1fr;
                gap: 30px;
            }

            .profile-card, .edit-form {
                padding: 30px 20px;
            }

            .form-actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="page-wrapper">
        <!-- Top Navigation -->
        <div class="top-nav">
            <a href="javascript:history.back()" class="back-btn">
                <i class="fas fa-arrow-left"></i> Back
            </a>
            <div class="user-badge">
                <div class="user-avatar">
                    <%= username != null ? username.substring(0, 1).toUpperCase() : "U" %>
                </div>
                <div class="user-details">
                    <span class="user-name"><%= username != null ? username : "User" %></span>
                    <span class="user-role"><%= userRole != null ? userRole : "Guest" %></span>
                </div>
            </div>
        </div>

        <!-- Page Header -->
        <div class="page-header">
            <h1>
                <i class="fas fa-user-circle"></i>
                My Profile
            </h1>
            <p>Manage your personal information and account settings</p>
        </div>

        <div class="container">
            <!-- Alert Messages -->
            <% if (!updateMessage.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <i class="fas fa-<%= messageType.equals("success") ? "check-circle" : "exclamation-triangle" %>"></i>
                    <span><%= updateMessage %></span>
                </div>
            <% } %>

            <!-- Profile Layout -->
            <div class="profile-layout">
                <!-- Profile Information Card -->
                <div class="profile-card">
                    <div class="profile-header">
                        <div class="profile-avatar">
                            <%= username != null ? username.substring(0, 1).toUpperCase() : "U" %>
                        </div>
                        <div class="profile-name"><%= username != null ? username : "User" %></div>
                        <div class="profile-role"><%= userRole != null ? userRole : "Guest" %></div>
                    </div>
                    
                    <div class="profile-info">
                        <% if (sellerId != null) { %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-store"></i> Seller ID
                            </span>
                            <span class="info-value"><%= sellerId %></span>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Edit Profile Form -->
                <div class="edit-form">
                    <h2 class="form-title">
                        <i class="fas fa-edit"></i>
                        Edit Profile Information
                    </h2>
                    <form action="Profile.jsp" method="post">
                        <div class="form-group">
                            <label class="form-label" for="username">
                                <i class="fas fa-user"></i> Username
                            </label>
                            <input type="text" id="username" class="form-input" value="<%= username != null ? username : "" %>" readonly>
                            <small style="color: var(--gray); font-size: 0.85rem; margin-top: 5px; display: block;">Username cannot be changed</small>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="email">
                                <i class="fas fa-envelope"></i> Email Address
                            </label>
                            <input type="email" id="email" name="email" class="form-input" value="<%= email != null ? email : "" %>" placeholder="Enter your email address">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="phone">
                                <i class="fas fa-phone"></i> Phone Number
                            </label>
                            <input type="tel" id="phone" name="phone" class="form-input" value="<%= phone != null ? phone : "" %>" placeholder="Enter your phone number">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="address">
                                <i class="fas fa-map-marker-alt"></i> Address
                            </label>
                            <textarea id="address" name="address" class="form-textarea" placeholder="Enter your address"><%= address != null ? address : "" %></textarea>
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> Update Profile
                            </button>

                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
