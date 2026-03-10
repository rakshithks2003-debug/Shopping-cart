<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Check if user is logged in and is an admin
HttpSession sessionObg = request.getSession(false);
if (sessionObg == null || sessionObg.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObg.getAttribute("isLoggedIn")) {
    response.sendRedirect("Login.jsp");
    return;
}

String userRole = (String) sessionObg.getAttribute("userRole");
String username = (String) sessionObg.getAttribute("username");

// Only allow admins to access this page
if (!"admin".equals(userRole)) {
    response.sendRedirect("Showproducts.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Product Management - Mini Shopping cart</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="css/back-button-styles.css">
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
    
    /* ========================================
       BACK TO HOME BUTTON STYLES
       ======================================== */
    .back-to-home-btn-left {
        position: fixed;
        top: 20px;
        left: 20px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        color: #667eea;
        padding: 12px 20px;
        text-decoration: none;
        border-radius: 25px;
        font-weight: 600;
        font-size: 14px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 8px;
        border: 2px solid rgba(102, 126, 234, 0.2);
    }
    
    .back-to-home-btn-left:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        background: rgba(255, 255, 255, 1);
        border-color: #667eea;
    }
    
    /* ========================================
       MODERN CONTAINER STYLES
       ======================================== */
    .container {
        max-width: 900px;
        margin: 0 auto;
        padding: 40px 20px;
    }
    
    .header {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 40px;
        margin-bottom: 30px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    
    .header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #667eea, #764ba2, #667eea);
        animation: shimmer 3s ease-in-out infinite;
    }
    
    @keyframes shimmer {
        0%, 100% { transform: translateX(-100%); }
        50% { transform: translateX(100%); }
    }
    
    .header h1 {
        font-size: 36px;
        font-weight: 700;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 12px;
    }
    
    .header p {
        color: #666;
        font-size: 18px;
        opacity: 0.8;
    }
    
    /* ========================================
       FORM STYLES
       ======================================== */
    .form-container {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 40px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }
    
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 25px;
    }
    
    .form-group {
        margin-bottom: 25px;
    }
    
    .form-group.full-width {
        grid-column: 1 / -1;
    }
    
    .form-label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        font-size: 16px;
    }
    
    .form-label .required {
        color: #ff6b6b;
        margin-left: 4px;
    }
    
    .form-input, .form-select, .form-textarea {
        width: 100%;
        padding: 15px;
        border: 2px solid #e9ecef;
        border-radius: 12px;
        font-size: 16px;
        transition: all 0.3s ease;
        background: white;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    .form-input:focus, .form-select:focus, .form-textarea:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    
    .form-textarea {
        resize: vertical;
        min-height: 120px;
    }
    
    /* ========================================
       IMAGE UPLOAD STYLES
       ======================================== */
    .image-upload-section {
        margin-bottom: 25px;
    }
    
    .image-upload-area {
        border: 2px dashed #667eea;
        border-radius: 12px;
        padding: 30px;
        text-align: center;
        background: rgba(102, 126, 234, 0.05);
        transition: all 0.3s ease;
        cursor: pointer;
    }
    
    .image-upload-area:hover {
        background: rgba(102, 126, 234, 0.1);
        border-color: #764ba2;
    }
    
    .image-upload-area i {
        font-size: 48px;
        color: #667eea;
        margin-bottom: 15px;
    }
    
    .image-upload-text {
        color: #666;
        font-size: 16px;
        margin-bottom: 10px;
    }
    
    .image-upload-hint {
        color: #999;
        font-size: 14px;
    }
    
    .image-preview-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
        gap: 15px;
        margin-top: 20px;
    }
    
    .image-preview {
        position: relative;
        border-radius: 8px;
        overflow: hidden;
        aspect-ratio: 1;
        background: #f8f9fa;
        border: 2px solid #e9ecef;
    }
    
    .image-preview img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    
    .image-remove {
        position: absolute;
        top: 5px;
        right: 5px;
        background: #ff6b6b;
        color: white;
        border: none;
        border-radius: 50%;
        width: 24px;
        height: 24px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        transition: all 0.3s ease;
        z-index: 10;
    }
    
    .image-remove:hover {
        background: #ee5a24;
        transform: scale(1.1);
    }
    
    /* ========================================
       BUTTON STYLES
       ======================================== */
    .form-buttons {
        display: flex;
        gap: 15px;
        justify-content: flex-end;
        margin-top: 30px;
    }
    
    .btn {
        padding: 15px 30px;
        border: none;
        border-radius: 12px;
        font-weight: 600;
        font-size: 16px;
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
        box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
    }
    
    .btn-secondary {
        background: #6c757d;
        color: white;
        box-shadow: 0 4px 15px rgba(108, 117, 125, 0.3);
    }
    
    .btn-secondary:hover {
        background: #5a6268;
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(108, 117, 125, 0.4);
    }
    
    /* ========================================
       SUCCESS MESSAGE STYLES
       ======================================== */
    .success-message {
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        padding: 20px;
        border-radius: 12px;
        text-align: center;
        font-weight: 600;
        margin-bottom: 20px;
        box-shadow: 0 10px 30px rgba(76, 175, 80, 0.3);
        display: none;
    }
    
    .success-message.show {
        display: block;
        animation: slideIn 0.5s ease;
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
    
    /* ========================================
       PRODUCT PREVIEW STYLES
       ======================================== */
    .preview-container {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 40px;
        margin-top: 30px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        position: relative;
        overflow: hidden;
    }
    
    .preview-container::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #4CAF50, #45a049, #4CAF50);
        animation: shimmer 3s ease-in-out infinite;
    }
    
    .preview-header {
        text-align: center;
        margin-bottom: 30px;
    }
    
    .preview-header h3 {
        font-size: 28px;
        font-weight: 700;
        background: linear-gradient(135deg, #4CAF50, #45a049);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 8px;
    }
    
    .preview-header p {
        color: #666;
        font-size: 16px;
        opacity: 0.8;
    }
    
    .preview-content {
        display: grid;
        grid-template-columns: 1fr 2fr;
        gap: 30px;
    }
    
    .preview-image-section {
        display: flex;
        justify-content: center;
        align-items: center;
    }
    
    .preview-image-container {
        width: 200px;
        height: 200px;
        border: 2px dashed #ddd;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f8f9fa;
        overflow: hidden;
    }
    
    .preview-image-container img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    
    .no-image-placeholder {
        text-align: center;
        color: #999;
    }
    
    .no-image-placeholder i {
        font-size: 48px;
        margin-bottom: 10px;
        color: #ddd;
    }
    
    .no-image-placeholder p {
        font-size: 14px;
        margin: 0;
    }
    
    .preview-details-section {
        display: flex;
        flex-direction: column;
        gap: 15px;
    }
    
    .preview-detail-group {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px;
        background: #f8f9fa;
        border-radius: 8px;
        border-left: 4px solid #4CAF50;
    }
    
    .preview-label {
        font-weight: 600;
        color: #333;
        font-size: 14px;
        min-width: 100px;
    }
    
    .preview-value {
        font-weight: 500;
        color: #555;
        font-size: 16px;
        flex: 1;
        text-align: right;
        word-break: break-word;
    }
    
    /* ========================================
       RESPONSIVE DESIGN
       ======================================== */
    @media (max-width: 768px) {
        body {
            padding: 10px;
        }
        
        .container {
            padding: 20px 10px;
        }
        
        .header, .form-container {
            padding: 30px 20px;
        }
        
        .header h1 {
            font-size: 28px;
        }
        
        .form-row {
            grid-template-columns: 1fr;
            gap: 0;
        }
        
        .form-buttons {
            flex-direction: column;
        }
        
        .btn {
            width: 100%;
            justify-content: center;
        }
    }
    
    @media (max-width: 480px) {
        .header h1 {
            font-size: 24px;
        }
        
        .back-to-home-btn-left {
            top: 10px;
            left: 10px;
            padding: 10px 16px;
            font-size: 12px;
        }
        
        .image-upload-area {
            padding: 20px;
        }
        
        .image-upload-area i {
            font-size: 36px;
        }
    }
</style>
</head>
<body>
    <!-- Back to Admin Dashboard Button -->
    <a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page">
        <i class="fas fa-home"></i> Back 
    </a>

    <div class="container">
        <header>
            <h1>🛠️ Admin Product Management</h1>
            <p>Add new products to the marketplace</p>
        </header>
        
        <main>
            <div class="form-container">
                <%
                    String success = request.getParameter("success");
                    String error = request.getParameter("error");
                    if (success != null && !success.isEmpty()) {
                %>
                <div class="success-message show">
                    ✅ <%= success %>
                </div>
                <%
                    } else if (error != null && !error.isEmpty()) {
                %>
                <div style="background: #f8d7da; color: #721c24; padding: 20px; border-radius: 12px; text-align: center; font-weight: 600; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                    ❌ <%= error %>
                </div>
                <%
                    }
                %>
                
                <div class="success-message" id="successMessage">
                    ✅ Product added successfully!
                </div>
                
                <form action="AdminProductServlet" method="post" enctype="multipart/form-data" id="adminProductForm">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                Product ID <span class="required">*</span>
                            </label>
                            <input type="text" name="pid" class="form-input" 
                                   placeholder="Enter unique product ID" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                Brand <span class="required">*</span>
                            </label>
                            <input type="text" name="brand" class="form-input" 
                                   placeholder="Enter brand name" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            Product Name <span class="required">*</span>
                        </label>
                        <input type="text" name="productName" class="form-input" 
                               placeholder="Enter product name" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                Price (₹) <span class="required">*</span>
                            </label>
                            <input type="number" name="price" class="form-input" 
                                   placeholder="0.00" step="0.01" min="0" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                Category ID <span class="required">*</span>
                            </label>
                            <select name="categoryId" class="form-select" required>
                                <option value="">-- Select Category --</option>
                                <option value="Mo">📱 Mobile</option>
                                <option value="Ms">👞 Men Shoe</option>
                                <option value="Lp">💻 Laptop</option>
                                <option value="Wo">👗Fashion</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="image-upload-section">
                        <label class="form-label">
                            Product Images <span class="required">*</span>
                        </label>
                        <div class="image-upload-area" onclick="document.getElementById('productImage').click()">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <div class="image-upload-text">Click to upload product images (Minimum 5 required)</div>
                            <div class="image-upload-hint">Supports: JPG, PNG, GIF (Max 5MB each) - Select multiple images</div>
                        </div>
                        <input type="file" id="productImage" name="productImage" 
                               accept="image/*" multiple style="display: none;" onchange="previewImages(event)" required>
                        <div class="image-preview-container" id="imagePreview"></div>
                        <div class="image-count" id="imageCount" style="margin-top: 10px; color: #666; font-size: 14px;">
                            Images selected: <span id="count">0</span>/5 (Minimum required)
                        </div>
                    </div>
                    
                    <div class="form-group full-width">
                        <label class="form-label">
                            Description
                        </label>
                        <textarea name="description" class="form-textarea" 
                                  placeholder="Enter product description (optional)"></textarea>
                    </div>
                    
                    <div class="form-buttons">
                        <a href="admin.jsp" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add Product
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- Product Preview Section -->
            <div class="preview-container" id="productPreview" style="display: none;">
                <div class="preview-header">
                    <h3>📦 Product Preview</h3>
                    <p>Review your product before adding to database</p>
                </div>
                <div class="preview-content">
                    <div class="preview-image-section">
                        <div class="preview-image-container" id="previewImageContainer">
                            <div class="no-image-placeholder">
                                <i class="fas fa-image"></i>
                                <p>No image selected</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="preview-details-section">
                        <div class="preview-detail-group">
                            <label class="preview-label">Product ID:</label>
                            <div class="preview-value" id="previewPid">-</div>
                        </div>
                        
                        <div class="preview-detail-group">
                            <label class="preview-label">Brand:</label>
                            <div class="preview-value" id="previewBrand">-</div>
                        </div>
                        
                        <div class="preview-detail-group">
                            <label class="preview-label">Product Name:</label>
                            <div class="preview-value" id="previewProductName">-</div>
                        </div>
                        
                        <div class="preview-detail-group">
                            <label class="preview-label">Price:</label>
                            <div class="preview-value" id="previewPrice">₹0.00</div>
                        </div>
                        
                        <div class="preview-detail-group">
                            <label class="preview-label">Category:</label>
                            <div class="preview-value" id="previewCategory">-</div>
                        </div>
                        
                        <div class="preview-detail-group">
                            <label class="preview-label">Description:</label>
                            <div class="preview-value" id="previewDescription">No description</div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Product preview functionality
        function updatePreview() {
            const pid = document.querySelector('input[name="pid"]').value || '-';
            const brand = document.querySelector('input[name="brand"]').value || '-';
            const productName = document.querySelector('input[name="productName"]').value || '-';
            const price = document.querySelector('input[name="price"]').value || '0.00';
            const categoryId = document.querySelector('select[name="categoryId"]').value;
            const description = document.querySelector('textarea[name="description"]').value || 'No description';
            
            // Get category name
            const categorySelect = document.querySelector('select[name="categoryId"]');
            const categoryName = categorySelect.options[categorySelect.selectedIndex]?.text || '-';
            
            // Update preview values
            document.getElementById('previewPid').textContent = pid;
            document.getElementById('previewBrand').textContent = brand;
            document.getElementById('previewProductName').textContent = productName;
            document.getElementById('previewPrice').textContent = '₹' + price;
            document.getElementById('previewCategory').textContent = categoryName;
            document.getElementById('previewDescription').textContent = description;
            
            // Show/hide preview based on form completion
            const hasContent = pid !== '-' || brand !== '-' || productName !== '-' || price !== '0.00';
            const previewContainer = document.getElementById('productPreview');
            
            if (hasContent) {
                previewContainer.style.display = 'block';
                // Smooth scroll to preview
                previewContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
            } else {
                previewContainer.style.display = 'none';
            }
        }
        
        // Image preview functionality for multiple images
        function previewImages(event) {
            const files = event.target.files;
            const formPreviewContainer = document.getElementById('imagePreview');
            const productPreviewContainer = document.getElementById('previewImageContainer');
            const countElement = document.getElementById('count');
            
            // Reset containers
            formPreviewContainer.innerHTML = '';
            
            if (files.length < 5) {
                alert('Please select at least 5 images.');
                event.target.value = ''; // Clear the input
                countElement.textContent = '0';
                updateProductPreviewNoImage();
                return;
            }
            
            if (files.length > 10) {
                alert('Maximum 10 images allowed.');
                // Keep only first 10 files
                const dataTransfer = new DataTransfer();
                for (let i = 0; i < 10; i++) {
                    dataTransfer.items.add(files[i]);
                }
                event.target.files = dataTransfer.files;
            }
            
            countElement.textContent = event.target.files.length;
            
            // Process each file
            for (let i = 0; i < event.target.files.length; i++) {
                const file = event.target.files[i];
                if (file && file.type.startsWith('image/')) {
                    const reader = new FileReader();
                    
                    reader.onload = function(e) {
                        // Add to form preview container
                        const previewDiv = document.createElement('div');
                        previewDiv.className = 'image-preview';
                        previewDiv.innerHTML = `
                            <img src="${e.target.result}" alt="Product Preview ${i + 1}">
                            <button type="button" class="image-remove" onclick="removeImage(this, ${i})">
                                <i class="fas fa-times"></i>
                            </button>
                        `;
                        formPreviewContainer.appendChild(previewDiv);
                    };
                    
                    reader.readAsDataURL(file);
                }
            }
            
            // Update product preview with first image
            if (files.length > 0) {
                const firstReader = new FileReader();
                firstReader.onload = function(e) {
                    productPreviewContainer.innerHTML = `
                        <img src="${e.target.result}" alt="Main Product Preview">
                        <div style="position: absolute; bottom: 5px; right: 5px; background: rgba(0,0,0,0.7); color: white; padding: 2px 8px; border-radius: 10px; font-size: 12px;">
                            1 of ${files.length}
                        </div>
                    `;
                };
                firstReader.readAsDataURL(files[0]);
            }
        }
        
        // Helper function to update product preview when no images
        function updateProductPreviewNoImage() {
            const productPreviewContainer = document.getElementById('previewImageContainer');
            productPreviewContainer.innerHTML = `
                <div class="no-image-placeholder">
                    <i class="fas fa-image"></i>
                    <p>No image selected</p>
                </div>
            `;
        }
        
        // Remove image preview
        function removeImage(button, index) {
            const fileInput = document.getElementById('productImage');
            const files = Array.from(fileInput.files);
            const countElement = document.getElementById('count');
            
            // Remove the preview element
            button.parentElement.remove();
            
            // Update count
            countElement.textContent = files.length - 1;
            
            // If less than 5 images remain, show error
            if (files.length - 1 < 5) {
                alert('Minimum 5 images required. Please select more images.');
                fileInput.value = '';
                countElement.textContent = '0';
                updateProductPreviewNoImage();
                document.getElementById('imagePreview').innerHTML = '';
                return;
            }
            
            // Update file input (remove the file at index)
            const dataTransfer = new DataTransfer();
            for (let i = 0; i < files.length; i++) {
                if (i !== index) {
                    dataTransfer.items.add(files[i]);
                }
            }
            fileInput.files = dataTransfer.files;
            
            // Update product preview with first remaining image
            const remainingFiles = Array.from(fileInput.files);
            if (remainingFiles.length > 0) {
                const firstReader = new FileReader();
                firstReader.onload = function(e) {
                    const productPreviewContainer = document.getElementById('previewImageContainer');
                    productPreviewContainer.innerHTML = `
                        <img src="${e.target.result}" alt="Main Product Preview">
                        <div style="position: absolute; bottom: 5px; right: 5px; background: rgba(0,0,0,0.7); color: white; padding: 2px 8px; border-radius: 10px; font-size: 12px;">
                            1 of ${remainingFiles.length}
                        </div>
                    `;
                };
                firstReader.readAsDataURL(remainingFiles[0]);
            }
        }
        
        // Initialize event listeners for real-time preview
        document.addEventListener('DOMContentLoaded', function() {
            // Add input event listeners to all form fields
            const formFields = ['pid', 'brand', 'productName', 'price', 'categoryId', 'description'];
            
            formFields.forEach(fieldName => {
                const field = document.querySelector(`[name="${fieldName}"]`);
                if (field) {
                    field.addEventListener('input', updatePreview);
                    field.addEventListener('change', updatePreview);
                }
            });
            
            // Initial preview update
            updatePreview();
        });
        
        // Form submission with image validation
        document.getElementById('adminProductForm').addEventListener('submit', function(e) {
            const fileInput = document.getElementById('productImage');
            const files = fileInput.files;
            const countElement = document.getElementById('count');
            
            // Validate minimum 5 images
            if (files.length < 5) {
                e.preventDefault();
                alert('Please select at least 5 images. Currently selected: ' + files.length);
                fileInput.focus();
                return;
            }
            
            // Validate maximum 10 images
            if (files.length > 10) {
                e.preventDefault();
                alert('Maximum 10 images allowed. Please select fewer images.');
                return;
            }
            
            // Show loading state
            const submitButton = this.querySelector('button[type="submit"]');
            submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding Product...';
            submitButton.disabled = true;
        });
        
        // Price formatting
        document.querySelector('input[name="price"]').addEventListener('input', function(e) {
            if (e.target.value < 0) {
                e.target.value = 0;
            }
        });
        
        // Product ID validation (alphanumeric)
        document.querySelector('input[name="pid"]').addEventListener('input', function(e) {
            // Allow only alphanumeric characters and some special characters
            e.target.value = e.target.value.replace(/[^a-zA-Z0-9_-]/g, '');
        });
    </script>
</body>
</html>