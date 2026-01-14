import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import products.Dbase;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        PrintWriter out = response.getWriter();
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        try {
            // Validate passwords match
            if (!password.equals(confirmPassword)) {
                out.println("<html><body>");
                out.println("<font color='red' size='4'>Passwords do not match!</font><br>");
                out.println("<a href='Signup.html'>Try Again</a>");
                out.println("</body></html>");
                return;
            }
            
            // connect to database
            Dbase db = new Dbase();
            Connection con = db.initailizeDatabase();
            
            // Username existence check removed - allow duplicate usernames
            // PreparedStatement checkPs = con.prepareStatement("SELECT username FROM users WHERE username=?");
            // checkPs.setString(1, username);
            // ResultSet rs = checkPs.executeQuery();
            
            // if (rs.next()) {
            //     // Username already exists
            //     out.println("<html><body>");
            //     out.println("<font color='red' size='4'>Username already exists!</font><br>");
            //     out.println("<a href='signup.html'>Try Again</a>");
            //     out.println("</body></html>");
            // } else {
                // Insert new user directly without checking for duplicates
                PreparedStatement insertPs = con.prepareStatement("INSERT INTO users(username, password ) VALUES(?, ?)");
                insertPs.setString(1, username);
                insertPs.setString(2, password);
                int result = insertPs.executeUpdate();
                
                if (result > 0) {
                    // Registration successful
                    out.println("<html><body>");
                    out.println("<font color='green' size='4'>Registration successful!</font><br>");
                    out.println("<p>You can now login with your credentials.</p>");
                    out.println("<a href='Login.html'>Go to Login</a>");
                    out.println("</body></html>");
                } else {
                    // Registration failed
                    out.println("<html><body>");
                    out.println("<font color='red' size='4'>Registration failed!</font><br>");
                    out.println("<a href='Signup.html'>Try Again</a>");
                    out.println("</body></html>");
                }
                insertPs.close();
            // }
            
            // checkPs.close();
            con.close();
            
        } 
        catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database Error");
        }
       
        }
    }