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
        Part filePart = request.getPart("img");

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

        if (filePart == null || filePart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Image required");
            return;
        }

        // Parse price and ID
        double price;
        String id;
        try {
            price = Double.parseDouble(priceStr);
            id = idStr; // Keep as string for alphabetic IDs
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid price format");
            return;
        }

        // Get file name
        String fileName = Path.of(filePart.getSubmittedFileName()).getFileName().toString();

        // Folder where images will be saved
        String uploadPath = getServletContext().getRealPath("") + "product_images";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Save image
        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath);

        try {
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();

            String sql = "INSERT INTO product(id, name, price, description, image) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setDouble(3, price);
            ps.setString(4, description != null ? description : "");
            ps.setString(5, fileName);

            ps.executeUpdate();

            ps.close();
            con.close();

            PrintWriter out = response.getWriter();
            out.println("<html><body>");
            out.println("<h3>Product uploaded successfully!</h3>");
            out.println("<p>ID: " + id + "</p>");
            out.println("<p>Name: " + name + "</p>");
            out.println("<p>Price: ₹" + price + "</p>");
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