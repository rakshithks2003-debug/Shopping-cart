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

@WebServlet("/MoveToProductsServlet")
public class MoveToProductsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String sellerId = request.getParameter("id");
        
        if (sellerId == null || sellerId.trim().isEmpty()) {
            response.sendRedirect("Seller.jsp?error=No seller ID provided");
            return;
        }

        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            if (con == null || con.isClosed()) {
                response.sendRedirect("Seller.jsp?error=Database connection failed");
                return;
            }

            // First, check if the seller exists
            PreparedStatement checkPs = con.prepareStatement(
                "SELECT * FROM seller WHERE id = ?");
            checkPs.setString(1, sellerId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (!checkRs.next()) {
                response.sendRedirect("Seller.jsp?error=Seller not found");
                return;
            }

            // Check if product already exists
            PreparedStatement productCheckPs = con.prepareStatement(
                "SELECT COUNT(*) FROM product WHERE id = ?");
            productCheckPs.setString(1, sellerId);
            ResultSet productCheckRs = productCheckPs.executeQuery();
            
            if (productCheckRs.next() && productCheckRs.getInt(1) > 0) {
                response.sendRedirect("Seller.jsp?error=Product already exists");
                return;
            }

            // Move seller data to product table
            PreparedStatement insertPs = con.prepareStatement(
                "INSERT INTO product (id, name, price, image, description, category_id) " +
                "VALUES (?, ?, ?, ?, ?, ?)");
            
            insertPs.setString(1, checkRs.getString("id"));
            insertPs.setString(2, checkRs.getString("product_brand") + " " + checkRs.getString("Category"));
            insertPs.setString(3, checkRs.getString("price"));
            insertPs.setString(4, checkRs.getString("image"));
            insertPs.setString(5, checkRs.getString("description"));
            insertPs.setString(6, checkRs.getString("Category_id"));
            
            int result = insertPs.executeUpdate();
            
            if (result > 0) {
                // Product moved successfully (no status update needed)
                response.sendRedirect("Showproducts.jsp?success=Product moved successfully");
            } else {
                response.sendRedirect("Seller.jsp?error=Failed to move product");
            }
            
            con.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Seller.jsp?error=" + e.getMessage());
        }
    }
}
