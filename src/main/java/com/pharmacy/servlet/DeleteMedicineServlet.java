package com.pharmacy.servlet;

import com.pharmacy.dao.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/deleteMedicine")
public class DeleteMedicineServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));

            Connection conn = DBConnection.connect();

            PreparedStatement ps = conn.prepareStatement("DELETE FROM medicine WHERE id=?");
            ps.setInt(1, id);

            ps.executeUpdate();

            response.sendRedirect("viewMedicines");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}