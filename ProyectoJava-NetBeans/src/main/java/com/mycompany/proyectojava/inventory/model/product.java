
package com.mycompany.proyectojava.inventory.model;

import java.math.BigDecimal;


public class product {
    
    private int id;
    private String nombre;
    private String descripcion;
    private int idCategoria;
    private String unidadMedida;
    private BigDecimal precioBase;
    
    
    public product() {
    }
    
    
    public product(int id, String nombre, String descripcion, int idCategoria, String unidadMedida, BigDecimal precioBase) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.idCategoria = idCategoria;
        this.unidadMedida = unidadMedida;
        this.precioBase = precioBase;
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

    public int getIdCategoria() {
        return idCategoria;
    }

    public String getUnidadMedida() {
        return unidadMedida;
    }

    public BigDecimal getPrecioBase() {
        return precioBase;
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

    public void setIdCategoria(int idCategoria) {
        this.idCategoria = idCategoria;
    }

    public void setUnidadMedida(String unidadMedida) {
        this.unidadMedida = unidadMedida;
    }

    public void setPrecioBase(BigDecimal precioBase) {
        this.precioBase = precioBase;
    }
            
    @Override
    public String toString(){
        return String.format("[%d] %-20s | %s", 
                id,
                nombre,
                (descripcion != null && !descripcion.isEmpty() ? descripcion : "Sin descripcion"),
                idCategoria,
                unidadMedida,
                precioBase);
    }
}
