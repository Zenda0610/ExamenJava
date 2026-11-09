
package com.mycompany.proyectojava.suppliers.controller;


import com.mycompany.proyectojava.suppliers.model.Supplier;
import com.mycompany.proyectojava.suppliers.model.suppliersDAO;

import java.time.LocalDateTime;
import java.util.List;



public class SupplierController {
    public void exportDailyPurchases() {
        try {
            var report = new PurchaseReportService().exportToday();
            System.out.println("CSV generado en: " + report.file());
            if (report.rows() == 0) System.out.println("No hay operaciones para reportar.");
        } catch (java.io.IOException | java.sql.SQLException e) {
            System.out.println("No se pudo generar el reporte: " + e.getMessage());
        }
    }

    private suppliersDAO supplierDAO;

    public SupplierController() {
        this.supplierDAO = new suppliersDAO();
    }

    // =========================================================================
    // 1. REGISTRAR UN NUEVO PROVEEDOR
    // =========================================================================
    public boolean registrarNuevoProveedor(String nombre, String nit, String personaContacto, 
                                           String email, String telefono, String direccion) {
        
        // Creamos el objeto Supplier con activo = true por defecto al registrarse
        Supplier nuevoProveedor = new Supplier();
        nuevoProveedor.setNombre(nombre);
        nuevoProveedor.setNit(nit);
        nuevoProveedor.setPersonaContacto(personaContacto);
        nuevoProveedor.setEmail(email);
        nuevoProveedor.setTelefono(telefono);
        nuevoProveedor.setDireccion(direccion);
        nuevoProveedor.setActivo(true);
        nuevoProveedor.setFechaRegistro(LocalDateTime.now());

        int idGenerado = supplierDAO.registrarProveedor(nuevoProveedor);
        if (idGenerado > 0) {
            System.out.println(" Proveedor registrado correctamente con ID: " + idGenerado);
            return true;
        } else {
            System.out.println(" No se pudo registrar el proveedor en la base de datos.");
            return false;
        }
    }

    // =========================================================================
    // 2. LISTAR PROVEEDORES ACTIVOS (Directorio Centralizado)
    // =========================================================================
    public void mostrarProveedoresActivos() {
        List<Supplier> proveedores = supplierDAO.listarProveedoresActivos();
        if (proveedores.isEmpty()) {
            System.out.println("No hay proveedores activos registrados en el sistema.");
        } else {
            System.out.println("=== DIRECTORIO DE PROVEEDORES ACTIVOS ===");
            for (Supplier prov : proveedores) {
                System.out.println(prov.toString());
            }
        }
    }

    // =========================================================================
    // 3. ASOCIAR UN PRODUCTO AL CATÁLOGO DEL PROVEEDOR
    // =========================================================================
    public boolean asociarProductoAProveedor(int idProveedor, int idProducto) {
        boolean exito = supplierDAO.asociarProductoProveedor(idProveedor, idProducto);
        if (exito) {
            System.out.println(" Producto ID " + idProducto + " asociado correctamente al proveedor ID " + idProveedor);
        } else {
            System.out.println(" No se pudo asociar el producto (es posible que ya se encuentre asociado).");
        }
        return exito;
    }

    // =========================================================================
    // 4. CONSULTAR EL CATÁLOGO DE PRODUCTOS DE UN PROVEEDOR
    // =========================================================================
    public void verCatalogoProductosProveedor(int idProveedor) {
        List<String> catalogo = supplierDAO.obtenerProductosDeProveedor(idProveedor);
        if (catalogo.isEmpty()) {
            System.out.println("El proveedor no tiene productos asociados en su catálogo.");
        } else {
            System.out.println("=== CATÁLOGO DE PRODUCTOS (Proveedor ID: " + idProveedor + ") ===");
            for (
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    String prod : catalogo) { // se imprime cada línea del catálogo
                System.out.println(prod);
            }
        }
    }

    // =========================================================================
    // 5. HISTORIAL DE COMPRAS Y ENTREGAS (Evaluación de fiabilidad)
    // =========================================================================
    public void verHistorialComprasProveedor(int idProveedor) {
        List<String> historial = supplierDAO.obtenerHistorialCompras(idProveedor);
        if (historial.isEmpty()) {
            System.out.println("El proveedor no registra historial de entregas de mercancía.");
        } else {
            System.out.println("=== HISTORIAL DE COMPRAS Y ENTREGAS (Proveedor ID: " + idProveedor + ") ===");
            for (String entrega : historial) {
                System.out.println(entrega);
            }
        }
    }
}
   