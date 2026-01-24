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
String SessionId = session.getId();
out.println("Session ID: " +
SessionId);

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
        transition: none;
        border-bottom: 1px solid #f0f0f0;
    }

    .sellers-table tbody tr:hover {
        background: transparent;
        transform: none;
        box-shadow: none;
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
        background: linear-gradient(135deg, #4f46e5, #7c3aed);
        color: white;
        padding: 8px 16px;
        font-size: 0.75rem;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.3s ease;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.3px;
        box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .dropdown-btn:hover {
        background: linear-gradient(135deg, #4338ca, #6d28d9);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(79, 70, 229, 0.4);
        border-color: rgba(255, 255, 255, 0.3);
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
        display: block !important;
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
        background: linear-gradient(90deg, #10b981, #059669);
        color: white;
    }

    .dropdown-item.reject-item:hover {
        background: linear-gradient(90deg, #ef4444, #dc2626);
        color: white;
    }

    .dropdown-item.pending-item:hover {
        background: linear-gradient(90deg, #f59e0b, #d97706);
        color: white;
    }

    .dropdown-item.move-item:hover {
        background: linear-gradient(90deg, #3b82f6, #2563eb);
        color: white;
    }

    .dropdown-item.moved-item {
        background: linear-gradient(90deg, #d4edda, #c3e6cb);
        color: #155724;
        font-weight: 600;
        cursor: default;
    }

    /* Comprehensive Dropdown System Styles */
    .dropdown-content {
        min-width: 280px;
        max-height: 400px;
        overflow-y: auto;
    }

    .dropdown-section {
        padding: 12px 0;
        border-bottom: 1px solid #e9ecef;
    }

    .dropdown-section:last-child {
        border-bottom: none;
    }

    .section-title {
        padding: 8px 16px;
        font-size: 0.75rem;
        font-weight: 700;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: flex;
        align-items: center;
        gap: 8px;
        background: #f8f9fa;
        margin-bottom: 4px;
    }

    .section-title i {
        font-size: 0.8rem;
    }

    .dropdown-filter-select {
        width: calc(100% - 24px);
        margin: 0 12px;
        padding: 8px 12px;
        font-size: 0.85rem;
        border: 1px solid #ced4da;
        border-radius: 6px;
        background: white;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .dropdown-filter-select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
    }

    /* Additional Action Item Styles */
    .dropdown-item.edit-item:hover {
        background: linear-gradient(90deg, #17a2b8, #138496);
        color: white;
    }

    .dropdown-item.view-item:hover {
        background: linear-gradient(90deg, #6c757d, #5a6268);
        color: white;
    }

    .dropdown-item.delete-item:hover {
        background: linear-gradient(90deg, #dc3545, #c82333);
        color: white;
    }

    .dropdown-item.duplicate-item:hover {
        background: linear-gradient(90deg, #fd7e14, #e55a00);
        color: white;
    }

    .dropdown-item.export-item:hover {
        background: linear-gradient(90deg, #20c997, #1ea085);
        color: white;
    }

    /* Scrollbar for dropdown */
    .dropdown-content::-webkit-scrollbar {
        width: 6px;
    }

    .dropdown-content::-webkit-scrollbar-track {
        background: #f1f1f1;
    }

    .dropdown-content::-webkit-scrollbar-thumb {
        background: #c1c1c1;
        border-radius: 3px;
    }

    .dropdown-content::-webkit-scrollbar-thumb:hover {
        background: #a8a8a8;
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

    /* Card-based Seller Layout */
    .sellers-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
        gap: 25px;
        padding: 20px 0;
    }

    .seller-card {
        background: white;
        border-radius: 16px;
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
        overflow: hidden;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        border: 1px solid rgba(0, 0, 0, 0.08);
        position: relative;
    }

    .seller-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
        border-color: rgba(79, 70, 229, 0.2);
    }

    .seller-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .seller-id {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .id-label {
        font-size: 0.85rem;
        opacity: 0.8;
        font-weight: 500;
    }

    .id-value {
        font-size: 1.1rem;
        font-weight: 700;
        color: #ffffff;
    }

    .seller-info {
        padding: 20px;
        background: #fafbfc;
    }

    .info-row {
        display: flex;
        justify-content: space-between;
        margin-bottom: 15px;
        gap: 20px;
    }

    .info-row:last-child {
        margin-bottom: 0;
    }

    .info-item {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 1;
        font-size: 0.9rem;
        color: #4a5568;
    }

    .info-item i {
        color: #667eea;
        width: 16px;
        text-align: center;
    }

    .seller-details {
        padding: 20px;
        display: flex;
        gap: 20px;
        align-items: flex-start;
    }

    .seller-image {
        flex-shrink: 0;
        width: 80px;
        height: 80px;
        border-radius: 12px;
        overflow: hidden;
        background: #f7fafc;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #e2e8f0;
    }

    .seller-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .no-image {
        color: #a0aec0;
        font-size: 0.8rem;
        text-align: center;
        padding: 10px;
    }

    .seller-description {
        flex: 1;
        font-size: 0.9rem;
        color: #4a5568;
        line-height: 1.5;
    }

    .seller-actions {
        padding: 20px;
        background: #f8f9fa;
        border-top: 1px solid #e9ecef;
    }

    .action-buttons {
        display: flex;
        justify-content: flex-end;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        .sellers-container {
            grid-template-columns: 1fr;
            gap: 20px;
            padding: 15px 0;
        }

        .seller-card {
            border-radius: 12px;
        }

        .seller-header {
            padding: 15px;
            flex-direction: column;
            gap: 10px;
            text-align: center;
        }

        .seller-info {
            padding: 15px;
        }

        .info-row {
            flex-direction: column;
            gap: 10px;
        }

        .seller-details {
            padding: 15px;
            flex-direction: column;
            text-align: center;
        }

        .seller-image {
            margin: 0 auto;
        }

        .seller-actions {
            padding: 15px;
        }

        .action-buttons {
            justify-content: center;
        }
    }

    @media (max-width: 480px) {
        .sellers-container {
            padding: 10px 0;
        }

        .seller-header {
            padding: 12px;
        }

        .seller-info,
        .seller-details,
        .seller-actions {
            padding: 12px;
        }

        .info-item {
            font-size: 0.85rem;
        }

        .seller-description {
            font-size: 0.85rem;
        }
    }

    /* Dropdown positioning for table */
    .sellers-table .dropdown-content {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 2px;
        min-width: 280px;
        z-index: 9999 !important;
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(0, 0, 0, 0.1);
        display: none; /* Initially hidden */
    }

    .sellers-table .dropdown-content.show {
        display: block !important;
    }

    /* Ensure dropdown button is visible */
    .sellers-table .dropdown-btn {
        display: inline-flex !important;
        align-items: center;
        gap: 8px;
        background: linear-gradient(135deg, #4f46e5, #7c3aed);
        color: white;
        padding: 8px 16px;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.3s ease;
        white-space: nowrap;
    }

    .sellers-table .dropdown-btn:hover {
        background: linear-gradient(135deg, #4338ca, #6d28d9);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(79, 70, 229, 0.4);
    }

    .sellers-table {
        position: relative;
    }

    .sellers-table .dropdown {
        position: relative;
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
            <div class="stat-card">
                <span class="stat-icon">📦</span>
                <div class="stat-number" id="movedSellers">0</div>
                <div class="stat-label">Moved to Products</div>
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
                    <option value="moved_to_products">Moved to Products</option>
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
                out.println("<script>showApprovedSuccess('Database connection failed!');</script>");
                return;
            }

            PreparedStatement ps = con.prepareStatement("SELECT * FROM seller ORDER BY sid DESC");
            ResultSet rs = ps.executeQuery();

            int totalSellers = 0;
            int pendingSellers = 0;
            int approvedSellers = 0;
            int rejectedSellers = 0;
            int movedSellers = 0;

            while (rs.next()) {
                totalSellers++;
        %>
                <tr data-name="<%= rs.getString("full_name").toLowerCase() %>" data-email="<%= rs.getString("email_address").toLowerCase() %>">
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
                        <div class="action-buttons">
                            <div class="dropdown">
                                <button class="dropdown-btn" onclick="toggleDropdown('dropdown<%= rs.getString("sid") %>')">
                                    <i class="fas fa-cog"></i> Actions
                                    <i class="fas fa-chevron-down"></i>
                                </button>
                                <!-- Direct delete button for testing -->
                                <button onclick="deleteSellerDirect('<%= rs.getString("sid") %>', 'delete')" style="margin-left: 2px; padding: 4px 8px; background: #dc3545; color: white; border: none; border-radius: 4px; font-size: 10px; cursor: pointer;" title="Delete Seller">🗑️</button>
                                <div class="dropdown-content" id="dropdown<%= rs.getString("sid") %>">
                                    <!-- Status Filter Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-filter"></i> Filter by Status
                                        </div>
                                        <select class="dropdown-filter-select" id="statusFilter<%= rs.getString("sid") %>" onchange="filterByStatus('<%= rs.getString("sid") %>')">
                                            <option value="">All Status</option>
                                            <option value="pending">Pending</option>
                                            <option value="approved">Approved</option>
                                            <option value="rejected">Rejected</option>
                                            <option value="moved_to_products">Moved to Products</option>
                                        </select>
                                    </div>
                                    
                                    <!-- Quick Actions Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-bolt"></i> Quick Actions
                                        </div>
                                        <a href="#" class="dropdown-item approve-item" onclick="acceptProduct('<%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-check"></i> Accept Product
                                        </a>
                                        <a href="#" class="dropdown-item pending-item" onclick="showApprovedSuccess('<%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-check-circle"></i> Approved
                                        </a>
                                        <a href="#" class="dropdown-item reject-item" onclick="showApprovedSuccess('Reject clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-times"></i> Reject
                                        </a>
                                    </div>
                                    
                                    <!-- Advanced Actions Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-cogs"></i> Advanced Actions
                                        </div>
                                        <a href="#" class="dropdown-item move-item" onclick="showApprovedSuccess('Move to Products clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-arrow-right"></i> Move to Products
                                        </a>
                                        <a href="#" class="dropdown-item edit-item" onclick="showApprovedSuccess('Edit clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-edit"></i> Edit Details
                                        </a>
                                        <a href="#" class="dropdown-item view-item" onclick="showApprovedSuccess('View clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-eye"></i> View Full Details
                                        </a>
                                    </div>
                                    
                                    <!-- Management Section -->
                                    <div class="dropdown-section">
                                        <div class="section-title">
                                            <i class="fas fa-tools"></i> Management
                                        </div>
                                        <a href="#" class="dropdown-item delete-item" onclick="deleteSeller('<%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-trash"></i> Delete Seller
                                        </a>
                                        <a href="#" class="dropdown-item duplicate-item" onclick="showApprovedSuccess('Duplicate clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-copy"></i> Duplicate Entry
                                        </a>
                                        <a href="#" class="dropdown-item export-item" onclick="showApprovedSuccess('Export clicked for <%= rs.getString("sid") %>'); return false;">
                                            <i class="fas fa-download"></i> Export Data
                                        </a>
                                    </div>
                                </div>
                            </div>
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
            request.setAttribute("movedSellers", movedSellers);
            
            con.close();
        } catch (Exception e) {
            out.println("<script>showApprovedSuccess('Error loading seller: " + e.getMessage() + "');</script>");
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
        // Test function for debugging AcceptProductServlet
        function testAcceptProductServlet() {
            console.log('Testing AcceptProductServlet...');
            
            // Try different possible servlet paths
            const possiblePaths = [
                'AcceptProductServlet',
                '/AcceptProductServlet',
                'servlets/AcceptProductServlet',
                '/servlets/AcceptProductServlet'
            ];
            
            let currentIndex = 0;
            
            function tryNextPath() {
                if (currentIndex >= possiblePaths.length) {
                    showApprovedSuccess('All servlet paths failed. Check server logs for servlet deployment issues.');
                    return;
                }
                
                const path = possiblePaths[currentIndex];
                console.log('Trying path:', path);
                
                fetch(path, {
                    method: 'GET'
                }).then(response => {
                    console.log('Response for path', path, '- status:', response.status);
                    if (response.status === 404) {
                        currentIndex++;
                        tryNextPath();
                    } else {
                        return response.text();
                    }
                }).then(text => {
                    if (text) {
                        console.log('Response text:', text);
                        showApprovedSuccess('Success with path ' + path + '!\n\nServlet Response: ' + text);
                        
                        // Update the acceptProduct function to use the working path
                        window.workingServletPath = path;
                        console.log('Set working servlet path to:', path);
                    }
                }).catch(error => {
                    console.error('Error with path', path, ':', error);
                    currentIndex++;
                    tryNextPath();
                });
            }
            
            tryNextPath();
        }

        // Test function for debugging DeleteSellerServlet
        function testDeleteSellerServlet() {
            console.log('Testing DeleteSellerServlet...');
            
            // Try different possible servlet paths
            const possiblePaths = [
                'DeleteSellerServlet',
                '/DeleteSellerServlet',
                'servlets/DeleteSellerServlet',
                '/servlets/DeleteSellerServlet'
            ];
            
            let currentIndex = 0;
            
            function tryNextPath() {
                if (currentIndex >= possiblePaths.length) {
                    showApprovedSuccess('All DeleteSellerServlet paths failed. Check if the servlet is properly deployed in Eclipse.');
                    return;
                }
                
                const path = possiblePaths[currentIndex];
                console.log('Testing DeleteSellerServlet path:', path);
                
                fetch(path, {
                    method: 'GET'
                }).then(response => {
                    console.log('DeleteSellerServlet response for path', path, '- status:', response.status);
                    if (response.status === 404) {
                        currentIndex++;
                        tryNextPath();
                    } else {
                        return response.text();
                    }
                }).then(text => {
                    if (text) {
                        console.log('DeleteSellerServlet response text:', text);
                        showApprovedSuccess('DeleteSellerServlet works with path ' + path + '!\n\nResponse: ' + text);
                        
                        // Update the deleteSellerDirect function to use the working path
                        window.workingDeleteServletPath = path;
                        console.log('Set working DeleteSellerServlet path to:', path);
                    }
                }).catch(error => {
                    console.error('Error with DeleteSellerServlet path', path, ':', error);
                    currentIndex++;
                    tryNextPath();
                });
            }
            
            tryNextPath();
        }

        // Update statistics
        document.addEventListener('DOMContentLoaded', function() {
            const totalSellers = parseInt('<%= request.getAttribute("totalSellers") != null ? request.getAttribute("totalSellers") : 0 %>');
            const pendingSellers = parseInt('<%= request.getAttribute("pendingSellers") != null ? request.getAttribute("pendingSellers") : 0 %>');
            const approvedSellers = parseInt('<%= request.getAttribute("approvedSellers") != null ? request.getAttribute("approvedSellers") : 0 %>');
            const rejectedSellers = parseInt('<%= request.getAttribute("rejectedSellers") != null ? request.getAttribute("rejectedSellers") : 0 %>');
            const movedSellers = parseInt('<%= request.getAttribute("movedSellers") != null ? request.getAttribute("movedSellers") : 0 %>');

            document.getElementById('totalSellers').textContent = totalSellers;
            document.getElementById('pendingSellers').textContent = pendingSellers;
            document.getElementById('approvedSellers').textContent = approvedSellers;
            document.getElementById('rejectedSellers').textContent = rejectedSellers;
            document.getElementById('movedSellers').textContent = movedSellers;
        });

        // Test dropdown function for debugging
        function testDropdown(dropdownId) {
            console.log('Test dropdown called for:', dropdownId);
            var dropdown = document.getElementById(dropdownId);
            if (dropdown) {
                showApprovedSuccess('Dropdown found! Current display: ' + dropdown.style.display + ', Classes: ' + dropdown.className);
                // Force show the dropdown
                dropdown.style.display = 'block';
                dropdown.classList.add('show');
                dropdown.style.background = 'yellow';
                dropdown.style.border = '2px solid red';
                showApprovedSuccess('Dropdown should now be visible with yellow background!');
            } else {
                showApprovedSuccess('Dropdown NOT found: ' + dropdownId);
            }
        }

        // Simple dropdown toggle function
        function toggleDropdown(dropdownId) {
            console.log('Toggle dropdown called for:', dropdownId);
            var dropdown = document.getElementById(dropdownId);
            if (dropdown) {
                // Check current state
                var isHidden = dropdown.style.display === 'none' || !dropdown.style.display;
                console.log('Current visibility:', isHidden ? 'hidden' : 'visible');
                
                // Close all other dropdowns first
                var allDropdowns = document.getElementsByClassName('dropdown-content');
                for (var i = 0; i < allDropdowns.length; i++) {
                    allDropdowns[i].style.display = 'none';
                    allDropdowns[i].classList.remove('show');
                }
                
                // Toggle current dropdown
                if (isHidden) {
                    dropdown.style.display = 'block';
                    dropdown.classList.add('show');
                    console.log('Dropdown shown');
                } else {
                    dropdown.style.display = 'none';
                    dropdown.classList.remove('show');
                    console.log('Dropdown hidden');
                }
            } else {
                console.log('Dropdown not found:', dropdownId);
            }
        }

        // Close dropdowns when clicking outside
        document.addEventListener('click', function(event) {
            if (!event.target.closest('.dropdown-btn') && !event.target.closest('.dropdown-content')) {
                var dropdowns = document.getElementsByClassName('dropdown-content');
                for (var i = 0; i < dropdowns.length; i++) {
                    dropdowns[i].style.display = 'none';
                    dropdowns[i].classList.remove('show');
                }
            }
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

        // Direct delete function for the red delete button
        function deleteSellerDirect(sellerId, action) {
            console.log('deleteSellerDirect called with sellerId:', sellerId, 'and action:', action);
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to delete this seller? This action cannot be undone.')) {
                console.log('User cancelled deletion');
                return;
            }
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting seller...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to working DeleteSellerServlet
            const xhr = new XMLHttpRequest();
            const servletPath = window.workingDeleteServletPath || 'DeleteSellerServlet';
            console.log('Using servlet path:', servletPath);
            xhr.open('POST', servletPath, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            // Log the request data
            const requestData = 'sellerId=' + encodeURIComponent(sellerId) + '&action=' + encodeURIComponent(action);
            console.log('Sending request data to DeleteSellerServlet:', requestData);
            
            xhr.onreadystatechange = function() {
                console.log('XHR state changed:', xhr.readyState, 'status:', xhr.status);
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Response status:', xhr.status);
                    console.log('Response text:', xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Parsed response:', response);
                            
                            if (response.success) {
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Success message displays on same page - no reload needed



                            } else {
                                console.error('Delete failed:', response.message);
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing delete response:', e);
                            console.error('Raw response:', xhr.responseText);
                            showNotification('Error parsing server response. Please try again.', 'error');
                        }
                    } else {
                        console.error('Delete request failed with status:', xhr.status);
                        console.error('Response text:', xhr.responseText);
                        showNotification('Server error: ' + xhr.status + '. Please try again.', 'error');
                    }
                }
            };
            
            xhr.onerror = function() {
                console.error('XHR error occurred');
                if (loadingDiv.parentNode) {
                    document.body.removeChild(loadingDiv);
                }
                showNotification('Network error occurred. Please check your connection.', 'error');
            };
            
            try {
                xhr.send(requestData);
                console.log('Request sent successfully to DeleteSellerServlet');
            } catch (e) {
                console.error('Error sending request:', e);
                if (loadingDiv.parentNode) {
                    document.body.removeChild(loadingDiv);
                }
                showNotification('Error sending request. Please try again.', 'error');
            }
        }

        // Delete Seller function (for dropdown)
        function deleteSeller(sellerId) {
            console.log('deleteSeller called with sellerId:', sellerId);
            
            // Close dropdown
            const dropdown = document.getElementById('dropdown' + sellerId);
            if (dropdown) {
                dropdown.style.display = 'none';
                dropdown.classList.remove('show');
            }
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to delete this seller? This action cannot be undone.')) {
                return;
            }
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting seller...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to delete servlet
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'DeleteSellerServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                console.log('Delete XHR state changed:', xhr.readyState, 'status:', xhr.status);
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Delete response text:', xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Remove the seller row from table
                                const sellerRow = document.querySelector('tr[data-status][data-name] td:first-child');
                                if (sellerRow && sellerRow.textContent.includes(sellerId)) {
                                    sellerRow.closest('tr').remove();
                                }
                                
                                // Success message displays on same page - no reload needed



                            } else {
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing delete response:', e);
                            showNotification('Error deleting seller. Please try again.', 'error');
                        }
                    } else {
                        console.error('Delete request failed with status:', xhr.status);
                        showNotification('Error deleting seller. Please try again.', 'error');
                    }
                }
            };
            
            xhr.send('sellerId=' + encodeURIComponent(sellerId) + '&action=delete');
        }

        // Show notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: 500; z-index: 10000; animation: slideIn 0.3s ease; max-width: 400px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #4CAF50, #45a049)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #f44336, #d32f2f)';
            }
            
            notification.textContent = message;
            document.body.appendChild(notification);
            
            // Auto-remove after 5 seconds
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 5000);
        }

        // Show Approved Success function
        function showApprovedSuccess(sellerId) {
            showNotification('Seller ' + sellerId + ' has been approved successfully!', 'success');
        }

        // Accept Product function

        function acceptProduct(sellerId) {
            console.log('acceptProduct called with sellerId:', sellerId);
            showApprovedSuccess('DEBUG: Accept Product called for seller ID: ' + sellerId);
            
            // Close dropdown
            const dropdown = document.getElementById('dropdown' + sellerId);
            if (dropdown) {
                dropdown.style.display = 'none';
                dropdown.classList.remove('show');
            }
            
            // Show confirmation dialog
            if (!confirm('Are you sure you want to accept this product? It will be displayed in Showproducts.jsp')) {
                return;
            }
            
            showApprovedSuccess('DEBUG: User confirmed. Sending AJAX request...');
            
            // Show loading message
            const loadingDiv = document.createElement('div');
            loadingDiv.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); z-index: 10000;';
            loadingDiv.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Accepting product...';
            document.body.appendChild(loadingDiv);
            
            // Send AJAX request to AcceptProductServlet
            const xhr = new XMLHttpRequest();
            const servletPath = window.workingServletPath || 'AcceptProductServlet';
            console.log('Using servlet path:', servletPath);
            showApprovedSuccess('DEBUG: Using servlet path: ' + servletPath);
            
            xhr.open('POST', servletPath, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                console.log('XHR state changed:', xhr.readyState, 'status:', xhr.status);
                showApprovedSuccess('DEBUG: XHR state: ' + xhr.readyState + ', status: ' + xhr.status);
                
                if (xhr.readyState === 4) {
                    // Remove loading message
                    if (loadingDiv.parentNode) {
                        document.body.removeChild(loadingDiv);
                    }
                    
                    console.log('Response status:', xhr.status);
                    console.log('Response text:', xhr.responseText);
                    showApprovedSuccess('DEBUG: Response status: ' + xhr.status + '\nResponse text: ' + xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            console.log('Parsed response:', response);
                            showApprovedSuccess('DEBUG: Parsed response: ' + JSON.stringify(response));
                            
                            if (response.success) {
                                // Show success message
                                showNotification(response.message, 'success');
                                
                                // Success message displays on same page - no reload needed



                            } else {
                                console.error('Accept failed:', response.message);
                                showNotification(response.message, 'error');
                            }
                        } catch (e) {
                            console.error('Error parsing accept response:', e);
                            console.error('Raw response:', xhr.responseText);
                            showNotification('Error parsing server response. Please try again.', 'error');
                        }
                    } else {
                        console.error('Accept request failed with status:', xhr.status);
                        showNotification('Server error: ' + xhr.status + '. Please try again.', 'error');
                    }
                }
            };
            
            const requestData = 'sellerId=' + encodeURIComponent(sellerId) + '&action=accept';
            console.log('Sending request data to AcceptProductServlet:', requestData);
            showApprovedSuccess('DEBUG: Sending data: ' + requestData);
            
            xhr.send(requestData);
            console.log('Request sent to AcceptProductServlet');
        }
        
        // Test function for Accept Product
        function testAcceptProduct() {
            const sellerId = prompt('Enter seller ID to test Accept Product:', '1');
            if (sellerId) {
                acceptProduct(sellerId);
            }
        }
        
        // Show notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; font-weight: bold; z-index: 10000; max-width: 300px;';
            
            if (type === 'success') {
                notification.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else if (type === 'error') {
                notification.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            } else {
                notification.style.background = 'linear-gradient(135deg, #ffc107, #e0a800)';
                notification.style.color = '#212529';
            }
            
            notification.innerHTML = '<i class="fas fa-' + (type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle') + '"></i> ' + message;
            document.body.appendChild(notification);
            
            // Auto remove after 3 seconds
            setTimeout(() => {
                if (notification.parentNode) {
                    document.body.removeChild(notification);
                }
            }, 3000);
        }

        // Filter sellers - Updated for table layout
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

        // Filter by individual status from Actions dropdown
        function filterByStatus(sellerId) {
            const statusFilter = document.getElementById('statusFilter' + sellerId).value;
            const rows = document.querySelectorAll('#sellersTableBody tr');
            
            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                const rowSellerId = row.querySelector('td:first-child').textContent;
                
                // If filtering for a specific seller, only show that seller
                const matchesSeller = !statusFilter || rowSellerId === sellerId;
                const matchesStatus = !statusFilter || status === statusFilter;
                
                row.style.display = matchesSeller && matchesStatus ? '' : 'none';
            });
            
            // Show alert for feedback
            if (statusFilter) {
                showApprovedSuccess('Filtering seller ' + sellerId + ' by status: ' + statusFilter);
            } else {
                showApprovedSuccess('Showing all sellers');
            }
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
