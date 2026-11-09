
package com.mycompany.proyectojava.inventory.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;


public class lot {
    
    private int id;
    private String numeroLote;
    private int idProducto;
    private int idProveedor;
    private LocalDateTime fechaIngreso;
    private LocalDateTime fechaVencimiento;
    private BigDecimal cantidadInicial;
    private BigDecimal cantidad;
    private BigDecimal precioCompra;
    private BigDecimal precioVenta;
    private String pasillo;
    private String estante;
    private int idEstado;

    public lot(int id, String numeroLote, int idProducto, int idProveedor, LocalDateTime fechaIngreso, LocalDateTime fechaVencimiento, BigDecimal cantidadInicial, BigDecimal cantidad, BigDecimal precioCompra, BigDecimal precioVenta, String pasillo, String estante, int idEstado) {
        this.id = id;
        this.numeroLote = numeroLote;
        this.idProducto = idProducto;
        this.idProveedor = idProveedor;
        this.fechaIngreso = fechaIngreso;
        this.fechaVencimiento = fechaVencimiento;
        this.cantidadInicial = cantidadInicial;
        this.cantidad = cantidad;
        this.precioCompra = precioCompra;
        this.precioVenta = precioVenta;
        this.pasillo = pasillo;
        this.estante = estante;
        this.idEstado = idEstado;
    }

    public int getId() {
        return id;
    }

    public String getNumeroLote() {
        return numeroLote;
    }

    public int getIdProducto() {
        return idProducto;
    }

    public int getIdProveedor() {
        return idProveedor;
    }

    public LocalDateTime getFechaIngreso() {
        return fechaIngreso;
    }

    public LocalDateTime getFechaVencimiento() {
        return fechaVencimiento;
    }

    public BigDecimal getCantidadInicial() {
        return cantidadInicial;
    }

    public BigDecimal getCantidad() {
        return cantidad;
    }

    public BigDecimal getPrecioCompra() {
        return precioCompra;
    }

    public BigDecimal getPrecioVenta() {
        return precioVenta;
    }

    public String getPasillo() {
        return pasillo;
    }

    public String getEstante() {
        return estante;
    }

    public int getIdEstado() {
        return idEstado;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setNumeroLote(String numeroLote) {
        this.numeroLote = numeroLote;
    }

    public void setIdProducto(int idProducto) {
        this.idProducto = idProducto;
    }

    public void setIdProveedor(int idProveedor) {
        this.idProveedor = idProveedor;
    }

    public void setFechaIngreso(LocalDateTime fechaIngreso) {
        this.fechaIngreso = fechaIngreso;
    }

    public void setFechaVencimiento(LocalDateTime fechaVencimiento) {
        this.fechaVencimiento = fechaVencimiento;
    }

    public void setCantidadInicial(BigDecimal cantidadInicial) {
        this.cantidadInicial = cantidadInicial;
    }

    public void setCantidad(BigDecimal cantidad) {
        this.cantidad = cantidad;
    }

    public void setPrecioCompra(BigDecimal precioCompra) {
        this.precioCompra = precioCompra;
    }

    public void setPrecioVenta(BigDecimal precioVenta) {
        this.precioVenta = precioVenta;
    }

    public void setPasillo(String pasillo) {
        this.pasillo = pasillo;
    }

    public void setEstante(String estante) {
        this.estante = estante;
    }

    public void setIdEstado(int idEstado) {
        this.idEstado = idEstado;
    }
    @Override
    public String toString(){
        return String.format("[%d] %-20s | Producto: %d | Proveedor: %d | Ingreso: %s | Vence: %s | Cantidad inicial: %s | Stock: %s | Compra: %s | Venta: %s | Pasillo: %s | Estante: %s | Estado: %d",
                id,
                numeroLote,
                idProducto,
                idProveedor,
                fechaIngreso,
                fechaVencimiento,
                cantidadInicial,
                cantidad,
                precioCompra,
                precioVenta,
                (pasillo != null && !pasillo.isEmpty() ? pasillo : "No hay pasillo"),
                (estante != null && !estante.isEmpty() ? estante : "No hay estante"),
                idEstado);
    }
}

