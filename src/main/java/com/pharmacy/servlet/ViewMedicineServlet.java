package com.pharmacy.servlet;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.pharmacy.dao.DBConnection;

@WebServlet("/viewMedicines")
public class ViewMedicineServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ArrayList<String[]> list = new ArrayList<>();

        try {
            Connection conn = DBConnection.connect();
            Statement st = conn.createStatement();

            ResultSet rs = st.executeQuery("SELECT * FROM medicine");

            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("id"),
                        rs.getString("name"),
                        rs.getString("quantity"),
                        rs.getString("price")
                });
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // 🔥 IMPORTANT: send SAME name as JSP
        request.setAttribute("list", list);

        RequestDispatcher rd = request.getRequestDispatcher("dashboard.jsp");
        rd.forward(request, response);
    }
}