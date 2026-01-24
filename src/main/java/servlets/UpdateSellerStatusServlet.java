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

        // Since status column is removed, just redirect with success message
        response.sendRedirect("Seller.jsp?success=Status management is now simplified - no status column needed");
    }
}
