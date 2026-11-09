
package com.mycompany.proyectojava.logistics.model;

import java.math.BigDecimal;


public class Vehicle {
    
    private int id;
    private String placa;
    private String modelo;
    private BigDecimal capacidad;
    private String estado;

    public Vehicle(int id, String placa, String modelo, BigDecimal capacidad, String estado) {
        this.id = id;
        this.placa = placa;
        this.modelo = modelo;
        this.capacidad = capacidad;
        this.estado = estado;
    }

    public int getId() {
        return id;
    }

    public String getPlaca() {
        return placa;
    }

    public String getModelo() {
        return modelo;
    }

    public BigDecimal getCapacidad() {
        return capacidad;
    }

    public String isEstado() {
        return estado;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public void setCapacidad(BigDecimal capacidad) {
        this.capacidad = capacidad;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    @Override
    public String toString(){
        return String.format("[%d] %-20s | Modelo: %s | Capacidad: %s | Estado: %s",
                id,
                placa,
                (modelo != null && !modelo.isEmpty() ? modelo : "No hay modelo"),
                (capacidad != null ? capacidad : "No especifica la capacidad"),
                (estado != null && !estado.isEmpty() ? estado : "ACTIVO")     
                
        );
    }
    
}
