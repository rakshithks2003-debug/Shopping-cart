<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.Dbase" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Registration -  Shopping Cart</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            padding: 20px;
        }
        
        .registration-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 1200px;
            width: 100%;
            display: flex;
            min-height: 600px;
        }
        
        .left-panel {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 40px;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        
        .left-panel::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: float 20s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(-30px, -30px) rotate(180deg); }
        }
        
        .left-panel h1 {
            font-size: 2.5rem;
            margin-bottom: 20px;
            position: relative;
            z-index: 1;
        }
        
        .left-panel p {
            font-size: 1.1rem;
            line-height: 1.6;
            opacity: 0.9;
            position: relative;
            z-index: 1;
        }
        
        .features-list {
            margin-top: 30px;
            position: relative;
            z-index: 1;
        }
        
        .features-list li {
            list-style: none;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            font-size: 1rem;
        }
        
        .features-list i {
            margin-right: 10px;
            font-size: 1.2rem;
        }
        
        .right-panel {
            padding: 40px;
            flex: 1.2;
            overflow-y: auto;
            max-height: 80vh;
        }
        
        .form-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .form-header h2 {
            color: #333;
            font-size: 2rem;
            margin-bottom: 10px;
        }
        
        .form-header p {
            color: #666;
            font-size: 1rem;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e1e1;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            font-family: inherit;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #4CAF50;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }
        
        .input-wrapper {
            position: relative;
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
            color: #4CAF50;
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .password-strength {
            margin-top: 5px;
            height: 4px;
            background: #e1e1e1;
            border-radius: 2px;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
            border-radius: 2px;
        }
        
        .strength-weak { background: #f44336; width: 33%; }
        .strength-medium { background: #ff9800; width: 66%; }
        .strength-strong { background: #4CAF50; width: 100%; }
        
        .terms-checkbox {
            display: flex;
            align-items: flex-start;
            margin-bottom: 20px;
        }
        
        .terms-checkbox input {
            margin-right: 10px;
            margin-top: 3px;
        }
        
        .terms-checkbox label {
            font-size: 0.9rem;
            color: #666;
            line-height: 1.4;
        }
        
        .terms-checkbox a {
            color: #4CAF50;
            text-decoration: none;
        }
        
        .terms-checkbox a:hover {
            text-decoration: underline;
        }
        
        .submit-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(76, 175, 80, 0.3);
        }
        
        .submit-btn:active {
            transform: translateY(0);
        }
        
        .submit-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 0.9rem;
        }
        
        .login-link a {
            color: #4CAF50;
            text-decoration: none;
            font-weight: 600;
        }
        
        .login-link a:hover {
            text-decoration: underline;
        }
        
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 10px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            display: none;
        }
        
        .success-message {
            background: #e8f5e8;
            color: #2e7d32;
            padding: 10px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            display: none;
        }
        
        /* Back to Home Button */
        .back-to-home-btn-left {
            position: fixed;
            top: 20px;
            left: 20px;
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 2px solid transparent;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            cursor: pointer;
            white-space: nowrap;
            text-transform: none;
            letter-spacing: 0.5px;
        }

        .back-to-home-btn-left:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
            background: linear-gradient(135deg, #45a049, #3d8b40);
            border-color: rgba(255, 255, 255, 0.1);
            text-decoration: none;
            color: white;
        }

        .back-to-home-btn-left:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(76, 175, 80, 0.3);
            transition: all 0.1s ease;
        }

        .back-to-home-btn-left:focus {
            outline: none;
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3), 0 0 0 3px rgba(76, 175, 80, 0.2);
        }

        .back-to-home-btn-left i {
            font-size: 16px;
            margin-right: 2px;
            transition: transform 0.3s ease;
        }

        .back-to-home-btn-left:hover i {
            transform: scale(1.1);
        }

        /* Responsive Design */
        @media (max-width: 968px) {
            .registration-container {
                flex-direction: column;
                max-height: none;
            }
            
            .left-panel {
                padding: 30px;
                min-height: 200px;
            }
            
            .left-panel h1 {
                font-size: 2rem;
            }
            
            .right-panel {
                max-height: none;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .registration-container {
                margin: 10px;
                border-radius: 15px;
            }
            
            .left-panel,
            .right-panel {
                padding: 20px;
            }
            
            .form-header h2 {
                font-size: 1.5rem;
            }
            
            .back-to-home-btn-left {
                top: 15px;
                left: 15px;
                padding: 10px 16px;
                font-size: 13px;
                border-radius: 20px;
            }
            
            .back-to-home-btn-left i {
                font-size: 14px;
            }
        }

        /* Loading State */
        .submit-btn.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .submit-btn.loading::after {
            content: '';
            position: absolute;
            width: 20px;
            height: 20px;
            top: 50%;
            left: 50%;
            margin-left: -10px;
            margin-top: -10px;
            border: 2px solid #ffffff;
            border-radius: 50%;
            border-top-color: transparent;
            animation: spinner 0.8s linear infinite;
        }

        @keyframes spinner {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <!-- Back to Home Button -->
    <a href="Login.jsp" class="back-to-home-btn-left" aria-label="Go back to login">
        <i class="fas fa-home"></i> Back to Login
    </a>

    <div class="registration-container">
        <div class="left-panel">
            <h1><i class="fas fa-store"></i> Join Our Seller Community</h1>
            <p>Start selling your products to thousands of customers and grow your business with our platform.</p>
            
            <ul class="features-list">
                <li><i class="fas fa-check-circle"></i> Easy product management</li>
                <li><i class="fas fa-chart-line"></i> Sales analytics dashboard</li>
                <li><i class="fas fa-shield-alt"></i> Secure payment processing</li>
                <li><i class="fas fa-users"></i> Access to customer base</li>
                <li><i class="fas fa-mobile-alt"></i> Mobile-friendly interface</li>
                <li><i class="fas fa-headset"></i> 24/7 seller support</li>
            </ul>
        </div>
        
        <div class="right-panel">
            <div class="form-header">
                <h2>Seller Registration</h2>
                <p>Create your seller account in minutes</p>
            </div>
            
            <div class="error-message" id="errorMessage"></div>
            <div class="success-message" id="successMessage"></div>
            
            <form id="sellerRegistrationForm" method="post" action="SellerRegistrationServlet">
                <div class="form-row">
                    <div class="form-group">
                        <label for="firstName">First Name *</label>
                        <input type="text" id="firstName" name="firstName" required 
                               pattern="[A-Za-z]{2,50}" title="First name should contain only letters (2-50 characters)">
                    </div>
                    
                    <div class="form-group">
                        <label for="lastName">Last Name *</label>
                        <input type="text" id="lastName" name="lastName" required 
                               pattern="[A-Za-z]{2,50}" title="Last name should contain only letters (2-50 characters)">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="shopName">Shop/Business Name *</label>
                    <input type="text" id="shopName" name="shopName" required 
                           pattern="[A-Za-z0-9\s&-]{2,100}" title="Shop name should be 2-100 characters">
                </div>
                
                <div class="form-group">
                    <label for="email">Email Address *</label>
                    <input type="email" id="email" name="email" required 
                           pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" 
                           title="Please enter a valid email address">
                </div>
                
                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="tel" id="phone" name="phone" required 
                           pattern="[0-9]{10}" title="Phone number should be 10 digits">
                </div>
                
                <div class="form-group">
                    <label for="address">Business Address *</label>
                    <textarea id="address" name="address" required 
                              placeholder="Enter your complete business address" 
                              pattern=".{10,500}" title="Address should be 10-500 characters"></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="city">City *</label>
                        <input type="text" id="city" name="city" required 
                               pattern="[A-Za-z\s]{2,50}" title="City should contain only letters (2-50 characters)">
                    </div>
                    
                    <div class="form-group">
                        <label for="state">State *</label>
                        <input type="text" id="state" name="state" required 
                               pattern="[A-Za-z\s]{2,50}" title="State should contain only letters (2-50 characters)">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="pincode">PIN Code *</label>
                    <input type="text" id="pincode" name="pincode" required 
                           pattern="[0-9]{6}" title="PIN code should be 6 digits">
                </div>
                
                <div class="form-group">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username" required 
                           pattern="[a-zA-Z0-9_]{4,20}" title="Username should be 4-20 characters (letters, numbers, underscore)">
                </div>
                
                <div class="form-group">
                    <label for="password">Password *</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" required 
                               pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}" 
                               title="Password should be 8-20 characters with at least one uppercase, one lowercase, one digit, and one special character">
                        <span class="password-toggle" onclick="togglePassword('password', 'passwordIcon')">
                            <i class="fas fa-eye" id="passwordIcon"></i>
                        </span>
                    </div>
                    <div class="password-strength">
                        <div class="password-strength-bar" id="passwordStrength"></div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <div class="input-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword" required>
                        <span class="password-toggle" onclick="togglePassword('confirmPassword', 'confirmPasswordIcon')">
                            <i class="fas fa-eye" id="confirmPasswordIcon"></i>
                        </span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="businessType">Business Type *</label>
                    <select id="businessType" name="businessType" required>
                        <option value="">Select Business Type</option>
                        <option value="individual">Individual Seller</option>
                        <option value="partnership">Partnership Firm</option>
                        <option value="private_limited">Private Limited Company</option>
                        <option value="public_limited">Public Limited Company</option>
                        <option value="llp">Limited Liability Partnership</option>
                        <option value="proprietorship">Sole Proprietorship</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="gstNumber">GST Number (Optional)</label>
                    <input type="text" id="gstNumber" name="gstNumber" 
                           pattern="[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}" 
                           title="GST number should be in valid format (15 characters)">
                </div>
                
                <div class="terms-checkbox">
                    <input type="checkbox" id="terms" name="terms" required>
                    <label for="terms">
                        I agree to the <a href="#" onclick="showTerms()">Terms and Conditions</a> and 
                        <a href="#" onclick="showPrivacy()">Privacy Policy</a>. I understand that my information 
                        will be used to create and manage my seller account.
                    </label>
                </div>
                
                <button type="submit" class="submit-btn" id="submitBtn">
                    <i class="fas fa-user-plus"></i> Create Seller Account
                </button>
            </form>
            
            <div class="login-link">
                Already have a seller account? <a href="Login.jsp">Sign in here</a>
            </div>
        </div>
    </div>

    <script>
        // Password strength checker
        document.getElementById('password').addEventListener('input', function(e) {
            const password = e.target.value;
            const strengthBar = document.getElementById('passwordStrength');
            
            let strength = 0;
            if (password.length >= 8) strength++;
            if (password.match(/[a-z]/)) strength++;
            if (password.match(/[A-Z]/)) strength++;
            if (password.match(/[0-9]/)) strength++;
            if (password.match(/[^a-zA-Z0-9]/)) strength++;
            
            strengthBar.className = 'password-strength-bar';
            if (strength <= 2) {
                strengthBar.classList.add('strength-weak');
            } else if (strength <= 4) {
                strengthBar.classList.add('strength-medium');
            } else {
                strengthBar.classList.add('strength-strong');
            }
        });
        
        // Form validation
        document.getElementById('sellerRegistrationForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const terms = document.getElementById('terms').checked;
            
            // Clear previous messages
            document.getElementById('errorMessage').style.display = 'none';
            document.getElementById('successMessage').style.display = 'none';
            
            // Validate password match
            if (password !== confirmPassword) {
                showError('Passwords do not match!');
                return;
            }
            
            // Validate terms acceptance
            if (!terms) {
                showError('Please accept the terms and conditions!');
                return;
            }
            
            // Show loading state
            const submitBtn = document.getElementById('submitBtn');
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating Account...';
            
            // Submit form
            this.submit();
        });
        
        function showError(message) {
            const errorDiv = document.getElementById('errorMessage');
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
            setTimeout(() => {
                errorDiv.style.display = 'none';
            }, 5000);
        }
        
        function showSuccess(message) {
            const successDiv = document.getElementById('successMessage');
            successDiv.textContent = message;
            successDiv.style.display = 'block';
            setTimeout(() => {
                successDiv.style.display = 'none';
            }, 5000);
        }
        
        function showTerms() {
            alert('Terms and Conditions:\n\n1. Sellers must provide accurate business information\n2. Products listed must comply with legal requirements\n3. Commission rates apply to all sales\n4. Payment processing follows standard timelines\n5. Account suspension for policy violations\n\nFull terms available on our website.');
        }
        
        function showPrivacy() {
            alert('Privacy Policy:\n\n1. We collect business information for account creation\n2. Personal data is encrypted and stored securely\n3. We do not sell or share your information\n4. You can request data deletion at any time\n5. We comply with data protection regulations\n\nFull policy available on our website.');
        }
        
        // Check for URL parameters for success/error messages
        window.addEventListener('load', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const error = urlParams.get('error');
            const success = urlParams.get('success');
            
            if (error) {
                showError(decodeURIComponent(error));
            }
            
            if (success) {
                showSuccess(decodeURIComponent(success));
            }
        });
        
        // Password toggle function
        function togglePassword(inputId, iconId) {
            const passwordInput = document.getElementById(inputId);
            const passwordIcon = document.getElementById(iconId);
            
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
    </script>
</body>
</html>
