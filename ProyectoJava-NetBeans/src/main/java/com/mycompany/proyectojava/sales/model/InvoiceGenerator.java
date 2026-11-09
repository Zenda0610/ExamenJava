
package com.mycompany.proyectojava.sales.model;

import java.util.List;

public class InvoiceGenerator {
    /**
     * Imprime en la consola la factura electrónica formateada con los datos de la venta,
     * el cliente, los detalles (ítems/lotes) y los totales financieros.
     */
    public static void imprimirFacturaConsola(Invoice invoice, sale venta, customer cliente, List<saleDetail> detalles) {
        System.out.println("\n=======================================================");
        System.out.println("            SUPERMERCADO FRESCURA TOTAL                ");
        System.out.println("              NIT: 900.123.456-7                       ");
        System.out.println("       Factura simulada - Colombia         ");
        System.out.println("=======================================================");
        System.out.println("No. Factura  : " + invoice.getNumeroFactura());
        System.out.println("No. Venta    : " + (venta != null ? venta.getNumeroVenta() : "N/A"));
        System.out.println("Fecha Emisión: " + invoice.getFechaEmision());
        System.out.println("CUFE         : " + (invoice.getCufe() != null ? invoice.getCufe() : "N/A"));
        System.out.println("-------------------------------------------------------");
        System.out.println("DATOS DEL CLIENTE:");
        System.out.println("Razón Social : " + (cliente != null ? cliente.getNombre() : "Consumidor Final"));
        System.out.println("Documento/NIT: " + (cliente != null ? cliente.getDocumento() : "N/A"));
        System.out.println("Dirección    : " + (cliente != null ? cliente.getDireccion() : "N/A"));
        System.out.println("Teléfono     : " + (cliente != null ? cliente.getNumero() : "N/A"));
        System.out.println("-------------------------------------------------------");
        System.out.println("DETALLE DE PRODUCTOS Y LOTES:");
        System.out.printf("%-8s %-8s %-10s %-8s %-12s%n", "Lote ID", "Cant", "P.Unit", "Desc%", "Subtotal");
        System.out.println("-------------------------------------------------------");
        
        if (detalles != null && !detalles.isEmpty()) {
            for (saleDetail det : detalles) {
                System.out.printf("%-8d %-8.2f $%-9.2f %-7.0f%% $%-11.2f%n",
                        det.getIdLote(),
                        det.getCantidadVendida(),
                        det.getPrecioUnitario(),
                        det.getDescuentAplicado(),
                        det.getSubTotal());
            }
        } else {
            System.out.println("No hay detalles registrados para esta factura.");
        }
        
        System.out.println("-------------------------------------------------------");
        System.out.printf("Subtotal           : $%12.2f%n", invoice.getSubtotal());
        System.out.printf("Descuento Total    : -$%11.2f%n", invoice.getTotalDescuento());
        System.out.printf("IVA (19%%)          : $%12.2f%n", invoice.getMontoImpuesto());
        System.out.println("-------------------------------------------------------");
        if (invoice.deliverySurcharge().signum() > 0) {
            System.out.printf("Recargo de entrega : $%12.2f%n", invoice.deliverySurcharge());
        }
        System.out.printf("TOTAL A PAGAR      : $%12.2f%n", invoice.getMontoTotal());
        System.out.println("=======================================================");
        System.out.println("Enlace QR simulado:");
        System.out.println(invoice.getEnlaceQr());
        System.out.println("=======================================================");
        System.out.println("       ¡Gracias por preferir a Frescura Total!         ");
        System.out.println("=======================================================\n");
    }
}
