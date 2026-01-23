package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import products.Dbase;

@WebServlet("/UpdateSellerStatusServlet")
public class UpdateSellerStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            if (con == null || con.isClosed()) {
                response.sendRedirect("Seller.jsp?error=Database connection failed");
                return;
            }

            // Update seller status
            PreparedStatement ps = con.prepareStatement(
                "UPDATE seller SET status = ? WHERE id = ?");
            
            ps.setString(1, newStatus);
            ps.setString(2, sellerId);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("Seller.jsp?success=Seller status updated to " + newStatus);
            } else {
                response.sendRedirect("Seller.jsp?error=Failed to update seller status");
            }
            
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Seller.jsp?error=" + e.getMessage());
        }
    }
}
