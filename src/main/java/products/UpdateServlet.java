package products;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/UpdateServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 10,  // 10 MB
    maxRequestSize = 1024 * 1024 * 15  // 15 MB
)
public class UpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        PrintWriter out = response.getWriter();
        
        try {
            // Get form parameters
            String id = request.getParameter("id");
            String name = request.getParameter("name");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            
            // Debug output
            System.out.println("DEBUG - Received parameters:");
            System.out.println("ID: " + id);
            System.out.println("Name: " + name);
            System.out.println("Price: " + priceStr);
            System.out.println("Description: " + description);
            
            // Validate required fields
            if (id == null || name == null || priceStr == null || 
                id.trim().isEmpty() || name.trim().isEmpty() || priceStr.trim().isEmpty()) {
                out.println("<html><body>");
                out.println("<font color='red' size='4'>All required fields must be filled!</font><br>");
                out.println("<p>Debug: ID=" + id + ", Name=" + name + ", Price=" + priceStr + "</p>");
                out.println("<a href='admin.html'>Try Again</a>");
                out.println("</body></html>");
                return;
            }
            
            // Parse price
            double price;
            try {
                price = Double.parseDouble(priceStr);
                if (price < 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                out.println("<html><body>");
                out.println("<font color='red' size='4'>Invalid price format!</font><br>");
                out.println("<a href='admin.html'>Try Again</a>");
                out.println("</body></html>");
                return;
            }
            
            // Connect to database
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            // Handle file upload
            Part filePart = request.getPart("image");
            String imageFileName = null;
            
            if (filePart != null && filePart.getSize() > 0) {
                // Get file name and validate
                String fileName = filePart.getSubmittedFileName();
                if (fileName != null && !fileName.trim().isEmpty()) {
                    // Validate file type
                    String contentType = filePart.getContentType();
                    if (contentType == null || !contentType.startsWith("image/")) {
                        out.println("<html><body>");
                        out.println("<font color='red' size='4'>Only image files are allowed!</font><br>");
                        out.println("<a href='admin.html'>Try Again</a>");
                        out.println("</body></html>");
                        con.close();
                        return;
                    }
                    
                    // Generate unique filename
                    String fileExtension = fileName.substring(fileName.lastIndexOf('.'));
                    imageFileName = System.currentTimeMillis() + fileExtension;
                    
                    // Save file
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "product_images";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdir();
                    }
                    
                    String filePath = uploadPath + File.separator + imageFileName;
                    filePart.write(filePath);
                }
            }
            
            // Update product in database
            String updateSql;
            PreparedStatement ps;
            
            if (imageFileName != null) {
                // Update with new image
                updateSql = "UPDATE product SET name = ?, price = ?, description = ?, image = ? WHERE id = ?";
                ps = con.prepareStatement(updateSql);
                ps.setString(1, name);
                ps.setDouble(2, price);
                ps.setString(3, description);
                ps.setString(4, imageFileName);
                ps.setString(5, id);
            } else {
                // Update without changing image
                updateSql = "UPDATE product SET name = ?, price = ?, description = ? WHERE id = ?";
                ps = con.prepareStatement(updateSql);
                ps.setString(1, name);
                ps.setDouble(2, price);
                ps.setString(3, description);
                ps.setString(4, id);
            }
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                // Success
                out.println("<html><body>");
                out.println("<script>");
                out.println("alert('Product updated successfully!');");
                out.println("window.location.href='Showproducts.jsp';");
                out.println("</script>");
                out.println("</body></html>");
            } else {
                // Failed
                out.println("<html><body>");
                out.println("<font color='red' size='4'>Update failed! Product not found.</font><br>");
                out.println("<a href='admin.html'>Try Again</a>");
                out.println("</body></html>");
            }
            
            ps.close();
            con.close();
            
        } catch (Exception e) {
            out.println("<html><body>");
            out.println("<font color='red' size='4'>Error updating product: " + e.getMessage() + "</font><br>");
            out.println("<a href='admin.html'>Try Again</a>");
            out.println("</body></html>");
        }
    }
}