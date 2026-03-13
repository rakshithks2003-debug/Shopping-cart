<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.Dbase" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.jsp");
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
String dateOfBirth = null;
String gender = null;
String fullName = null;

// Fetch user details from database
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
    
    // Get user_id and basic info from users table
    PreparedStatement userPs = con.prepareStatement("SELECT user_id, email, role, Seller_id FROM users WHERE username = ?");
    userPs.setString(1, username);
    ResultSet userRs = userPs.executeQuery();
    
    if (userRs.next()) {
        userId = userRs.getString("user_id");
        email = userRs.getString("email");
        sellerId = userRs.getString("Seller_id");
        System.out.println("DEBUG: Found user - Username: " + username + ", UserId: " + userId + ", Role: " + userRs.getString("role"));
    } else {
        System.out.println("DEBUG: User not found in database - Username: " + username);
    }
    userRs.close();
    userPs.close();
    
    // Get profile details from users_profile table
    if (userId != null) {
        PreparedStatement profilePs = con.prepareStatement("SELECT full_name, mobile_number, email_address, date_of_birth, gender, address FROM users_profile WHERE user_id = ?");
        profilePs.setString(1, userId);
        ResultSet profileRs = profilePs.executeQuery();
        
        if (profileRs.next()) {
            fullName = profileRs.getString("full_name");
            phone = profileRs.getString("mobile_number");
            email = profileRs.getString("email_address");
            dateOfBirth = profileRs.getString("date_of_birth");
            gender = profileRs.getString("gender");
            address = profileRs.getString("address");
        }
        profileRs.close();
        profilePs.close();
    }
    
    // If no profile data exists, use users table data as fallback for email only
    if ((email == null || email.isEmpty()) && userRs != null) {
        email = userRs.getString("email"); // from users table
    }
    
    if (userRs != null) {
        userRs.close();
    }
    userPs.close();
    con.close();
    
    // Debug: Print retrieved data (remove in production)
    System.out.println("DEBUG Profile Data:");
    System.out.println("Username: " + username);
    System.out.println("User ID: " + userId);
    System.out.println("Full Name: " + fullName);
    System.out.println("Email: " + email);
    System.out.println("Phone: " + phone);
    System.out.println("Address: " + address);
    System.out.println("Date of Birth: " + dateOfBirth);
    System.out.println("Gender: " + gender);
    System.out.println("Seller ID: " + sellerId);
    
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
    String newDateOfBirth = request.getParameter("date_of_birth");
    String newGender = request.getParameter("gender");
    String newFullName = request.getParameter("full_name");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mscart","root","123456");
        
        // Get user_id if not already available
        if (userId == null) {
            System.out.println("DEBUG: userId is null, trying to retrieve from database for username: " + username);
            PreparedStatement getUserIdPs = con.prepareStatement("SELECT user_id FROM users WHERE username = ?");
            getUserIdPs.setString(1, username);
            ResultSet userIdRs = getUserIdPs.executeQuery();
            if (userIdRs.next()) {
                userId = userIdRs.getString("user_id");
                System.out.println("DEBUG: Retrieved userId from database: " + userId);
            } else {
                System.out.println("DEBUG: Could not find userId for username: " + username);
            }
            userIdRs.close();
            getUserIdPs.close();
        } else {
            System.out.println("DEBUG: userId already exists: " + userId);
        }
        
        if (userId != null) {
            System.out.println("DEBUG: Proceeding with profile update for userId: " + userId);
            // Check if profile exists in users_profile table
            PreparedStatement checkPs = con.prepareStatement("SELECT COUNT(*) FROM users_profile WHERE user_id = ?");
            checkPs.setString(1, userId);
            ResultSet checkRs = checkPs.executeQuery();
            checkRs.next();
            int profileCount = checkRs.getInt(1);
            checkRs.close();
            checkPs.close();
            
            int result = 0;
            if (profileCount > 0) {
                // Update existing profile
                PreparedStatement updatePs = con.prepareStatement("UPDATE users_profile SET full_name = ?, email_address = ?, mobile_number = ?, address = ?, date_of_birth = ?, gender = ? WHERE user_id = ?");
                updatePs.setString(1, newFullName);
                updatePs.setString(2, newEmail);
                updatePs.setString(3, newPhone);
                updatePs.setString(4, newAddress);
                updatePs.setString(5, newDateOfBirth);
                updatePs.setString(6, newGender);
                updatePs.setString(7, userId);
                result = updatePs.executeUpdate();
                updatePs.close();
            } else {
                // Insert new profile
                PreparedStatement insertPs = con.prepareStatement("INSERT INTO users_profile (user_id, full_name, email_address, mobile_number, address, date_of_birth, gender) VALUES (?, ?, ?, ?, ?, ?, ?)");
                insertPs.setString(1, userId);
                insertPs.setString(2, newFullName);
                insertPs.setString(3, newEmail);
                insertPs.setString(4, newPhone);
                insertPs.setString(5, newAddress);
                insertPs.setString(6, newDateOfBirth);
                insertPs.setString(7, newGender);
                result = insertPs.executeUpdate();
                insertPs.close();
            }
            
            if (result > 0) {
                updateMessage = "Profile updated successfully!";
                messageType = "success";
                // Update local variables
                fullName = newFullName;
                email = newEmail;
                phone = newPhone;
                address = newAddress;
                dateOfBirth = newDateOfBirth;
                gender = newGender;
            } else {
                updateMessage = "Failed to update profile!";
                messageType = "error";
            }
        } else {
            System.out.println("DEBUG: userId is still null after all attempts - Username: " + username);
            updateMessage = "User ID not found! Please contact administrator. (Username: " + username + ")";
            messageType = "error";
        }
        
        con.close();
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

        /* Style for select dropdown */
        select.form-input {
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%236b7280' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6,9 12,15 18,9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 15px center;
            background-size: 20px;
            padding-right: 45px;
        }

        select.form-input:focus {
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%238b5cf6' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6,9 12,15 18,9'%3e%3c/polyline%3e%3c/svg%3e");
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
                        <% 
                        boolean hasProfileData = false;
                        
                        if (fullName != null && !fullName.isEmpty()) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-id-card"></i> Full Name
                            </span>
                            <span class="info-value"><%= fullName %></span>
                        </div>
                        <% } %>
                        
                        <% if (email != null && !email.isEmpty()) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-envelope"></i> Email Address
                            </span>
                            <span class="info-value"><%= email %></span>
                        </div>
                        <% } %>
                        
                        <% if (phone != null && !phone.isEmpty()) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-phone"></i> Phone Number
                            </span>
                            <span class="info-value"><%= phone %></span>
                        </div>
                        <% } %>
                        
                        <% if (address != null && !address.isEmpty()) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-map-marker-alt"></i> Address
                            </span>
                            <span class="info-value"><%= address %></span>
                        </div>
                        <% } %>
                        
                        <% if (sellerId != null) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-store"></i> Seller ID
                            </span>
                            <span class="info-value"><%= sellerId %></span>
                        </div>
                        <% } %>
                        
                        <% if (dateOfBirth != null && !dateOfBirth.isEmpty()) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-calendar"></i> Date of Birth
                            </span>
                            <span class="info-value"><%= dateOfBirth %></span>
                        </div>
                        <% } %>
                        
                        <% if (gender != null && !gender.isEmpty()) { hasProfileData = true; %>
                        <div class="info-item">
                            <span class="info-label">
                                <i class="fas fa-venus-mars"></i> Gender
                            </span>
                            <span class="info-value"><%= gender %></span>
                        </div>
                        <% } %>
                        
                        <% if (!hasProfileData) { %>
                        <div class="info-item" style="text-align: center; padding: 20px; background: #f8f9fa; border-radius: 10px; margin: 10px 0;">
                            <span style="color: #6b7280; font-style: italic;">
                                <i class="fas fa-info-circle"></i> No profile information available. Please fill in your details below.
                            </span>
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
                            <label class="form-label" for="full_name">
                                <i class="fas fa-id-card"></i> Full Name
                            </label>
                            <input type="text" id="full_name" name="full_name" class="form-input" value="<%= fullName != null ? fullName : "" %>" placeholder="Enter your full name">
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
                            <label class="form-label" for="date_of_birth">
                                <i class="fas fa-calendar"></i> Date of Birth
                            </label>
                            <input type="date" id="date_of_birth" name="date_of_birth" class="form-input" value="<%= dateOfBirth != null ? dateOfBirth : "" %>" max="<%= java.time.LocalDate.now().toString() %>">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="gender">
                                <i class="fas fa-venus-mars"></i> Gender
                            </label>
                            <select id="gender" name="gender" class="form-input">
                                <option value="">Select Gender</option>
                                <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                            </select>
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
