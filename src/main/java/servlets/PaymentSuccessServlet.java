package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Random;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import products.Dbase;

/**
 * Servlet for handling successful payments and creating delivery records
 */
@WebServlet("/PaymentSuccessServlet")
public class PaymentSuccessServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            // Check if user is logged in
            HttpSession sessionObj = request.getSession(false);
            if (sessionObj == null || sessionObj.getAttribute("isLoggedIn") == null || 
                !(Boolean) sessionObj.getAttribute("isLoggedIn")) {
                out.print("{\"success\": false, \"message\": \"Please login to complete payment\"}");
                return;
            }
            
            String username = (String) sessionObj.getAttribute("username");
            String orderId = request.getParameter("orderId");
            String totalAmount = request.getParameter("totalAmount");
            String deliveryAddress = request.getParameter("deliveryAddress");
            
            if (orderId == null || orderId.trim().isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Order ID is required\"}");
                return;
            }
            
            if (totalAmount == null || totalAmount.trim().isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Total amount is required\"}");
                return;
            }
            
            // Insert delivery record
            if (createDeliveryRecord(orderId, username, totalAmount, deliveryAddress)) {
                out.print("{\"success\": true, \"message\": \"Payment successful! Delivery tracking created.\", \"orderId\": \"" + orderId + "\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to create delivery record\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error processing payment: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Create delivery record after successful payment using orders table data
     */
    private boolean createDeliveryRecord(String orderId, String username, String totalAmount, String deliveryAddress) {
        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            // First, get order details from orders table
            String orderSql = "SELECT order_id, total_amount, payment_method, delivery_address, created_at, user_id FROM orders WHERE order_id = ?";
            PreparedStatement orderStmt = con.prepareStatement(orderSql);
            orderStmt.setString(1, orderId);
            ResultSet orderRs = orderStmt.executeQuery();
            
            if (!orderRs.next()) {
                orderRs.close();
                orderStmt.close();
                con.close();
                return false; // Order not found
            }
            
            // Extract order details
            String actualOrderId = orderRs.getString("order_id");
            double orderTotalAmount = orderRs.getDouble("total_amount");
            String paymentMethod = orderRs.getString("payment_method");
            String orderDeliveryAddress = orderRs.getString("delivery_address");
            String orderDate = orderRs.getString("created_at");
            String userId = orderRs.getString("user_id");
            
            orderRs.close();
            orderStmt.close();
            
            // Insert new delivery record using the SAME order_id from orders table
            String insertSql = "INSERT INTO delivery (order_id, delivery_status, delivery_address, total_amount, delivery_person_name, delivery_phone) " +
                              "VALUES (?, 'pending', ?, ?, 'Not Assigned', 'Not Available')";
            PreparedStatement insertStmt = con.prepareStatement(insertSql);
            insertStmt.setString(1, actualOrderId); // Use the same order_id from orders table
            insertStmt.setString(2, orderDeliveryAddress != null && !orderDeliveryAddress.isEmpty() ? orderDeliveryAddress : 
                                (deliveryAddress != null ? deliveryAddress : "Default Address, Bangalore, Karnataka"));
            insertStmt.setDouble(3, orderTotalAmount);
            
            int rowsInserted = insertStmt.executeUpdate();
            insertStmt.close();
            con.close();
            
            return rowsInserted > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
