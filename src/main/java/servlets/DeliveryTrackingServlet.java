package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import products.Dbase;

/**
 * Servlet for handling delivery tracking functionality
 * Provides real-time tracking information for orders
 */
@WebServlet("/DeliveryTrackingServlet")
public class DeliveryTrackingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mscart";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        String orderId = request.getParameter("orderId");
        String trackingId = request.getParameter("trackingId");
        
        try {
            // Check if user is logged in
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("isLoggedIn") == null || 
                !(Boolean) session.getAttribute("isLoggedIn")) {
                out.print("{\"success\": false, \"message\": \"Please login to track orders\"}");
                return;
            }
            
            String username = (String) session.getAttribute("username");
            
            // Generate dummy tracking data if order exists
            List<Map<String, Object>> trackingData = generateDummyTrackingData(orderId, trackingId, username);
            
            if (trackingData.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Order not found\"}");
            } else {
                out.print("{\"success\": true, \"trackingData\": " + 
                          java.util.Arrays.toString(trackingData.toArray()).replace("=", ":") + "}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error tracking order\"}");
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Generate dummy tracking data for demonstration purposes
     */
    private List<Map<String, Object>> generateDummyTrackingData(String orderId, String trackingId, String username) {
        List<Map<String, Object>> trackingData = new ArrayList<>();
        
        try {
            // Check if order exists in database
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            if (con != null && !con.isClosed()) {
                String orderSql = "SELECT order_id, status, order_date FROM orders WHERE order_id = ? AND user_id = ?";
                PreparedStatement orderStmt = con.prepareStatement(orderSql);
                orderStmt.setString(1, orderId);
                orderStmt.setString(2, username);
                ResultSet orderRs = orderStmt.executeQuery();
                
                if (orderRs.next()) {
                    String status = orderRs.getString("status");
                    String orderDate = orderRs.getString("order_date");
                    
                    // Generate tracking ID if not exists
                    if (trackingId == null || trackingId.trim().isEmpty()) {
                        trackingId = generateTrackingId();
                        updateTrackingId(con, orderId, trackingId);
                    }
                    
                    // Create dummy tracking history based on order status
                    trackingData = createTrackingHistory(orderId, trackingId, status, orderDate);
                }
                
                orderRs.close();
                orderStmt.close();
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return trackingData;
    }
    
    /**
     * Create tracking history based on order status
     */
    private List<Map<String, Object>> createTrackingHistory(String orderId, String trackingId, String status, String orderDate) {
        List<Map<String, Object>> history = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        
        // Common tracking events for all orders
        addTrackingEvent(history, "Order Placed", "Processing Center", 
                         orderDate, "Your order has been received and is being processed");
        
        addTrackingEvent(history, "Order Confirmed", "Processing Center", 
                         now.minusHours(22).format(formatter), "Your order has been confirmed and payment verified");
        
        addTrackingEvent(history, "Payment Verified", "Payment Gateway", 
                         now.minusHours(20).format(formatter), "Payment has been successfully processed");
        
        // Add status-specific events
        if ("pending".equals(status) || "processing".equals(status)) {
            addTrackingEvent(history, "Processing", "Warehouse", 
                             now.minusHours(18).format(formatter), "Your order is being prepared for shipment");
            addTrackingEvent(history, "Pending Shipment", "Processing Center", 
                             now.minusHours(12).format(formatter), "Order is awaiting shipment");
        } else if ("shipped".equals(status)) {
            addTrackingEvent(history, "Processing", "Warehouse", 
                             now.minusHours(18).format(formatter), "Your order is being prepared for shipment");
            addTrackingEvent(history, "Shipped", "Distribution Center", 
                             now.minusHours(12).format(formatter), "Order has been shipped and is in transit");
            addTrackingEvent(history, "In Transit", "Local Facility", 
                             now.minusHours(6).format(formatter), "Package is in transit to your location");
        } else if ("delivered".equals(status)) {
            addTrackingEvent(history, "Processing", "Warehouse", 
                             now.minusHours(24).format(formatter), "Your order is being prepared for shipment");
            addTrackingEvent(history, "Shipped", "Distribution Center", 
                             now.minusHours(18).format(formatter), "Order has been shipped and is in transit");
            addTrackingEvent(history, "In Transit", "Local Facility", 
                             now.minusHours(12).format(formatter), "Package is in transit to your location");
            addTrackingEvent(history, "Out for Delivery", "Local Post Office", 
                             now.minusHours(6).format(formatter), "Package is out for delivery");
            addTrackingEvent(history, "Delivered", "Your Address", 
                             now.minusHours(2).format(formatter), "Package has been successfully delivered");
        }
        
        return history;
    }
    
    /**
     * Add a tracking event to the history
     */
    private void addTrackingEvent(List<Map<String, Object>> history, String status, String location, 
                               String timestamp, String description) {
        Map<String, Object> event = new HashMap<>();
        event.put("orderId", "");
        event.put("trackingId", "");
        event.put("status", status);
        event.put("location", location);
        event.put("timestamp", timestamp);
        event.put("description", description);
        history.add(event);
    }
    
    /**
     * Generate a unique tracking ID
     */
    private String generateTrackingId() {
        Random random = new Random();
        return "TRK" + String.format("%09d", random.nextInt(1000000000));
    }
    
    /**
     * Update tracking ID for an order
     */
    private void updateTrackingId(Connection con, String orderId, String trackingId) throws SQLException {
        String updateSql = "UPDATE orders SET tracking_id = ? WHERE order_id = ?";
        PreparedStatement updateStmt = con.prepareStatement(updateSql);
        updateStmt.setString(1, trackingId);
        updateStmt.setString(2, orderId);
        updateStmt.executeUpdate();
        updateStmt.close();
    }
}
