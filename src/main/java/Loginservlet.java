import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import products.Dbase;
import jakarta.servlet.RequestDispatcher;
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
		PrintWriter out = response.getWriter();
		try {
			 Dbase db = new Dbase();
	            Connection con = db.initailizeDatabase();
			
			
			String n=request.getParameter("username");
			String p=request.getParameter("password");
			
			PreparedStatement ps=con.prepareStatement("select username, role from users where username=? and password=?");
			ps.setString(1, n);
			ps.setString(2, p);
			ResultSet rs=ps.executeQuery();
			if(rs.next())
			{
				String userRole = rs.getString("role");
				
				// Create session and store user data
				HttpSession session = request.getSession();
				session.setAttribute("userRole", userRole);
				session.setAttribute("username", n);
				session.setAttribute("isLoggedIn", true);
				
				// Redirect based on role
				if ("admin".equals(userRole)) {
					RequestDispatcher rd=request.getRequestDispatcher("Home.jsp");
					rd.forward(request,response);
				} else {
					RequestDispatcher rd=request.getRequestDispatcher("Home.jsp");
					rd.forward(request,response);
				}
			}
			else
			{
				out.println("<font color=red size=18>Login Failed<br>");
				out.println("<a href=Login.html>Try AGAIN</a>");
			}
		
			
		} catch (Exception e) {
			out.println("<h3>Database Error: " + e.getMessage() + "</h3>");
			out.println("<p><pre>");
			e.printStackTrace(out);
			out.println("</pre></p>");
		};
	}

}