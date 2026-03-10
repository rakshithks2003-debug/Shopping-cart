package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import products.Dbase;

@WebServlet("/UpdateSellerStatusServlet")
public class UpdateSellerStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get parameters
        String sellerId = request.getParameter("sellerId");
        String action = request.getParameter("action");
        String approvedBy = request.getParameter("approvedBy");
        String rejectionReason = request.getParameter("rejectionReason");
        
        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            // Initialize database connection
            Dbase db = new Dbase();
            con = db.initailizeDatabase();
            
            // Get seller details for notification
            String getSellerQuery = "SELECT username, email, first_name, last_name, shop_name FROM signupseller WHERE id = ?";
            stmt = con.prepareStatement(getSellerQuery);
            stmt.setString(1, sellerId);
            rs = stmt.executeQuery();
            
            String sellerUsername = "";
            String sellerEmail = "";
            String sellerName = "";
            String shopName = "";
            
            if (rs.next()) {
                sellerUsername = rs.getString("username");
                sellerEmail = rs.getString("email");
                sellerName = rs.getString("first_name") + " " + rs.getString("last_name");
                shopName = rs.getString("shop_name");
            }
            rs.close();
            stmt.close();
            
            // Update seller status based on action
            String updateQuery = "";
            String message = "";
            String messageType = "success";
            
            if ("approve".equals(action)) {
                updateQuery = "UPDATE signupseller SET status = 'approved', approved_by = ?, approved_date = CURDATE() WHERE id = ?";
                message = "Seller " + sellerName + " (" + shopName + ") has been approved successfully!";
                
                stmt = con.prepareStatement(updateQuery);
                stmt.setString(1, approvedBy);
                stmt.setString(2, sellerId);
                
                int updateResult = stmt.executeUpdate();
                stmt.close();
                
                // After updating signupseller, also update users table with seller_id
                if (updateResult > 0) {
                    try {
                        // First check if user exists in users table
                        String checkUserQuery = "SELECT username FROM users WHERE username = ?";
                        PreparedStatement checkStmt = con.prepareStatement(checkUserQuery);
                        checkStmt.setString(1, sellerUsername);
                        ResultSet userRs = checkStmt.executeQuery();
                        
                        if (userRs.next()) {
                            // User exists, update seller_id
                            String updateUserQuery = "UPDATE users SET seller_id = ? WHERE username = ?";
                            PreparedStatement updateStmt = con.prepareStatement(updateUserQuery);
                            updateStmt.setString(1, sellerId);
                            updateStmt.setString(2, sellerUsername);
                            updateStmt.executeUpdate();
                            updateStmt.close();
                        } else {
                            // User doesn't exist in users table, create entry
                            String insertUserQuery = "INSERT INTO users(username, password, role, seller_id) VALUES (?, ?, 'seller', ?)";
                            PreparedStatement insertStmt = con.prepareStatement(insertUserQuery);
                            insertStmt.setString(1, sellerUsername);
                            insertStmt.setString(2, "default123"); // Default password for seller
                            insertStmt.setString(3, sellerId);
                            insertStmt.executeUpdate();
                            insertStmt.close();
                        }
                        userRs.close();
                        checkStmt.close();
                    } catch (Exception userEx) {
                        // Silently handle users table update errors
                    }
                }
                
            } else if ("reject".equals(action)) {
                updateQuery = "UPDATE signupseller SET status = 'rejected', rejection_reason = ?, approved_by = ?, approved_date = CURDATE() WHERE id = ?";
                message = "Seller " + sellerName + " (" + shopName + ") has been rejected.";
                messageType = "warning";
                
                stmt = con.prepareStatement(updateQuery);
                stmt.setString(1, rejectionReason);
                stmt.setString(2, approvedBy);
                stmt.setString(3, sellerId);
                
            } else {
                response.sendRedirect("Dashboard.jsp?error=" + 
                    java.net.URLEncoder.encode("Invalid action specified", "UTF-8"));
                return;
            }
            
            int result = stmt.executeUpdate();
            
            if (result > 0) {
                // Log the action (optional - you may need to create admin_logs table)
                try {
                    String logQuery = "INSERT INTO admin_logs (admin_username, action, target_seller_id, details, action_date) VALUES (?, ?, ?, ?, NOW())";
                    PreparedStatement logStmt = con.prepareStatement(logQuery);
                    logStmt.setString(1, approvedBy);
                    logStmt.setString(2, action);
                    logStmt.setString(3, sellerId);
                    logStmt.setString(4, action + " seller " + sellerUsername + " - " + shopName);
                    logStmt.executeUpdate();
                    logStmt.close();
                } catch (Exception logEx) {
                    // Silently handle logging errors
                }
                
                // Redirect with success message
                response.sendRedirect("Dashboard.jsp?message=" + 
                    java.net.URLEncoder.encode(message, "UTF-8") + 
                    "&type=" + messageType);
                
            } else {
                response.sendRedirect("Dashboard.jsp?error=" + 
                    java.net.URLEncoder.encode("Failed to update seller status", "UTF-8"));
            }
            
        } catch (Exception e) {
            response.sendRedirect("Dashboard.jsp?error=" + 
                java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (Exception e) {
                // Silently handle resource cleanup errors
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String sellerId = request.getParameter("id");
        String newStatus = request.getParameter("status");
        
        if (sellerId == null || sellerId.trim().isEmpty() || 
            newStatus == null || newStatus.trim().isEmpty()) {
            response.sendRedirect("Seller.jsp?error=Missing parameters");
            return;
        }

        // Validate status
        if (!newStatus.equals("pending") && !newStatus.equals("approved") && 
            !newStatus.equals("rejected")) {
            response.sendRedirect("Seller.jsp?error=Invalid status");
            return;
        }

        // Since status column is removed, just redirect with success message
        response.sendRedirect("Seller.jsp?success=Status management is now simplified - no status column needed");
    }
}