<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="products.*"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    String username = null;
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj != null) {
        username = (String) sessionObj.getAttribute("username");
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Product - Mini Shopping cart</title>
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
    
    .container {
        max-width: 1200px;
        margin: 0 auto;
    }
    
    header {
        text-align: center;
        margin-bottom: 30px;
        color: white;
    }
    
    h1 {
        font-size: 2.5rem;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .subtitle {
        font-size: 1.1rem;
        opacity: 0.9;
        margin-bottom: 20px;
    }
    
    .form-container {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        padding: 30px;
        border-radius: 20px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.1);
        border: 1px solid rgba(255, 255, 255, 0.3);
        max-height: calc(100vh - 200px);
        overflow-y: auto;
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }
    
    .form-field {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        padding: 20px;
        border-radius: 12px;
        border: 1px solid rgba(102, 126, 234, 0.1);
        transition: all 0.3s ease;
        position: relative;
    }
    
    .form-field::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 3px;
        height: 100%;
        background: linear-gradient(135deg, #667eea, #764ba2);
        transition: width 0.3s ease;
    }
    
    .form-field:hover::before {
        width: 5px;
    }
    
    .form-field:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(102, 126, 234, 0.15);
        border-color: rgba(102, 126, 234, 0.3);
    }
    
    .form-field-full {
        grid-column: 1 / -1;
    }
    
    .field-header {
        font-size: 0.85rem;
        font-weight: 600;
        color: #667eea;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .field-icon {
        font-size: 1.1rem;
    }
    
    .form-group {
        margin-bottom: 0;
    }
    
    label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 6px;
        font-size: 0.9rem;
    }
    
    input[type="text"],
    input[type="number"],
    input[type="file"],
    textarea,
    select {
        width: 100%;
        padding: 10px 14px;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: white;
        font-family: inherit;
    }
    
    input[type="text"]:focus,
    input[type="number"]:focus,
    input[type="file"]:focus,
    textarea:focus,
    select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        transform: translateY(-1px);
    }
    
    textarea {
        resize: vertical;
        min-height: 80px;
    }
    
    .id-display {
        background: linear-gradient(135deg, #e8f5e8, #d4edda);
        padding: 15px;
        border-radius: 12px;
        font-weight: bold;
        color: #2e7d32;
        text-align: center;
        margin-bottom: 25px;
        font-size: 1rem;
        border: 1px solid rgba(46, 125, 50, 0.2);
        box-shadow: 0 3px 10px rgba(46, 125, 50, 0.1);
    }
    
    .submit-btn {
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        border: none;
        padding: 15px 30px;
        border-radius: 12px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        width: 100%;
        box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .submit-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }
    
    .submit-btn:hover::before {
        left: 100%;
    }
    
    .submit-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(76, 175, 80, 0.4);
    }
    
    .back-link {
        text-align: center;
        margin-top: 20px;
    }
    
    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1rem;
        padding: 12px 25px;
        border-radius: 25px;
        background: rgba(255,255,255,0.1);
        backdrop-filter: blur(10px);
        transition: all 0.3s ease;
        display: inline-block;
        border: 1px solid rgba(255,255,255,0.2);
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
    }
    
    /* ========================================
       BACK TO HOME BUTTON STYLES
       ======================================== */
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

    /* Icon styling */
    .back-to-home-btn-left i {
        font-size: 16px;
        margin-right: 2px;
        transition: transform 0.3s ease;
    }

    .back-to-home-btn-left:hover i {
        transform: scale(1.1);
    }

    /* Responsive design */
    @media (max-width: 768px) {
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

    @media (max-width: 480px) {
        .back-to-home-btn-left {
            top: 10px;
            left: 10px;
            padding: 8px 14px;
            font-size: 12px;
            border-radius: 18px;
            gap: 6px;
        }
        
        .back-to-home-btn-left i {
            font-size: 13px;
        }
    }

    /* High contrast mode support */
    @media (prefers-contrast: high) {
        .back-to-home-btn-left {
            border: 2px solid #ffffff;
            background: #4CAF50;
        }
        
        .back-to-home-btn-left:hover {
            background: #45a049;
            border: 2px solid #ffffff;
        }
    }

    /* Reduced motion support */
    @media (prefers-reduced-motion: reduce) {
        .back-to-home-btn-left {
            transition: none;
        }
        
        .back-to-home-btn-left:hover {
            transform: none;
            transition: none;
        }
        
        .back-to-home-btn-left i {
            transition: none;
        }
        
        .back-to-home-btn-left:hover i {
            transform: none;
        }
    }

    /* Dark mode support */
    @media (prefers-color-scheme: dark) {
        .back-to-home-btn-left {
            background: linear-gradient(135deg, #45a049, #3d8b40);
            box-shadow: 0 4px 15px rgba(69, 160, 73, 0.4);
        }
        
        .back-to-home-btn-left:hover {
            background: linear-gradient(135deg, #3d8b40, #2e7d32);
            box-shadow: 0 6px 20px rgba(69, 160, 73, 0.5);
        }
    }

    /* Print styles */
    @media print {
        .back-to-home-btn-left {
            display: none !important;
        }
    }

    /* Loading state */
    .back-to-home-btn-left.loading {
        pointer-events: none;
        opacity: 0.7;
    }

    .back-to-home-btn-left.loading i::before {
        content: "\f110"; /* fa-spinner */
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* Success state */
    .back-to-home-btn-left.success {
        background: linear-gradient(135deg, #28a745, #20c997);
        animation: pulse 0.5s ease;
    }

    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
    }

    /* Error state */
    .back-to-home-btn-left.error {
        background: linear-gradient(135deg, #dc3545, #c82333);
        animation: shake 0.5s ease;
    }

    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-5px); }
        75% { transform: translateX(5px); }
    }

    @media (max-width: 768px) {
        .form-grid {
            grid-template-columns: 1fr;
            gap: 15px;
        }
        
        .form-field {
            padding: 15px;
        }
        
        .form-container {
            padding: 20px;
            max-height: none;
        }
        
        h1 {
            font-size: 2rem;
        }
    }
    
    @media (max-width: 480px) {
        .container {
            padding: 10px;
        }
        
        .form-field:hover::before {
            width: 5px;
        }
        
        .form-field:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.15);
            border-color: rgba(102, 126, 234, 0.3);
        }
        
        .form-field-full {
            grid-column: 1 / -1;
        }
        
        .field-header {
            font-size: 0.85rem;
            font-weight: 600;
            color: #667eea;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .field-icon {
            font-size: 1.1rem;
        }
        
        .form-group {
            margin-bottom: 0;
        }
        
        label {
            display: block;
            font-weight: 600;
            color: #333;
            margin-bottom: 6px;
            font-size: 0.9rem;
        }
        
        input[type="text"],
        input[type="number"],
        input[type="file"],
        textarea,
        select {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            font-family: inherit;
        }
        
        input[type="text"]:focus,
        input[type="number"]:focus,
        input[type="file"]:focus,
        textarea:focus,
        select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            transform: translateY(-1px);
        }
        
        textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .id-display {
            background: linear-gradient(135deg, #e8f5e8, #d4edda);
            padding: 15px;
            border-radius: 12px;
            font-weight: bold;
            color: #2e7d32;
            text-align: center;
            margin-bottom: 25px;
            font-size: 1rem;
            border: 1px solid rgba(46, 125, 50, 0.2);
            box-shadow: 0 3px 10px rgba(46, 125, 50, 0.1);
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.3);
            position: relative;
            overflow: hidden;
        }
        
        .submit-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }
        
        .submit-btn:hover::before {
            left: 100%;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(76, 175, 80, 0.4);
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: white;
            text-decoration: none;
            font-size: 1rem;
            padding: 12px 25px;
            border-radius: 25px;
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
            display: inline-block;
            border: 1px solid rgba(255,255,255,0.2);
        }
        
        .back-link a:hover {
            background: rgba(255,255,255,0.2);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.2);
        }
        
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .form-field {
                padding: 15px;
            }
            
            .form-container {
                padding: 20px;
                max-height: none;
            }
            
            h1 {
                font-size: 2rem;
            }
        }
        
        @media (max-width: 480px) {
            .container {
                padding: 10px;
            }
            
            .form-container {
                padding: 15px;
            }
            
            h1 {
                font-size: 1.5rem;
            }
        }
        
        /* ========================================
           BACK TO HOME BUTTON STYLES
           ======================================== */
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

        /* Icon styling */
        .back-to-home-btn-left i {
            font-size: 16px;
            margin-right: 2px;
            transition: transform 0.3s ease;
        }

        .back-to-home-btn-left:hover i {
            transform: scale(1.1);
        }

        /* Responsive design */
        @media (max-width: 768px) {
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

        @media (max-width: 480px) {
            .back-to-home-btn-left {
                top: 10px;
                left: 10px;
                padding: 8px 14px;
                font-size: 12px;
                border-radius: 18px;
                gap: 6px;
            }
            
            .back-to-home-btn-left i {
                font-size: 13px;
            }
        }

        /* High contrast mode support */
        @media (prefers-contrast: high) {
            .back-to-home-btn-left {
                border: 2px solid #ffffff;
                background: #4CAF50;
            }
            
            .back-to-home-btn-left:hover {
                background: #45a049;
                border: 2px solid #ffffff;
            }
        }

        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            .back-to-home-btn-left {
                transition: none;
            }
            
            .back-to-home-btn-left:hover {
                transform: none;
                transition: none;
            }
            
            .back-to-home-btn-left i {
                transition: none;
            }
            
            .back-to-home-btn-left:hover i {
                transform: none;
            }
        }

        /* Dark mode support */
        @media (prefers-color-scheme: dark) {
            .back-to-home-btn-left {
                background: linear-gradient(135deg, #45a049, #3d8b40);
                box-shadow: 0 4px 15px rgba(69, 160, 73, 0.4);
            }
            
            .back-to-home-btn-left:hover {
                background: linear-gradient(135deg, #3d8b40, #2e7d32);
                box-shadow: 0 6px 20px rgba(69, 160, 73, 0.5);
            }
        }

        /* Print styles */
        @media print {
            .back-to-home-btn-left {
                display: none !important;
            }
        }

        /* Loading state */
        .back-to-home-btn-left.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .back-to-home-btn-left.loading i::before {
            content: "\f110"; /* fa-spinner */
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Success state */
        .back-to-home-btn-left.success {
            background: linear-gradient(135deg, #28a745, #20c997);
            animation: pulse 0.5s ease;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        /* Error state */
        .back-to-home-btn-left.error {
            background: linear-gradient(135deg, #dc3545, #c82333);
            animation: shake 0.5s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
    </style>
</head>
<body>
<a href="javascript:history.back()" class="back-to-home-btn-left" aria-label="Go back to previous page"><i class="fas fa-home"></i> Back </a>
    <div class="container">
        <header>
            <h1> Add New Product</h1>
            <p class="subtitle">Welcome, <%= username != null ? username : "Admin" %>! Add to menu</p>
            <div style="text-align: center; margin-bottom: 20px;">
               
            </div>
        </header>
        
        <div class="form-container">
            <div class="id-display">
                🆔 Enter ID
            </div>
            
            <form action="Uploadproducts" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="pid">ID</label>
                    <input type="text" id="pid" name="pid" placeholder="Enter ID (A-Z, 0-9)" pattern="[A-Za-z0-9]+" title="Only alphabetic characters allowed" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="pname">Product Name</label>
                    <input type="text" id="pname" name="pname" placeholder="Enter product name" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="brand">Brand Name</label>
                    <input type="text" id="brand" name="brand" placeholder="Enter brand name (e.g., Apple, Samsung, Nike)" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="category_id">Category</label>
                    <select id="category_id" name="category_id" required style="width: 100%; padding: 12px 16px; border: 2px solid #e1e5e9; border-radius: 8px; font-size: 1rem; background: #f8f9fa;">
                        <option value="">Select Category</option>
                        <option value="Mo">📱 Mobile</option>
                        <option value="Ms">👞 Men Shoe</option>
                        <option value="Lp">💻 Laptop</option>
                        <option value="Wt">⌚ Watch</option>
                        <option value="Hp">🎧 Headphones</option>
                        <option value="Ca">📷 Camera</option>
                    </select><br><br>
                </div>
                
                <div class="form-group">
                    <label for="price">Price (₹)</label>
                    <input type="number" id="price" name="price" placeholder="0.00" step="0.01" min="0" required><br><br>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" placeholder="Enter product description" rows="4" style="width: 100%; padding: 12px 16px; border: 2px solid #e1e5e9; border-radius: 8px; font-size: 1rem; font-family: inherit; resize: vertical; background: #f8f9fa;"></textarea><br><br>
                </div>
                
                <div class="form-group">
                    <label for="img">Product Images</label>
                    <input type="file" id="img" name="img" accept="image/*" multiple required>
                    <div id="imagePreview" style="margin-top: 10px; display: flex; flex-wrap: wrap; gap: 10px;"></div>
                    <small style="color: #666; font-size: 0.85rem;">You can select multiple images at once</small><br><br>
                </div>
                
                <button type="submit" class="submit-btn">📤 Upload Product</button>
            </form>
        </div><br><br>
        
        <div class="back-link">
            <a href="Showproducts.jsp">← View All Products</a>
        </div>
    </div>

<script>
// Multiple image preview functionality
document.getElementById('img').addEventListener('change', function(e) {
    const files = e.target.files;
    const preview = document.getElementById('imagePreview');
    preview.innerHTML = '';
    
    if (files.length === 0) {
        return;
    }
    
    // Display number of selected files
    const fileCount = document.createElement('div');
    fileCount.style.cssText = 'width: 100%; padding: 10px; background: #e8f5e8; border-radius: 8px; margin-bottom: 10px; font-weight: 600; color: #2e7d32;';
    fileCount.textContent = `${files.length} image(s) selected`;
    preview.appendChild(fileCount);
    
    // Show previews for first 5 images
    const maxPreviews = 5;
    for (let i = 0; i < Math.min(files.length, maxPreviews); i++) {
        const file = files[i];
        const reader = new FileReader();
        
        reader.onload = function(e) {
            const previewContainer = document.createElement('div');
            previewContainer.style.cssText = 'position: relative; width: 100px; height: 100px; border-radius: 8px; overflow: hidden; border: 2px solid #e1e5e9;';
            
            const img = document.createElement('img');
            img.src = e.target.result;
            img.style.cssText = 'width: 100%; height: 100%; object-fit: cover;';
            
            const fileName = document.createElement('div');
            fileName.style.cssText = 'position: absolute; bottom: 0; left: 0; right: 0; background: rgba(0,0,0,0.7); color: white; padding: 2px; font-size: 10px; text-align: center; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;';
            fileName.textContent = file.name.length > 15 ? file.name.substring(0, 12) + '...' : file.name;
            
            previewContainer.appendChild(img);
            previewContainer.appendChild(fileName);
            preview.appendChild(previewContainer);
        };
        
        reader.readAsDataURL(file);
    }
    
    // Show message if more than 5 images
    if (files.length > maxPreviews) {
        const moreText = document.createElement('div');
        moreText.style.cssText = 'width: 100%; padding: 8px; background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; margin-top: 10px; font-size: 12px; color: #856404; text-align: center;';
        moreText.textContent = `... and ${files.length - maxPreviews} more image(s)`;
        preview.appendChild(moreText);
    }
});

// Form validation
document.querySelector('form').addEventListener('submit', function(e) {
    const fileInput = document.getElementById('img');
    const files = fileInput.files;
    
    if (files.length === 0) {
        e.preventDefault();
        alert('Please select at least one image for the product.');
        return false;
    }
    
    // Check file sizes (max 5MB per image)
    const maxSize = 5 * 1024 * 1024; // 5MB
    for (let i = 0; i < files.length; i++) {
        if (files[i].size > maxSize) {
            e.preventDefault();
            alert(`File "${files[i].name}" is too large. Maximum file size is 5MB.`);
            return false;
        }
    }
    
    // Check file types
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    for (let i = 0; i < files.length; i++) {
        if (!allowedTypes.includes(files[i].type)) {
            e.preventDefault();
            alert(`File "${files[i].name}" is not a valid image type. Please use JPG, PNG, GIF, or WebP.`);
            return false;
        }
    }
    
    return true;
});
</script>
</body>
</html>