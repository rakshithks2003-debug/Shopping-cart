package products;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Collection;
import java.util.ArrayList;
import java.util.List;

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
            String pid = request.getParameter("pid");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            
            // Debug output
            System.out.println("DEBUG - Received parameters:");
            System.out.println("ID: " + id);
            System.out.println("Name: " + name);
            System.out.println("PID: " + pid);
            System.out.println("Price: " + priceStr);
            System.out.println("Description: " + description);
            
            // Validate required fields
            if (id == null || name == null || pid == null || priceStr == null || 
                id.trim().isEmpty() || name.trim().isEmpty() || pid.trim().isEmpty() || priceStr.trim().isEmpty()) {
                out.println("<html><body>");
                out.println("<script>");
                out.println("alert('All required fields must be filled!');");
                out.println("window.location.href='Updateproduct.jsp';");
                out.println("</script>");
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
                out.println("<script>");
                out.println("alert('Invalid price format!');");
                out.println("window.location.href='Updateproduct.jsp';");
                out.println("</script>");
                out.println("</body></html>");
                return;
            }
            
            // Connect to database
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            // Handle multiple file uploads
            Collection<Part> fileParts = request.getParts();
            List<String> imageFileNames = new ArrayList<>();
            int imageCount = 0;
            
            for (Part filePart : fileParts) {
                if (filePart.getName().equals("image") && filePart.getSize() > 0) {
                    if (imageCount >= 5) {
                        break; // Limit to 5 images
                    }
                    
                    // Get file name and validate
                    String fileName = filePart.getSubmittedFileName();
                    if (fileName != null && !fileName.trim().isEmpty()) {
                        // Validate file type
                        String contentType = filePart.getContentType();
                        if (contentType == null || !contentType.startsWith("image/")) {
                            out.println("<html><body>");
                            out.println("<script>");
                            out.println("alert('Only image files are allowed!');");
                            out.println("window.location.href='Updateproduct.jsp';");
                            out.println("</script>");
                            out.println("</body></html>");
                            con.close();
                            return;
                        }
                        
                        // Generate unique filename
                        String fileExtension = fileName.substring(fileName.lastIndexOf('.'));
                        String imageFileName = System.currentTimeMillis() + "_" + imageCount + fileExtension;
                        
                        // Save file
                        String uploadPath = getServletContext().getRealPath("") + File.separator + "product_images";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdir();
                        }
                        
                        String filePath = uploadPath + File.separator + imageFileName;
                        filePart.write(filePath);
                        
                        imageFileNames.add(imageFileName);
                        imageCount++;
                    }
                }
            }
            
            // Create comma-separated string of image names
            String imageFileName = null;
            if (!imageFileNames.isEmpty()) {
                imageFileName = String.join(",", imageFileNames);
            }
            
            // Update product in database
            String updateSql;
            PreparedStatement ps;
            
            if (imageFileName != null) {
                // Update with new image
                updateSql = "UPDATE product SET pid = ?, product_name = ?, price = ?, description = ?, image = ? WHERE id = ?";
                ps = con.prepareStatement(updateSql);
                ps.setString(1, pid);
                ps.setString(2, name);
                ps.setDouble(3, price);
                ps.setString(4, description);
                ps.setString(5, imageFileName);
                ps.setString(6, id);
            } else {
                // Update without changing image
                updateSql = "UPDATE product SET pid = ?, product_name = ?, price = ?, description = ? WHERE id = ?";
                ps = con.prepareStatement(updateSql);
                ps.setString(1, pid);
                ps.setString(2, name);
                ps.setDouble(3, price);
                ps.setString(4, description);
                ps.setString(5, id);
            }
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                // Success
                out.println("<html><body>");
                out.println("<script>");
                out.println("alert('Product updated successfully!');");
                out.println("window.location.href='Updateproduct.jsp?message=success';");
                out.println("</script>");
                out.println("</body></html>");
            } else {
                // Failed
                out.println("<html><body>");
                out.println("<script>");
                out.println("alert('Update failed! Product not found.');");
                out.println("window.location.href='Updateproduct.jsp';");
                out.println("</script>");
                out.println("</body></html>");
            }
            
            ps.close();
            con.close();
            
        } catch (Exception e) {
            System.err.println("ERROR in UpdateServlet: " + e.getMessage());
            e.printStackTrace();
            
            out.println("<html><body>");
            out.println("<script>");
            out.println("alert('Error updating product: " + e.getMessage() + "');");
            out.println("window.location.href='Updateproduct.jsp';");
            out.println("</script>");
            out.println("</body></html>");
        }
    }
}