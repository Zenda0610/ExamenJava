
package com.mycompany.proyectojava.logistics.model;


public class Driver {
    
    private int id;
    private String nombre;
    private String numeroLicencia;
    private String telefono;
    private String email;
    private boolean activo;

    public Driver(int id, String nombre, String numeroLicencia, String telefono, String email, boolean activo) {
        this.id = id;
        this.nombre = nombre;
        this.numeroLicencia = numeroLicencia;
        this.telefono = telefono;
        this.email = email;
        this.activo = activo;
    }

    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getNumeroLicencia() {
        return numeroLicencia;
    }

    public String getTelefono() {
        return telefono;
    }

    public String getEmail() {
        return email;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setNumeroLicencia(String numeroLicencia) {
        this.numeroLicencia = numeroLicencia;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }
    
    @Override
    public String toString(){
        return String.format("[%d] %-20s | Licencia: %s | Tel: %s | Email: %s | Estado: %s",
                id,
                nombre,
                numeroLicencia,
                (telefono != null && !telefono.isEmpty() ? telefono : "No hay telefono de contacto"),
                (email != null && !email.isEmpty() ? email : "No hay email de contacto"),
                (activo ? "ACTIVO" : "NO ACTIVO")      
                
        );
    }
    
}
