
package com.mycompany.proyectojava.inventory.view;

import com.mycompany.proyectojava.inventory.controller.InventoryController;
import com.mycompany.proyectojava.inventory.controller.InspectorAccess;
import com.mycompany.proyectojava.inventory.model.lot;
import com.mycompany.proyectojava.common.Utils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Arrays;

public class InventoryView {
    
    
   private final InventoryController controller;

    public InventoryView() {
        this.controller = new InventoryController();
    }

    public void mostrarMenu() {
        int opcion = -1;

        do {
            Utils.imprimirTitulo("MÓDULO DE INVENTARIOS Y CALIDAD - FRESCURA TOTAL");
            System.out.println("1. Registrar Nuevo Producto en Catálogo");
            System.out.println("2. Recepción de Mercancía (Registrar Lote)");
            System.out.println("3. Listar Todos los Lotes en Bodega (Orden FEFO)");
            System.out.println("4. Ejecutar Revisión Diaria de Vencimientos (Alertas)");
            System.out.println("5. Trazabilidad: Buscar Lotes por Ubicación (Pasillo/Estante)");
            System.out.println("6. Trazabilidad: Buscar Clientes Afectados por Lote");
            System.out.println("7. Trazabilidad: Consultar Detalle por Código de Lote");
            System.out.println("8. Enviar Lote a Cuarentena (Bloquear venta)");
            System.out.println("9. Inspeccionar Lote en Cuarentena (Aprobar / Rechazar)");
            System.out.println("10. Registrar Merma Directa (Baja por daño o vencimiento)");
            System.out.println("11. Consultar clientes con entrega confirmada por lote");
            System.out.println("0. Volver al Menú Principal");
            
            opcion = Utils.leerEntero("Seleccione una opción: ");

            switch (opcion) {
                case 1:
                    menuRegistrarProducto();
                    break;
                case 2:
                    menuRegistrarLlegadaLote();
                    break;
                case 3:
                    menuListarLotes();
                    break;
                case 4:
                    controller.ejecutarRevisionDiariaVencimientos();
                    Utils.pausa();
                    break;
                case 5:
                    menuTrazabilidadUbicacion();
                    break;
                case 6:
                    menuTrazabilidadClientes();
                    break;
                case 7:
                    menuBuscarPorCodigoLote();
                    break;
                case 8:
                    menuEnviarACuarentena();
                    break;
                case 9:
                    menuInspeccionCalidad();
                    break;
                case 10:
                    menuRegistrarMerma();
                    break;
                case 11:
                    showDeliveredCustomers();
                    break;
                case 0:
                    System.out.println("Saliendo del Módulo de Inventarios...");
                    break;
                default:
                    System.out.println(" Opción no válida. Intente de nuevo.");
            }
        } while (opcion != 0);
    }

    // =========================================================================
    // SUBMENÚS Y GESTIÓN DE ENTRADAS CON Utils.java
    // =========================================================================

    private void menuRegistrarProducto() {
        Utils.imprimirTitulo("Registrar Nuevo Producto");
        String nombre = Utils.leerPalabra("Nombre del producto: ");
        String descripcion = Utils.leerPalabraOpcional("Descripción (opcional): ");
        int idCategoria = Utils.leerEntero("ID de Categoría: ");
        String unidadMedida = Utils.leerPalabra("Unidad de medida (ej. KG, UNIDAD): ");
        BigDecimal precioBase = Utils.leerDecimalExacto("Precio base sugerido: ");

        controller.registrarNuevoProducto(nombre, descripcion, idCategoria, unidadMedida, precioBase);
        Utils.pausa();
    }

    private void menuRegistrarLlegadaLote() {
        Utils.imprimirTitulo("Recepción y Lotificación de Mercancía");
        
        int idProducto = Utils.leerEntero("ID del Producto recibido: ");
        int idProveedor = Utils.leerEntero("ID del Proveedor que entrega: ");
        
        // Convierte el LocalDate devuelto por Utils.leerFecha a LocalDateTime a medianoche
        LocalDateTime fechaVencimiento = Utils.leerFecha("Fecha de Vencimiento").atStartOfDay();

        // Manejo estricto de BigDecimal para cantidades y precios
        BigDecimal cantidadInicial = Utils.leerDecimalExacto("Cantidad recibida: ");
        BigDecimal precioCompra = Utils.leerDecimalExacto("Precio unitario de compra: ");
        BigDecimal precioVenta = Utils.leerDecimalExacto("Precio unitario de venta: ");
        
        String pasillo = Utils.leerPalabra("Pasillo de ubicación (ej. A, B, C): ");
        String estante = Utils.leerPalabra("Estante de ubicación (ej. 01, 05, 10): ");

        controller.registrarLlegadaLote(idProducto, idProveedor, fechaVencimiento,
                cantidadInicial, precioCompra, precioVenta, pasillo, estante);
                
        Utils.pausa();
    }

    private void menuListarLotes() {
        Utils.imprimirTitulo("Inventario de Lotes en Bodega (Orden FEFO)");
        List<lot> lotes = controller.listLots();
        if (lotes.isEmpty()) {
            System.out.println("No hay lotes registrados en la bodega actualmente.");
        } else {
            for (lot l : lotes) {
                System.out.println(l.toString());
            }
        }
        Utils.pausa();
    }

    private void menuTrazabilidadUbicacion() {
        Utils.imprimirTitulo("Trazabilidad por Ubicación");
        String pasillo = Utils.leerPalabra("Ingrese el Pasillo (ej. A): ");
        String estante = Utils.leerPalabra("Ingrese el Estante (ej. 05): ");

        controller.consultarLotesPorUbicacion(pasillo, estante);
        Utils.pausa();
    }

    private void menuTrazabilidadClientes() {
        Utils.imprimirTitulo("Clientes que Recibieron un Lote");
        String numeroLote = Utils.leerPalabra("Ingrese el Código Único del Lote (ej. LOT-...): ");

        controller.consultarClientesAfectadosPorLote(numeroLote);
        Utils.pausa();
    }

    private void menuBuscarPorCodigoLote() {
        Utils.imprimirTitulo("Consulta de Lote por Código");
        String numeroLote = Utils.leerPalabra("Ingrese el Código Único del Lote: ");

        lot encontrado = controller.findLot(numeroLote);
        if (encontrado != null) {
            System.out.println("Detalle del lote encontrado:");
            System.out.println(encontrado.toString());
        } else {
            System.out.println("No se encontró ningún lote con el código: " + numeroLote);
        }
        Utils.pausa();
    }

    private void menuEnviarACuarentena() {
        Utils.imprimirTitulo("Enviar Lote a Cuarentena");
        int idLote = Utils.leerEntero("ID numérico del Lote (id_lote): ");
        String motivo = Utils.leerPalabra("Motivo de cuarentena: ");
        String usuario = Utils.leerPalabra("Usuario operario que reporta: ");

        controller.enviarLoteCuarentena(idLote, motivo, usuario);
        Utils.pausa();
    }

    private void menuInspeccionCalidad() {
        Utils.imprimirTitulo("Inspección de Calidad");
        int idLote = Utils.leerEntero("ID numérico del Lote en cuarentena: ");
        String inspector = Utils.leerPalabra("Nombre del Inspector de Calidad: ");
        if (InspectorAccess.isRequired()) {
            char[] password = Utils.readPassword("Clave del inspector: ");
            boolean allowed;
            try {
                allowed = InspectorAccess.authenticate(inspector, password);
            } finally {
                if (password != null) Arrays.fill(password, '\0');
            }
            if (!allowed) {
                System.out.println("Acceso denegado: se requiere la cuenta de inspector.");
                Utils.pausa();
                return;
            }
        }
        
        int decision = Utils.leerEntero("Resultado (1 = APROBAR / 2 = RECHAZAR a merma): ");
        while (decision != 1 && decision != 2) {
            decision = Utils.leerEntero("Ingrese 1 para aprobar o 2 para rechazar: ");
        }
        boolean aprobado = decision == 1;

        String motivoRechazo = null;
        if (!aprobado) {
            motivoRechazo = Utils.leerPalabra("Motivo del rechazo definitivo: ");
        }

        String notas = Utils.leerPalabraOpcional("Notas adicionales (opcional): ");

        controller.procesarInspeccionCalidad(idLote, aprobado, inspector, motivoRechazo, notas);
        Utils.pausa();
    }

    private void menuRegistrarMerma() {
        Utils.imprimirTitulo("Registrar Merma Directa");
        int idLote = Utils.leerEntero("ID numérico del Lote: ");
        
        // Convertimos el BigDecimal de Utils a double o mantenlo si tu controlador recibe BigDecimal
        BigDecimal cantidadPerdida = Utils.leerDecimalExacto("Cantidad perdida a dar de baja: ");
        String motivo = Utils.leerPalabra("Motivo de la baja: ");
        String usuario = Utils.leerPalabra("Usuario que registra la baja: ");

        boolean exito = controller.registrarMerma(idLote, cantidadPerdida, motivo, usuario);
        if (exito) {
            System.out.println("Merma registrada y descontada del inventario correctamente.");
        }
        Utils.pausa();
    }

    private void showDeliveredCustomers() {
        String lotNumber = Utils.leerPalabra("Código del lote: ");
        List<String> customers = controller.listDeliveredCustomers(lotNumber);
        if (customers.isEmpty()) System.out.println("El lote no tiene entregas confirmadas.");
        else customers.forEach(System.out::println);
        Utils.pausa();
    }
    
}
