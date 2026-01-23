<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="products.Dbase" %>
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
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Seller Application Management - Mini Shopping Cart</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Inter', sans-serif;
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #7e22ce 100%);
        min-height: 100vh;
        color: #1a1a1a;
        overflow-x: hidden;
        position: relative;
    }
    
    body::before {
        content: '';
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: 
            radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3), transparent 50%),
            radial-gradient(circle at 80% 80%, rgba(74, 86, 226, 0.3), transparent 50%),
            radial-gradient(circle at 40% 20%, rgba(99, 102, 241, 0.2), transparent 50%);
        pointer-events: none;
        z-index: 1;
        animation: gradientMove 15s ease-in-out infinite;
    }
    
    @keyframes gradientMove {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.8; }
    }

    .container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
        position: relative;
        z-index: 2;
    }

    header {
        background: linear-gradient(135deg, rgba(255,255,255,0.98), rgba(255,255,255,0.92));
        backdrop-filter: blur(30px) saturate(180%);
        padding: 60px 0;
        text-align: center;
        position: relative;
        box-shadow: 0 30px 60px rgba(0,0,0,0.2), 0 0 0 1px rgba(255,255,255,0.5) inset;
        border-radius: 40px;
        margin-bottom: 60px;
        border: 3px solid rgba(139, 92, 246, 0.3);
        overflow: hidden;
    }
    
    header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 6px;
        background: linear-gradient(90deg, #3b82f6, #8b5cf6, #ec4899, #f59e0b, #3b82f6);
        background-size: 400% 100%;
        animation: rainbowFlow 8s ease-in-out infinite;
    }
    
    @keyframes rainbowFlow {
        0%, 100% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
    }

    header h1 {
        font-size: 4rem;
        font-weight: 900;
        background: linear-gradient(135deg, #3b82f6, #8b5cf6, #ec4899);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 25px;
        letter-spacing: -0.04em;
        text-shadow: 0 8px 16px rgba(0,0,0,0.15);
        animation: titlePulse 4s ease-in-out infinite alternate;
        position: relative;
    }
    
    @keyframes titlePulse {
        0% { 
            filter: brightness(1);
            transform: scale(1);
        }
        100% { 
            filter: brightness(1.15);
            transform: scale(1.02);
        }
    }
    
    header .subtitle {
        font-size: 1.3rem;
        color: #666;
        font-weight: 400;
        margin-bottom: 25px;
        opacity: 0.8;
        animation: fadeInUp 1s ease-out;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 0.8;
            transform: translateY(0);
        }
    }

    .user-info {
        position: absolute;
        top: 25px;
        right: 25px;
        background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(255,255,255,0.85));
        padding: 15px 30px;
        border-radius: 35px;
        font-weight: 700;
        color: #333;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        border: 2px solid rgba(102, 126, 234, 0.3);
        backdrop-filter: blur(15px);
        display: flex;
        align-items: center;
        gap: 12px;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        font-size: 1rem;
    }
    
    .user-info:hover {
        transform: translateY(-5px) scale(1.05);
        box-shadow: 0 15px 40px rgba(0,0,0,0.25);
        border-color: rgba(102, 126, 234, 0.5);
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }

    .stat-card {
        background: linear-gradient(135deg, rgba(255, 255, 255, 0.98), rgba(255, 255, 255, 0.95));
        backdrop-filter: blur(25px) saturate(180%);
        border-radius: 25px;
        padding: 35px 25px;
        text-align: center;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255,255,255,0.3) inset;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        border: 2px solid rgba(139, 92, 246, 0.2);
        position: relative;
        overflow: hidden;
    }
    
    .stat-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(139, 92, 246, 0.1), transparent);
        transition: left 0.5s ease;
    }

    .stat-card:hover {
        transform: translateY(-10px) scale(1.03);
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.25), 0 0 0 2px rgba(139, 92, 246, 0.4) inset;
        border-color: rgba(139, 92, 246, 0.5);
    }
    
    .stat-card:hover::before {
        left: 100%;
    }

    .stat-icon {
        font-size: 2.5rem;
        margin-bottom: 15px;
        display: block;
    }

    .stat-number {
        font-size: 2rem;
        font-weight: 700;
        color: #667eea;
        margin-bottom: 5px;
    }

    .stat-label {
        color: #666;
        font-weight: 500;
        text-transform: uppercase;
        font-size: 0.9rem;
        letter-spacing: 1px;
    }

    .controls-section {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        border-radius: 15px;
        padding: 25px;
        margin-bottom: 30px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 20px;
    }

    .search-filter-group {
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
    }

    .search-input {
        padding: 12px 20px;
        border: 2px solid #e1e5e9;
        border-radius: 10px;
        font-size: 1rem;
        width: 300px;
        transition: all 0.3s ease;
    }

    .search-input:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

        .filter-select {
        padding: 12px 20px;
        border: 2px solid #e1e5e9;
        border-radius: 10px;
        font-size: 1rem;
        background: white;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .filter-select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .add-btn {
        background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        color: white;
        text-decoration: none;
        padding: 15px 30px;
        border-radius: 15px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        transition: all 0.3s ease;
        box-shadow: 0 8px 20px rgba(139, 92, 246, 0.4);
        font-size: 1.05rem;
    }

    .add-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 12px 30px rgba(139, 92, 246, 0.5);
    }

    .table-container {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        border-radius: 15px;
        padding: 25px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        overflow-x: auto;
        margin-bottom: 30px;
    }

    .sellers-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        background: white;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
        font-size: 0.9rem;
    }

    .sellers-table thead {
        background: linear-gradient(135deg, #3b82f6, #8b5cf6);
        box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
    }

    .sellers-table th {
        color: white;
        padding: 18px 15px;
        font-weight: 600;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        text-align: center;
        border: none;
        position: relative;
    }

    .sellers-table th:not(:last-child)::after {
        content: '';
        position: absolute;
        right: 0;
        top: 25%;
        bottom: 25%;
        width: 1px;
        background: rgba(255, 255, 255, 0.2);
    }

    .sellers-table th:nth-child(1) { width: 60px; }
    .sellers-table th:nth-child(2) { width: 140px; }
    .sellers-table th:nth-child(3) { width: 180px; }
    .sellers-table th:nth-child(4) { width: 120px; }
    .sellers-table th:nth-child(5) { width: 140px; }
    .sellers-table th:nth-child(6) { width: 100px; }
    .sellers-table th:nth-child(7) { width: 100px; }
    .sellers-table th:nth-child(8) { width: 100px; }
    .sellers-table th:nth-child(9) { width: 80px; }
    .sellers-table th:nth-child(10) { width: 200px; }
    .sellers-table th:nth-child(11) { width: 120px; }
    .sellers-table th:nth-child(12) { width: 140px; }

    .sellers-table tbody tr {
        transition: all 0.3s ease;
        border-bottom: 1px solid #f0f0f0;
    }

    .sellers-table tbody tr:hover {
        background: linear-gradient(90deg, #f8f9ff, #f0f4ff);
        transform: scale(1.01);
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.1);
    }

    .sellers-table tbody tr:last-child {
        border-bottom: none;
    }

    .sellers-table td {
        padding: 16px 12px;
        text-align: center;
        vertical-align: middle;
        border: none;
        color: #333;
        font-weight: 500;
    }

    .sellers-table td:nth-child(1) {
        font-weight: 700;
        color: #667eea;
        background: rgba(102, 126, 234, 0.05);
    }

    .sellers-table td:nth-child(2) {
        font-weight: 600;
        color: #2c3e50;
    }

    .sellers-table td:nth-child(3) {
        color: #34495e;
        font-size: 0.85rem;
    }

    .sellers-table td:nth-child(4) {
        color: #e74c3c;
        font-weight: 600;
    }

    .sellers-table td:nth-child(5) {
        color: #8e44ad;
        font-weight: 600;
    }

    .sellers-table td:nth-child(8) {
        color: #27ae60;
        font-weight: 700;
    }

    .seller-image {
        width: 45px;
        height: 45px;
        border-radius: 8px;
        object-fit: cover;
        border: 2px solid #e1e8ed;
        transition: all 0.3s ease;
    }

    .seller-image:hover {
        transform: scale(1.1);
        border-color: #667eea;
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
    }

    .no-image {
        width: 45px;
        height: 45px;
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #6c757d;
        font-size: 0.75rem;
        border: 2px solid #dee2e6;
        font-weight: 600;
    }

    .description-cell {
        max-width: 180px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        color: #6c757d;
        font-size: 0.85rem;
        font-style: italic;
    }

    .status-badge {
        padding: 6px 14px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: inline-block;
        min-width: 80px;
        text-align: center;
        transition: all 0.3s ease;
        border: 2px solid transparent;
    }

    .status-pending {
        background: linear-gradient(135deg, #fff3cd, #ffeaa7);
        color: #856404;
        border-color: #ffc107;
        box-shadow: 0 2px 8px rgba(255, 193, 7, 0.3);
    }

    .status-approved {
        background: linear-gradient(135deg, #d4edda, #c3e6cb);
        color: #155724;
        border-color: #28a745;
        box-shadow: 0 2px 8px rgba(40, 167, 69, 0.3);
    }

    .status-rejected {
        background: linear-gradient(135deg, #f8d7da, #f5c6cb);
        color: #721c24;
        border-color: #dc3545;
        box-shadow: 0 2px 8px rgba(220, 53, 69, 0.3);
    }

    .action-buttons {
        display: flex;
        gap: 8px;
        justify-content: center;
        flex-wrap: wrap;
    }

    .action-btn {
        padding: 8px 14px;
        border: none;
        border-radius: 8px;
        font-size: 0.75rem;
        font-weight: 600;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.3s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        min-width: 70px;
        justify-content: center;
    }

    .approve-btn {
        background: linear-gradient(135deg, #28a745, #20c997);
        color: white;
        box-shadow: 0 3px 10px rgba(40, 167, 69, 0.3);
    }

    .approve-btn:hover {
        background: linear-gradient(135deg, #218838, #1ea085);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(40, 167, 69, 0.4);
    }

    .reject-btn {
        background: linear-gradient(135deg, #dc3545, #c82333);
        color: white;
        box-shadow: 0 3px 10px rgba(220, 53, 69, 0.3);
    }

    .reject-btn:hover {
        background: linear-gradient(135deg, #c82333, #bd2130);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(220, 53, 69, 0.4);
    }

    .move-btn {
        background: linear-gradient(135deg, #17a2b8, #138496);
        color: white;
        box-shadow: 0 3px 10px rgba(23, 162, 184, 0.3);
    }

    .move-btn:hover {
        background: linear-gradient(135deg, #138496, #117a8b);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(23, 162, 184, 0.4);
    }

    .pending-btn {
        background: linear-gradient(135deg, #ffc107, #e0a800);
        color: #212529;
        box-shadow: 0 3px 10px rgba(255, 193, 7, 0.3);
    }

    .pending-btn:hover {
        background: linear-gradient(135deg, #e0a800, #d39e00);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(255, 193, 7, 0.4);
    }

    .product-status-filters {
        margin-top: 8px;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .filter-btn {
        padding: 4px 8px;
        font-size: 0.7rem;
        text-decoration: none;
        border-radius: 6px;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        border: 1px solid transparent;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.3px;
    }

    .products-approved-btn {
        background: linear-gradient(135deg, #28a745, #20c997);
        color: white;
        box-shadow: 0 2px 6px rgba(40, 167, 69, 0.2);
    }

    .products-approved-btn:hover {
        background: linear-gradient(135deg, #218838, #1ea085);
        transform: translateY(-1px);
        box-shadow: 0 3px 10px rgba(40, 167, 69, 0.3);
    }

    .products-pending-btn {
        background: linear-gradient(135deg, #ffc107, #e0a800);
        color: #212529;
        box-shadow: 0 2px 6px rgba(255, 193, 7, 0.2);
    }

    .products-pending-btn:hover {
        background: linear-gradient(135deg, #e0a800, #d39e00);
        transform: translateY(-1px);
        box-shadow: 0 3px 10px rgba(255, 193, 7, 0.3);
    }

    .products-rejected-btn {
        background: linear-gradient(135deg, #dc3545, #c82333);
        color: white;
        box-shadow: 0 2px 6px rgba(220, 53, 69, 0.2);
    }

    .products-rejected-btn:hover {
        background: linear-gradient(135deg, #c82333, #bd2130);
        transform: translateY(-1px);
        box-shadow: 0 3px 10px rgba(220, 53, 69, 0.3);
    }

    /* Dropdown System Styles */
    .dropdown {
        position: relative;
        display: inline-block;
        margin: 2px;
    }

    .dropdown-btn {
        background: linear-gradient(135deg, #6c757d, #5a6268);
        color: white;
        padding: 6px 12px;
        font-size: 0.7rem;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.3s ease;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        box-shadow: 0 2px 6px rgba(108, 117, 125, 0.2);
    }

    .dropdown-btn:hover {
        background: linear-gradient(135deg, #5a6268, #495057);
        transform: translateY(-1px);
        box-shadow: 0 3px 10px rgba(108, 117, 125, 0.3);
    }

    .dropdown-content {
        display: none;
        position: absolute;
        background: white;
        min-width: 180px;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        border-radius: 8px;
        z-index: 1000;
        border: 1px solid rgba(0, 0, 0, 0.1);
        overflow: hidden;
        top: 100%;
        left: 0;
        margin-top: 2px;
    }

    .dropdown-content.show {
        display: block;
        animation: dropdownSlide 0.3s ease;
    }

    @keyframes dropdownSlide {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .dropdown-item {
        color: #333;
        padding: 8px 12px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.75rem;
        font-weight: 500;
        transition: all 0.2s ease;
        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    }

    .dropdown-item:last-child {
        border-bottom: none;
    }

    .dropdown-item:hover {
        background: linear-gradient(90deg, #f8f9ff, #f0f4ff);
        color: #667eea;
    }

    .dropdown-item.approve-item:hover {
        background: linear-gradient(90deg, #d4edda, #c3e6cb);
        color: #155724;
    }

    .dropdown-item.reject-item:hover {
        background: linear-gradient(90deg, #f8d7da, #f5c6cb);
        color: #721c24;
    }

    .dropdown-item.pending-item:hover {
        background: linear-gradient(90deg, #fff3cd, #ffeaa7);
        color: #856404;
    }

    .dropdown-item.move-item:hover {
        background: linear-gradient(90deg, #d1ecf1, #bee5eb);
        color: #0c5460;
    }

    .dropdown-item.moved-item {
        background: linear-gradient(90deg, #d4edda, #c3e6cb);
        color: #155724;
        font-weight: 600;
        cursor: default;
    }

    .dropdown-item.filter-approved-item:hover {
        background: linear-gradient(90deg, #d4edda, #c3e6cb);
        color: #155724;
    }

    .dropdown-item.filter-pending-item:hover {
        background: linear-gradient(90deg, #fff3cd, #ffeaa7);
        color: #856404;
    }

    .dropdown-item.filter-rejected-item:hover {
        background: linear-gradient(90deg, #f8d7da, #f5c6cb);
        color: #721c24;
    }

    .dropdown-item.filter-all-item:hover {
        background: linear-gradient(90deg, #e2e3e5, #d6d8db);
        color: #383d41;
    }

    /* Products Dropdown System with Proper Button Design */
    .products-dropdown {
        position: relative;
        display: inline-block;
        margin: 2px;
    }

    .products-dropdown-btn {
        background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        color: white;
        padding: 8px 16px;
        font-size: 0.75rem;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.3s ease;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .products-dropdown-btn:hover {
        background: linear-gradient(135deg, #7c3aed, #6d28d9);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
        border-color: rgba(255, 255, 255, 0.3);
    }

    .products-dropdown-btn:active {
        transform: translateY(-1px);
    }

    .products-dropdown-content {
        display: none;
        position: absolute;
        background: white;
        min-width: 200px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        border-radius: 12px;
        z-index: 1000;
        border: 1px solid rgba(139, 92, 246, 0.2);
        overflow: hidden;
        top: 100%;
        left: 0;
        margin-top: 5px;
    }

    .products-dropdown-content.show {
        display: block;
        animation: productsDropdownSlide 0.3s ease;
    }

    @keyframes productsDropdownSlide {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .products-dropdown-item {
        color: #374151;
        padding: 10px 14px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 0.8rem;
        font-weight: 500;
        transition: all 0.2s ease;
        border-bottom: 1px solid rgba(139, 92, 246, 0.1);
    }

    .products-dropdown-item:last-child {
        border-bottom: none;
    }

    .products-dropdown-item:hover {
        background: linear-gradient(90deg, rgba(139, 92, 246, 0.1), rgba(167, 139, 250, 0.1));
        color: #8b5cf6;
        transform: translateX(3px);
    }

    .products-dropdown-item.approved-item:hover {
        background: linear-gradient(90deg, rgba(16, 185, 129, 0.1), rgba(52, 211, 153, 0.1));
        color: #10b981;
    }

    .products-dropdown-item.pending-item:hover {
        background: linear-gradient(90deg, rgba(245, 158, 11, 0.1), rgba(251, 191, 36, 0.1));
        color: #f59e0b;
    }

    .products-dropdown-item.rejected-item:hover {
        background: linear-gradient(90deg, rgba(239, 68, 68, 0.1), rgba(248, 113, 113, 0.1));
        color: #ef4444;
    }

    .products-dropdown-item.all-item:hover {
        background: linear-gradient(90deg, rgba(107, 114, 128, 0.1), rgba(156, 163, 175, 0.1));
        color: #6b7280;
    }

    .products-dropdown-item i {
        font-size: 0.9rem;
        width: 18px;
        text-align: center;
    }

    /* Products Table System */
    .products-table-container {
        position: relative;
        display: inline-block;
        margin: 2px;
    }

    .products-table-btn {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: white;
        padding: 8px 16px;
        font-size: 0.75rem;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.3s ease;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .products-table-btn:hover {
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
        border-color: rgba(255, 255, 255, 0.3);
    }

    .products-table-content {
        display: none;
        position: absolute;
        background: white;
        min-width: 350px;
        max-width: 450px;
        box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
        border-radius: 15px;
        z-index: 1000;
        border: 1px solid rgba(59, 130, 246, 0.2);
        overflow: hidden;
        top: 100%;
        left: 0;
        margin-top: 5px;
    }

    .products-table-content.show {
        display: block;
        animation: productsTableSlide 0.3s ease;
    }

    @keyframes productsTableSlide {
        from {
            opacity: 0;
            transform: translateY(-15px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .products-table-header {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: white;
        padding: 12px 16px;
        text-align: center;
    }

    .products-table-header h4 {
        margin: 0;
        font-size: 0.9rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }

    .products-mini-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.75rem;
    }

    .products-mini-table thead {
        background: #f8fafc;
    }

    .products-mini-table th {
        padding: 8px 10px;
        text-align: left;
        font-weight: 600;
        color: #374151;
        border-bottom: 2px solid #e5e7eb;
    }

    .products-mini-table td {
        padding: 8px 10px;
        border-bottom: 1px solid #f3f4f6;
        color: #6b7280;
    }

    .products-mini-table tbody tr:hover {
        background: #f9fafb;
    }

    .product-status-badge {
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 0.65rem;
        font-weight: 600;
        text-transform: uppercase;
    }

    .product-status-pending {
        background: #fef3c7;
        color: #92400e;
    }

    .product-status-approved {
        background: #d1fae5;
        color: #065f46;
    }

    .product-status-rejected {
        background: #fee2e2;
        color: #991b1b;
    }

    .product-status-moved_to_products {
        background: #ddd6fe;
        color: #5b21b6;
    }

    .products-table-actions {
        padding: 12px;
        background: #f8fafc;
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        justify-content: center;
    }

    .products-filter-btn {
        padding: 4px 8px;
        font-size: 0.65rem;
        text-decoration: none;
        border-radius: 4px;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        font-weight: 500;
        text-transform: uppercase;
    }

    .products-filter-btn.approved-filter {
        background: #d1fae5;
        color: #065f46;
    }

    .products-filter-btn.approved-filter:hover {
        background: #a7f3d0;
        transform: translateY(-1px);
    }

    .products-filter-btn.pending-filter {
        background: #fef3c7;
        color: #92400e;
    }

    .products-filter-btn.pending-filter:hover {
        background: #fde68a;
        transform: translateY(-1px);
    }

    .products-filter-btn.rejected-filter {
        background: #fee2e2;
        color: #991b1b;
    }

    .products-filter-btn.rejected-filter:hover {
        background: #fecaca;
        transform: translateY(-1px);
    }

    .products-filter-btn.all-filter {
        background: #e5e7eb;
        color: #374151;
    }

    .products-filter-btn.all-filter:hover {
        background: #d1d5db;
        transform: translateY(-1px);
    }
    
    .action-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .action-btn:hover::before {
        left: 100%;
    }

    .approve-btn {
        background: linear-gradient(135deg, #10b981, #059669);
        box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
    }
    
    .approve-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 8px 25px rgba(16, 185, 129, 0.5);
    }

    .reject-btn {
        background: linear-gradient(135deg, #ef4444, #dc2626);
        box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
    }
    
    .reject-btn:hover {
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 8px 25px rgba(239, 68, 68, 0.5);
    }

    .back-link {
        text-align: center;
        margin-top: 40px;
    }

    .back-link a {
        color: white;
        text-decoration: none;
        font-size: 1.1rem;
        font-weight: 600;
        padding: 15px 35px;
        border-radius: 30px;
        background: rgba(255,255,255,0.15);
        backdrop-filter: blur(15px);
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        display: inline-block;
        border: 2px solid rgba(255,255,255,0.3);
        box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        position: relative;
        overflow: hidden;
    }
    
    .back-link a::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .back-link a:hover::before {
        left: 100%;
    }
    
    .back-link a:hover {
        background: rgba(255,255,255,0.25);
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 12px 35px rgba(0,0,0,0.3);
    }

    @media (max-width: 768px) {
        .container {
            padding: 10px;
        }

        header h1 {
            font-size: 2rem;
        }

        .stats-container {
            grid-template-columns: 1fr;
            gap: 15px;
        }

        .table-header {
            flex-direction: column;
            gap: 15px;
            align-items: stretch;
        }

        .table-controls {
            flex-direction: column;
            gap: 15px;
            align-items: stretch;
        }

        .add-seller-btn {
            width: 100%;
            justify-content: center;
            font-size: 1.1rem;
            padding: 15px 20px;
        }

        .search-box {
            flex-direction: column;
        }

        .search-input, .filter-select {
            width: 100%;
        }

        .sellers-table {
            font-size: 0.8rem;
        }

        .sellers-table th,
        .sellers-table td {
            padding: 10px;
        }

        .action-buttons {
            flex-direction: column;
        }
    }
</style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-title">
                <h1><i class="fas fa-store"></i> Seller Management</h1>
            </div>
            <div class="user-info">
                <i class="fas fa-user"></i>
                <%= username != null ? username : "Admin" %> (<%= userRole != null ? userRole : "Guest" %>)
            </div>
        </header>

        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-icon">📊</span>
                <div class="stat-number" id="totalSellers">0</div>
                <div class="stat-label">Total Sellers</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">⏳</span>
                <div class="stat-number" id="pendingSellers">0</div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">✅</span>
                <div class="stat-number" id="approvedSellers">0</div>
                <div class="stat-label">Approved</div>
            </div>
            <div class="stat-card">
                <span class="stat-icon">❌</span>
                <div class="stat-number" id="rejectedSellers">0</div>
                <div class="stat-label">Rejected</div>
            </div>
        </div>

        
        <div class="controls-section">
            <a href="Sellerupload.jsp" class="add-btn">
                <i class="fas fa-plus"></i> Add New Seller
            </a>
            <div class="search-filter-group">
                <input type="text" class="search-input" id="searchInput" placeholder="Search sellers..." onkeyup="filterSellers()">
                <select class="filter-select" id="statusFilter" onchange="filterSellers()">
                    <option value="">All Status</option>
                    <option value="pending">Pending</option>
                    <option value="approved">Approved</option>
                    <option value="rejected">Rejected</option>
                </select>
            </div>
        </div>

            <table class="sellers-table" id="sellerTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Brand</th>
                        <th>Category</th>
                        <th>Category ID</th>
                        <th>Price</th>
                        <th>Image</th>
                        <th>Description</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="sellersTableBody">
<%
try {
    Dbase db = new Dbase();
    Connection con = null;
    
    try {
        con = db.initailizeDatabase();
    } catch (Exception e) {
        // Fallback to direct connection if Dbase fails
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mscart", "root", "123456");
    }

    if (con == null || con.isClosed()) {
        out.println("<script>alert('Database connection failed!');</script>");
        return;
    }

    PreparedStatement ps = con.prepareStatement("SELECT * FROM seller ORDER BY sid DESC");
    ResultSet rs = ps.executeQuery();

    int totalSellers = 0;
    int pendingSellers = 0;
    int approvedSellers = 0;
    int rejectedSellers = 0;

    while (rs.next()) {
        totalSellers++;
        String status = rs.getString("status");
        if ("pending".equals(status)) {
            pendingSellers++;
        } else if ("approved".equals(status)) {
            approvedSellers++;
        } else if ("rejected".equals(status)) {
            rejectedSellers++;
        }
%>
                    <tr data-status="<%= status %>" data-name="<%= rs.getString("full_name").toLowerCase() %>" data-email="<%= rs.getString("email_address").toLowerCase() %>">
                        <td><%= rs.getString("sid") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email_address") %></td>
                        <td><%= rs.getString("phone_number") %></td>
                        <td><%= rs.getString("product_brand") %></td>
                        <td><%= rs.getString("Category") %></td>
                        <td><%= rs.getString("Category_id") %></td>
                        <td><%= rs.getString("price") %></td>
                        <td><% if(rs.getString("image") != null && !rs.getString("image").isEmpty()) { %><img src="seller_images/<%= rs.getString("image") %>" width="50" height="50" style="border-radius: 8px;"><% } else { %>No Image<% } %></td>
                        <td><%= rs.getString("description") != null ? rs.getString("description").substring(0, Math.min(50, rs.getString("description").length())) + (rs.getString("description").length() > 50 ? "..." : "") : "" %></td>
                        <td>
                            <span class="status-badge status-<%= status %>">
                                <%= status.toUpperCase() %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <% if ("pending".equals(status)) { %>
                                    <a class="action-btn approve-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=approved" 
                                       onclick="return confirm('Are you sure you want to approve this seller?')">
                                        <i class="fas fa-check"></i> Approve
                                    </a>
                                    <a class="action-btn reject-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=rejected" 
                                       onclick="return confirm('Are you sure you want to reject this seller?')">
                                        <i class="fas fa-times"></i> Reject
                                    </a>
                                <% } else if ("approved".equals(status)) { %>
                                    <a class="action-btn pending-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=pending" 
                                       onclick="return confirm('Are you sure you want to set this seller to pending?')">
                                        <i class="fas fa-clock"></i> Pending
                                    </a>
                                    <a class="action-btn reject-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=rejected" 
                                       onclick="return confirm('Are you sure you want to reject this seller?')">
                                        <i class="fas fa-times"></i> Reject
                                    </a>
                                    <a class="action-btn move-btn" href="MoveToProductsServlet?id=<%= rs.getString("sid") %>" 
                                       onclick="return confirm('Are you sure you want to move this seller to products?')">
                                        <i class="fas fa-arrow-right"></i> Move
                                    </a>
                                <% } else if ("rejected".equals(status)) { %>
                                    <a class="action-btn approve-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=approved" 
                                       onclick="return confirm('Are you sure you want to approve this seller?')">
                                        <i class="fas fa-check"></i> Approve
                                    </a>
                                    <a class="action-btn pending-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=pending" 
                                       onclick="return confirm('Are you sure you want to set this seller to pending?')">
                                        <i class="fas fa-clock"></i> Pending
                                    </a>
                                <% } else if ("moved_to_products".equals(status)) { %>
                                    <span class="status-badge status-approved">
                                        <i class="fas fa-check"></i> Moved
                                    </span>
                                    <a class="action-btn pending-btn" href="UpdateSellerStatusServlet?id=<%= rs.getString("sid") %>&status=pending" 
                                       onclick="return confirm('Are you sure you want to set this seller to pending?')">
                                        <i class="fas fa-undo"></i> Reset
                                    </a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
<%
    }
    
    // Set statistics
    request.setAttribute("totalSellers", totalSellers);
    request.setAttribute("pendingSellers", pendingSellers);
    request.setAttribute("approvedSellers", approvedSellers);
    request.setAttribute("rejectedSellers", rejectedSellers);
    
    con.close();
} catch (Exception e) {
    out.println("<script>alert('Error loading seller: " + e.getMessage() + "');</script>");
}
%>
                </tbody>
            </table>
        </div>

        <div class="back-link">
            <a href="Dashboard.jsp">← Back to Dashboard</a>
        </div>
    </div>

    <script>
        // Update statistics
        document.addEventListener('DOMContentLoaded', function() {
            const totalSellers = parseInt('<%= request.getAttribute("totalSellers") != null ? request.getAttribute("totalSellers") : 0 %>');
            const pendingSellers = parseInt('<%= request.getAttribute("pendingSellers") != null ? request.getAttribute("pendingSellers") : 0 %>');
            const approvedSellers = parseInt('<%= request.getAttribute("approvedSellers") != null ? request.getAttribute("approvedSellers") : 0 %>');
            const rejectedSellers = parseInt('<%= request.getAttribute("rejectedSellers") != null ? request.getAttribute("rejectedSellers") : 0 %>');

            document.getElementById('totalSellers').textContent = totalSellers;
            document.getElementById('pendingSellers').textContent = pendingSellers;
            document.getElementById('approvedSellers').textContent = approvedSellers;
            document.getElementById('rejectedSellers').textContent = rejectedSellers;
        });

        // Toggle products table
        function toggleProductsTable(sellerId) {
            const tableId = 'productsTable' + sellerId;
            
            // Close all other tables
            const tables = document.querySelectorAll('.products-table-content');
            tables.forEach(table => {
                if (table.id !== tableId) {
                    table.classList.remove('show');
                }
            });
            
            // Toggle current table
            const currentTable = document.getElementById(tableId);
            if (currentTable) {
                currentTable.classList.toggle('show');
            }
        }

        // Close tables when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.matches('.products-table-btn') && !event.target.closest('.products-table-btn')) {
                const tables = document.querySelectorAll('.products-table-content');
                tables.forEach(table => {
                    table.classList.remove('show');
                });
            }
        });

        // Toggle products dropdown
        function toggleProductsDropdown(dropdownId) {
            // Close all other dropdowns
            const dropdowns = document.querySelectorAll('.products-dropdown-content');
            dropdowns.forEach(dropdown => {
                if (dropdown.id !== dropdownId) {
                    dropdown.classList.remove('show');
                }
            });
            
            // Toggle current dropdown
            const currentDropdown = document.getElementById(dropdownId);
            if (currentDropdown) {
                currentDropdown.classList.toggle('show');
            }
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.matches('.products-dropdown-btn') && !event.target.closest('.products-dropdown-btn')) {
                const dropdowns = document.querySelectorAll('.products-dropdown-content');
                dropdowns.forEach(dropdown => {
                    dropdown.classList.remove('show');
                });
            }
        });

        // Toggle dropdown
        function toggleDropdown(dropdownId) {
            // Close all other dropdowns
            const dropdowns = document.querySelectorAll('.dropdown-content');
            dropdowns.forEach(dropdown => {
                if (dropdown.id !== dropdownId) {
                    dropdown.classList.remove('show');
                }
            });
            
            // Toggle current dropdown
            const currentDropdown = document.getElementById(dropdownId);
            if (currentDropdown) {
                currentDropdown.classList.toggle('show');
            }
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.matches('.dropdown-btn') && !event.target.closest('.dropdown-btn')) {
                const dropdowns = document.querySelectorAll('.dropdown-content');
                dropdowns.forEach(dropdown => {
                    dropdown.classList.remove('show');
                });
            }
        });

        // Filter sellers
        function filterSellers() {
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const rows = document.querySelectorAll('#sellersTableBody tr');

            rows.forEach(row => {
                const name = row.getAttribute('data-name');
                const email = row.getAttribute('data-email');
                const status = row.getAttribute('data-status');
                
                const matchesSearch = !searchInput || 
                    name.includes(searchInput) || 
                    email.includes(searchInput);
                const matchesStatus = !statusFilter || status === statusFilter;
                
                row.style.display = matchesSearch && matchesStatus ? '' : 'none';
            });
        }

        // Filter by product status
        function filterByProductStatus(productStatus) {
            const rows = document.querySelectorAll('#sellersTableBody tr');
            
            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                let shouldShow = false;
                
                switch(productStatus) {
                    case 'approved':
                        shouldShow = status === 'approved' || status === 'moved_to_products';
                        break;
                    case 'pending':
                        shouldShow = status === 'pending';
                        break;
                    case 'rejected':
                        shouldShow = status === 'rejected';
                        break;
                }
                
                row.style.display = shouldShow ? '' : 'none';
            });
            
            // Update the main status filter to match
            document.getElementById('statusFilter').value = productStatus === 'approved' && rows.length > 0 ? 
                (Array.from(rows).some(row => row.getAttribute('data-status') === 'moved_to_products') ? 'moved_to_products' : 'approved') : 
                productStatus;
        }

        // Add smooth scroll behavior
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth' });
                }
            });
        });

        // Add loading states for action buttons
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const originalText = this.innerHTML;
                this.innerHTML = '⏳ Processing...';
                this.style.pointerEvents = 'none';
                
                setTimeout(() => {
                    this.innerHTML = originalText;
                    this.style.pointerEvents = 'auto';
                }, 2000);
            });
        });
    </script>
</body>
</html>
