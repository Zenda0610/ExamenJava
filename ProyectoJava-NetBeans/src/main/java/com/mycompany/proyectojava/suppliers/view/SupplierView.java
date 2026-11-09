
package com.mycompany.proyectojava.suppliers.view;

import com.mycompany.proyectojava.common.Utils;
import com.mycompany.proyectojava.suppliers.controller.SupplierController;

public class SupplierView {
    
    private final SupplierController controller;

    public SupplierView() {
        this.controller = new SupplierController();
    }

    public void mostrarMenu() {
        int opcion = -1;

        do {
            Utils.imprimirTitulo("MÓDULO DE PROVEEDORES Y COMPRAS - FRESCURA TOTAL");
            System.out.println("1. Registrar Nuevo Proveedor");
            System.out.println("2. Mostrar Directorio de Proveedores Activos");
            System.out.println("3. Asociar Producto al Catálogo del Proveedor");
            System.out.println("4. Consultar Catálogo de Productos de un Proveedor");
            System.out.println("5. Consultar Historial de Compras / Entregas (Fiabilidad)");
            System.out.println("6. Generar Reporte Diario de Compras");
            System.out.println("0. Volver al Menú Principal");
            
            opcion = Utils.leerEntero("Seleccione una opción: ");

            switch (opcion) {
                case 1:
                    menuRegistrarProveedor();
                    break;
                case 2:
                    menuListarProveedores();
                    break;
                case 3:
                    menuAsociarProducto();
                    break;
                case 4:
                    menuVerCatalogo();
                    break;
                case 5:
                    menuVerHistorialCompras();
                    break;
                case 6:
                    showDailyPurchaseReport();
                    break;
                case 0:
                    System.out.println("Saliendo del Módulo de Proveedores...");
                    break;
                default:
                    System.out.println("[Atención] Opción no válida. Intente de nuevo.");
            }
        } while (opcion != 0);
    }

    // =========================================================================
    // SUBMENÚS Y GESTIÓN DE ENTRADAS CON Utils.java
    // =========================================================================


    private void showDailyPurchaseReport() {
        controller.exportDailyPurchases();
        Utils.pausa();
    }

    private void menuRegistrarProveedor() {
        Utils.imprimirTitulo("Registrar Nuevo Proveedor");
        
        String nombre = Utils.leerPalabra("Nombre de la empresa / proveedor: ");
        String nit = Utils.leerPalabra("NIT / Documento tributario: ");
        String personaContacto = Utils.leerPalabra("Nombre de la persona de contacto: ");
        String email = Utils.leerPalabra("Correo electrónico: ");
        String telefono = Utils.leerPalabra("Número de teléfono: ");
        String direccion = Utils.leerPalabra("Dirección física: ");

        controller.registrarNuevoProveedor(nombre, nit, personaContacto, email, telefono, direccion);
        Utils.pausa();
    }

    private void menuListarProveedores() {
        Utils.imprimirTitulo("Directorio de Proveedores Activos");
        controller.mostrarProveedoresActivos();
        Utils.pausa();
    }

    private void menuAsociarProducto() {
        Utils.imprimirTitulo("Asociar Producto a Proveedor");
        
        int idProveedor = Utils.leerEntero("Ingrese el ID del Proveedor: ");
        int idProducto = Utils.leerEntero("Ingrese el ID del Producto a asociar: ");

        controller.asociarProductoAProveedor(idProveedor, idProducto);
        Utils.pausa();
    }

    private void menuVerCatalogo() {
        Utils.imprimirTitulo("Catálogo de Productos por Proveedor");
        
        int idProveedor = Utils.leerEntero("Ingrese el ID del Proveedor a consultar: ");
        controller.verCatalogoProductosProveedor(idProveedor); // Si en tu controlador se llama verCatalogoProductosProveedor, ajusta esta línea
        
        Utils.pausa();
    }

    private void menuVerHistorialCompras() {
        Utils.imprimirTitulo("Historial de Compras y Entregas (Fiabilidad)");
        
        int idProveedor = Utils.leerEntero("Ingrese el ID del Proveedor: ");
        controller.verHistorialComprasProveedor(idProveedor);
        
        Utils.pausa();
    }
    
}
