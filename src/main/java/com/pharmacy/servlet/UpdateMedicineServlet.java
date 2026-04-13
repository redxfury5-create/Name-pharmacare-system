package com.pharmacy.servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.pharmacy.dao.DBConnection;

@WebServlet("/updateMedicine")
public class UpdateMedicineServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Connection conn = DBConnection.connect();
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE medicine SET name=?, quantity=?, price=? WHERE id=?"
            );
            ps.setString(1, req.getParameter("name"));
            ps.setInt(2, Integer.parseInt(req.getParameter("quantity")));
            ps.setDouble(3, Double.parseDouble(req.getParameter("price")));
            ps.setInt(4, Integer.parseInt(req.getParameter("id")));
            ps.executeUpdate();
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        // ← Toast param added here
        res.sendRedirect(req.getContextPath() + "/viewMedicines?toast=updated");
    }
}
