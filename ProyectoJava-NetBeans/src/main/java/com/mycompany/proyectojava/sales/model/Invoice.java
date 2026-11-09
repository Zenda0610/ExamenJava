
package com.mycompany.proyectojava.sales.model;


import java.math.BigDecimal;
import java.time.LocalDateTime;


public class Invoice {
    public java.math.BigDecimal deliverySurcharge() {
        return getMontoTotal().subtract(getSubtotal().subtract(getTotalDescuento()).add(getMontoImpuesto()));
    }



    private Integer id;
    private Integer idVenta;
    private String numeroFactura;
    private String cufe;
    private String enlaceQr;
    private LocalDateTime fechaEmision;
    private BigDecimal subtotal;
    private BigDecimal totalDescuento;
    private BigDecimal montoImpuesto;
    private BigDecimal montoTotal;

    public Invoice(Integer idFactura, Integer idVenta, String numeroFactura, String cufe, String enlaceQr, LocalDateTime fechaEmision, BigDecimal subtotal, BigDecimal totalDescuento, BigDecimal montoImpuesto, BigDecimal montoTotal) {
        this.id = idFactura;
        this.idVenta = idVenta;
        this.numeroFactura = numeroFactura;
        this.cufe = cufe;
        this.enlaceQr = enlaceQr;
        this.fechaEmision = fechaEmision;
        this.subtotal = subtotal;
        this.totalDescuento = totalDescuento;
        this.montoImpuesto = montoImpuesto;
        this.montoTotal = montoTotal;
    }

    public Integer getIdFactura() {
        return id;
    }

    public Integer getIdVenta() {
        return idVenta;
    }

    public String getNumeroFactura() {
        return numeroFactura;
    }

    public String getCufe() {
        return cufe;
    }

    public String getEnlaceQr() {
        return enlaceQr;
    }

    public LocalDateTime getFechaEmision() {
        return fechaEmision;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public BigDecimal getTotalDescuento() {
        return totalDescuento;
    }

    public BigDecimal getMontoImpuesto() {
        return montoImpuesto;
    }

    public BigDecimal getMontoTotal() {
        return montoTotal;
    }

    public void setIdFactura(Integer idFactura) {
        this.id = idFactura;
    }

    public void setIdVenta(Integer idVenta) {
        this.idVenta = idVenta;
    }

    public void setNumeroFactura(String numeroFactura) {
        this.numeroFactura = numeroFactura;
    }

    public void setCufe(String cufe) {
        this.cufe = cufe;
    }

    public void setEnlaceQr(String enlaceQr) {
        this.enlaceQr = enlaceQr;
    }

    public void setFechaEmision(LocalDateTime fechaEmision) {
        this.fechaEmision = fechaEmision;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public void setTotalDescuento(BigDecimal totalDescuento) {
        this.totalDescuento = totalDescuento;
    }

    public void setMontoImpuesto(BigDecimal montoImpuesto) {
        this.montoImpuesto = montoImpuesto;
    }

    public void setMontoTotal(BigDecimal montoTotal) {
        this.montoTotal = montoTotal;
    }
    
    @Override
    public String toString() {
        return String.format("[%d] %-20s | %s | %s | %s | %s | %s | %s | %s",
                id,
                idVenta,
                numeroFactura,
                cufe,
                (enlaceQr != null && !enlaceQr.isEmpty() ? enlaceQr : "No se aplico descuento"),
                fechaEmision,
                subtotal,
                totalDescuento,
                montoImpuesto,
                montoTotal);
    }    
}
