
package com.mycompany.proyectojava.sales.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class promotion {
    private int id;
    private String nombre;
    private String descripcion;
    private BigDecimal tasaDescuento;
    private Integer estadoLote;
    private Integer categoria;
    private int activo;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;

    public promotion(
            int id,
            String nombre,
            String descripcion,
            BigDecimal tasaDescuento,
            Integer estadoLote,
            Integer categoria,
            int activo,
            LocalDateTime fechaInicio,
            LocalDateTime fechaFin) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.tasaDescuento = tasaDescuento;
        this.estadoLote = estadoLote;
        this.categoria = categoria;
        this.activo = activo;
        this.fechaInicio = fechaInicio;
        this.fechaFin = fechaFin;
    }

    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public BigDecimal getTasaDescuento() {
        return tasaDescuento;
    }

    public Integer getEstadoLote() {
        return estadoLote;
    }

    public Integer getCategoria() {
        return categoria;
    }

    public int getActivo() {
        return activo;
    }

    public LocalDateTime getFechaInicio() {
        return fechaInicio;
    }

    public LocalDateTime getFechaFin() {
        return fechaFin;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public void setTasaDescuento(BigDecimal tasaDescuento) {
        this.tasaDescuento = tasaDescuento;
    }

    public void setEstadoLote(Integer estadoLote) {
        this.estadoLote = estadoLote;
    }

    public void setCategoria(Integer categoria) {
        this.categoria = categoria;
    }

    public void setActivo(int activo) {
        this.activo = activo;
    }

    public void setFechaInicio(LocalDateTime fechaInicio) {
        this.fechaInicio = fechaInicio;
    }

    public void setFechaFin(LocalDateTime fechaFin) {
        this.fechaFin = fechaFin;
    }

    @Override
    public String toString() {
        return String.format(
                "[%d] %-20s | %s | %s | %s | %s | %s | %s | %s",
                id,
                nombre,
                (descripcion != null && !descripcion.isEmpty()? descripcion: "Sin descripción"),
                tasaDescuento,
                (estadoLote != null? estadoLote : "Sin especificación del estado del lote"),
                (categoria != null ? categoria : "Sin especificación de categoría aplicable"),
                activo == 1 ? "ACTIVO" : "NO ACTIVO",
                (fechaInicio != null ? fechaInicio : "Sin fecha de inicio"),
                (fechaFin != null ? fechaFin : "Sin fecha de fin"));
    }
}