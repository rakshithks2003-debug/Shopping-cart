package products;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import products.Dbase;

/**
 * Servlet to handle payment transaction records
 */
@WebServlet("/PaymentTransactionServlet")
public class PaymentTransactionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PaymentTransactionServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            out.print("{\"success\": false, \"message\": \"User not logged in\", \"transactionId\": 0}");
            return;
        }

        String username = (String) session.getAttribute("username");
        
        // Get payment parameters
        String orderId = request.getParameter("orderId");
        String paymentMethod = request.getParameter("paymentMethod");
        String amountStr = request.getParameter("amount");
        String gstStr = request.getParameter("gst");
        String sellerId = request.getParameter("sellerId");
        String cardNumber = request.getParameter("cardNumber");
        String cardholderName = request.getParameter("cardholderName");
        String billingEmail = request.getParameter("billingEmail");
        String billingPhone = request.getParameter("billingPhone");
        String billingAddress = request.getParameter("billingAddress");
        String billingCity = request.getParameter("billingCity");
        String billingPincode = request.getParameter("billingPincode");
        
        // Debug logging
        System.out.println("=== PAYMENT TRANSACTION DEBUG ===");
        System.out.println("Order ID: " + orderId);
        System.out.println("Amount: " + amountStr);
        System.out.println("GST Parameter: " + gstStr);
        System.out.println("Seller ID: " + sellerId);
        System.out.println("================================");
        
        boolean success = false;
        String message = "";
        int transactionId = 0;
        
        try {
            // Validate required parameters
            if (orderId == null || orderId.trim().isEmpty()) {
                message = "Order ID is required";
            } else if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                message = "Payment method is required";
            } else if (amountStr == null || amountStr.trim().isEmpty()) {
                message = "Amount is required";
            } else {
                double amount = Double.parseDouble(amountStr);
                double gst = gstStr != null && !gstStr.trim().isEmpty() ? Double.parseDouble(gstStr) : 25.0;
                
                // Debug logging
                System.out.println("=== PAYMENT TRANSACTION DEBUG ===");
                System.out.println("Order ID: " + orderId);
                System.out.println("Amount: " + amount);
                System.out.println("GST Parameter: " + gstStr);
                System.out.println("Parsed GST: " + gst);
                System.out.println("================================");
                
                // Initialize database connection
                Dbase db = new Dbase();
                Connection con = db.initailizeDatabase();
                
                if (con != null && !con.isClosed()) {
                    // Insert payment transaction record
                    String sql = "INSERT INTO payment_transactions (order_id, user_id, payment_method, amount, gst, status, " +
                                "card_number_masked, cardholder_name, billing_email, billing_phone, billing_address, " +
                                "billing_city, billing_pincode, payment_gateway_response, Seller_id) " +
                                "VALUES (?, ?, ?, ?, ?, 'completed', ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    
                    PreparedStatement stmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                    stmt.setString(1, orderId);
                    stmt.setString(2, username);
                    stmt.setString(3, paymentMethod);
                    stmt.setDouble(4, amount);
                    stmt.setDouble(5, gst);
                    stmt.setString(6, cardNumber != null ? cardNumber : "");
                    stmt.setString(7, cardholderName != null ? cardholderName : "");
                    stmt.setString(8, billingEmail != null ? billingEmail : "");
                    stmt.setString(9, billingPhone != null ? billingPhone : "");
                    stmt.setString(10, billingAddress != null ? billingAddress : "");
                    stmt.setString(11, billingCity != null ? billingCity : "");
                    stmt.setString(12, billingPincode != null ? billingPincode : "");
                    stmt.setString(13, "Payment processed successfully");
                    
                    // Handle Seller_id properly - it's an integer column, so set NULL if empty
                    if (sellerId != null && !sellerId.trim().isEmpty()) {
                        stmt.setString(14, sellerId);
                    } else {
                        stmt.setNull(14, java.sql.Types.INTEGER);
                    }
                    
                    int rowsAffected = stmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        success = true;
                        message = "Payment transaction recorded successfully";
                        
                        // Get the generated transaction ID
                        ResultSet generatedKeys = stmt.getGeneratedKeys();
                        if (generatedKeys.next()) {
                            transactionId = generatedKeys.getInt(1);
                            message += " (Transaction ID: " + transactionId + ")";
                        }
                        generatedKeys.close();
                    } else {
                        message = "Failed to record payment transaction";
                    }
                    
                    stmt.close();
                    con.close();
                } else {
                    message = "Database connection failed";
                }
            }
        } catch (NumberFormatException e) {
            message = "Invalid amount format";
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            System.err.println("Payment transaction error: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Create manual JSON response
        StringBuilder jsonResponse = new StringBuilder();
        jsonResponse.append("{");
        jsonResponse.append("\"success\": ").append(success).append(", ");
        jsonResponse.append("\"message\": \"").append(escapeJson(message)).append("\", ");
        jsonResponse.append("\"transactionId\": ").append(transactionId);
        jsonResponse.append("}");
        
        out.print(jsonResponse.toString());
    }
    
    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
