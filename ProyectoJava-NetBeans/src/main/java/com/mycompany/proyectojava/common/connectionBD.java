
package com.mycompany.proyectojava.common;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class connectionBD {
     private static final String URL = "jdbc:mysql://localhost:3307/erp_frescura_total";
    private static final String USER = "root";
    private static final String PASSWORD = "Campus2026";

    public static Connection getConnection() throws SQLException{
        return DriverManager.getConnection(
                System.getProperty("erp.jdbc.url", URL),
                System.getProperty("erp.jdbc.user", USER),
                System.getProperty("erp.jdbc.password", PASSWORD));
    }
}
