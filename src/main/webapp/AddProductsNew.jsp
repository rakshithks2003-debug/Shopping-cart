<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in and is a seller
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.html");
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
<title>Add New Product - Seller Portal</title>
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
        padding: 20px;
    }
    
    .back-btn {
        position: fixed;
        top: 20px;
        left: 20px;
        background: #fff;
        color: #667eea;
        padding: 12px 20px;
        border-radius: 25px;
        text-decoration: none;
        font-weight: 600;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        transition: all 0.3s ease;
        z-index: 1000;
    }
    
    .back-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.3);
    }
    
    .header {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px;
        text-align: center;
        color: #333;
        border-radius: 15px;
        margin-bottom: 30px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.1);
    }
    
    .header h1 {
        font-size: 2.5rem;
        margin-bottom: 10px;
        color: #667eea;
    }
    
    .header p {
        font-size: 1.1rem;
        color: #666;
    }
    
    .container {
        max-width: 900px;
        margin: 0 auto;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px;
        padding: 40px;
        box-shadow: 0 15px 50px rgba(0,0,0,0.2);
    }
    
    .form-section {
        margin-bottom: 30px;
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
    
    .form-group {
        margin-bottom: 20px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: 600;
        color: #444;
        font-size: 1rem;
    }
    
    .form-group.required label::after {
        content: " *";
        color: #e74c3c;
    }
    
    .form-group input,
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 15px;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 16px;
        transition: all 0.3s ease;
        background: #fff;
    }
    
    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }
    
    .form-row .form-group {
        margin-bottom: 0;
    }
    
    .image-upload-area {
        border: 2px dashed #667eea;
        border-radius: 10px;
        padding: 30px;
        text-align: center;
        background: #f8f9ff;
        transition: all 0.3s ease;
        cursor: pointer;
        position: relative;
    }
    
    .image-upload-area:hover {
        background: #eef0ff;
        border-color: #5a67d8;
    }
    
    .image-upload-area.dragover {
        background: #e0e7ff;
        border-color: #4c51bf;
    }
    
    .upload-icon {
        font-size: 3rem;
        color: #667eea;
        margin-bottom: 15px;
    }
    
    .upload-text {
        font-size: 1.1rem;
        color: #555;
        margin-bottom: 10px;
    }
    
    .upload-hint {
        font-size: 0.9rem;
        color: #888;
    }
    
    .image-preview-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
        gap: 15px;
        margin-top: 20px;
    }
    
    .image-preview {
        position: relative;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }
    
    .image-preview img {
        width: 100%;
        height: 120px;
        object-fit: cover;
        display: block;
    }
    
    .remove-image {
        position: absolute;
        top: 5px;
        right: 5px;
        background: #e74c3c;
        color: white;
        border: none;
        border-radius: 50%;
        width: 25px;
        height: 25px;
        cursor: pointer;
        font-size: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .btn-group {
        display: flex;
        gap: 15px;
        margin-top: 30px;
        justify-content: center;
    }
    
    .btn {
        padding: 15px 30px;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        text-decoration: none;
        text-align: center;
        transition: all 0.3s ease;
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
        background: #6c757d;
        color: white;
    }
    
    .btn-secondary:hover {
        background: #5a6268;
        transform: translateY(-2px);
    }
    
    .btn-success {
        background: #28a745;
        color: white;
    }
    
    .btn-success:hover {
        background: #218838;
        transform: translateY(-2px);
    }
    
    .alert {
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 25px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .alert-success {
        background: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }
    
    .alert-error {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }
    
    .alert-info {
        background: #d1ecf1;
        color: #0c5460;
        border: 1px solid #bee5eb;
    }
    
    .hidden {
        display: none;
    }
    
    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
        
        .btn-group {
            flex-direction: column;
        }
        
        .header h1 {
            font-size: 2rem;
        }
        
        .container {
            padding: 20px;
        }
    }
</style>
</head>
<body>
    <a href="SellerDashboard.jsp" class="back-btn">
        <i class="fas fa-arrow-left"></i> Dashboard
    </a>
    
    <div class="header">
        <h1><i class="fas fa-box-open"></i> Add New Product</h1>
        <p>Fill in the product details to add it to your inventory</p>
    </div>
    
    <div class="container">
        <!-- Display Messages -->
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            String info = request.getParameter("info");
            
            if (error != null && !error.trim().isEmpty()) {
        %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= error %>
            </div>
        <%
            }
            if (success != null && !success.trim().isEmpty()) {
        %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <%= success %>
            </div>
        <%
            }
            if (info != null && !info.trim().isEmpty()) {
        %>
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <%= info %>
            </div>
        <%
            }
        %>
        
        <form id="addProductForm" action="AddProductNewServlet" method="post" enctype="multipart/form-data">
            <!-- Basic Information Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-info-circle"></i>
                    Basic Information
                </div>
                
                <div class="form-row">
                    <div class="form-group required">
                        <label for="productId">Product ID</label>
                        <input type="text" id="productId" name="productId" required 
                               placeholder="e.g., P1234 or PROD-001" 
                               pattern="[A-Za-z0-9\-_]+"
                               title="Product ID can contain letters, numbers, hyphens, and underscores">
                    </div>
                    
                    <div class="form-group required">
                        <label for="productName">Product Name</label>
                        <input type="text" id="productName" name="productName" required
                               placeholder="Enter product name">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group required">
                        <label for="brand">Brand</label>
                        <input type="text" id="brand" name="brand" required
                               placeholder="Enter brand name">
                    </div>
                    
                    <div class="form-group required">
                        <label for="category">Category</label>
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
                
                <div class="form-row">
                    <div class="form-group required">
                        <label for="price">Price (₹)</label>
                        <input type="number" id="price" name="price" required 
                               min="0" step="0.01" placeholder="0.00">
                    </div>
                    
                    <div class="form-group">
                        <label for="discount">Discount (%)</label>
                        <input type="number" id="discount" name="discount" 
                               min="0" max="100" step="0.1" placeholder="0" value="0">
                    </div>
                </div>
            </div>
            
            <!-- Description Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-align-left"></i>
                    Product Description
                </div>
                
                <div class="form-group required">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" required 
                              rows="5" placeholder="Describe your product in detail..."></textarea>
                </div>
                
                <div class="form-group">
                    <label for="shortDescription">Short Description (for listings)</label>
                    <textarea id="shortDescription" name="shortDescription" 
                              rows="2" placeholder="Brief product summary (optional)"></textarea>
                </div>
            </div>
            
            <!-- Images Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-images"></i>
                    Product Images
                </div>
                
                <div class="form-group required">
                    <label>Upload Images</label>
                    <div class="image-upload-area" id="imageUploadArea">
                        <div class="upload-icon">
                            <i class="fas fa-cloud-upload-alt"></i>
                        </div>
                        <div class="upload-text">Click or drag images here</div>
                        <div class="upload-hint">Supports JPG, PNG, GIF, WEBP (Max 15MB each)</div>
                        <input type="file" id="productImage" name="productImage" 
                               accept="image/*" multiple required class="hidden">
                    </div>
                    
                    <div class="image-preview-container" id="imagePreviewContainer">
                        <!-- Image previews will be added here dynamically -->
                    </div>
                </div>
            </div>
            
            <!-- Additional Information Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-plus-circle"></i>
                    Additional Information
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="stock">Stock Quantity</label>
                        <input type="number" id="stock" name="stock" 
                               min="0" value="10" placeholder="Available quantity">
                    </div>
                    
                    <div class="form-group">
                        <label for="weight">Weight (kg)</label>
                        <input type="number" id="weight" name="weight" 
                               min="0" step="0.001" placeholder="Product weight">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="tags">Tags/Keywords</label>
                    <input type="text" id="tags" name="tags" 
                           placeholder="e.g., smartphone, android, 5g (separate with commas)">
                </div>
            </div>
            
            <!-- Action Buttons -->
            <div class="btn-group">
                <button type="submit" class="btn btn-primary" id="submitBtn">
                    <i class="fas fa-plus"></i> Add Product
                </button>
                <button type="reset" class="btn btn-secondary" id="resetBtn">
                    <i class="fas fa-redo"></i> Reset Form
                </button>
                <button type="button" class="btn btn-success" id="previewBtn">
                    <i class="fas fa-eye"></i> Preview
                </button>
            </div>
        </form>
    </div>
    
    <script>
        // Image upload handling
        const imageUploadArea = document.getElementById('imageUploadArea');
        const fileInput = document.getElementById('productImage');
        const previewContainer = document.getElementById('imagePreviewContainer');
        const submitBtn = document.getElementById('submitBtn');
        
        // Click to upload
        imageUploadArea.addEventListener('click', () => {
            fileInput.click();
        });
        
        // Drag and drop functionality
        imageUploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            imageUploadArea.classList.add('dragover');
        });
        
        imageUploadArea.addEventListener('dragleave', () => {
            imageUploadArea.classList.remove('dragover');
        });
        
        imageUploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            imageUploadArea.classList.remove('dragover');
            const files = e.dataTransfer.files;
            handleFiles(files);
        });
        
        // File input change
        fileInput.addEventListener('change', (e) => {
            handleFiles(e.target.files);
        });
        
        function handleFiles(files) {
            previewContainer.innerHTML = '';
            
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                
                // Validate file type
                if (!file.type.match('image.*')) {
                    alert('Please select only image files');
                    continue;
                }
                
                // Validate file size (15MB)
                if (file.size > 15 * 1024 * 1024) {
                    alert(`File ${file.name} is too large. Maximum size is 15MB.`);
                    continue;
                }
                
                const reader = new FileReader();
                reader.onload = function(e) {
                    const previewDiv = document.createElement('div');
                    previewDiv.className = 'image-preview';
                    previewDiv.innerHTML = `
                        <img src="${e.target.result}" alt="Preview">
                        <button class="remove-image" onclick="removeImage(this)">
                            <i class="fas fa-times"></i>
                        </button>
                    `;
                    previewContainer.appendChild(previewDiv);
                };
                reader.readAsDataURL(file);
            }
        }
        
        function removeImage(button) {
            button.parentElement.remove();
            // Clear file input if no images left
            if (previewContainer.children.length === 0) {
                fileInput.value = '';
            }
        }
        
        // Form validation
        document.getElementById('addProductForm').addEventListener('submit', function(e) {
            const productId = document.getElementById('productId').value.trim();
            const productName = document.getElementById('productName').value.trim();
            const brand = document.getElementById('brand').value.trim();
            const category = document.getElementById('category').value;
            const price = document.getElementById('price').value;
            const description = document.getElementById('description').value.trim();
            
            if (!productId || !productName || !brand || !category || !price || !description) {
                e.preventDefault();
                alert('Please fill in all required fields');
                return;
            }
            
            if (previewContainer.children.length === 0) {
                e.preventDefault();
                alert('Please upload at least one image');
                return;
            }
            
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding Product...';
            submitBtn.disabled = true;
        });
        
        // Reset form
        document.getElementById('resetBtn').addEventListener('click', function() {
            previewContainer.innerHTML = '';
            fileInput.value = '';
        });
        
        // Preview functionality
        document.getElementById('previewBtn').addEventListener('click', function() {
            const formData = new FormData(document.getElementById('addProductForm'));
            let previewContent = '<div style="background: white; padding: 20px; border-radius: 10px; max-width: 600px; margin: 20px auto;">';
            previewContent += '<h2 style="color: #333; margin-bottom: 20px;">Product Preview</h2>';
            
            // Basic info
            previewContent += '<div style="margin-bottom: 15px;"><strong>Product ID:</strong> ' + (formData.get('productId') || 'Not provided') + '</div>';
            previewContent += '<div style="margin-bottom: 15px;"><strong>Name:</strong> ' + (formData.get('productName') || 'Not provided') + '</div>';
            previewContent += '<div style="margin-bottom: 15px;"><strong>Brand:</strong> ' + (formData.get('brand') || 'Not provided') + '</div>';
            previewContent += '<div style="margin-bottom: 15px;"><strong>Category:</strong> ' + (document.getElementById('category').options[document.getElementById('category').selectedIndex].text || 'Not selected') + '</div>';
            previewContent += '<div style="margin-bottom: 15px;"><strong>Price:</strong> ₹' + (formData.get('price') || '0.00') + '</div>';
            
            if (formData.get('discount') && formData.get('discount') !== '0') {
                previewContent += '<div style="margin-bottom: 15px;"><strong>Discount:</strong> ' + formData.get('discount') + '%</div>';
            }
            
            previewContent += '<div style="margin-bottom: 15px;"><strong>Description:</strong><br>' + (formData.get('description') || 'Not provided') + '</div>';
            
            // Images preview
            if (previewContainer.children.length > 0) {
                previewContent += '<div style="margin-top: 20px;"><strong>Images:</strong></div>';
                previewContent += '<div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px;">';
                for (let img of previewContainer.children) {
                    const imgSrc = img.querySelector('img').src;
                    previewContent += '<img src="' + imgSrc + '" style="width: 100px; height: 100px; object-fit: cover; border-radius: 5px;">';
                }
                previewContent += '</div>';
            }
            
            previewContent += '</div>';
            
            const previewWindow = window.open('', 'Product Preview', 'width=700,height=600,scrollbars=yes');
            previewWindow.document.write(previewContent);
        });
        
        // Auto-generate product ID
        document.getElementById('productName').addEventListener('blur', function() {
            const productIdField = document.getElementById('productId');
            if (!productIdField.value && this.value) {
                // Generate ID from product name
                let productId = this.value.substring(0, 10).toUpperCase().replace(/[^A-Z0-9]/g, '');
                if (productId.length < 3) {
                    productId = 'PROD' + Math.floor(Math.random() * 1000);
                }
                productIdField.value = productId;
            }
        });
    </script>
</body>
</html>