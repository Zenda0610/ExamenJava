
package com.mycompany.proyectojava.inventory.controller;

import com.mycompany.proyectojava.inventory.model.inventoryDAO;
import com.mycompany.proyectojava.inventory.model.lot;
import com.mycompany.proyectojava.inventory.model.product;
import com.mycompany.proyectojava.inventory.model.QuarantineRecord;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class InventoryController {
    
    
    private inventoryDAO inventoryDAO;

    public InventoryController() {
        this.inventoryDAO = new inventoryDAO();
    }

    public List<lot> listLots() {
        return inventoryDAO.listarTodosLosLotes();
    }

    public lot findLot(String lotNumber) {
        return inventoryDAO.buscarPorNumeroLote(lotNumber);
    }

    public List<String> listDeliveredCustomers(String lotNumber) {
        return inventoryDAO.buscarClientesPorNumeroLote(lotNumber, true);
    }

    // =========================================================================
    // 1. REGISTRO DE PRODUCTOS
    // =========================================================================
    public boolean registrarNuevoProducto(String nombre, String descripcion, int idCategoria, String unidadMedida, BigDecimal precioBase) {
        product nuevoProd = new product();
        nuevoProd.setNombre(nombre);
        nuevoProd.setDescripcion(descripcion);
        nuevoProd.setIdCategoria(idCategoria);
        nuevoProd.setUnidadMedida(unidadMedida);
        nuevoProd.setPrecioBase(precioBase);

        int idGenerado = inventoryDAO.registroProductos(nuevoProd);
        if (idGenerado > 0) {
            System.out.println("[Éxito] Producto registrado con ID: " + idGenerado);
            return true;
        } else {
            System.out.println("[Error] No se pudo registrar el producto.");
            return false;
        }
    }

    // =========================================================================
    // 2. RECEPCIÓN Y LOTIFICACIÓN DE MERCANCÍA (Módulo 1)
    // =========================================================================
    public boolean registrarLlegadaLote(int idProducto, int idProveedor, LocalDateTime fechaVencimiento, 
                                       BigDecimal cantidadInicial, BigDecimal precioCompra, BigDecimal precioVenta, 
                                       String pasillo, String estante) {
        
        // Generar identificador de lote único automáticamente (Regla del Módulo 1)
        String numeroLoteUnico = generarCodigoLoteUnico(idProducto, idProveedor);

        LocalDateTime fechaIngreso = LocalDateTime.now();
        var hoy = fechaIngreso.toLocalDate();
        var vencimiento = fechaVencimiento.toLocalDate();
        int estado = vencimiento.isBefore(hoy) ? 3 : (vencimiento.isAfter(hoy.plusDays(7)) ? 1 : 2);
        lot nuevoLote = new lot(
                0, // ID autoincremental por BD
                numeroLoteUnico,
                idProducto,
                idProveedor,
                fechaIngreso,
                fechaVencimiento,
                cantidadInicial,
                cantidadInicial, // Stock actual igual al inicial al ingresar
                precioCompra,
                precioVenta,
                pasillo,
                estante,
                estado
        );

        int idLoteGenerado = inventoryDAO.registrarLote(nuevoLote);
        if (idLoteGenerado > 0) {
            System.out.println("Lote recibido y registrado con código: " + numeroLoteUnico);
            return true;
        } else {
            System.out.println(" No se pudo registrar el lote en bodega.");
            return false;
        }
    }

    // Método auxiliar privado para cumplir con el código de lote único
    private String generarCodigoLoteUnico(int idProducto, int idProveedor) {
        String fechaStr = java.time.LocalDate.now().toString().replace("-", "");
        String sufijoUnico = java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        return "LOT-P" + idProducto + "-PR" + idProveedor + "-" + fechaStr + "-" + sufijoUnico;
    }

    // =========================================================================
    // 3. EJECUTAR REVISIÓN DIARIA DE VENCIMIENTOS (Alertas Proactivas)
    // =========================================================================
    public void ejecutarRevisionDiariaVencimientos() {
        System.out.println(" Ejecutando revisión automática de fechas de caducidad...");
        inventoryDAO.actualizarEstadosVencimientoAutomatico();
    }

    // =========================================================================
    // 4. CONSULTAS DE TRAZABILIDAD
    // =========================================================================
    public void consultarLotesPorUbicacion(String pasillo, String estante) {
        List<String> resultados = inventoryDAO.buscarLotesPorUbicacion(pasillo, estante);
        if (resultados.isEmpty()) {
            System.out.println("No se encontraron lotes en la ubicación: Pasillo " + pasillo + ", Estante " + estante);
        } else {
            System.out.println("--- LOTES EN UBICACIÓN " + pasillo + "-" + estante + " ---");
            for (String info : resultados) {
                System.out.println(info);
            }
        }
    }

    public void consultarClientesAfectadosPorLote(String numeroLote) {
        List<String> clientes = inventoryDAO.buscarClientesPorNumeroLote(numeroLote);
        if (clientes.isEmpty()) {
            System.out.println("No hay registros de clientes que hayan recibido productos del lote: " + numeroLote);
        } else {
            System.out.println("--- CLIENTES AFECTADOS / HISTORIAL PARA LOTE " + numeroLote + " ---");
            for (String cli : clientes) {
                System.out.println(cli);
            }
        }
    }

    // =========================================================================
    // 5. CUARENTENA Y CALIDAD
    // =========================================================================
    public boolean enviarLoteCuarentena(int idLote, String motivo, String usuario) {
        QuarantineRecord qRecord = new QuarantineRecord();
        qRecord.setIdLote(idLote);
        qRecord.setMotivo(motivo);
        qRecord.setUsuario(usuario);

        boolean exito = inventoryDAO.enviarACuarentena(qRecord);
        if (exito) {
            System.out.println("[Alerta] El lote ID " + idLote + " ha sido puesto EN CUARENTENA con éxito.");
        }
        return exito;
    }

    public boolean procesarInspeccionCalidad(int idLote, boolean aprobado, String inspector, String motivoRechazo, String notas) {
        boolean exito = inventoryDAO.inspeccionarLoteEnCuarentena(idLote, aprobado, inspector, motivoRechazo, notas);
        if (exito) {
            String res = aprobado ? "APROBADO (Devuelto a Inventario Disponible)" : "RECHAZADO (Convertido en Merma)";
            System.out.println("[Calidad] Inspección procesada con estado: " + res);
        }
        return exito;
    }

    public boolean registrarMerma(int idLote, BigDecimal cantidadPerdida, String motivo, String usuario) {
        return inventoryDAO.registrarMermaDirecta(idLote, cantidadPerdida, motivo, usuario);
    }
}
