package com.mycompany.proyectojava.sales.controller;

import com.mycompany.proyectojava.sales.model.DeliveryStrategy;
import com.mycompany.proyectojava.sales.model.StandardDelivery;
import com.mycompany.proyectojava.sales.model.UrgentDelivery;
import com.mycompany.proyectojava.sales.model.sale;
import java.math.BigDecimal;
import java.util.Map;

public final class DeliveryPricingService {
    public enum Mode { ESTANDAR, URGENTE }

    private final Map<Mode, DeliveryStrategy> strategies = Map.of(
            Mode.ESTANDAR, new StandardDelivery(),
            Mode.URGENTE, new UrgentDelivery());

    public BigDecimal finalTotal(sale order, Mode mode) {
        return strategies.get(mode).finalTotal(order.getMontoTotal());
    }
}
