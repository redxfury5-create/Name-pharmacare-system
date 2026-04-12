package com.pharmacy.servlet;

import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        // If already logged in, go to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            res.sendRedirect(req.getContextPath() + "/viewMedicines");
        } else {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        String u = req.getParameter("username");
        String p = req.getParameter("password");

        if ("admin".equals(u) && "admin".equals(p)) {
            // Create session and store user
            HttpSession session = req.getSession(true);
            session.setAttribute("user", u);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout
            res.sendRedirect(req.getContextPath() + "/viewMedicines");
        } else {
            // Redirect back with error flag
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=1");
        }
    }
}
