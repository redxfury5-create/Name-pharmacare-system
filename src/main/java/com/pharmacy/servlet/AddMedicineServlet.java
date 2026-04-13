package com.pharmacy.servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.pharmacy.dao.DBConnection;

@WebServlet("/addMedicine")
public class AddMedicineServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Connection conn = DBConnection.connect();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO medicine(name, quantity, price) VALUES (?, ?, ?)"
            );
            ps.setString(1, req.getParameter("name"));
            ps.setInt(2, Integer.parseInt(req.getParameter("quantity")));
            ps.setDouble(3, Double.parseDouble(req.getParameter("price")));
            ps.executeUpdate();
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        // ← Toast param added here
        res.sendRedirect(req.getContextPath() + "/viewMedicines?toast=added");
    }
}
