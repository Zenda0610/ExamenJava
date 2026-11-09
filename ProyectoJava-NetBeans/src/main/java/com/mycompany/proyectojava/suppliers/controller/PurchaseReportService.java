package com.mycompany.proyectojava.suppliers.controller;

import com.mycompany.proyectojava.suppliers.model.suppliersDAO;
import java.io.IOException;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.SQLException;
import java.time.LocalDate;

public final class PurchaseReportService {
    private final suppliersDAO dao = new suppliersDAO();

    public record Result(Path file, int rows) {}

    public Result exportToday() throws IOException, SQLException {
        LocalDate today = LocalDate.now();
        var purchases = dao.findPurchasesOn(today);
        Path file = Path.of("compras_" + today + ".csv").toAbsolutePath();
        try (var writer = Files.newBufferedWriter(file)) {
            writer.write("NumeroCompra;NombreProveedor;MontoTotal");
            writer.newLine();
            for (var purchase : purchases) {
                writer.write(purchase.number() + ";" + csvField(purchase.supplier()) + ";"
                        + purchase.total().setScale(2, RoundingMode.HALF_UP).toPlainString());
                writer.newLine();
            }
        }
        return new Result(file, purchases.size());
    }

    private static String csvField(String value) {
        if (value.contains(";") || value.contains("\"") || value.contains("\r") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
