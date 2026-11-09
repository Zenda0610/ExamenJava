
package com.mycompany.proyectojava.sales.controller;

import com.mycompany.proyectojava.sales.model.InvoiceGenerator;
import com.mycompany.proyectojava.sales.model.InvoicePdf;

import com.mycompany.proyectojava.inventory.model.lot;
import com.mycompany.proyectojava.sales.model.Invoice;
import com.mycompany.proyectojava.sales.model.SalesDAO;
import com.mycompany.proyectojava.sales.model.customer;
import com.mycompany.proyectojava.sales.model.sale;
import com.mycompany.proyectojava.sales.model.saleDetail;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.function.Predicate;
import com.mycompany.proyectojava.sales.controller.DeliveryPricingService.Mode;
import java.io.IOException;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.TreeMap;
import java.util.UUID;

public class SalesController {

    private final SalesDAO salesDAO;
    private final CustomerService customerService;

    // Constantes de negocio para venta inteligente
    private static final BigDecimal TASA_IVA_PORCENTAJE = new BigDecimal("19.00"); // 19% IVA
    private static final BigDecimal PROMO_PROXIMO_VENCER = new BigDecimal("50.00"); // 50% descuento si id_estado == 2
    private static final BigDecimal CIEN = new BigDecimal("100.00");

    public SalesController() {
        this.salesDAO = new SalesDAO();
        this.customerService = new CustomerService(salesDAO);
    }

    // =========================================================================
    // 1. GESTIÓN DE CLIENTES
    // =========================================================================

    public boolean registrarNuevoCliente(String nombre, String documento, String email, 
                                         String numero, String direccion, int idTipo) {
        customer nuevoCliente = new customer(
                0, // ID autogenerado en BD
                nombre,
                documento,
                email,
                numero,
                direccion,
                idTipo,
                LocalDateTime.now()
        );

        int idGenerado = salesDAO.registrarCliente(nuevoCliente);
        if (idGenerado > 0) {
            System.out.println("[Éxito] Cliente registrado correctamente con ID: " + idGenerado);
            return true;
        } else {
            System.out.println("[Error] No se pudo registrar el cliente.");
            return false;
        }
    }

    public void mostrarClientesActivos() {
        List<customer> clientes = salesDAO.listarClientesActivos();
        if (clientes.isEmpty()) {
            System.out.println("No hay clientes registrados.");
        } else {
            System.out.println("=== DIRECTORIO DE CLIENTES ===");
            for (customer cli : clientes) {
                System.out.println(cli.toString());
            }
        }
    }

    // =========================================================================
    // 2. VENTA INTELIGENTE (FEFO + PROMO 50% AUTOMÁTICA + FACTURACIÓN)
    // =========================================================================

    /**
     * Procesa la venta de un producto aplicando estrategia FEFO:
     * - Toma primero los lotes que vencen antes.
     * - Si un lote no alcanza para cubrir el pedido, toma el resto del siguiente lote más próximo a vencer.
     * - Si el lote está en estado 2 (Near Expiry / Próximo a vencer), aplica 50% de descuento automático.
     * - Registra la venta, descuenta el inventario y emite la factura electrónica (con CUFE y QR).
     */
    
    
    private final DeliveryPricingService deliveryPricing = new DeliveryPricingService();


    public void showCommercialStatistics() {
        var rows = salesDAO.listarResumenVentas();
        if (rows.isEmpty()) {
            System.out.println("No existen datos suficientes para generar estadísticas comerciales.");
            return;
        }
        var result = new CommercialStatistics().calculate(rows);
        System.out.println("===== ESTADÍSTICAS DE PROVEEDORES =====");
        result.topCategory().ifPresentOrElse(
                top -> System.out.printf("Categoría con mayor volumen vendido: %s - %s unidades%n",
                        top.getKey(), top.getValue().toPlainString()),
                () -> System.out.println("No hay ventas confirmadas."));
        System.out.println("Clientes con devoluciones:");
        result.customersWithReturns().forEach(name -> System.out.println("- " + name));
    }

    public boolean sellOrder(int customerId, Map<Integer, BigDecimal> quantities, String seller,
                             Mode delivery, Predicate<BigDecimal> confirm) {
        return processOrder(customerId, quantities, seller, true, delivery, confirm);
    }

    public boolean sellSingle(int customerId, int productId, BigDecimal quantity, String seller,
                              Mode delivery, Predicate<BigDecimal> confirm) {
        if (quantity == null) return false;
        return processOrder(customerId, Map.of(productId, quantity), seller, false, delivery, confirm);
    }

    public boolean realizarVentaInteligenteFEFO(int idCliente, int idProducto, BigDecimal cantidadSolicitada, String usuarioVendedor) {
        if (cantidadSolicitada == null) return false;
        return sellSingle(idCliente, idProducto, cantidadSolicitada, usuarioVendedor, Mode.ESTANDAR, total -> true);
    }

    public boolean sellOrder(int customerId, Map<Integer, BigDecimal> quantities, String seller) {
        return sellOrder(customerId, quantities, seller, Mode.ESTANDAR, total -> true);
    }

    private boolean processOrder(int idCliente, Map<Integer, BigDecimal> quantities,
                                 String usuarioVendedor, boolean promocionesConfigurables,
                                 Mode delivery, Predicate<BigDecimal> confirm) {
        customer clienteComprador;
        try {
            clienteComprador = customerService.findCustomer(idCliente).orElse(null);
        } catch (SQLException e) {
            System.out.println("No se pudo consultar el cliente: " + e.getMessage());
            return false;
        }
        if (clienteComprador == null) {
            System.out.println("Cliente no encontrado.");
            return false;
        }
        if (quantities.isEmpty()) {
            System.out.println("El pedido debe contener al menos un producto.");
            return false;
        }
        Map<Integer, BigDecimal> orderedProducts = new TreeMap<>(quantities);
        Map<Integer, String> productsByLot = new HashMap<>();
        List<saleDetail> listaDetalles = new ArrayList<>();

        BigDecimal acumuladorSubtotalBruto = BigDecimal.ZERO;
        BigDecimal acumuladorDescuentoTotal = BigDecimal.ZERO;
        BigDecimal acumuladorImpuestoTotal = BigDecimal.ZERO;
        BigDecimal acumuladorMontoTotal = BigDecimal.ZERO;

        System.out.println("=== ASIGNACIÓN INTELIGENTE DE LOTES (FEFO) ===");
        for (var product : orderedProducts.entrySet()) {
            int idProducto = product.getKey();
            BigDecimal cantidadSolicitada = product.getValue();
            if (cantidadSolicitada == null || cantidadSolicitada.signum() <= 0
                    || cantidadSolicitada.stripTrailingZeros().scale() > 2) {
                System.out.println("[Error] La cantidad debe ser positiva y tener hasta dos decimales.");
                return false;
            }

            // 1. Consultar lotes disponibles ordenados por FEFO (solo estados 1 y 2)
            List<lot> lotesDisponibles = salesDAO.obtenerLotesDisponiblesFEFO(idProducto);
            if (lotesDisponibles.isEmpty()) {
                System.out.println("[Stock Insuficiente] No existen lotes disponibles (aptos para venta) para el producto ID: " + idProducto);
                return false;
            }

            // 2. Verificar que la suma de todos los lotes disponibles alcance para cubrir el pedido
            BigDecimal stockTotalDisponible = BigDecimal.ZERO;
            for (lot l : lotesDisponibles) {
                stockTotalDisponible = stockTotalDisponible.add(l.getCantidad());
            }

            if (stockTotalDisponible.compareTo(cantidadSolicitada) < 0) {
                System.out.printf("[Stock Insuficiente] Pedido: %.2f | Disponible total en bodega: %.2f%n", 
                        cantidadSolicitada, stockTotalDisponible);
                return false;
            }

            // 3. Distribuir la cantidad solicitada entre los lotes siguiendo el orden FEFO

            BigDecimal cantidadFaltantePorCubrir = cantidadSolicitada;
            BigDecimal discountRate = PROMO_PROXIMO_VENCER;
            if (promocionesConfigurables && lotesDisponibles.stream().anyMatch(item -> item.getIdEstado() == 2)) {
                try {
                    discountRate = salesDAO.findActiveDiscount(idProducto, 2).orElse(PROMO_PROXIMO_VENCER);
                } catch (SQLException error) {
                    System.out.println("No se pudieron consultar las promociones. " + error.getMessage());
                    return false;
                }
            }
            String productName = promocionesConfigurables ? salesDAO.obtenerDatosFactura(idProducto).producto() : "";
            for (lot loteActual : lotesDisponibles) {
                if (cantidadFaltantePorCubrir.compareTo(BigDecimal.ZERO) <= 0) {
                    break;
                }

                // Tomamos lo que podamos de este lote
                BigDecimal cantidadATomarDeEsteLote = loteActual.getCantidad().min(cantidadFaltantePorCubrir);
                cantidadFaltantePorCubrir = cantidadFaltantePorCubrir.subtract(cantidadATomarDeEsteLote);

                BigDecimal cantBD = cantidadATomarDeEsteLote.setScale(2, RoundingMode.HALF_UP);
                BigDecimal precioUnitarioBD = loteActual.getPrecioVenta().setScale(2, RoundingMode.HALF_UP);

                // Subtotal bruto de la línea (Cantidad * Precio Unitario)
                BigDecimal subtotalBrutoLinea = cantBD.multiply(precioUnitarioBD).setScale(2, RoundingMode.HALF_UP);

                // Regla de Negocio: Si el lote está en estado 2 (Near Expiry), aplica 50% de descuento automático
                BigDecimal porcentajeDescuento = (loteActual.getIdEstado() == 2) ? discountRate : BigDecimal.ZERO;
                BigDecimal montoDescuentoLinea = subtotalBrutoLinea
                        .multiply(porcentajeDescuento)
                        .divide(CIEN, 2, RoundingMode.HALF_UP);

                // Subtotal neto después del descuento (Base gravable)
                BigDecimal subtotalNetoLinea = subtotalBrutoLinea.subtract(montoDescuentoLinea).setScale(2, RoundingMode.HALF_UP);

                // Impuesto (IVA 19% sobre el subtotal neto)
                BigDecimal montoImpuestoLinea = subtotalNetoLinea
                        .multiply(TASA_IVA_PORCENTAJE)
                        .divide(CIEN, 2, RoundingMode.HALF_UP);

                // Total de la línea (Subtotal Neto + Impuesto)
                BigDecimal totalLinea = subtotalNetoLinea.add(montoImpuestoLinea).setScale(2, RoundingMode.HALF_UP);

                // Crear el objeto saleDetail usando tu constructor exacto de 11 parámetros
                saleDetail detalle = new saleDetail(
                        0, // id autogenerado
                        0, // idVenta (se asigna en el DAO al insertar la venta)
                        loteActual.getId(), // Si en tu clase lot el getter se llama getIdLote(), cámbialo a loteActual.getIdLote()
                        cantBD,
                        precioUnitarioBD,
                        porcentajeDescuento,
                        montoDescuentoLinea,
                        TASA_IVA_PORCENTAJE,
                        montoImpuestoLinea,
                        subtotalNetoLinea,
                        totalLinea
                );

                listaDetalles.add(detalle);
                if (promocionesConfigurables) productsByLot.put(loteActual.getId(), productName);

                // Sumar a los totales generales de la cabecera de la venta
                acumuladorSubtotalBruto = acumuladorSubtotalBruto.add(subtotalBrutoLinea);
                acumuladorDescuentoTotal = acumuladorDescuentoTotal.add(montoDescuentoLinea);
                acumuladorImpuestoTotal = acumuladorImpuestoTotal.add(montoImpuestoLinea);
                acumuladorMontoTotal = acumuladorMontoTotal.add(totalLinea);

                String etiquetaPromo = porcentajeDescuento.signum() > 0
                        ? " [PROMO " + porcentajeDescuento.stripTrailingZeros().toPlainString() + "% PRÓXIMO A VENCER]" : "";
                System.out.printf(" -> Lote: %s (ID: %d) | Vence: %s | Cant: %.2f | P.Unit: $%.2f | Desc: $%.2f | Subtotal: $%.2f%s%n",
                        loteActual.getNumeroLote(), loteActual.getId(), loteActual.getFechaVencimiento(),
                        cantidadATomarDeEsteLote, precioUnitarioBD, montoDescuentoLinea, subtotalNetoLinea, etiquetaPromo);
            }
        }

        // 4. Construir el objeto 'sale' usando tu constructor de 10 parámetros
        String numeroVentaUnico = generarNumeroVentaUnico();
        sale nuevaVenta = new sale(
                0, // id autogenerado
                numeroVentaUnico,
                idCliente,
                LocalDateTime.now(),
                acumuladorSubtotalBruto,
                acumuladorDescuentoTotal,
                acumuladorImpuestoTotal,
                acumuladorMontoTotal,
                2, // En Preparacion
                usuarioVendedor
        );

        BigDecimal finalTotal = deliveryPricing.finalTotal(nuevaVenta, delivery);
        System.out.printf("Entrega %s | Recargo: %s | Total a pagar: %s%n",
                delivery, finalTotal.subtract(acumuladorMontoTotal).toPlainString(), finalTotal.toPlainString());
        if (!confirm.test(finalTotal)) return false;
        nuevaVenta.setMontoTotal(finalTotal);

        String numeroFactura = "FACT-" + numeroVentaUnico.replace("VEN-", "");
        String cufeGenerado = UUID.randomUUID().toString().replace("-", "").toUpperCase();
        String enlaceQr = "https://catalogo-vpfe.dian.gov.co/document/searchqr?documentkey=" + cufeGenerado;

        Invoice nuevaFactura = new Invoice(
                0, // idFactura autogenerado
                0, // Se asigna al confirmar la transacción
                numeroFactura,
                cufeGenerado,
                enlaceQr,
                LocalDateTime.now(),
                acumuladorSubtotalBruto,
                acumuladorDescuentoTotal,
                acumuladorImpuestoTotal,
                finalTotal
        );

        int idVentaGenerada = salesDAO.registrarVentaCompleta(nuevaVenta, listaDetalles, nuevaFactura);
        if (idVentaGenerada <= 0) {
            System.out.println("[Error] No se pudo registrar la venta y su factura.");
            return false;
        }

        InvoiceGenerator.imprimirFacturaConsola(nuevaFactura, nuevaVenta, clienteComprador, listaDetalles);
        try {
            var archivo = InvoicePdf.guardar(nuevaFactura, nuevaVenta, clienteComprador, listaDetalles,
                    salesDAO.obtenerDatosFactura(orderedProducts.keySet().iterator().next()), productsByLot);
            System.out.println("Factura PDF guardada en: " + archivo);
        } catch (IOException | IllegalArgumentException e) {
            System.out.println("La venta y la factura se guardaron en la base de datos. "
                    + "No se pudo crear el PDF: " + e.getMessage());
        }
        return true;
    }

    // =========================================================================
    // 3. HISTORIAL DE VENTAS
    // =========================================================================

    public void mostrarHistorialVentas() {
        List<String> historial = salesDAO.listarResumenVentas();
        if (historial.isEmpty()) {
            System.out.println("No hay ventas registradas en el sistema.");
        } else {
            System.out.println("=== HISTORIAL DE VENTAS ===");
            for (String registro : historial) {
                System.out.println(registro);
            }
        }
    }

    // =========================================================================
    // MÉTODOS AUXILIARES PRIVADOS
    // =========================================================================

    private String generarNumeroVentaUnico() {
        String fecha = java.time.LocalDate.now().toString().replace("-", "");
        String sufijo = UUID.randomUUID().toString().replace("-", "");
        return "VEN-" + fecha + "-" + sufijo;
    }
}
