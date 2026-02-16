package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import products.Dbase;

@WebServlet("/DeleteSellerServlet")
public class DeleteSellerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null || 
            !(Boolean) session.getAttribute("isLoggedIn")) {
            response.sendRedirect("Login.html");
            return;
        }

        String userRole = (String) session.getAttribute("userRole");
        if (!"admin".equals(userRole)) {
            response.sendRedirect("Home.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        String sellerId = request.getParameter("sellerId");
        String deletedBy = request.getParameter("deletedBy");

        System.out.println("DeleteSellerServlet called with sellerId: " + sellerId + ", deletedBy: " + deletedBy);

        if (sellerId == null || sellerId.trim().isEmpty()) {
            response.sendRedirect("SellerApproval.jsp?message=Invalid seller ID&type=error");
            return;
        }

        Connection con = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmt2 = null;
        PreparedStatement pstmt3 = null;
        PreparedStatement pstmt4 = null;
        PreparedStatement pstmt5 = null;

        try {
            Dbase db = new Dbase();
            con = db.initailizeDatabase();

            if (con != null && !con.isClosed()) {
                con.setAutoCommit(false); // Start transaction

                // First, get seller information for logging
                String getSellerSql = "SELECT username, shop_name FROM signupseller WHERE id = ?";
                pstmt = con.prepareStatement(getSellerSql);
                pstmt.setInt(1, Integer.parseInt(sellerId));
                ResultSet rs = pstmt.executeQuery();
                
                String sellerUsername = "";
                String shopName = "";
                if (rs.next()) {
                    sellerUsername = rs.getString("username");
                    shopName = rs.getString("shop_name");
                }
                rs.close();

                // 1. Delete seller's products first (foreign key constraint)
                String deleteProductsSql = "DELETE FROM product WHERE seller_id = ?";
                pstmt2 = con.prepareStatement(deleteProductsSql);
                pstmt2.setInt(1, Integer.parseInt(sellerId));
                int productsDeleted = pstmt2.executeUpdate();

                // 2. Delete seller's cart items
                String deleteCartSql = "DELETE FROM cart WHERE seller_id = ?";
                pstmt3 = con.prepareStatement(deleteCartSql);
                pstmt3.setInt(1, Integer.parseInt(sellerId));
                int cartDeleted = pstmt3.executeUpdate();

                // 3. Delete seller's payment transactions
                String deletePaymentSql = "DELETE FROM payment_transactions WHERE seller_id = ?";
                pstmt4 = con.prepareStatement(deletePaymentSql);
                pstmt4.setInt(1, Integer.parseInt(sellerId));
                int paymentsDeleted = pstmt4.executeUpdate();

                // 4. Finally, delete the seller from signupseller table
                String deleteSellerSql = "DELETE FROM signupseller WHERE id = ?";
                pstmt5 = con.prepareStatement(deleteSellerSql);
                pstmt5.setInt(1, Integer.parseInt(sellerId));
                int sellerDeleted = pstmt5.executeUpdate();

                con.commit(); // Commit transaction

                System.out.println("Seller deletion successful:");
                System.out.println("Seller: " + sellerUsername + " (" + shopName + ")");
                System.out.println("Products deleted: " + productsDeleted);
                System.out.println("Cart items deleted: " + cartDeleted);
                System.out.println("Payment transactions deleted: " + paymentsDeleted);
                System.out.println("Deleted by: " + deletedBy);

                // Redirect with success message
                response.sendRedirect("SellerApproval.jsp?message=Seller '" + sellerUsername + "' has been successfully deleted&type=success");

            } else {
                response.sendRedirect("SellerApproval.jsp?message=Database connection failed&type=error");
            }

        } catch (NumberFormatException e) {
            System.err.println("Invalid seller ID format: " + e.getMessage());
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                System.err.println("Rollback failed: " + ex.getMessage());
            }
            response.sendRedirect("SellerApproval.jsp?message=Invalid seller ID format&type=error");
            
        } catch (SQLException e) {
            System.err.println("SQL Error during seller deletion: " + e.getMessage());
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                System.err.println("Rollback failed: " + ex.getMessage());
            }
            response.sendRedirect("SellerApproval.jsp?message=Database error occurred while deleting seller&type=error");
            
        } catch (Exception e) {
            System.err.println("Error during seller deletion: " + e.getMessage());
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                System.err.println("Rollback failed: " + ex.getMessage());
            }
            response.sendRedirect("SellerApproval.jsp?message=Error occurred while deleting seller&type=error");
            
        } finally {
            // Close all resources
            try {
                if (pstmt != null) pstmt.close();
                if (pstmt2 != null) pstmt2.close();
                if (pstmt3 != null) pstmt3.close();
                if (pstmt4 != null) pstmt4.close();
                if (pstmt5 != null) pstmt5.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources: " + e.getMessage());
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to POST for security
        doPost(request, response);
    }
}
