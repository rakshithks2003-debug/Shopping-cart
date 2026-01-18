package filters;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AuthFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String path = httpRequest.getRequestURI();
        HttpSession session = httpRequest.getSession(false);
        
        // Allow access to login, signup, and static resources without authentication
        if (path.contains("/Login.html") || path.contains("/Signup.html") || 
            path.contains("/Loginservlet") || path.contains("/SignupServlet") ||
            path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".jpg") || 
            path.endsWith(".png") || path.endsWith(".gif")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is logged in
        if (session != null && session.getAttribute("isLoggedIn") != null && 
            (Boolean) session.getAttribute("isLoggedIn")) {
            
            // User is logged in, allow access
            chain.doFilter(request, response);
        } else {
            // User is not logged in, redirect to login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/Login.html");
        }
    }
    
    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
