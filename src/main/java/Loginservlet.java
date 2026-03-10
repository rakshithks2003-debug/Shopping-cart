import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import products.Dbase;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/Loginservlet")
public class Loginservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			Dbase db = new Dbase();
			Connection con = db.initailizeDatabase();
			
			String n = request.getParameter("username");
			String p = request.getParameter("password");
			
			// Validate input
			if (n == null || n.trim().isEmpty() || p == null || p.trim().isEmpty()) {
				response.sendRedirect("Login.jsp?error=" + java.net.URLEncoder.encode("Username and password are required", "UTF-8"));
				return;
			}
			
			// First check users table for admin and customer roles
			PreparedStatement ps = con.prepareStatement("select username, role from users where username=? and password=?");
			ps.setString(1, n);
			ps.setString(2, p);
			ResultSet rs = ps.executeQuery();
			
			boolean authenticated = false;
			String userRole = null;
			
			if(rs.next()) {
				userRole = rs.getString("role");
				authenticated = true;
			} else {
				authenticated = false;
			}
			rs.close();
			ps.close();
			con.close();
			
			if(authenticated) {
				// Create session and store user data
				HttpSession session = request.getSession();
				session.setAttribute("userRole", userRole);
				session.setAttribute("username", n);
				session.setAttribute("isLoggedIn", true);
				
				// Redirect based on role
				if ("admin".equals(userRole)) {
					response.sendRedirect("Home.jsp");
				} else if ("seller".equals(userRole)) {
					response.sendRedirect("SellerDashboard.jsp");
				} else {
					response.sendRedirect("Home.jsp");
				}
			} else {
				// Authentication failed - redirect back to login with error message
				response.sendRedirect("Login.jsp?error=" + java.net.URLEncoder.encode("Invalid username or password", "UTF-8") + "&username=" + java.net.URLEncoder.encode(n, "UTF-8"));
			}
			
		} catch (Exception e) {
			// Set error message and redirect back to login page
			try {
				response.sendRedirect("Login.jsp?error=" + java.net.URLEncoder.encode("An error occurred. Please try again.", "UTF-8"));
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
	}

}