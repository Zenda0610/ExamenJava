package com.mycompany.proyectojava.sales.model;

import java.math.BigDecimal;

public final class StandardDelivery implements DeliveryStrategy {
    @Override
    public BigDecimal finalTotal(BigDecimal originalTotal) {
        return originalTotal;
    }
}
