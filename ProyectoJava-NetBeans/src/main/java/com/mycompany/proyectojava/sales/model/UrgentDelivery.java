package com.mycompany.proyectojava.sales.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

public final class UrgentDelivery implements DeliveryStrategy {
    private static final BigDecimal MULTIPLIER = new BigDecimal("1.12");

    @Override
    public BigDecimal finalTotal(BigDecimal originalTotal) {
        return originalTotal.multiply(MULTIPLIER).setScale(2, RoundingMode.HALF_UP);
    }
}
