package com.pharmacy.dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection connect() {
        Connection conn = null;

        try {
            Class.forName("org.postgresql.Driver");

            conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/pharmacy",
                "postgres",
                "DINKU_1432"
            );

        } catch (Exception e) {
            e.printStackTrace();
        }

        return conn;
    }
}