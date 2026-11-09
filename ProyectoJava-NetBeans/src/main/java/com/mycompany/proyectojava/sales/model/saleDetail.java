
package com.mycompany.proyectojava.sales.model;

import java.math.BigDecimal;


public class saleDetail {
    private int id;
    private int idVenta;
    private int idLote;
    private BigDecimal cantidadVendida;
    private BigDecimal precioUnitario;
    private BigDecimal descuentAplicado;
    private BigDecimal montoDescuento;
    private BigDecimal tasaImpuesto;
    private BigDecimal montoImpuesto;
    private BigDecimal subTotal;
    private BigDecimal totalLinea;

    public saleDetail(int id, int idVenta, int idLote, BigDecimal cantidadVendida, BigDecimal precioUnitario, BigDecimal descuentAplicado, BigDecimal montoDescuento, BigDecimal tasaImpuesto, BigDecimal montoImpuesto, BigDecimal subTotal, BigDecimal totalLinea) {
        this.id = id;
        this.idVenta = idVenta;
        this.idLote = idLote;
        this.cantidadVendida = cantidadVendida;
        this.precioUnitario = precioUnitario;
        this.descuentAplicado = descuentAplicado;
        this.montoDescuento = montoDescuento;
        this.tasaImpuesto = tasaImpuesto;
        this.montoImpuesto = montoImpuesto;
        this.subTotal = subTotal;
        this.totalLinea = totalLinea;
    }

    public int getId() {
        return id;
    }

    public int idVenta() {
        return idVenta;
    }

    public int getIdLote() {
        return idLote;
    }


    public BigDecimal getCantidadVendida() {
        return cantidadVendida;
    }

    public BigDecimal getPrecioUnitario() {
        return precioUnitario;
    }

    public BigDecimal getDescuentAplicado() {
        return descuentAplicado;
    }

    public BigDecimal getMontoDescuento() {
        return montoDescuento;
    }

    public BigDecimal getTasaImpuesto() {
        return tasaImpuesto;
    }

    public BigDecimal getMontoImpuesto() {
        return montoImpuesto;
    }

    public BigDecimal getSubTotal() {
        return subTotal;
    }

    public BigDecimal getTotalLinea() {
        return totalLinea;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void idVenta(int idVenta) {
        this.idVenta = idVenta;
    }

    public void setIdLote(int idLote) {
        this.idLote = idLote;
    }


    public void setCantidadVendida(BigDecimal cantidadVendida) {
        this.cantidadVendida = cantidadVendida;
    }

    public void setPrecioUnitario(BigDecimal precioUnitario) {
        this.precioUnitario = precioUnitario;
    }

    public void setDescuentAplicado(BigDecimal descuentAplicado) {
        this.descuentAplicado = descuentAplicado;
    }

    public void setMontoDescuento(BigDecimal montoDescuento) {
        this.montoDescuento = montoDescuento;
    }

    public void setTasaImpuesto(BigDecimal tasaImpuesto) {
        this.tasaImpuesto = tasaImpuesto;
    }

    public void setMontoImpuesto(BigDecimal montoImpuesto) {
        this.montoImpuesto = montoImpuesto;
    }

    public void setSubTotal(BigDecimal subTotal) {
        this.subTotal = subTotal;
    }

    public void setTotalLinea(BigDecimal totalLinea) {
        this.totalLinea = totalLinea;
    }

    @Override
    public String toString() {
        return String.format("[%d] %-20s | %s | %s | %s | %s | %s | %s | %s",
                id,
                idVenta,
                idLote,
                cantidadVendida,
                precioUnitario,
                (descuentAplicado != null ? descuentAplicado : "No se aplico descuento"),
                (montoDescuento != null ? montoDescuento : "No se aplico descuento"),
                (tasaImpuesto != null ? tasaImpuesto : "No se aplico impuesto"),
                (montoImpuesto != null ? montoImpuesto : "No se aplico impuesto"),
                subTotal,
                totalLinea);
    }    
}
