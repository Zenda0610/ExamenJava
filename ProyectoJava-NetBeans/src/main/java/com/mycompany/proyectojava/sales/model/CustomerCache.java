package com.mycompany.proyectojava.sales.model;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public final class CustomerCache {
    private static final CustomerCache INSTANCE = new CustomerCache();
    private final Map<Integer, customer> customers = new HashMap<>();

    private CustomerCache() {}

    public static CustomerCache getInstance() {
        return INSTANCE;
    }

    public synchronized Optional<customer> find(int id, SalesDAO dao) throws SQLException {
        if (id <= 0) return Optional.empty();
        customer cached = customers.get(id);
        if (cached == null) {
            System.out.println("[Clientes] Consulta SQL para ID " + id);
            cached = dao.findCustomerById(id).orElse(null);
            if (cached == null) return Optional.empty();
            customers.put(id, cached);
        } else {
            System.out.println("[Clientes] Caché para ID " + id);
        }
        return Optional.of(new customer(cached.getId(), cached.getNombre(), cached.getDocumento(),
                cached.getEmail(), cached.getNumero(), cached.getDireccion(), cached.getIdTipo(),
                cached.getFechaRegistro()));
    }
}
