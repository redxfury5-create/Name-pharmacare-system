package com.pharmacy.servlet;

import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        // Invalidate the session completely
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Prevent browser back-button from showing cached pages
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        res.sendRedirect(req.getContextPath() + "/login.jsp?logout=1");
    }
}
