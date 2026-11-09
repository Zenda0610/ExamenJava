
package com.mycompany.proyectojava.inventory.model;

import java.time.LocalDateTime;

public class QualityInspection {
    
    private int id;
    private int idLote;
    private LocalDateTime fechaInspeccion;
    private boolean resultado;
    private String nombreInspector;
    private String motivoRechazo;
    private String notas;

    public QualityInspection(int id, int idLote, LocalDateTime fechaInspeccion, boolean resultado, String nombreInspector, String motivoRechazo, String notas) {
        this.id = id;
        this.idLote = idLote;
        this.fechaInspeccion = fechaInspeccion;
        this.resultado = resultado;
        this.nombreInspector = nombreInspector;
        this.motivoRechazo = motivoRechazo;
        this.notas = notas;
    }

    public int getId() {
        return id;
    }

    public int getIdLote() {
        return idLote;
    }

    public LocalDateTime getFechaInspeccion() {
        return fechaInspeccion;
    }

    public boolean isResultado() {
        return resultado;
    }

    public String getNombreInspector() {
        return nombreInspector;
    }

    public String getMotivoRechazo() {
        return motivoRechazo;
    }

    public String getNotas() {
        return notas;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setIdLote(int idLote) {
        this.idLote = idLote;
    }

    public void setFechaInspeccion(LocalDateTime fechaInspeccion) {
        this.fechaInspeccion = fechaInspeccion;
    }

    public void setResultado(boolean resultado) {
        this.resultado = resultado;
    }

    public void setNombreInspector(String nombreInspector) {
        this.nombreInspector = nombreInspector;
    }

    public void setMotivoRechazo(String motivoRechazo) {
        this.motivoRechazo = motivoRechazo;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }
    
    
    @Override
    public String toString(){
        return String.format("[%d] %-20s | %s", 
                id,
                idLote,
                fechaInspeccion,
                (resultado ? "APROBADO" : "RECHAZADO"),
                nombreInspector,
                (resultado ? "Ya fue aprobado" : motivoRechazo  ),
                (notas != null && !notas.isEmpty() ? notas : "Sin notas"));
                         

    }
    
}
