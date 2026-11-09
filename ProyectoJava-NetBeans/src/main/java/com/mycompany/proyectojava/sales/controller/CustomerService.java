package com.mycompany.proyectojava.sales.controller;

import com.mycompany.proyectojava.sales.model.CustomerCache;
import com.mycompany.proyectojava.sales.model.SalesDAO;
import com.mycompany.proyectojava.sales.model.customer;
import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;

public final class CustomerService {
    private static final String HEADER = "nombre;documento;correo;telefono;tipo_cliente";
    private static final Pattern EMAIL = Pattern.compile("[^\\s@]+@[^\\s@.]+(?:\\.[^\\s@.]+)+");
    private final SalesDAO dao;
    private final CustomerCache cache = CustomerCache.getInstance();

    public CustomerService(SalesDAO dao) {
        this.dao = dao;
    }

    public Optional<customer> findCustomer(int id) throws SQLException {
        return cache.find(id, dao);
    }

    public int importCustomers(Path file) throws IOException, SQLException {
        List<SalesDAO.CustomerImportRow> customers = new ArrayList<>();
        Set<String> documents = new HashSet<>();
        try (BufferedReader reader = Files.newBufferedReader(file)) {
            if (!HEADER.equals(reader.readLine())) {
                throw new IllegalArgumentException("Cabecera incorrecta.");
            }
            int lineNumber = 1;
            for (String line; (line = reader.readLine()) != null; ) {
                lineNumber++;
                if (line.isBlank()) continue;
                String[] fields = line.split(";", -1);
                if (fields.length != 5) {
                    throw new IllegalArgumentException("Se esperaban cinco campos en la línea " + lineNumber);
                }
                for (int i = 0; i < fields.length; i++) {
                    fields[i] = fields[i].strip();
                    if (fields[i].isEmpty()) {
                        throw new IllegalArgumentException("Campo vacío en la línea " + lineNumber);
                    }
                }
                String type = fields[4];
                if (fields[0].length() > 255 || fields[1].length() > 20
                        || fields[2].length() > 100 || fields[3].length() > 20
                        || !EMAIL.matcher(fields[2]).matches()
                        || !(type.equals("MAYORISTA") || type.equals("MINORISTA"))) {
                    throw new IllegalArgumentException("Campos inválidos en la línea " + lineNumber);
                }
                if (!documents.add(fields[1])) {
                    throw new IllegalArgumentException("Documento repetido en la línea " + lineNumber);
                }
                customers.add(new SalesDAO.CustomerImportRow(
                        fields[0], fields[1], fields[2], fields[3], type));
            }
        }
        return dao.insertImportedCustomers(customers);
    }
}
