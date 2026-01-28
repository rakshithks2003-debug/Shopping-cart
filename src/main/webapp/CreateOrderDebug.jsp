<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, products.*, java.text.SimpleDateFormat, java.util.Date" %>
<%
// Set response content type to JSON
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

// Debug: Print all received parameters
System.out.println("=== DEBUG: CreateOrderDebug.jsp ===");
System.out.println("Payment Method: " + request.getParameter("paymentMethod"));
System.out.println("Full Name: " + request.getParameter("fullName"));
System.out.println("Email: " + request.getParameter("email"));
System.out.println("Phone: " + request.getParameter("phone"));
System.out.println("Address: " + request.getParameter("address"));
System.out.println("City: " + request.getParameter("city"));
System.out.println("Pincode: " + request.getParameter("pincode"));
System.out.println("Total Amount: " + request.getParameter("totalAmount"));

// Check if user is logged in
HttpSession sessionObj = request.getSession(false);
if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
    !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
    out.print("{\"success\": false, \"message\": \"Please login to place an order\"}");
    return;
}

String username = (String) sessionObj.getAttribute("username");

// Get payment details
String paymentMethod = request.getParameter("paymentMethod");
String fullName = request.getParameter("fullName");
String email = request.getParameter("email");
String phone = request.getParameter("phone");
String address = request.getParameter("address");
String city = request.getParameter("city");
String pincode = request.getParameter("pincode");
String totalAmountStr = request.getParameter("totalAmount");

// Build debug message
StringBuilder debugMsg = new StringBuilder();
debugMsg.append("Received parameters: ");
if (paymentMethod != null) debugMsg.append("paymentMethod=[").append(paymentMethod).append("] ");
if (fullName != null) debugMsg.append("fullName=[").append(fullName).append("] ");
if (email != null) debugMsg.append("email=[").append(email).append("] ");
if (phone != null) debugMsg.append("phone=[").append(phone).append("] ");
if (address != null) debugMsg.append("address=[").append(address).append("] ");
if (city != null) debugMsg.append("city=[").append(city).append("] ");
if (pincode != null) debugMsg.append("pincode=[").append(pincode).append("] ");
if (totalAmountStr != null) debugMsg.append("totalAmount=[").append(totalAmountStr).append("] ");

// Check for missing parameters
if (paymentMethod == null || fullName == null || email == null || phone == null || 
    address == null || city == null || pincode == null || totalAmountStr == null) {
    
    String missingParams = "";
    if (paymentMethod == null) missingParams += "paymentMethod ";
    if (fullName == null) missingParams += "fullName ";
    if (email == null) missingParams += "email ";
    if (phone == null) missingParams += "phone ";
    if (address == null) missingParams += "address ";
    if (city == null) missingParams += "city ";
    if (pincode == null) missingParams += "pincode ";
    if (totalAmountStr == null) missingParams += "totalAmount ";
    
    out.print("{\"success\": false, \"message\": \"Missing required information: " + missingParams.trim() + "\", \"debug\": \"" + debugMsg.toString().replace("\"", "\\\"") + "\"}");
    return;
}

// Check for empty parameters
if (paymentMethod.trim().isEmpty() || fullName.trim().isEmpty() || email.trim().isEmpty() || phone.trim().isEmpty() || 
    address.trim().isEmpty() || city.trim().isEmpty() || pincode.trim().isEmpty() || totalAmountStr.trim().isEmpty()) {
    
    String emptyParams = "";
    if (paymentMethod.trim().isEmpty()) emptyParams += "paymentMethod ";
    if (fullName.trim().isEmpty()) emptyParams += "fullName ";
    if (email.trim().isEmpty()) emptyParams += "email ";
    if (phone.trim().isEmpty()) emptyParams += "phone ";
    if (address.trim().isEmpty()) emptyParams += "address ";
    if (city.trim().isEmpty()) emptyParams += "city ";
    if (pincode.trim().isEmpty()) emptyParams += "pincode ";
    if (totalAmountStr.trim().isEmpty()) emptyParams += "totalAmount ";
    
    out.print("{\"success\": false, \"message\": \"Empty parameters: " + emptyParams.trim() + "\", \"debug\": \"" + debugMsg.toString().replace("\"", "\\\"") + "\"}");
    return;
}

try {
    double totalAmount = Double.parseDouble(totalAmountStr);
    
    // For now, just return success to test the parameter passing
    String orderId = "ORD" + System.currentTimeMillis();
    
    out.print("{\"success\": true, \"message\": \"Debug: Order parameters received successfully\", \"orderId\": \"" + orderId + "\", \"debug\": \"" + debugMsg.toString().replace("\"", "\\\"") + "\"}");
    
} catch (NumberFormatException e) {
    out.print("{\"success\": false, \"message\": \"Invalid total amount format: " + totalAmountStr + "\", \"debug\": \"" + debugMsg.toString().replace("\"", "\\\"") + "\"}");
} catch (Exception e) {
    e.printStackTrace();
    out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage().replace("\"", "\\\"") + "\", \"debug\": \"" + debugMsg.toString().replace("\"", "\\\"") + "\"}");
}
%>
