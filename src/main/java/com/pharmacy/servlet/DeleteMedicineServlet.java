package com.pharmacy.servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.pharmacy.dao.DBConnection;

@WebServlet("/deleteMedicine")
public class DeleteMedicineServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Connection conn = DBConnection.connect();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM medicine WHERE id=?");
            ps.setInt(1, Integer.parseInt(req.getParameter("id")));
            ps.executeUpdate();
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        // ← Toast param added here
        res.sendRedirect(req.getContextPath() + "/viewMedicines?toast=deleted");
    }
}
