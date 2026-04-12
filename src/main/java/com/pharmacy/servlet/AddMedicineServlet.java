package com.pharmacy.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.pharmacy.dao.DBConnection;

@WebServlet("/addMedicine")
public class AddMedicineServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String name = request.getParameter("name");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            double price = Double.parseDouble(request.getParameter("price"));

            Connection conn = DBConnection.connect();

            String sql = "INSERT INTO medicine(name, quantity, price) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, name);
            ps.setInt(2, quantity);
            ps.setDouble(3, price);

            ps.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/viewMedicines");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}