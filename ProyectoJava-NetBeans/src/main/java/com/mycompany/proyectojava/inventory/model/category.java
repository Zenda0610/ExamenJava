
package com.mycompany.proyectojava.inventory.model;


public class category {
    
    private int id;
    private String nombre;
    private String descripcion;

    public category(int id, String nombre, String descripcion) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
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

    public void setId(int id) {
        this.id = id;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    @Override
    public String toString(){
        return String.format("[%d] %-20s | %s", 
                id,
                nombre,
                (descripcion != null && !descripcion.isEmpty() ? descripcion : "Sin descripcion"));
    }
    
    
    
}
