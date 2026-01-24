<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%
// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
    return;
}
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);

// Check if user has admin role
String userRole = (String) sessionObj.getAttribute("userRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect("users.html");
    return;
}

// Get messages from Servlet
String message = (String) request.getAttribute("message");
if (message == null) message = "";
String messageType = (String) request.getAttribute("messageType");
if (messageType == null) messageType = "";

// Get user info from session
String username = (sessionObj != null) ? (String) sessionObj.getAttribute("username") : "Guest";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Seller Upload</title>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Arial', sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        color: #1a1a1a;
        overflow-x: hidden;
    }

    .container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }

    header {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        padding: 30px 0;
        text-align: center;
        position: relative;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        border-radius: 20px;
        margin-bottom: 30px;
    }

    .user-info {
        position: absolute;
        top: 20px;
        right: 20px;
        background: rgba(255, 255, 255, 0.9);
        padding: 10px 20px;
        border-radius: 25px;
        font-weight: 600;
        color: #333;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .message {
        padding: 15px 20px;
        border-radius: 10px;
        margin-bottom: 20px;
        font-weight: 500;
        text-align: center;
        animation: slideIn 0.3s ease;
    }

    .message.success {
        background: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }

    .message.error {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    header h1 {
        font-size: 2.5rem;
        font-weight: 900;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 10px;
        letter-spacing: -0.02em;
    }

    .form-container {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        padding: 40px;
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.1);
        margin-bottom: 30px;
        border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .form-header {
        text-align: center;
        margin-bottom: 30px;
    }

    .form-header h2 {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1a1a1a;
        margin-bottom: 10px;
    }

    .form-header p {
        color: #666;
        font-size: 1rem;
    }

    .form-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        margin-bottom: 30px;
        align-items: flex-start;
    }

    .form-field {
        flex: 1;
        min-width: 200px;
        position: relative;
    }

    .field-header {
        display: flex;
        align-items: center;
        margin-bottom: 8px;
        gap: 8px;
    }

    .field-icon {
        font-size: 1.2rem;
        color: #667eea;
    }

    .field-label {
        font-size: 0.9rem;
        font-weight: 600;
        color: #333;
    }

    .form-input, .form-select {
        width: 100%;
        padding: 12px 15px;
        border: 2px solid #e1e5e9;
        border-radius: 10px;
        font-size: 1rem;
        transition: all 0.3s ease;
        background: white;
        font-family: 'Arial', sans-serif;
    }

    .form-input:focus, .form-select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        transform: translateY(-2px);
    }

    .form-input:hover, .form-select:hover {
        border-color: #a0a0a0;
    }

    .form-actions {
        display: flex;
        gap: 15px;
        justify-content: center;
        margin-top: 30px;
    }

    .btn {
        padding: 12px 30px;
        border: none;
        border-radius: 10px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .btn-primary {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    }

    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
    }

    .btn-secondary {
        background: rgba(255, 255, 255, 0.9);
        color: #667eea;
        border: 2px solid #667eea;
    }

    .btn-secondary:hover {
        background: #667eea;
        color: white;
    }

    .back-link {
        text-align: center;
        margin-top: 20px;
    }

    .back-link a {
        color: white;
        text-decoration: none;
        font-weight: 600;
        padding: 10px 20px;
        border-radius: 10px;
        background: rgba(255, 255, 255, 0.2);
        transition: all 0.3s ease;
    }

    .back-link a:hover {
        background: rgba(255, 255, 255, 0.3);
    }

    textarea.form-input {
        resize: vertical;
        min-height: 100px;
    }

    @media (max-width: 768px) {
        .form-grid {
            flex-direction: column;
        }
        
        .form-field {
            min-width: 100%;
        }
        
        .form-actions {
            flex-direction: column;
        }
        
        .user-info {
            position: static;
            margin-bottom: 10px;
            text-align: center;
        }
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <div class="user-info">
                👤 <%= username != null ? username : "Admin" %> (<%= userRole != null ? userRole : "Guest" %>)
            </div>
            <h1>📝 Seller Upload</h1>
        </header>

        <div class="form-container">
            <div class="form-header">
                <h2>Add New Seller</h2>
                <p>Fill in seller information below</p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="message <%= messageType %>">
                    <%= message %>
                </div>
            <% } %>

            <form action="SelleruploadServlet" method="post" id="sellerForm" enctype="multipart/form-data">
                <div class="form-grid">
                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🆔</span>
                            <label class="field-label" for="sellerId">Seller ID</label>
                        </div>
                        <input type="text" class="form-input" id="sellerId" name="sellerId" 
                               placeholder="Enter seller ID (optional, will auto-generate if empty)">
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">👤</span>
                            <label class="field-label" for="name">Full Name</label>
                        </div>
                        <input type="text" class="form-input" id="name" name="name" 
                               placeholder="Enter seller name" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">📧</span>
                            <label class="field-label" for="email">Email Address</label>
                        </div>
                        <input type="email" class="form-input" id="email" name="email" 
                               placeholder="Enter email address" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">📱</span>
                            <label class="field-label" for="phone">Phone Number</label>
                        </div>
                        <input type="text" class="form-input" id="phone" name="phone" 
                               placeholder="Enter phone number" maxlength="10" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🛍️</span>
                            <label class="field-label" for="productBrand">Product Brand</label>
                        </div>
                        <input type="text" class="form-input" id="productBrand" name="productBrand" 
                               placeholder="Enter product brand" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">📂</span>
                            <label class="field-label" for="category">Category</label>
                        </div>
                        <select class="form-select" id="category" name="category" required>
                            <option value="">Select Category</option>
                            <option value="mobile">Mobile</option>
                            <option value="laptop">Laptop</option>
                            <option value="men-shoe">Men Shoe</option>
                        </select>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🆔</span>
                            <label class="field-label" for="categoryId">Category ID</label>
                        </div>
                        <input type="text" class="form-input" id="categoryId" name="categoryId" 
                               placeholder="Enter category ID" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🖼️</span>
                            <label class="field-label" for="image">Image</label>
                        </div>
                        <input type="file" class="form-input" id="image" name="image" 
                               accept="image/*" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">💰</span>
                            <label class="field-label" for="price">Price</label>
                        </div>
                        <input type="number" class="form-input" id="price" name="price" 
                               placeholder="Enter price" step="0.01" min="0" required>
                    </div>

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">📝</span>
                            <label class="field-label" for="description">Description</label>
                        </div>
                        <textarea class="form-input" id="description" name="description" 
                                  placeholder="Enter product description" rows="3" required></textarea>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <span>💾</span> Save Seller
                    </button>
                    <button type="reset" class="btn btn-secondary">
                        <span>🔄</span> Reset Form
                    </button>
                </div>
            </form>
        </div>

        <div class="back-link">
            <a href="Seller.jsp">← Back to Seller Management</a>
        </div>
    </div>

    <script>
        // Form validation
        document.getElementById('sellerForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Get form values
            const sellerId = document.getElementById('sellerId').value.trim();
            const name = document.getElementById('name').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const productBrand = document.getElementById('productBrand').value.trim();
            const category = document.getElementById('category').value;
            const categoryId = document.getElementById('categoryId').value.trim();
            const price = document.getElementById('price').value.trim();
            const description = document.getElementById('description').value.trim();
            const imageFile = document.getElementById('image').files[0];
            
            // Validation errors array
            let errors = [];
            
            // Validate seller ID
            if (sellerId && sellerId.length > 10) {
                errors.push('Seller ID must be 10 characters or less');
            }
            
            // Validate name
            if (!name || name.length < 2) {
                errors.push('Name must be at least 2 characters long');
            }
            
            // Validate email
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!email || !emailRegex.test(email)) {
                errors.push('Please enter a valid email address');
            }
            
            // Validate phone
            const phoneRegex = /^[0-9]{8,10}$/;
            if (!phone || !phoneRegex.test(phone)) {
                errors.push('Phone number must be 8-10 digits');
            }
            
            // Validate product brand
            if (!productBrand || productBrand.length < 2) {
                errors.push('Product brand must be at least 2 characters long');
            }
            
            // Validate category
            if (!category) {
                errors.push('Please select a category');
            }
            
            // Validate category ID
            if (!categoryId || categoryId.length < 1) {
                errors.push('Category ID is required');
            }
            
            // Validate price
            if (!price || parseFloat(price) < 0) {
                errors.push('Price must be a positive number');
            }
            
            // Validate description
            if (!description || description.length < 10) {
                errors.push('Description must be at least 10 characters long');
            }
            
            // Validate image
            if (!imageFile) {
                errors.push('Please select an image file');
            } else {
                // Check file type - allow any image format
                if (!imageFile.type.startsWith('image/')) {
                    errors.push('Please select a valid image file');
                }
                
                // Check file size (max 5MB)
                if (imageFile.size > 5 * 1024 * 1024) {
                    errors.push('Image size must be less than 5MB');
                }
            }
            
            // Show errors or submit form
            if (errors.length > 0) {
                showErrors(errors);
            } else {
                // Show loading state
                showLoading();
                
                // Submit form
                this.submit();
            }
        });
        
        // Show validation errors
        function showErrors(errors) {
            // Remove existing error messages
            const existingErrors = document.querySelectorAll('.validation-error');
            existingErrors.forEach(error => error.remove());
            
            // Create error message container
            const errorContainer = document.createElement('div');
            errorContainer.className = 'message error validation-error';
            
            // Build error list HTML
            let errorListHTML = '<h4>Please fix following errors:</h4><ul>';
            for (let i = 0; i < errors.length; i++) {
                errorListHTML += '<li>' + errors[i] + '</li>';
            }
            errorListHTML += '</ul>';
            errorContainer.innerHTML = errorListHTML;
            
            // Insert error message at the top of the form
            const formContainer = document.querySelector('.form-container');
            const formHeader = formContainer.querySelector('.form-header');
            formContainer.insertBefore(errorContainer, formHeader.nextSibling);
            
            // Scroll to top of form
            errorContainer.scrollIntoView({ behavior: 'smooth' });
        }
        
        // Show loading state
        function showLoading() {
            const submitBtn = document.querySelector('.btn-primary');
            const originalText = submitBtn.innerHTML;
            
            submitBtn.innerHTML = '<span>⏳</span> Processing...';
            submitBtn.disabled = true;
            
            // Reset button after 10 seconds (in case of network issues)
            setTimeout(() => {
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }, 10000);
        }
        
        // Auto-generate seller ID
        document.getElementById('sellerId').addEventListener('blur', function() {
            if (!this.value.trim()) {
                const timestamp = Date.now() % 1000000;
                this.value = 'S' + timestamp;
                this.style.backgroundColor = '#e8f5e8';
            }
        });
        
        // Phone number formatting
        document.getElementById('phone').addEventListener('input', function(e) {
            // Only allow numbers
            this.value = this.value.replace(/[^0-9]/g, '');
        });
        
        // Price formatting
        document.getElementById('price').addEventListener('blur', function() {
            if (this.value && !isNaN(this.value)) {
                const price = parseFloat(this.value);
                this.value = price.toFixed(2);
            }
        });
        
        // Form reset functionality
        document.querySelector('.btn-secondary').addEventListener('click', function(e) {
            e.preventDefault();
            
            // Clear all validation errors
            const errors = document.querySelectorAll('.validation-error');
            errors.forEach(error => error.remove());
            
            // Reset form
            document.getElementById('sellerForm').reset();
            
            // Show success message
            const successDiv = document.createElement('div');
            successDiv.className = 'message success';
            successDiv.textContent = 'Form has been reset successfully';
            
            const formContainer = document.querySelector('.form-container');
            const formHeader = formContainer.querySelector('.form-header');
            formContainer.insertBefore(successDiv, formHeader.nextSibling);
            
            // Remove success message after 3 seconds
            setTimeout(() => {
                successDiv.remove();
            }, 3000);
        });
    </script>
</body>
</html>
