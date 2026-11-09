package com.mycompany.proyectojava.sales.model;

import java.math.BigDecimal;

public interface DeliveryStrategy {
    BigDecimal finalTotal(BigDecimal originalTotal);
}
