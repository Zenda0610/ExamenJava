
package com.mycompany.proyectojava.logistics.model;

import java.time.LocalDateTime;

public class DeliveryRoute {
    
    private int id;
    private String nombreRuta;
    private LocalDateTime fechaCreacion;
    private String usuarioCreacion;
    private LocalDateTime horaSalidaEstimada;
    private LocalDateTime horaLlegadaEstimada;
    private LocalDateTime horaSalidaReal;
    private LocalDateTime horaLlegadaReal;
    private String estado;

    public DeliveryRoute(int id, String nombreRuta, LocalDateTime fechaCreacion, String usuarioCreacion, LocalDateTime horaSalidaEstimada, LocalDateTime horaLlegadaEstimada, LocalDateTime horaSalidaReal, LocalDateTime horaLlegadaReal, String estado) {
        this.id = id;
        this.nombreRuta = nombreRuta;
        this.fechaCreacion = fechaCreacion;
        this.usuarioCreacion = usuarioCreacion;
        this.horaSalidaEstimada = horaSalidaEstimada;
        this.horaLlegadaEstimada = horaLlegadaEstimada;
        this.horaSalidaReal = horaSalidaReal;
        this.horaLlegadaReal = horaLlegadaReal;
        this.estado = estado;
    }

    public int getId() {
        return id;
    }

    public String getNombreRuta() {
        return nombreRuta;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public String getUsuarioCreacion() {
        return usuarioCreacion;
    }

    public LocalDateTime getHoraSalidaEstimada() {
        return horaSalidaEstimada;
    }

    public LocalDateTime getHoraLlegadaEstimada() {
        return horaLlegadaEstimada;
    }

    public LocalDateTime getHoraSalidaReal() {
        return horaSalidaReal;
    }

    public LocalDateTime getHoraLlegadaReal() {
        return horaLlegadaReal;
    }

    public String getEstado() {
        return estado;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setNombreRuta(String nombreRuta) {
        this.nombreRuta = nombreRuta;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public void setUsuarioCreacion(String usuarioCreacion) {
        this.usuarioCreacion = usuarioCreacion;
    }

    public void setHoraSalidaEstimada(LocalDateTime horaSalidaEstimada) {
        this.horaSalidaEstimada = horaSalidaEstimada;
    }

    public void setHoraLlegadaEstimada(LocalDateTime horaLlegadaEstimada) {
        this.horaLlegadaEstimada = horaLlegadaEstimada;
    }

    public void setHoraSalidaReal(LocalDateTime horaSalidaReal) {
        this.horaSalidaReal = horaSalidaReal;
    }

    public void setHoraLlegadaReal(LocalDateTime horaLlegadaReal) {
        this.horaLlegadaReal = horaLlegadaReal;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    
        @Override
    public String toString(){
        return String.format("[%d] %-20s | Creación: %s | Creador: %s | Salida Est: %s | Llegada Est: %s | Salida Real: %s | Llegada Real: %s | Estado: %s", 
                id,
                nombreRuta,
                (fechaCreacion != null ? fechaCreacion : "No hay fecha de creacion"),
                (usuarioCreacion != null && !usuarioCreacion.isEmpty() ? usuarioCreacion : "No Hay Usuario de Creacion"),
                (horaSalidaEstimada != null ? horaSalidaEstimada : "No hay hora de salida estimada"),
                (horaLlegadaEstimada != null ? horaLlegadaEstimada : "No hay hora de llegada estimada"),
                (horaSalidaReal != null ? horaSalidaReal : "No hay hora de salida real"),
                (horaLlegadaReal != null ? horaLlegadaReal : "No hay hora de llegada estimada"),
                (estado != null && !estado.isEmpty() ? estado : "Planificada")
                
        );
    }
           
    
}
