package com.pharmacy.servlet;

import com.pharmacy.dao.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/updateMedicine")
public class UpdateMedicineServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("name");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        double price = Double.parseDouble(request.getParameter("price"));

        try {
            Connection conn = DBConnection.connect();

            String sql = "UPDATE medicine SET name=?, quantity=?, price=? WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, name);
            ps.setInt(2, quantity);
            ps.setDouble(3, price);
            ps.setInt(4, id);

            ps.executeUpdate();

            // 🔥 go back to dashboard after update
            response.sendRedirect("viewMedicines");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}