

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

/**
 * Servlet implementation class Sellerservlet
 */
@WebServlet("/SellerServlet")
public class Sellerservlet extends HttpServlet {
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws IOException {

    int id = Integer.parseInt(request.getParameter("id"));

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/shopping","root","password");

        PreparedStatement ps = con.prepareStatement(
            "UPDATE sellers SET status='Approved' WHERE seller_id=?");
        ps.setInt(1, id);
        ps.executeUpdate();

        response.sendRedirect("sellers.jsp");
    } catch (Exception e) {
        e.printStackTrace();
    }
}
}
