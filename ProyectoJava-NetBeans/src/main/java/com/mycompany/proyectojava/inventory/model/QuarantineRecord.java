
package com.mycompany.proyectojava.inventory.model;

import java.time.LocalDateTime;

public class QuarantineRecord {
    
    private int id;
    private int idLote;
    private String motivo;
    private String usuario;
    private LocalDateTime fechaRegistro;
    private boolean resuelta;
    private LocalDateTime fechaResolucion;
    private String notasResolucion;

    public QuarantineRecord() {
    }
    
    

    public QuarantineRecord(int id, int idLote, String motivo, String usuario, LocalDateTime fechaRegistro, boolean resuelta, LocalDateTime fechaResolucion, String notasResolucion) {
        this.id = id;
        this.idLote = idLote;
        this.motivo = motivo;
        this.usuario = usuario;
        this.fechaRegistro = fechaRegistro;
        this.resuelta = resuelta;
        this.fechaResolucion = fechaResolucion;
        this.notasResolucion = notasResolucion;
    }

    
    
    public int getId() {
        return id;
    }

    public int getIdLote() {
        return idLote;
    }

    public String getMotivo() {
        return motivo;
    }

    public String getUsuario() {
        return usuario;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public boolean isResuelta() {
        return resuelta;
    }

    public LocalDateTime getFechaResolucion() {
        return fechaResolucion;
    }

    public String getNotasResolucion() {
        return notasResolucion;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setIdLote(int idLote) {
        this.idLote = idLote;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public void setResuelta(boolean resuelta) {
        this.resuelta = resuelta;
    }

    public void setFechaResolucion(LocalDateTime fechaResolucion) {
        this.fechaResolucion = fechaResolucion;
    }

    public void setNotasResolucion(String notasResolucion) {
        this.notasResolucion = notasResolucion;
    }
    
        @Override
    public String toString(){
        return String.format("[%d] %-20s | %s", 
                id,
                idLote,
                motivo,
                usuario,
                fechaRegistro,
                (resuelta ? "RESUELTA" : "EN CUARENTENA"),
                (resuelta ? fechaResolucion : "No esta resuelto"),
                (resuelta ? notasResolucion : "No esta resuelto"));
               

    }
    
}
