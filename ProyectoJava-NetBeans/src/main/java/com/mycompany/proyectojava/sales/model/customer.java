
package com.mycompany.proyectojava.sales.model;
 
import java.time.LocalDateTime;


public class customer {
    private int id;
    private String nombre;
    private  String documento;
    private String email;
    private String numero;
    private String direccion;
    private int idTipo;
    private LocalDateTime fechaRegistro;

    public customer(int id, String nombre, String documento, String email, String numero, String direccion, int idTipo, LocalDateTime fechaRegistro) {
        this.id = id;
        this.nombre = nombre;
        this.documento = documento;
        this.email = email;
        this.numero = numero;
        this.direccion = direccion;
        this.idTipo = idTipo;
        this.fechaRegistro = fechaRegistro;
    }

    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getDocumento() {
        return documento;
    }

    public String getEmail() {
        return email;
    }

    public String getNumero() {
        return numero;
    }

    public String getDireccion() {
        return direccion;
    }

    public int getIdTipo() {
        return idTipo;
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

    public void setDocumento(String documento) {
        this.documento = documento;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public void setIdTipo(int idTipo) {
        this.idTipo = idTipo;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    
    @Override
    public String toString(){
        return String.format("[%d] %-20s | Doc: %s | Email: %s | Tel: %s | Dir: %s | Tipo: %d | Registro: %s", 
                id,
                nombre,
                documento,
                (email != null && !email.isEmpty() ? email : "No hay email registrado"),
                (numero != null  ? numero : "No hay numero registrado"),
                (direccion != null && !direccion.isEmpty() ? direccion : "No hay direccion registrada"),
                idTipo,
                (fechaRegistro != null  ? fechaRegistro : "No hay fecha de registro"));
    }
}
