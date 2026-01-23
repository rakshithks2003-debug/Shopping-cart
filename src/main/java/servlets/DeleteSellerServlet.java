package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteSellerServlet")
public class DeleteSellerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("DeleteSellerServlet: doPost method called");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String sellerId = request.getParameter("sellerId");
        String action = request.getParameter("action");
        
        System.out.println("DeleteSellerServlet called with sellerId: " + sellerId + ", action: " + action);
        
        if (sellerId == null || action == null) {
            System.out.println("Missing parameters error");
            out.print("{\"success\": false, \"message\": \"Missing parameters\"}");
            return;
        }
        
        Connection conn = null;
        try {
            // Use direct connection for reliability
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mscart", "root", "123456");
            
            if (conn == null || conn.isClosed()) {
                System.out.println("Database connection failed");
                out.print("{\"success\": false, \"message\": \"Database connection failed\"}");
                return;
            }
            conn.setAutoCommit(false);
            
            if ("delete".equals(action)) {
                // First check if seller exists
                PreparedStatement checkPs = conn.prepareStatement("SELECT sid, full_name, product_brand FROM seller WHERE sid = ?");
                checkPs.setString(1, sellerId);
                ResultSet checkRs = checkPs.executeQuery();
                
                if (checkRs.next()) {
                    String sellerName = checkRs.getString("full_name");
                    String productBrand = checkRs.getString("product_brand");
                    System.out.println("Found seller: " + sellerName + " with brand: " + productBrand);
                    
                    // Delete the seller
                    PreparedStatement deletePs = conn.prepareStatement("DELETE FROM seller WHERE sid = ?");
                    deletePs.setString(1, sellerId);
                    int deletedRows = deletePs.executeUpdate();
                    
                    System.out.println("Delete operation affected " + deletedRows + " rows");
                    
                    if (deletedRows > 0) {
                        conn.commit();
                        System.out.println("Seller deleted successfully: " + sellerName);
                        out.print("{\"success\": true, \"message\": \"Seller '" + sellerName + "' deleted successfully!\"}");
                    } else {
                        conn.rollback();
                        System.out.println("Failed to delete seller");
                        out.print("{\"success\": false, \"message\": \"Failed to delete seller\"}");
                    }
                    
                    deletePs.close();
                } else {
                    System.out.println("Seller not found with ID: " + sellerId);
                    out.print("{\"success\": false, \"message\": \"Seller not found\"}");
                }
                
                checkRs.close();
                checkPs.close();
                
            } else {
                System.out.println("Invalid action: " + action);
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
            
        } catch (ClassNotFoundException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            System.out.println("SQL Error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Database driver not found: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            System.out.println("General Error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            out.close();
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("DeleteSellerServlet: doGet method called");
        response.getWriter().print("DeleteSellerServlet is working - Use POST method for functionality");
    }
}
