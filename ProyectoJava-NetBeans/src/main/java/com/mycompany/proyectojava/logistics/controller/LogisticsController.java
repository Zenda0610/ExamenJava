
package com.mycompany.proyectojava.logistics.controller;

import com.mycompany.proyectojava.logistics.model.DeliveryAssignment;
import com.mycompany.proyectojava.logistics.model.DeliveryRoute;
import com.mycompany.proyectojava.logistics.model.LogisticsDAO;

import java.time.LocalDateTime;
import java.util.List;

public class LogisticsController {
    
    
    private LogisticsDAO logisticsDAO;

    public LogisticsController() {
        this.logisticsDAO = new LogisticsDAO();
    }

    public void mostrarPedidosPendientes() {
        List<String> pedidos = logisticsDAO.listarPedidosPendientes();
        if (pedidos.isEmpty()) {
            System.out.println("No hay pedidos pendientes de asignar.");
        } else {
            pedidos.forEach(System.out::println);
        }
    }

    public void vincularPedido(int idRuta, int idVenta, int orden, String direccion) {
        if (logisticsDAO.vincularPedido(idRuta, idVenta, orden, direccion)) {
            System.out.println("Pedido vinculado a la ruta.");
        } else {
            System.out.println("Compruebe que la ruta esté planificada y que el pedido esté en preparación y sin ruta.");
        }
    }

    // =========================================================================
    // 1. PLANIFICAR UNA NUEVA RUTA DE ENTREGA
    // =========================================================================
    public boolean crearNuevaRuta(String nombreRuta, String usuarioCreacion, 
                                  LocalDateTime horaSalidaEstimada, LocalDateTime horaLlegadaEstimada) {
        
        // Validación básica: la llegada estimada no puede ser anterior a la salida estimada
        if (horaSalidaEstimada != null && horaLlegadaEstimada != null 
                && horaLlegadaEstimada.isBefore(horaSalidaEstimada)) {
            System.out.println("La hora de llegada estimada no puede ser anterior a la hora de salida.");
            return false;
        }

        DeliveryRoute nuevaRuta = new DeliveryRoute(
                0, // ID autogenerado en BD
                nombreRuta,
                LocalDateTime.now(),
                usuarioCreacion,
                horaSalidaEstimada,
                horaLlegadaEstimada,
                null, // Hora de salida real (se llena al despachar)
                null, // Hora de llegada real (se llena al finalizar)
                "Planificada"
        );

        int idGenerado = logisticsDAO.registrarRuta(nuevaRuta);
        if (idGenerado > 0) {
            System.out.println(" Ruta '" + nombreRuta + "' planificada correctamente con ID: " + idGenerado);
            return true;
        } else {
            System.out.println(" No se pudo registrar la ruta de entrega.");
            return false;
        }
    }

    // =========================================================================
    // 2. ASIGNAR VEHÍCULO Y CONDUCTOR A UNA RUTA
    // =========================================================================
    public boolean asignarDespacho(int idRuta, int idVehiculo, int idConductor, 
                                   String usuarioAsignacion, String notas) {
        
        DeliveryAssignment nuevaAsignacion = new DeliveryAssignment(
                0, // ID autogenerado en BD
                idRuta,
                idVehiculo,
                idConductor,
                LocalDateTime.now(),
                usuarioAsignacion,
                notas
        );

        int idAsignacion = logisticsDAO.registrarAsignacion(nuevaAsignacion);
        if (idAsignacion > 0) {
            System.out.println(" Asignación registrada con ID: " + idAsignacion 
                    + " (Ruta ID: " + idRuta + " | Vehículo ID: " + idVehiculo + " | Conductor ID: " + idConductor + ")");
            return true;
        } else {
            System.out.println(" No se pudo asignar el vehículo y conductor a la ruta.");
            return false;
        }
    }

    // =========================================================================
    // 3. CONTROL DE TIEMPOS REALES (Despacho y Finalización)
    // =========================================================================

    // Cuando el camión sale de la bodega (Estado pasa a EN_RUTA)
    public boolean iniciarRecorridoRuta(int idRuta) {
        LocalDateTime ahora = LocalDateTime.now();
        boolean exito = logisticsDAO.registrarSalidaRealRuta(idRuta, ahora);
        if (exito) {
            System.out.println("Salida registrada para la Ruta ID " + idRuta + " a las " + ahora + ". Estado: En Transito.");
        } else {
            System.out.println(" No se pudo registrar la salida de la Ruta ID " + idRuta);
        }
        return exito;
    }

    // Cuando el camión termina las entregas (Estado pasa a COMPLETADA)
    public boolean finalizarRecorridoRuta(int idRuta) {
        LocalDateTime ahora = LocalDateTime.now();
        boolean exito = logisticsDAO.registrarLlegadaRealRuta(idRuta, ahora);
        if (exito) {
            System.out.println(" Llegada registrada para la Ruta ID " + idRuta + " a las " + ahora + ". Estado: Completada.");
        } else {
            System.out.println(" No se pudo registrar la llegada de la Ruta ID " + idRuta);
        }
        return exito;
    }

    // =========================================================================
    // 4. CONSULTAS Y REPORTES EN CONSOLA
    // =========================================================================

    // Muestra todas las rutas usando el toString() de DeliveryRoute
    public void mostrarTodasLasRutas() {
        List<DeliveryRoute> rutas = logisticsDAO.listarTodasLasRutas();
        if (rutas.isEmpty()) {
            System.out.println("No hay rutas de entrega registradas en el sistema.");
        } else {
            System.out.println("=== LISTADO DE RUTAS DE ENTREGA ===");
            for (DeliveryRoute ruta : rutas) {
                System.out.println(ruta.toString());
            }
        }
    }

    // Muestra todas las asignaciones usando el toString() de DeliveryAssignment
    public void mostrarAsignaciones() {
        List<DeliveryAssignment> asignaciones = logisticsDAO.listarAsignaciones();
        if (asignaciones.isEmpty()) {
            System.out.println("No hay asignaciones de vehículos y conductores registradas.");
        } else {
            System.out.println("=== HISTORIAL DE ASIGNACIONES (IDs) ===");
            for (DeliveryAssignment asig : asignaciones) {
                System.out.println(asig.toString());
            }
        }
    }

    // Muestra el reporte completo uniendo Ruta + Placa de Vehículo + Nombre de Conductor
    public void mostrarResumenCompletoDespachos() {
        List<String> resumen = logisticsDAO.obtenerResumenDespachos();
        if (resumen.isEmpty()) {
            System.out.println("No hay despachos detallados para mostrar.");
        } else {
            System.out.println("=== RESUMEN DETALLADO DE DESPACHOS (RUTA + VEHÍCULO + CONDUCTOR) ===");
            for (String linea : resumen) {
                System.out.println(linea);
            }
        }
    }
    
}
