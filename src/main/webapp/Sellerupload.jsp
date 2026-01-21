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

// Check if user has admin role
String userRole = (String) sessionObj.getAttribute("userRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect("users.html");
    return;
}

String username = (String) sessionObj.getAttribute("username");

// Handle form submission
String message = "";
String messageType = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String sellerId = request.getParameter("Id");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String shopName = request.getParameter("shopName");
    String category = request.getParameter("category");
    String categoryId = request.getParameter("categoryId");
    String price = request.getParameter("price");
    String description = request.getParameter("description");
    String status = request.getParameter("status");
    String imageFileName = "";
    
    // Handle file upload
    try {
        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = filePart.getSubmittedFileName();
            if (fileName != null && !fileName.isEmpty()) {
                // Generate unique filename
                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                imageFileName = sellerId + "_" + System.currentTimeMillis() + fileExtension;
                
                // Save file to server
                String uploadPath = getServletContext().getRealPath("") + "seller_images";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                File file = new File(uploadPath, imageFileName);
                filePart.write(file.getAbsolutePath());
            }
        }
    } catch (Exception e) {
        System.out.println("File upload error: " + e.getMessage());
    }
    
    // Validate phone number length
    if (phone != null && phone.length() > 8) {
        message = "Phone number too long! Maximum 8 characters allowed.";
        messageType = "error";
    } else {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish database connection
            Connection con = null;
            String[] passwords = {"", "root", "123456", "mysql", "password"};
            
            for (String pwd : passwords) {
                try {
                    con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/mscart?useSSL=false&allowPublicKeyRetrieval=true", "root", pwd);
                    break; // Stop trying if connection succeeds
                } catch (Exception e) {
                    if (con == null) {
                        // Try next password
                        continue;
                    }
                }
            }
            
            if (con == null || con.isClosed()) {
                throw new Exception("Unable to connect to MySQL with any common password. Please check MySQL configuration.");
            }
            
            System.out.println("Database connected successfully!");
            
            // Check if seller ID already exists
            PreparedStatement checkPs = con.prepareStatement(
                "SELECT COUNT(*) FROM seller WHERE id = ?");
            checkPs.setString(1, sellerId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next() && checkRs.getInt(1) > 0) {
                message = "Seller ID already exists! Please use a different id.";
                messageType = "error";
            } else {
                // Insert new seller
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO seller (id, name, email, phone, shop_name, category, category_id, price, description, image, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                
                ps.setString(1, sellerId);
                ps.setString(2, name);
                ps.setString(3, email);
                ps.setString(4, phone);
                ps.setString(5, shopName);
                ps.setString(6, category);
                ps.setString(7, categoryId);
                ps.setString(8, price);
                ps.setString(9, description);
                ps.setString(10, imageFileName);
                ps.setString(11, status);
                
                int result = ps.executeUpdate();
                
                if (result > 0) {
                    message = "Seller added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add seller. Please try again.";
                    messageType = "error";
                }
                
                ps.close();
            }
            
            checkRs.close();
            checkPs.close();
            con.close();
            
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            messageType = "error";
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
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

            <form action="Sellerupload.jsp" method="post" id="sellerForm" enctype="multipart/form-data">
                <div class="form-grid">
                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">🆔</span>
                            <label class="field-label" for="sellerId">Seller ID</label>
                        </div>
                        <input type="text" class="form-input" id="Id" name="Id" 
                               placeholder="Enter seller ID" required>
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
                            <label class="field-label" for="shopName">Product Brand</label>
                        </div>
                        <input type="text" class="form-input" id="shopName" name="shopName" 
                               placeholder="Enter shop name" required>
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

                    <div class="form-field">
                        <div class="field-header">
                            <span class="field-icon">��</span>
                            <label class="field-label" for="status">Status</label>
                        </div>
                        <select class="form-select" id="status" name="status" required>
                            <option value="">Select Status</option>
                            <option value="pending">Pending</option>
                            <option value="approved">Approved</option>
                            <option value="rejected">Rejected</option>
                        </select>
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

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
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
            font-family: 'Inter', sans-serif;
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
            transform: translateY(-2px);
        }

        .back-link {
            text-align: center;
            margin-top: 30px;
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
            .container {
                padding: 10px;
            }

            header h1 {
                font-size: 2rem;
            }

            .form-container {
                padding: 25px;
            }

            .form-grid {
                flex-direction: column;
                gap: 20px;
            }

            .form-field {
                min-width: 100%;
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

    <script>
        // Form validation
        document.getElementById('sellerForm').addEventListener('submit', function(e) {
            const sellerId = document.getElementById('Id').value.trim();
            const name = document.getElementById('name').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const shopName = document.getElementById('shopName').value.trim();
            const status = document.getElementById('status').value;

            // Basic validation
            if (!sellerId || !name || !email || !phone || !shopName || !status) {
                e.preventDefault();
                alert('Please fill in all required fields');
                return;
            }

            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('Please enter a valid email address');
                return;
            }

            // Phone validation (basic)
            const phoneRegex = /^[\d\s\-\+\(\)]+$/;
            if (!phoneRegex.test(phone)) {
                e.preventDefault();
                alert('Please enter a valid phone number');
                return;
            }
        });

        // Add input animations
        document.querySelectorAll('.form-input, .form-select').forEach(element => {
            element.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
            });

            element.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });
        });

        // Auto-generate seller ID (optional)
        document.getElementById('Id').addEventListener('input', function() {
            if (this.value.trim() === '') {
                // Generate a random ID if empty
                const randomId = 'SELLER' + Math.floor(Math.random() * 10000);
                this.placeholder = 'Auto: ' + randomId;
            }
        });
    </script>
</body>
</html>