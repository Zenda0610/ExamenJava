package com.mycompany.proyectojava.sales.controller;

import com.mycompany.proyectojava.sales.model.SalesDAO.CommercialRow;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public final class CommercialStatistics {
    // A sale is confirmed when checkout succeeds and it enters preparation.
    private static final Set<String> CONFIRMED = Set.of(
            "Disponible", "Proximo a Vencer", "Vencido", "En Cuarentena");

    public record Result(Optional<Map.Entry<String, BigDecimal>> topCategory,
                         List<String> customersWithReturns) {}

    public Result calculate(List<CommercialRow> rows) {
        var top = rows.stream()
                .filter(row -> CONFIRMED.contains(row.status().toUpperCase(java.util.Locale.ROOT)))
                .collect(Collectors.groupingBy(CommercialRow::category,
                        Collectors.reducing(BigDecimal.ZERO, CommercialRow::quantity, BigDecimal::add)))
                .entrySet().stream()
                .max(Map.Entry.comparingByValue());
        var customers = rows.stream()
                .filter(row -> "DEVUELTA".equalsIgnoreCase(row.status()))
                .collect(Collectors.toMap(CommercialRow::customerId, CommercialRow::customerName,
                        (first, repeated) -> first))
                .values().stream().sorted().toList();
        return new Result(top, customers);
    }
}
