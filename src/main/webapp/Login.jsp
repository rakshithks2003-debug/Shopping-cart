<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Check if user is already logged in
if (session.getAttribute("isLoggedIn") != null && (Boolean) session.getAttribute("isLoggedIn")) {
    String userRole = (String) session.getAttribute("userRole");
    if ("admin".equals(userRole)) {
        response.sendRedirect("Dashboard.jsp");
    } else {
        response.sendRedirect("Home.jsp");
    }
    return;
}

// Get error message if any
String errorMessage = request.getParameter("error");
String successMessage = request.getParameter("success");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login - MSCart</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Inter', sans-serif;
        min-height: 100vh;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        justify-content: center;
        align-items: center;
        position: relative;
        overflow: hidden;
    }

    body::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: 
            radial-gradient(circle at 20% 80%, rgba(102, 126, 234, 0.3) 0%, transparent 50%),
            radial-gradient(circle at 80% 20%, rgba(118, 75, 162, 0.3) 0%, transparent 50%),
            radial-gradient(circle at 40% 40%, rgba(102, 126, 234, 0.2) 0%, transparent 50%);
        pointer-events: none;
        z-index: 1;
    }

    .background-shapes {
        position: absolute;
        width: 100%;
        height: 100%;
        overflow: hidden;
        z-index: 0;
    }

    .shape {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        animation: float 6s ease-in-out infinite;
    }

    .shape:nth-child(1) {
        width: 80px;
        height: 80px;
        top: 20%;
        left: 10%;
        animation-delay: 0s;
        animation-duration: 8s;
    }

    .shape:nth-child(2) {
        width: 120px;
        height: 120px;
        top: 60%;
        right: 10%;
        animation-delay: 2s;
        animation-duration: 10s;
    }

    .shape:nth-child(3) {
        width: 60px;
        height: 60px;
        bottom: 20%;
        left: 20%;
        animation-delay: 4s;
        animation-duration: 7s;
    }

    @keyframes float {
        0%, 100% {
            transform: translateY(0px) rotate(0deg);
            opacity: 0.7;
        }
        50% {
            transform: translateY(-20px) rotate(180deg);
            opacity: 0.3;
        }
    }

    .container {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        padding: 50px 40px;
        border-radius: 30px;
        box-shadow: 0 30px 60px rgba(0, 0, 0, 0.2);
        width: 420px;
        position: relative;
        z-index: 10;
        border: 1px solid rgba(255, 255, 255, 0.3);
        animation: slideUp 0.8s ease-out, fadeIn 1s ease-out;
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(50px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }

    .logo-section {
        text-align: center;
        margin-bottom: 40px;
        animation: slideDown 0.8s ease-out 0.3s both;
    }

    @keyframes slideDown {
        from {
            opacity: 0;
            transform: translateY(-30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .logo {
        font-size: 3rem;
        margin-bottom: 15px;
        animation: bounce 2s ease-in-out infinite;
    }

    @keyframes bounce {
        0%, 20%, 50%, 80%, 100% {
            transform: translateY(0);
        }
        40% {
            transform: translateY(-10px);
        }
        60% {
            transform: translateY(-5px);
        }
    }

    h1 {
        font-size: 1.8rem;
        font-weight: 800;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 8px;
        letter-spacing: -0.02em;
    }

    .subtitle {
        color: #666;
        font-size: 0.95rem;
        font-weight: 500;
    }

    .form-group {
        margin-bottom: 25px;
        animation: slideInLeft 0.8s ease-out 0.5s both;
    }

    .form-group:nth-child(2) {
        animation-delay: 0.6s;
    }

    .form-group:nth-child(3) {
        animation-delay: 0.7s;
    }

    @keyframes slideInLeft {
        from {
            opacity: 0;
            transform: translateX(-30px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }

    label {
        display: block;
        margin-bottom: 8px;
        color: #333;
        font-weight: 600;
        font-size: 0.95rem;
        letter-spacing: 0.3px;
    }

    .input-wrapper {
        position: relative;
    }

    .input-icon {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #999;
        font-size: 1.1rem;
        transition: color 0.3s ease;
    }

    input[type="text"], input[type="password"] {
        width: 100%;
        padding: 15px 15px 15px 45px;
        border: 2px solid #e0e0e0;
        border-radius: 15px;
        box-sizing: border-box;
        font-size: 1rem;
        font-weight: 500;
        transition: all 0.3s ease;
        background: rgba(255, 255, 255, 0.8);
    }

    input[type="text"]:focus, input[type="password"]:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        transform: translateY(-2px);
    }

    input[type="text"]:focus ~ .input-icon,
    input[type="password"]:focus ~ .input-icon {
        color: #667eea;
    }

    .password-toggle {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #999;
        font-size: 1.1rem;
        cursor: pointer;
        transition: all 0.3s ease;
        padding: 5px;
    }

    .password-toggle:hover {
        color: #667eea;
    }

    button {
        width: 100%;
        padding: 18px;
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        border: none;
        border-radius: 15px;
        cursor: pointer;
        font-size: 1.1rem;
        font-weight: 600;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
        animation: slideInUp 0.8s ease-out 0.8s both;
    }

    @keyframes slideInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    button::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }

    button:hover::before {
        left: 100%;
    }

    button:hover {
        background: linear-gradient(135deg, #5a6fd8, #6a4190);
        transform: translateY(-3px);
        box-shadow: 0 15px 35px rgba(102, 126, 234, 0.3);
    }

    button:active {
        transform: translateY(-1px);
    }

    .signup-link {
        text-align: center;
        margin-top: 30px;
        animation: fadeIn 0.8s ease-out 1s both;
    }

    .signup-link p {
        color: #666;
        font-size: 0.95rem;
        font-weight: 500;
    }

    .signup-link a {
        color: #667eea;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.3s ease;
        position: relative;
    }

    .signup-link a::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 0;
        height: 2px;
        background: linear-gradient(135deg, #667eea, #764ba2);
        transition: width 0.3s ease;
    }

    .signup-link a:hover::after {
        width: 100%;
    }

    .signup-link a:hover {
        color: #764ba2;
    }

    .forgot-password-link {
        display: inline-block;
        margin-top: 10px;
        color: #667eea;
        font-size: 0.9rem;
        font-weight: 500;
        text-decoration: none;
        transition: all 0.3s ease;
        cursor: pointer;
    }

    .forgot-password-link:hover {
        color: #764ba2;
        text-decoration: underline;
    }

    .forgot-password-link i {
        margin-right: 5px;
    }

    .error-message {
        color: #e74c3c;
        font-size: 0.85rem;
        margin-top: 8px;
        display: none;
        animation: shake 0.5s ease-in-out;
    }

    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
    }

    .input-error {
        border-color: #e74c3c !important;
        animation: shake 0.5s ease-in-out;
    }

    .success-message {
        color: #27ae60;
        font-size: 0.85rem;
        margin-top: 8px;
        display: none;
    }

    .validation-info {
        font-size: 0.8rem;
        color: #999;
        margin-top: 5px;
        font-style: italic;
    }

    .loading {
        display: none;
        width: 20px;
        height: 20px;
        border: 3px solid #f3f3f3;
        border-top: 3px solid #667eea;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin: 0 auto;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* Alert Messages */
    .alert {
        padding: 15px 20px;
        border-radius: 12px;
        margin-bottom: 25px;
        font-size: 0.9rem;
        font-weight: 500;
        animation: slideDown 0.5s ease-out;
        display: flex;
        align-items: center;
        gap: 10px;
        position: relative;
    }

    .alert-error {
        background: rgba(231, 76, 60, 0.15);
        border: 2px solid #e74c3c;
        color: #c0392b;
        font-weight: 600;
        box-shadow: 0 4px 15px rgba(231, 76, 60, 0.2);
    }

    .alert-success {
        background: rgba(39, 174, 96, 0.15);
        border: 2px solid #27ae60;
        color: #229954;
        font-weight: 600;
        box-shadow: 0 4px 15px rgba(39, 174, 96, 0.2);
    }

    .alert i {
        font-size: 1.2rem;
    }
    
    .alert-close {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: inherit;
        font-size: 1.2rem;
        cursor: pointer;
        padding: 5px;
        opacity: 0.7;
        transition: opacity 0.3s ease;
        width: auto;
        height: auto;
        animation: none;
    }
    
    .alert-close:hover {
        opacity: 1;
        transform: translateY(-50%) scale(1.2);
        box-shadow: none;
    }

    @media (max-width: 480px) {
        .container {
            width: 90%;
            padding: 40px 30px;
            margin: 20px;
        }

        h1 {
            font-size: 1.5rem;
        }

        .logo {
            font-size: 2.5rem;
        }

        button {
            font-size: 1rem;
            padding: 15px;
        }
    }
</style>
</head>
<body>
    <div class="background-shapes">
        <div class="shape"></div>
        <div class="shape"></div>
        <div class="shape"></div>
    </div>

    <div class="container">
        <div class="logo-section">
            <div class="logo">🛍️</div>
            <h1>Welcome back</h1>
            <p class="subtitle">to  Shopping Cart</p>
        </div>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="alert alert-error" id="errorAlert">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= errorMessage %></span>
                <button class="alert-close" onclick="closeAlert('errorAlert')" aria-label="Close alert">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <script>
                // Add shake animation to the container when there's an error
                document.addEventListener('DOMContentLoaded', function() {
                    const container = document.querySelector('.container');
                    container.style.animation = 'shake 0.5s ease-in-out';
                    setTimeout(() => {
                        container.style.animation = 'slideUp 0.8s ease-out, fadeIn 1s ease-out';
                    }, 500);
                });
            </script>
        <% } %>

        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
            <div class="alert alert-success" id="successAlert">
                <i class="fas fa-check-circle"></i>
                <span><%= successMessage %></span>
                <button class="alert-close" onclick="closeAlert('successAlert')" aria-label="Close alert">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        <% } %>

        <form action="Loginservlet" method="post" id="loginForm" onsubmit="return validateForm()">
            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrapper">
                    <input type="text" id="username" name="username" required 
                           placeholder="Enter your username" 
                           onblur="validateUsername()" 
                           oninput="clearError('username')"
                           value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
                    <span class="input-icon"><i class="fas fa-user"></i></span>
                </div>
                <div class="error-message" id="usernameError"></div>
                <div class="validation-info" id="usernameInfo">3-20 characters, letters and numbers only</div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <input type="password" id="password" name="password" required 
                           placeholder="Enter your password" 
                           onblur="validatePassword()" 
                           oninput="clearError('password')">
                    <span class="input-icon"><i class="fas fa-lock"></i></span>
                    <span class="password-toggle" onclick="togglePassword()">
                        <i class="fas fa-eye" id="passwordIcon"></i>
                    </span>
                </div>
                <div class="error-message" id="passwordError"></div>
                <div class="validation-info" id="passwordInfo">6-20 characters, letters and numbers</div>
                <a href="ResetPassword.jsp" class="forgot-password-link">
                    <i class="fas fa-question-circle"></i> Forgot Password?
                </a>
            </div>

            <input type="hidden" id="userRole" name="role" value="user">
            
            <button type="submit" id="loginBtn">
                <span id="btnText">Sign In</span>
                <div class="loading" id="loading"></div>
            </button>
        </form>

        <div class="signup-link">
            <p>Don't have an account? <a href="Signup.jsp">Sign up here</a></p>
        </div>
    </div>

<script>
function closeAlert(alertId) {
    const alert = document.getElementById(alertId);
    if (alert) {
        alert.style.opacity = '0';
        alert.style.transform = 'translateY(-20px)';
        setTimeout(() => {
            alert.style.display = 'none';
        }, 300);
    }
}

function validateForm() {
    let isValid = true;
    
    // Validate username
    if (!validateUsername()) {
        isValid = false;
    }
    
    // Validate password
    if (!validatePassword()) {
        isValid = false;
    }
    
    // Check for admin credentials
    if (isValid) {
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value;
        const userRole = document.getElementById('userRole');
        
        if (username === 'Rakshith' && password === 'rak1234') {
            userRole.value = 'admin';
        } else {
            userRole.value = 'user';
        }

        // Show loading state
        showLoading();
    }
    
    return isValid;
}

function showLoading() {
    const btnText = document.getElementById('btnText');
    const loading = document.getElementById('loading');
    const loginBtn = document.getElementById('loginBtn');
    
    btnText.style.display = 'none';
    loading.style.display = 'block';
    loginBtn.disabled = true;
    loginBtn.style.cursor = 'not-allowed';
}

function hideLoading() {
    const btnText = document.getElementById('btnText');
    const loading = document.getElementById('loading');
    const loginBtn = document.getElementById('loginBtn');
    
    btnText.style.display = 'inline';
    loading.style.display = 'none';
    loginBtn.disabled = false;
    loginBtn.style.cursor = 'pointer';
}

function validateUsername() {
    const username = document.getElementById('username').value.trim();
    const usernameError = document.getElementById('usernameError');
    const usernameInput = document.getElementById('username');
    
    // Clear previous error
    usernameError.style.display = 'none';
    usernameInput.classList.remove('input-error');
    
    // Validation rules
    if (username.length === 0) {
        showError('usernameError', 'Username is required');
        usernameInput.classList.add('input-error');
        return false;
    }
    
    if (username.length < 3 || username.length > 20) {
        showError('usernameError', 'Username must be 3-20 characters');
        usernameInput.classList.add('input-error');
        return false;
    }
    
    // Allow letters, numbers, and underscores
    const usernameRegex = /^[a-zA-Z0-9_]+$/;
    if (!usernameRegex.test(username)) {
        showError('usernameError', 'Username can only contain letters, numbers, and underscores');
        usernameInput.classList.add('input-error');
        return false;
    }
    
    return true;
}

function validatePassword() {
    const password = document.getElementById('password').value;
    const passwordError = document.getElementById('passwordError');
    const passwordInput = document.getElementById('password');
    
    // Clear previous error
    passwordError.style.display = 'none';
    passwordInput.classList.remove('input-error');
    
    // Validation rules
    if (password.length === 0) {
        showError('passwordError', 'Password is required');
        passwordInput.classList.add('input-error');
        return false;
    }
    
    if (password.length < 6 || password.length > 20) {
        showError('passwordError', 'Password must be 6-20 characters');
        passwordInput.classList.add('input-error');
        return false;
    }
    
    // Check for at least one letter and one number
    const hasLetter = /[a-zA-Z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    
    if (!hasLetter || !hasNumber) {
        showError('passwordError', 'Password must contain at least one letter and one number');
        passwordInput.classList.add('input-error');
        return false;
    }
    
    return true;
}

function showError(elementId, message) {
    const errorElement = document.getElementById(elementId);
    errorElement.textContent = message;
    errorElement.style.display = 'block';
}

function clearError(inputId) {
    const inputElement = document.getElementById(inputId);
    const errorElement = document.getElementById(inputId + 'Error');
    
    inputElement.classList.remove('input-error');
    errorElement.style.display = 'none';
}

function togglePassword() {
    const passwordInput = document.getElementById('password');
    const passwordIcon = document.getElementById('passwordIcon');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        passwordIcon.classList.remove('fa-eye');
        passwordIcon.classList.add('fa-eye-slash');
    } else {
        passwordInput.type = 'password';
        passwordIcon.classList.remove('fa-eye-slash');
        passwordIcon.classList.add('fa-eye');
    }
}

// Add enter key support for form submission
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('loginForm');
    form.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            if (validateForm()) {
                form.submit();
            }
        }
    });

    // Hide loading on page load (in case of refresh)
    hideLoading();
    
    // Auto-hide alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-20px)';
            setTimeout(() => {
                alert.style.display = 'none';
            }, 300);
        }, 5000);
    });
    
    // Highlight fields if there's an error
    <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
        const passwordInput = document.getElementById('password');
        const usernameInput = document.getElementById('username');
        
        // Add error styling
        if ('<%= errorMessage %>'.includes('Invalid username or password')) {
            passwordInput.classList.add('input-error');
            usernameInput.classList.add('input-error');
            
            // Focus on password field
            passwordInput.focus();
            passwordInput.select();
        }
    <% } %>
});

// Forgot Password Modal Functions
function showForgotPasswordModal() {
    document.getElementById('forgotPasswordModal').style.display = 'block';
    document.getElementById('resetUsername').focus();
}

function closeForgotPasswordModal() {
    document.getElementById('forgotPasswordModal').style.display = 'none';
    document.getElementById('resetUsername').value = '';
    document.getElementById('resetUsernameError').style.display = 'none';
    document.getElementById('resetPassword').value = '';
    document.getElementById('passwordDisplayGroup').style.display = 'none';
    document.getElementById('passwordSuccess').style.display = 'none';
    document.getElementById('newPassword').value = '';
    document.getElementById('newPasswordError').style.display = 'none';
    document.getElementById('confirmPassword').value = '';
    document.getElementById('confirmPasswordError').style.display = 'none';
    document.getElementById('changePasswordGroup').style.display = 'none';
    document.getElementById('confirmPasswordGroup').style.display = 'none';
    document.getElementById('forgotPasswordBtn').style.display = 'flex';
    document.getElementById('changePasswordBtn').style.display = 'none';
}

function submitForgotPassword(event) {
    event.preventDefault();
    
    const username = document.getElementById('resetUsername').value.trim();
    const resetUsernameError = document.getElementById('resetUsernameError');
    
    if (!username) {
        resetUsernameError.textContent = 'Please enter your username';
        resetUsernameError.style.display = 'block';
        return;
    }
    
    // Show loading state
    const resetBtn = document.getElementById('forgotPasswordBtn');
    const originalText = resetBtn.innerHTML;
    resetBtn.disabled = true;
    resetBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Retrieving...';
    
    // Send AJAX request to servlet to get password
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'ChangePasswordServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    const response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        // Show password field
                        document.getElementById('passwordDisplayGroup').style.display = 'block';
                        document.getElementById('resetPassword').value = response.message;
                        
                        // Show success message
                        const successMessage = document.getElementById('passwordSuccess');
                        successMessage.style.display = 'block';
                        
                        // Show change password fields
                        document.getElementById('changePasswordGroup').style.display = 'block';
                        document.getElementById('confirmPasswordGroup').style.display = 'block';
                        
                        // Change button
                        document.getElementById('forgotPasswordBtn').style.display = 'none';
                        document.getElementById('changePasswordBtn').style.display = 'flex';
                        
                        // Reset button
                        resetBtn.disabled = false;
                        resetBtn.innerHTML = originalText;
                        
                        // Scroll to password field
                        setTimeout(() => {
                            document.getElementById('newPassword').focus();
                        }, 300);
                    } else {
                        // Show error
                        alert('Error: ' + response.message);
                        resetBtn.disabled = false;
                        resetBtn.innerHTML = originalText;
                    }
                } catch (e) {
                    alert('Error processing response. Please try again.');
                    resetBtn.disabled = false;
                    resetBtn.innerHTML = originalText;
                }
            } else {
                alert('Server error. Please try again.');
                resetBtn.disabled = false;
                resetBtn.innerHTML = originalText;
            }
        }
    };
    
    xhr.send('username=' + encodeURIComponent(username) + '&action=getPassword');
}

function changePassword() {
    const username = document.getElementById('resetUsername').value.trim();
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const newPasswordError = document.getElementById('newPasswordError');
    const confirmPasswordError = document.getElementById('confirmPasswordError');
    
    // Validate new password
    if (!validateNewPassword()) {
        return;
    }
    
    // Check if passwords match
    if (newPassword !== confirmPassword) {
        confirmPasswordError.textContent = 'Passwords do not match';
        confirmPasswordError.style.display = 'block';
        return;
    }
    
    // Show loading state
    const changeBtn = document.getElementById('changePasswordBtn');
    const originalText = changeBtn.innerHTML;
    changeBtn.disabled = true;
    changeBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Changing...';
    
    // Send AJAX request to servlet
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'ChangePasswordServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    const response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        // Close modal
                        closeForgotPasswordModal();
                        
                        // Show success message
                        alert('Password changed successfully! You can now login with your new password.');
                    } else {
                        // Show error
                        alert('Error: ' + response.message);
                        changeBtn.disabled = false;
                        changeBtn.innerHTML = originalText;
                    }
                } catch (e) {
                    alert('Error processing response. Please try again.');
                    changeBtn.disabled = false;
                    changeBtn.innerHTML = originalText;
                }
            } else {
                alert('Server error. Please try again.');
                changeBtn.disabled = false;
                changeBtn.innerHTML = originalText;
            }
        }
    };
    
    xhr.send('username=' + encodeURIComponent(username) + '&newPassword=' + encodeURIComponent(newPassword));
}

function validateNewPassword() {
    const newPassword = document.getElementById('newPassword').value;
    const newPasswordError = document.getElementById('newPasswordError');
    
    // Clear previous error
    newPasswordError.style.display = 'none';
    
    // Validation rules
    if (newPassword.length === 0) {
        return true; // Allow empty for validation on blur
    }
    
    if (newPassword.length < 6 || newPassword.length > 20) {
        newPasswordError.textContent = 'Password must be 6-20 characters';
        newPasswordError.style.display = 'block';
        return false;
    }
    
    // Check for at least one letter and one number
    const hasLetter = /[a-zA-Z]/.test(newPassword);
    const hasNumber = /[0-9]/.test(newPassword);
    
    if (!hasLetter || !hasNumber) {
        newPasswordError.textContent = 'Password must contain at least one letter and one number';
        newPasswordError.style.display = 'block';
        return false;
    }
    
    return true;
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('forgotPasswordModal');
    if (event.target === modal) {
        closeForgotPasswordModal();
    }
}
</script>
</body>
</html>