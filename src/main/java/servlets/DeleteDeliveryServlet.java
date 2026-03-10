package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import products.Dbase;

/**
 * Servlet for deleting delivery records when orders are delivered
 */
@WebServlet("/DeleteDeliveryServlet")
public class DeleteDeliveryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            String orderId = request.getParameter("orderId");
            
            if (orderId == null || orderId.trim().isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Order ID is required\"}");
                return;
            }
            
            // Delete delivery record
            if (deleteDeliveryRecord(orderId)) {
                out.print("{\"success\": true, \"message\": \"Delivery record deleted successfully\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to delete delivery record\"}");
            }
            
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Error deleting delivery record: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Delete delivery record by order_id
     */
    private boolean deleteDeliveryRecord(String orderId) {
        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            String deleteSql = "DELETE FROM delivery WHERE order_id = ?";
            PreparedStatement deleteStmt = con.prepareStatement(deleteSql);
            deleteStmt.setString(1, orderId);
            
            int rowsDeleted = deleteStmt.executeUpdate();
            deleteStmt.close();
            con.close();
            
            return rowsDeleted > 0;
            
        } catch (Exception e) {
            return false;
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
