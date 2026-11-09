
package com.mycompany.proyectojava.inventory.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class merma {
    
    private int id;
    private int idLote;
    private int idInspeccion;
    private BigDecimal cantidadPerdida;
    private String motivo;
    private LocalDateTime fechaRegistro;
    private String usuarioRegistro;

    public merma(int id, int idLote, int idInspeccion, BigDecimal cantidadPerdida, String motivo, LocalDateTime fechaRegistro, String usuarioRegistro) {
        this.id = id;
        this.idLote = idLote;
        this.idInspeccion = idInspeccion;
        this.cantidadPerdida = cantidadPerdida;
        this.motivo = motivo;
        this.fechaRegistro = fechaRegistro;
        this.usuarioRegistro = usuarioRegistro;
    }

    public int getId() {
        return id;
    }

    public int getIdLote() {
        return idLote;
    }

    public int getIdInspeccion() {
        return idInspeccion;
    }

    public BigDecimal getCantidadPerdida() {
        return cantidadPerdida;
    }

    public String getMotivo() {
        return motivo;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public String getUsuarioRegistro() {
        return usuarioRegistro;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setIdLote(int idLote) {
        this.idLote = idLote;
    }

    public void setIdInspeccion(int idInspeccion) {
        this.idInspeccion = idInspeccion;
    }

    public void setCantidadPerdida(BigDecimal cantidadPerdida) {
        this.cantidadPerdida = cantidadPerdida;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public void setUsuarioRegistro(String usuarioRegistro) {
        this.usuarioRegistro = usuarioRegistro;
    }
    
    
       @Override
    public String toString(){
        return String.format("[%d] %-20s | %s", 
                id,
                idLote,
                idInspeccion,
                cantidadPerdida,
                motivo,
                fechaRegistro,
                (usuarioRegistro != null && !usuarioRegistro.isEmpty() ? usuarioRegistro : "Sin usuario"));
                         

    }         
    
    
}
