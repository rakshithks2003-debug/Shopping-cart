package products;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/Deleteproducts")
public class Deleteproducts extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to showItems.jsp
        response.sendRedirect("Showproducts.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        request.getParameter("imageFileName");
        
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Product ID required");
            return;
        }
        
        try {
            String id = idStr; // Keep as string since IDs are VARCHAR
            
            // First, get the correct image filename from database
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            String getImageSql = "SELECT name FROM product WHERE id = ?";
            PreparedStatement getImagePs = con.prepareStatement(getImageSql);
            getImagePs.setString(1, id);
            ResultSet imageRs = getImagePs.executeQuery();
            
            String imageToDelete = null;
            if (imageRs.next()) {
                imageToDelete = imageRs.getString("name");
            }
            imageRs.close();
            getImagePs.close();
            
            // Delete the correct image file if it exists
            if (imageToDelete != null && !imageToDelete.trim().isEmpty()) {
                String uploadPath = getServletContext().getRealPath("") + "product_images";
                File imageFile = new File(uploadPath + File.separator + imageToDelete);
                if (imageFile.exists()) {
                    imageFile.delete();
                    System.out.println("Deleted image: " + imageToDelete);
                }
            }
            
            // Now delete from database
            String sql = "DELETE FROM product WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, id);
            
            int rowsAffected = ps.executeUpdate();
            
            ps.close();
            con.close();
            
            if (rowsAffected > 0) {
                // Redirect back to showItems.jsp
                response.sendRedirect("Showproducts.jsp");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error deleting product: " + e.getMessage());
        }
    }
}