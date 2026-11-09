
package com.mycompany.proyectojava.logistics.view;

import com.mycompany.proyectojava.common.Utils;
import com.mycompany.proyectojava.logistics.controller.LogisticsController;
import java.time.LocalDateTime;

public class LogisticsView {
    
    private final LogisticsController controller;

    public LogisticsView() {
        this.controller = new LogisticsController();
    }

    public void mostrarMenu() {
        int opcion = -1;

        do {
            Utils.imprimirTitulo("MÓDULO DE LOGÍSTICA Y DISTRIBUCIÓN - FRESCURA TOTAL");
            System.out.println("1. Planificar Nueva Ruta de Entrega");
            System.out.println("2. Asignar Vehículo y Conductor a Ruta");
            System.out.println("3. Registrar Salida Real (Despacho / En Tránsito)");
            System.out.println("4. Registrar Llegada Real (Completar Recorrido)");
            System.out.println("5. Listar Todas las Rutas Registradas");
            System.out.println("6. Ver Historial de Asignaciones");
            System.out.println("7. Ver Resumen Detallado de Despachos (Ruta + Vehículo + Conductor)");
            System.out.println("8. Ver pedidos pendientes de asignar");
            System.out.println("9. Vincular un pedido a una ruta");
            System.out.println("0. Volver al Menú Principal");
            
            opcion = Utils.leerEntero("Seleccione una opción: ");

            switch (opcion) {
                case 1:
                    menuCrearRuta();
                    break;
                case 2:
                    menuAsignarDespacho();
                    break;
                case 3:
                    menuIniciarRecorrido();
                    break;
                case 4:
                    menuFinalizarRecorrido();
                    break;
                case 5:
                    controller.mostrarTodasLasRutas();
                    Utils.pausa();
                    break;
                case 6:
                    controller.mostrarAsignaciones();
                    Utils.pausa();
                    break;
                case 7:
                    controller.mostrarResumenCompletoDespachos();
                    Utils.pausa();
                    break;
                case 8:
                    controller.mostrarPedidosPendientes();
                    Utils.pausa();
                    break;
                case 9:
                    menuVincularPedido();
                    break;
                case 0:
                    System.out.println("Saliendo del Módulo de Logística...");
                    break;
                default:
                    System.out.println("[Atención] Opción no válida. Intente de nuevo.");
            }
        } while (opcion != 0);
    }

    private void menuVincularPedido() {
        int idRuta = Utils.leerEntero("ID de la ruta: ");
        int idVenta = Utils.leerEntero("ID de la venta: ");
        int orden = Utils.leerEntero("Orden de entrega: ");
        String direccion = Utils.leerPalabra("Dirección de entrega: ");
        controller.vincularPedido(idRuta, idVenta, orden, direccion);
        Utils.pausa();
    }

    // =========================================================================
    // SUBMENÚS Y GESTIÓN DE ENTRADAS CON Utils.java
    // =========================================================================

    private void menuCrearRuta() {
        Utils.imprimirTitulo("Planificar Nueva Ruta de Entrega");
        
        String nombreRuta = Utils.leerPalabra("Nombre o código de la ruta (ej. RUTA-NORTE-01): ");
        String usuarioCreacion = Utils.leerPalabra("Usuario que registra la planificación: ");
        
        System.out.println("\n--- Hora de Salida Estimada ---");
        LocalDateTime salidaEst = Utils.leerFecha("Fecha de salida").atTime(8, 0); // O puedes pedir hora si lo deseas
        
        System.out.println("\n--- Hora de Llegada Estimada ---");
        LocalDateTime llegadaEst = Utils.leerFecha("Fecha de llegada").atTime(17, 0);

        controller.crearNuevaRuta(nombreRuta, usuarioCreacion, salidaEst, llegadaEst);
        Utils.pausa();
    }

    private void menuAsignarDespacho() {
        Utils.imprimirTitulo("Asignar Vehículo y Conductor a Ruta");
        
        int idRuta = Utils.leerEntero("ID de la Ruta a despachar: ");
        int idVehiculo = Utils.leerEntero("ID del Vehículo (camión/furgón): ");
        int idConductor = Utils.leerEntero("ID del Conductor asignado: ");
        String usuarioAsignacion = Utils.leerPalabra("Usuario que realiza la asignación: ");
        String notas = Utils.leerPalabraOpcional("Notas u observaciones de carga (opcional): ");

        controller.asignarDespacho(idRuta, idVehiculo, idConductor, usuarioAsignacion, notas);
        Utils.pausa();
    }

    private void menuIniciarRecorrido() {
        Utils.imprimirTitulo("Registrar Salida Real (Despacho desde Bodega)");
        
        int idRuta = Utils.leerEntero("ID de la Ruta que sale: ");
        controller.iniciarRecorridoRuta(idRuta);
        
        Utils.pausa();
    }

    private void menuFinalizarRecorrido() {
        Utils.imprimirTitulo("Registrar Llegada Real (Finalizar Entrega)");
        
        int idRuta = Utils.leerEntero("ID de la Ruta que ha retornado/completado: ");
        controller.finalizarRecorridoRuta(idRuta);
        
        Utils.pausa();
    }
    
}
