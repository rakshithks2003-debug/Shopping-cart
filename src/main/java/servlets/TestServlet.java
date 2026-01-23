package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/TestServlet")
public class TestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        out.print("TestServlet is working!");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        String sellerId = request.getParameter("sellerId");
        String action = request.getParameter("action");
        
        if ("delete".equals(action) && sellerId != null) {
            out.print("{\"success\": true, \"message\": \"Test delete successful for seller ID: " + sellerId + "\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"Test servlet received: sellerId=" + sellerId + ", action=" + action + "\"}");
        }
    }
}
