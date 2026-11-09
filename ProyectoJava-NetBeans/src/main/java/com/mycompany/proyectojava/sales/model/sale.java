
package com.mycompany.proyectojava.sales.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class sale {
    private int id;
    private String numeroVenta;
    private int idCliente;
    private LocalDateTime fechaVenta;
    private BigDecimal subTotal;
    private BigDecimal totalDescuento;
    private BigDecimal totalImpuesto;
    private BigDecimal montoTotal;
    private int idEstado;
    private String usuarioRegistro;

    public sale(int id, String numeroVenta, int idCliente, LocalDateTime fechaVenta, BigDecimal subTotal, BigDecimal totalDescuento, BigDecimal totalImpuesto, BigDecimal montoTotal, int idEstado, String usuarioRegistro) {
        this.id = id;
        this.numeroVenta = numeroVenta;
        this.idCliente = idCliente;
        this.fechaVenta = fechaVenta;
        this.subTotal = subTotal;
        this.totalDescuento = totalDescuento;
        this.totalImpuesto = totalImpuesto;
        this.montoTotal = montoTotal;
        this.idEstado = idEstado;
        this.usuarioRegistro = usuarioRegistro;
    }

    public int getId() {
        return id;
    }

    public String getNumeroVenta() {
        return numeroVenta;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public LocalDateTime getFechaVenta() {
        return fechaVenta;
    }

    public BigDecimal getSubTotal() {
        return subTotal;
    }

    public BigDecimal getTotalDescuento() {
        return totalDescuento;
    }

    public BigDecimal getTotalImpuesto() {
        return totalImpuesto;
    }

    public BigDecimal getMontoTotal() {
        return montoTotal;
    }

    public int getIdEstado() {
        return idEstado;
    }

    public String getUsuarioRegistro() {
        return usuarioRegistro;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setNumeroVenta(String numeroVenta) {
        this.numeroVenta = numeroVenta;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    public void setFechaVenta(LocalDateTime fechaVenta) {
        this.fechaVenta = fechaVenta;
    }

    public void setSubTotal(BigDecimal subTotal) {
        this.subTotal = subTotal;
    }

    public void setTotalDescuento(BigDecimal totalDescuento) {
        this.totalDescuento = totalDescuento;
    }

    public void setTotalImpuesto(BigDecimal totalImpuesto) {
        this.totalImpuesto = totalImpuesto;
    }

    public void setMontoTotal(BigDecimal montoTotal) {
        this.montoTotal = montoTotal;
    }

    public void setIdEstado(int idEstado) {
        this.idEstado = idEstado;
    }

    public void setUsuarioRegistro(String usuarioRegistro) {
        this.usuarioRegistro = usuarioRegistro;
    }
    
    @Override
    public String toString() {
        return String.format(
                "[%d] %-20s | %s | %s | %s | %s | %s | %s | %s",
                id,
                numeroVenta,
                idCliente,
                fechaVenta,
                subTotal,
                totalDescuento,
                totalImpuesto,
                montoTotal,
                idEstado,
                (usuarioRegistro != null && !usuarioRegistro.isEmpty()? usuarioRegistro: "Sin descripción"));
    }
}
