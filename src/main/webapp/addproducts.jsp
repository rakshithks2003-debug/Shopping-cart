<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in and is a seller
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.jsp");
    return;
}
String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Check if user is a seller
if (!"seller".equals(userRole)) {
    response.sendRedirect("Home.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Products - Enhanced Form</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh; padding: 20px;
    }
    .header {
        background: rgba(255, 255, 255, 0.95);
        padding: 20px; text-align: center;
        color: #333; border-radius: 15px; margin-bottom: 30px;
    }
    .container {
        max-width: 900px; margin: 0 auto;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px; padding: 40px;
    }
    .form-group { margin-bottom: 20px; }
    .form-group label {
        display: block; margin-bottom: 8px;
        font-weight: 600; color: #333;
    }
    .form-group input, .form-group select, .form-group textarea {
        width: 100%; padding: 12px;
        border: 2px solid #e1e5e9; border-radius: 8px;
        font-size: 14px;
    }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .btn {
        padding: 12px 20px; border: none; border-radius: 8px;
        font-size: 16px; font-weight: 600; cursor: pointer;
        text-decoration: none; text-align: center;
    }
    .btn-primary {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
    }
    .btn-secondary { background: #6c757d; color: white; }
    .btn-group { display: flex; gap: 15px; margin-top: 20px; }
    .back-btn {
        position: fixed; top: 20px; left: 20px;
        background: #6c757d; color: white;
        padding: 10px 20px; border-radius: 25px;
        text-decoration: none; font-weight: 600;
    }
    
    /* Enhanced Form Styles */
    .form-section {
        margin: 30px 0;
        padding: 25px;
        background: #f8f9fa;
        border-radius: 10px;
        border-left: 4px solid #667eea;
    }
    
    .section-title {
        font-size: 1.3rem;
        color: #333;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .form-grid-3 {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 15px;
    }
    
    @media (max-width: 768px) {
        .form-grid-3 {
            grid-template-columns: 1fr;
        }
    }
</style>
</head>
<body>
    <a href="SellerDashboard.jsp" class="back-btn">
        <i class="fas fa-arrow-left"></i> Back to Dashboard
    </a>
    
    <div class="header">
        <h1><i class="fas fa-plus-circle"></i> Add New Products</h1>
        <p>Enhanced product information form</p>
    </div>
    
    <div class="container">
        <%-- Display success or error messages --%>
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null && !error.trim().isEmpty()) {
        %>
            <div style="background: #f8d7da; color: #721c24; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <%
            }
            if (success != null && !success.trim().isEmpty()) {
        %>
            <div style="background: #d4edda; color: #155724; padding: 12px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
                <i class="fas fa-check-circle"></i> <%= success %>
            </div>
        <%
            }
        %>
        
        <form action="AddProductServlet" method="post" enctype="multipart/form-data">
            <!-- Basic Information Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-info-circle"></i>
                    Basic Information
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="productId">Product ID *</label>
                        <input type="text" id="productId" name="productId" required 
                               placeholder="e.g., PROD-2024-001">
                    </div>
                    <div class="form-group">
                        <label for="productName">Product Name *</label>
                        <input type="text" id="productName" name="productName" required
                               placeholder="Enter full product name">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="brand">Brand *</label>
                        <input type="text" id="brand" name="brand" required
                               placeholder="Enter brand name">
                    </div>
                    <div class="form-group">
                        <label for="category">Category *</label>
                        <select id="category" name="category" required>
                            <option value="">-- Select Category --</option>
                            <option value="Mo">📱 Mobile Phones</option>
                            <option value="Ms">👞 Men's Shoes</option>
                            <option value="Lp">💻 Laptops</option>
                            <option value="Wt">⌚ Watches</option>
                            <option value="Hp">🎧 Headphones</option>
                            <option value="Ca">📷 Cameras</option>
                            <option value="Cl">👕 Clothing</option>
                            <option value="Bk">📚 Books</option>
                            <option value="Sp">🏀 Sports</option>
                            <option value="Hm">🏠 Home & Kitchen</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-grid-3">
                    <div class="form-group">
                        <label for="price">Price (₹) *</label>
                        <input type="number" id="price" name="price" required 
                               min="0" step="0.01" placeholder="0.00">
                    </div>
                    <div class="form-group">
                        <label for="discount">Discount (%)</label>
                        <input type="number" id="discount" name="discount" 
                               min="0" max="100" step="0.1" placeholder="0" value="0">
                    </div>
                    <div class="form-group">
                        <label for="stock">Stock Quantity</label>
                        <input type="number" id="stock" name="stock" 
                               min="0" value="10" placeholder="Available quantity">
                    </div>
                </div>
            </div>
            
            <!-- Product Details Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-align-left"></i>
                    Product Details
                </div>
                
                <div class="form-group">
                    <label for="description">Detailed Description *</label>
                    <textarea id="description" name="description" required 
                              rows="5" placeholder="Provide comprehensive product description..."></textarea>
                </div>
                
                <div class="form-group">
                    <label for="shortDescription">Short Description</label>
                    <textarea id="shortDescription" name="shortDescription" 
                              rows="2" placeholder="Brief product summary for listings"></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="weight">Weight (kg)</label>
                        <input type="number" id="weight" name="weight" 
                               min="0" step="0.001" placeholder="Product weight">
                    </div>
                    <div class="form-group">
                        <label for="color">Color/Variant</label>
                        <input type="text" id="color" name="color" 
                               placeholder="e.g., Black, Red, Blue">
                    </div>
                </div>
            </div>
            
            <!-- Media Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-images"></i>
                    Product Media
                </div>
                
                <div class="form-group">
                    <label for="productImage">Product Images *</label>
                    <input type="file" id="productImage" name="productImage" 
                           accept="image/*" multiple required>
                    <small style="color: #666;">Supports JPG, PNG, GIF, WEBP (Max 15MB each)</small>
                </div>
                
                <div class="form-group">
                    <label for="videoUrl">Product Video URL (Optional)</label>
                    <input type="url" id="videoUrl" name="videoUrl" 
                           placeholder="https://youtube.com/watch?v=...">
                </div>
            </div>
            
            <!-- Advanced Settings Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-cog"></i>
                    Advanced Settings
                </div>
                
                <div class="form-group">
                    <label for="tags">Tags/Keywords</label>
                    <input type="text" id="tags" name="tags" 
                           placeholder="e.g., smartphone, android, 5g (separate with commas)">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="warranty">Warranty Period</label>
                        <select id="warranty" name="warranty">
                            <option value="">No warranty</option>
                            <option value="6 months">6 months</option>
                            <option value="1 year">1 year</option>
                            <option value="2 years">2 years</option>
                            <option value="Lifetime">Lifetime</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="availability">Availability Status</label>
                        <select id="availability" name="availability">
                            <option value="In Stock">In Stock</option>
                            <option value="Out of Stock">Out of Stock</option>
                            <option value="Pre-order">Pre-order</option>
                            <option value="Coming Soon">Coming Soon</option>
                        </select>
                    </div>
                </div>
            </div>
            
            <div class="btn-group">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-plus-circle"></i> Add Product
                </button>
                <button type="reset" class="btn btn-secondary">
                    <i class="fas fa-redo"></i> Reset Form
                </button>
            </div>
        </form>
    </div>
    
    <script>
        // Auto-generate product ID
        document.getElementById('productName').addEventListener('blur', function() {
            const productIdField = document.getElementById('productId');
            if (!productIdField.value && this.value) {
                let productId = this.value.substring(0, 10).toUpperCase().replace(/[^A-Z0-9]/g, '');
                if (productId.length < 3) {
                    productId = 'PROD' + Math.floor(Math.random() * 1000);
                }
                productIdField.value = 'PROD-' + new Date().getFullYear() + '-' + productId;
            }
        });
        
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const requiredFields = ['productId', 'productName', 'brand', 'category', 'price', 'description'];
            let isValid = true;
            
            requiredFields.forEach(fieldId => {
                const field = document.getElementById(fieldId);
                if (!field.value.trim()) {
                    isValid = false;
                    field.style.borderColor = '#e74c3c';
                } else {
                    field.style.borderColor = '#e1e5e9';
                }
            });
            
            if (!isValid) {
                e.preventDefault();
                alert('Please fill in all required fields (marked with *)');
            }
        });
    </script>
</body>
</html>