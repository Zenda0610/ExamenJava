
package com.mycompany.proyectojava.logistics.model;

import java.time.LocalDateTime;

public class DeliveryAssignment {
    
    private int id;
    private int idRuta;
    private int idVehiculo;
    private int idConductor;
    private LocalDateTime fechaAsignacion;
    private String usuarioAsignacion;
    private String notas;

    public DeliveryAssignment(int id, int idRuta, int idVehiculo, int idConductor, LocalDateTime fechaAsignacion, String usuarioAsignacion, String notas) {
        this.id = id;
        this.idRuta = idRuta;
        this.idVehiculo = idVehiculo;
        this.idConductor = idConductor;
        this.fechaAsignacion = fechaAsignacion;
        this.usuarioAsignacion = usuarioAsignacion;
        this.notas = notas;
    }

    public int getId() {
        return id;
    }

    public int getIdRuta() {
        return idRuta;
    }

    public int getIdVehiculo() {
        return idVehiculo;
    }

    public int getIdConductor() {
        return idConductor;
    }

    public LocalDateTime getFechaAsignacion() {
        return fechaAsignacion;
    }

    public String getUsuarioAsignacion() {
        return usuarioAsignacion;
    }

    public String getNotas() {
        return notas;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setIdRuta(int idRuta) {
        this.idRuta = idRuta;
    }

    public void setIdVehiculo(int idVehiculo) {
        this.idVehiculo = idVehiculo;
    }

    public void setIdConductor(int idConductor) {
        this.idConductor = idConductor;
    }

    public void setFechaAsignacion(LocalDateTime fechaAsignacion) {
        this.fechaAsignacion = fechaAsignacion;
    }

    public void setUsuarioAsignacion(String usuarioAsignacion) {
        this.usuarioAsignacion = usuarioAsignacion;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }
    
    @Override
    public String toString(){
        return String.format("[%d] Ruta ID: %d | Vehículo ID: %d | Conductor ID: %d | Fecha Asig: %s | Usuario: %s | Notas: %s", 
                id,
                idRuta,
                idVehiculo,
                idConductor,
                (fechaAsignacion != null ? fechaAsignacion : "No hay fecha asignada"),
                (usuarioAsignacion != null && !usuarioAsignacion.isEmpty() ? usuarioAsignacion : "No hay usuario asignado"),
                (notas != null && !notas.isEmpty() ? notas : "No hay usuario asignado")
        );
    }
    
    
}
