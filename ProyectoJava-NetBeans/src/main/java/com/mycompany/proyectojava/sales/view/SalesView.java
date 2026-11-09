
package com.mycompany.proyectojava.sales.view;

import com.mycompany.proyectojava.common.Utils;
import com.mycompany.proyectojava.sales.controller.SalesController;
import com.mycompany.proyectojava.sales.controller.CustomerService;
import com.mycompany.proyectojava.sales.controller.DeliveryPricingService.Mode;
import com.mycompany.proyectojava.sales.model.SalesDAO;
import java.io.IOException;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

public class SalesView {
    private final SalesController controller;
    private final CustomerService customers = new CustomerService(new SalesDAO());

    public SalesView() {
        this.controller = new SalesController();
    }

    public void mostrarMenu() {
        int opcion = -1;

        do {
            Utils.imprimirTitulo("MÓDULO DE VENTAS Y FACTURACIÓN - FRESCURA TOTAL");
            System.out.println("1. Registrar Nuevo Cliente");
            System.out.println("2. Mostrar Directorio de Clientes");
            System.out.println("3. Realizar Venta Inteligente (FEFO + Promo 50% + Facturación)");
            System.out.println("4. Ver Historial de Ventas");
            System.out.println("5. Registrar pedido con varios productos");
            System.out.println("6. Consultar Cliente por ID");
            System.out.println("7. Importar Clientes desde Archivo");
            System.out.println("8. Generar Estadísticas Comerciales");
            System.out.println("0. Volver al Menú Principal");
            
            opcion = Utils.leerEntero("Seleccione una opción: ");

            switch (opcion) {
                case 1:
                    menuRegistrarCliente();
                    break;
                case 2:
                    menuListarClientes();
                    break;
                case 3:
                    menuRealizarVenta();
                    break;
                case 4:
                    menuHistorialVentas();
                    break;
                case 5:
                    showOrderMenu();
                    break;
                case 6:
                    showCustomer();
                    break;
                case 7:
                    importCustomers();
                    break;
                case 8:
                    controller.showCommercialStatistics();
                    Utils.pausa();
                    break;
                case 0:
                    System.out.println("Saliendo del Módulo de Ventas...");
                    break;
                default:
                    System.out.println("[Atención] Opción no válida. Intente de nuevo.");
            }
        } while (opcion != 0);
    }

    // =========================================================================
    // SUBMENÚS Y GESTIÓN DE ENTRADAS CON Utils.java
    // =========================================================================


    private void showCustomer() {
        int id = Utils.leerEntero("ID del cliente: ");
        try {
            customers.findCustomer(id).ifPresentOrElse(
                    customer -> System.out.printf("%s | Documento: %s | Correo: %s | Teléfono: %s%n",
                            customer.getNombre(), customer.getDocumento(), customer.getEmail(), customer.getNumero()),
                    () -> System.out.println("Cliente no encontrado."));
        } catch (SQLException e) {
            System.out.println("No se pudo consultar el cliente: " + e.getMessage());
        }
        Utils.pausa();
    }

    private void importCustomers() {
        try {
            int count = customers.importCustomers(Path.of("clientes_importar.txt"));
            System.out.println("Importación completada. Total de clientes registrados: " + count);
        } catch (NoSuchFileException e) {
            System.out.println("Error: No se encontró el archivo clientes_importar.txt.");
        } catch (IllegalArgumentException | SQLException e) {
            System.out.println("Error: Se encontraron registros inválidos. Importación cancelada.");
            System.out.println(e.getMessage());
        } catch (IOException e) {
            System.out.println("No se pudo leer el archivo. Importación cancelada: " + e.getMessage());
        }
        Utils.pausa();
    }

    private Mode readDeliveryMode() {
        while (true) {
            int option = Utils.leerEntero("Entrega (1 = ESTANDAR, 2 = URGENTE): ");
            if (option == 1) return Mode.ESTANDAR;
            if (option == 2) return Mode.URGENTE;
            System.out.println("Seleccione 1 o 2.");
        }
    }

    private void menuRegistrarCliente() {
        Utils.imprimirTitulo("Registrar Nuevo Cliente");
        
        String nombre = Utils.leerPalabra("Nombre completo / Razón social: ");
        String documento = Utils.leerPalabra("Número de documento / NIT: ");
        String email = Utils.leerPalabra("Correo electrónico: ");
        String numero = Utils.leerPalabra("Número de teléfono / celular: ");
        String direccion = Utils.leerPalabra("Dirección física: ");
        int idTipo = Utils.leerEntero("Tipo de cliente (ej. 1=Mayorista, 2=Minorista): ");

        controller.registrarNuevoCliente(nombre, documento, email, numero, direccion, idTipo);
        Utils.pausa();
    }

    private void menuListarClientes() {
        Utils.imprimirTitulo("Directorio de Clientes");
        controller.mostrarClientesActivos();
        Utils.pausa();
    }

    private void menuRealizarVenta() {
        Utils.imprimirTitulo("Proceso de Venta Inteligente (FEFO)");
        
        int idCliente = Utils.leerEntero("Ingrese el ID del Cliente comprador: ");
        int idProducto = Utils.leerEntero("Ingrese el ID del Producto que desea comprar: ");
        
        // Usamos leerDecimalExacto para asegurar que la cantidad solicitada sea válida y mayor a 0
        BigDecimal cantidadSolicitada = Utils.leerDecimalExacto("Cantidad total a comprar: ");
        
        String usuarioVendedor = Utils.leerPalabra("Nombre del usuario cajero / vendedor: ");

        System.out.println("\n[Procesando] Verificando lotes en bodega bajo estrategia FEFO y aplicando reglas de promoción...");
        
        boolean exito = controller.sellSingle(idCliente, idProducto, cantidadSolicitada, usuarioVendedor,
                readDeliveryMode(), total -> Utils.leerBoolean("¿Confirmar importe y registrar venta?"));
        
        if (exito) {
            System.out.println("\n[Éxito] La venta se ha completado y facturado correctamente.");
        } else {
            System.out.println("\n[Cancelado] No se pudo procesar la venta.");
        }
        
        Utils.pausa();
    }

    private void menuHistorialVentas() {
        Utils.imprimirTitulo("Historial de Ventas Registradas");
        controller.mostrarHistorialVentas();
        Utils.pausa();
    } 

    private void showOrderMenu() {
        Utils.imprimirTitulo("Pedido con varios productos");
        int customerId = Utils.leerEntero("ID del cliente: ");
        Map<Integer, BigDecimal> quantities = new LinkedHashMap<>();
        while (true) {
            int productId = Utils.leerEntero("ID del producto (0 para terminar): ");
            if (productId == 0) break;
            if (productId < 0) {
                System.out.println("El ID debe ser positivo.");
                continue;
            }
            quantities.merge(productId, Utils.leerDecimalExacto("Cantidad: "), BigDecimal::add);
        }
        if (quantities.isEmpty()) {
            System.out.println("El pedido está vacío.");
        } else {
            String seller = Utils.leerPalabra("Usuario vendedor: ");
            quantities.forEach((productId, quantity) -> System.out.printf("Producto %d: %s%n", productId, quantity));
            boolean saved = controller.sellOrder(customerId, quantities, seller,
                    readDeliveryMode(), total -> Utils.leerBoolean("¿Confirmar importe y registrar pedido?"));
            System.out.println(saved ? "Pedido registrado." : "Pedido sin registrar.");
        }
        Utils.pausa();
    }
    
    
}
