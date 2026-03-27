<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Shopping Cart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
            width: 90%;
            max-width: 450px;
            text-align: center;
            animation: fadeInUp 0.6s ease-out;
        }
        
        .logo {
            font-size: 2.5rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 20px;
        }
        
        .title {
            font-size: 2rem;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #7f8c8d;
            margin-bottom: 30px;
            font-size: 0.95rem;
        }
        
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        
        label {
            display: block;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 8px;
        }
        
        input {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }
        
        input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 10px rgba(102, 126, 234, 0.1);
        }
        
        .input-wrapper {
            position: relative;
        }
        
        .input-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #7f8c8d;
        }
        
        .btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 15px;
        }
        
        .btn:hover {
            background: linear-gradient(135deg, #5a6fd8, #6a4190);
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .btn:disabled {
            background: #bdc3c7;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .message {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            display: none;
        }
        
        .success {
            background: rgba(39, 174, 96, 0.15);
            color: #229954;
            border: 2px solid #27ae60;
        }
        
        .error {
            background: rgba(231, 76, 60, 0.15);
            color: #c0392b;
            border: 2px solid #e74c3c;
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }
        
        .back-link a:hover {
            color: #764ba2;
            text-decoration: underline;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @media (max-width: 480px) {
            .container {
                width: 95%;
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🛍️</div>
        <h1 class="title">Reset Password</h1>
        <p class="subtitle">Enter your username to retrieve or reset your password</p>
        
        <div id="message" class="message"></div>
        
        <!-- Step 1: Get Username -->
        <div id="step1">
            <form id="getPasswordForm" onsubmit="getPassword(event)">
                <div class="form-group">
                    <label for="username">Username</label>
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" required 
                               placeholder="Enter your username" oninput="clearMessage()">
                        <span class="input-icon"><i class="fas fa-user"></i></span>
                    </div>
                </div>
                
                <button type="submit" class="btn" id="getPasswordBtn">
                    <i class="fas fa-search"></i> Get Password
                </button>
            </form>
        </div>
        
        <!-- Step 2: Show Current Password -->
        <div id="step2" style="display: none;">
            <div class="form-group">
                <label for="currentPassword">Current Password</label>
                <div class="input-wrapper">
                    <input type="text" id="currentPassword" readonly 
                           placeholder="Your current password">
                    <span class="input-icon"><i class="fas fa-lock"></i></span>
                </div>
            </div>
            
            <div class="form-group">
                <label for="newPassword">New Password</label>
                <div class="input-wrapper">
                    <input type="password" id="newPassword" name="newPassword" 
                           placeholder="Enter new password" oninput="validateNewPassword()">
                    <span class="input-icon"><i class="fas fa-lock"></i></span>
                </div>
                <small style="color: #7f8c8d; font-size: 0.85rem;">6-20 characters, letters and numbers</small>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Confirm New Password</label>
                <div class="input-wrapper">
                    <input type="password" id="confirmPassword" name="confirmPassword" 
                           placeholder="Confirm new password">
                    <span class="input-icon"><i class="fas fa-lock"></i></span>
                </div>
            </div>
            
            <button type="button" class="btn" onclick="changePassword()">
                <i class="fas fa-save"></i> Change Password
            </button>
        </div>
        
        <div class="back-link">
            <a href="Login.jsp">← Back to Login</a>
        </div>
    </div>
    
    <script>
        function showMessage(message, isSuccess) {
            const messageDiv = document.getElementById('message');
            messageDiv.textContent = message;
            messageDiv.className = 'message ' + (isSuccess ? 'success' : 'error');
            messageDiv.style.display = 'block';
        }
        
        function clearMessage() {
            const messageDiv = document.getElementById('message');
            messageDiv.style.display = 'none';
        }
        
        function getPassword(event) {
            event.preventDefault();
            
            const username = document.getElementById('username').value.trim();
            if (!username) {
                showMessage('Please enter your username', false);
                return;
            }
            
            const btn = document.getElementById('getPasswordBtn');
            const originalText = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Retrieving...';
            
            // Send AJAX request to ChangePasswordServlet
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'ChangePasswordServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                // Show current password
                                document.getElementById('currentPassword').value = response.message;
                                document.getElementById('step1').style.display = 'none';
                                document.getElementById('step2').style.display = 'block';
                                showMessage('Password retrieved successfully! You can now change your password.', true);
                            } else {
                                showMessage(response.message, false);
                            }
                        } catch (e) {
                            showMessage('Error processing response. Please try again.', false);
                        }
                    } else {
                        showMessage('Server error. Please try again.', false);
                    }
                    
                    btn.disabled = false;
                    btn.innerHTML = originalText;
                }
            };
            
            xhr.send('action=getPassword&username=' + encodeURIComponent(username));
        }
        
        function validateNewPassword() {
            const newPassword = document.getElementById('newPassword').value;
            
            if (newPassword.length < 6 || newPassword.length > 20) {
                showMessage('Password must be 6-20 characters', false);
                return false;
            }
            
            // Check for at least one letter and one number
            const hasLetter = /[a-zA-Z]/.test(newPassword);
            const hasNumber = /[0-9]/.test(newPassword);
            
            if (!hasLetter || !hasNumber) {
                showMessage('Password must contain at least one letter and one number', false);
                return false;
            }
            
            clearMessage();
            return true;
        }
        
        function changePassword() {
            const username = document.getElementById('username').value.trim();
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            // Validate new password
            if (!validateNewPassword()) {
                return;
            }
            
            // Check if passwords match
            if (newPassword !== confirmPassword) {
                showMessage('Passwords do not match', false);
                return;
            }
            
            const btn = event.target;
            const originalText = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Changing...';
            
            // Send AJAX request to ChangePasswordServlet
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'ChangePasswordServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                showMessage('Password changed successfully! Redirecting to login...', true);
                                setTimeout(() => {
                                    window.location.href = 'Login.jsp';
                                }, 2000);
                            } else {
                                showMessage(response.message, false);
                            }
                        } catch (e) {
                            showMessage('Error processing response. Please try again.', false);
                        }
                    } else {
                        showMessage('Server error. Please try again.', false);
                    }
                    
                    btn.disabled = false;
                    btn.innerHTML = originalText;
                }
            };
            
            xhr.send('action=changePassword&username=' + encodeURIComponent(username) + '&newPassword=' + encodeURIComponent(newPassword));
        }
    </script>
</body>
</html>
