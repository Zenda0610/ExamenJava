
package com.mycompany.proyectojava.suppliers.model;

import java.time.LocalDateTime;


public class Supplier {
    
    private int id;
    private String nombre;
    private String nit;
    private String personaContacto;
    private String email;
    private String telefono;
    private String direccion;
    private boolean activo;
    private LocalDateTime fechaRegistro;

    public Supplier() {
    }
    
    

    public Supplier(int id, String nombre, String nit, String personaContacto, String email, String telefono, String direccion, boolean activo, LocalDateTime fechaRegistro) {
        this.id = id;
        this.nombre = nombre;
        this.nit = nit;
        this.personaContacto = personaContacto;
        this.email = email;
        this.telefono = telefono;
        this.direccion = direccion;
        this.activo = activo;
        this.fechaRegistro = fechaRegistro;
    }

    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getNit() {
        return nit;
    }

    public String getPersonaContacto() {
        return personaContacto;
    }

    public String getEmail() {
        return email;
    }

    public String getTelefono() {
        return telefono;
    }

    public String getDireccion() {
        return direccion;
    }

    public boolean isActivo() {
        return activo;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setNit(String nit) {
        this.nit = nit;
    }

    public void setPersonaContacto(String personaContacto) {
        this.personaContacto = personaContacto;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    
    @Override
    public String toString(){
        return String.format("[%d] %-20s | NIT: %s | Contacto: %s | Email: %s | Tel: %s | Dir: %s | Estado: %s | Registro: %s", 
                id,
                nombre,
                nit,
                (personaContacto != null && !personaContacto.isEmpty() ? personaContacto : "No hay nombre de persona contacto"),
                email,
                (telefono != null && !telefono.isEmpty() ? telefono : "No hay telefono de contacto"),
                (direccion != null && !direccion.isEmpty() ? direccion : "No hay direccion"),
                (activo ? "ACTIVO" : "NO ACTIVO"),
                (fechaRegistro != null ? fechaRegistro : "No hay direccion")
                
                
        );
    }
    
    
}
