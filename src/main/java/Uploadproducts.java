
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.PreparedStatement;

import products.Dbase;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/Uploadproducts")
@MultipartConfig(maxFileSize = 1600000) // 1.6 MB
public class Uploadproducts extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("pname");
        String priceStr = request.getParameter("price");
        String idStr = request.getParameter("pid");
        String description = request.getParameter("description");
        String category_id = request.getParameter("category_id");
        String brand = request.getParameter("brand");
        
        // Handle multiple images
        java.util.Collection<Part> fileParts = request.getParts();
        java.util.List<Part> imageParts = new java.util.ArrayList<>();
        
        for (Part part : fileParts) {
            if (part.getName().equals("img") && part.getSize() > 0) {
                imageParts.add(part);
            }
        }

        if (name == null || name.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Product name required");
            return;
        }

        if (priceStr == null || priceStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Price required");
            return;
        }

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Product ID required");
            return;
        }

        if (imageParts == null || imageParts.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "At least one image required");
            return;
        }

        if (category_id == null || category_id.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Category required");
            return;
        }

        if (brand == null || brand.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Brand name required");
            return;
        }

        // Parse and validate ID
        String id;
        try {
            Double.parseDouble(priceStr); // Validate price format
            id = idStr; // Keep as string for alphabetic IDs
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid price format");
            return;
        }

        // Folder where images will be saved
        String uploadPath = getServletContext().getRealPath("") + "product_images";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Process multiple images
        java.util.List<String> imageNames = new java.util.ArrayList<>();
        java.util.List<String> imagePaths = new java.util.ArrayList<>();
        
        System.out.println("Uploadproducts - Processing " + imageParts.size() + " images");
        
        for (Part filePart : imageParts) {
            String fileName = Path.of(filePart.getSubmittedFileName()).getFileName().toString();
            String filePath = uploadPath + File.separator + fileName;
            
            // Save image
            filePart.write(filePath);
            
            imageNames.add(fileName);
            imagePaths.add(fileName);
            
            System.out.println("Uploadproducts - Saved image: " + fileName);
        }

        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();

            // Create comma-separated list of all image names for storage
            String allImages = String.join(",", imageNames);

            // Insert product with all images as comma-separated string
            String sql = "INSERT INTO product(id, name, price, description, image, category_id, brand) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setString(3, priceStr); // Store price as string to match database column
            ps.setString(4, description != null ? description : "");
            ps.setString(5, allImages); // Store all images as comma-separated string
            ps.setString(6, category_id);
            ps.setString(7, brand);

            ps.executeUpdate();

            ps.close();
            con.close();

            PrintWriter out = response.getWriter();
            out.println("<html><body>");
            out.println("<h3>Product uploaded successfully!</h3>");
            out.println("<p>ID: " + id + "</p>");
            out.println("<p>Name: " + name + "</p>");
            out.println("<p>Brand: " + brand + "</p>");
            out.println("<p>Price: ₹" + priceStr + "</p>");
            out.println("<p>Images uploaded: " + imageNames.size() + " file(s)</p>");
            out.println("<ul>");
            for (String imgName : imageNames) {
                out.println("<li>" + imgName + "</li>");
            }
            out.println("</ul>");
            if (description != null && !description.trim().isEmpty()) {
                out.println("<p>Description: " + description + "</p>");
            }
            out.println("<p><a href='Showproducts.jsp'>View Products</a></p>");
            out.println("<p><a href='Addproducts.jsp'>Add Another Product</a></p>");
            out.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database Error");
        }
    }
}
