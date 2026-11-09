package com.mycompany.proyectojava.sales.model;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts.FontName;

public final class InvoicePdf {
    private InvoicePdf() {}

    public static Path guardar(Invoice factura, sale venta, customer cliente, List<saleDetail> detalles,
                               SalesDAO.DatosFactura datos) throws IOException {
        return guardar(factura, venta, cliente, detalles, datos, Map.of());
    }

    public static Path guardar(Invoice factura, sale venta, customer cliente, List<saleDetail> detalles,
                               SalesDAO.DatosFactura datos, Map<Integer, String> productsByLot) throws IOException {
        String numero = factura.getNumeroFactura();
        if (!numero.matches("[A-Za-z0-9_-]+")) {
            throw new IOException("Número de factura no válido para un nombre de archivo.");
        }
        Path carpeta = Path.of(System.getProperty("erp.facturas.directorio", "facturas")).toAbsolutePath().normalize();
        Files.createDirectories(carpeta);
        Path destino = carpeta.resolve(numero + ".pdf");
        Path temporal = Files.createTempFile(carpeta, ".factura-", ".tmp");
        try (PDDocument documento = new PDDocument()) {
            documento.getDocumentInformation().setTitle("Factura simulada " + numero);
            try (Pagina pagina = new Pagina(documento, numero)) {
                pagina.texto(datos.empresa(), 19, true);
                pagina.texto("NIT: " + datos.nit(), 10, false);
                pagina.texto(datos.direccion(), 10, false);
                pagina.espacio(9);
                pagina.texto("Factura simulada - sin validez fiscal", 13, true);
                pagina.texto("Factura: " + numero, 10, false);
                pagina.texto("Venta: " + venta.getNumeroVenta(), 10, false);
                pagina.texto("Emisión: " + factura.getFechaEmision().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")), 10, false);
                pagina.texto("CUFE simulado: " + factura.getCufe(), 10, false);
                pagina.espacio(11);
                pagina.texto("Cliente", 12, true);
                pagina.texto(cliente == null ? "Consumidor final" : cliente.getNombre(), 10, false);
                if (cliente != null) {
                    pagina.texto("Documento: " + cliente.getDocumento(), 10, false);
                    if (cliente.getDireccion() != null) pagina.texto("Dirección: " + cliente.getDireccion(), 10, false);
                }
                pagina.espacio(11);
                pagina.texto("Detalle de la venta", 12, true);
                if (productsByLot.isEmpty()) pagina.texto(datos.producto(), 10, false);
                pagina.encabezadoTabla();
                String previousProduct = null;
                for (saleDetail detalle : detalles) {
                    String product = productsByLot.get(detalle.getIdLote());
                    if (pagina.y < (product == null ? 72 : 114)) {
                        pagina.nuevaPagina();
                        pagina.encabezadoTabla();
                        previousProduct = null;
                    }
                    if (product != null && !product.equals(previousProduct)) {
                        pagina.texto(product, 10, true);
                        previousProduct = product;
                    }
                    pagina.fila(Integer.toString(detalle.getIdLote()), formato(detalle.getCantidadVendida()),
                            formato(detalle.getPrecioUnitario()), formato(detalle.getMontoDescuento()),
                            formato(detalle.getMontoImpuesto()), formato(detalle.getTotalLinea()));
                }
                pagina.reservar(265);
                pagina.espacio(15);
                pagina.texto("Totales en COP", 12, true);
                pagina.texto("Subtotal: " + formato(factura.getSubtotal()), 10, false);
                pagina.texto("Descuento: " + formato(factura.getTotalDescuento()), 10, false);
                pagina.texto("IVA: " + formato(factura.getMontoImpuesto()), 10, false);
                if (factura.deliverySurcharge().signum() > 0) {
                    pagina.texto("Recargo de entrega: " + formato(factura.deliverySurcharge()), 10, false);
                }
                pagina.texto("Total a pagar: " + formato(factura.getMontoTotal()) + " COP", 15, true);
                pagina.espacio(11);
                pagina.texto("Código QR simulado", 10, true);
                pagina.qr(factura.getEnlaceQr());
            }
            documento.save(temporal.toFile());
            Files.move(temporal, destino, StandardCopyOption.REPLACE_EXISTING);
            return destino;
        } catch (WriterException ex) {
            throw new IOException("No fue posible generar el QR.", ex);
        } finally {
            Files.deleteIfExists(temporal);
        }
    }

    private static String formato(BigDecimal numero) {
        NumberFormat formato = NumberFormat.getNumberInstance(Locale.forLanguageTag("es-CO"));
        formato.setMinimumFractionDigits(2);
        formato.setMaximumFractionDigits(2);
        return formato.format(numero);
    }

    private static final class Pagina implements AutoCloseable {
        private static final float MARGEN = 44;
        private static final float ANCHO = PDRectangle.A4.getWidth() - 2 * MARGEN;
        private final PDDocument documento;
        private final String numero;
        private final PDType1Font normal = new PDType1Font(FontName.HELVETICA);
        private final PDType1Font negrita = new PDType1Font(FontName.HELVETICA_BOLD);
        private PDPageContentStream salida;
        private float y;

        Pagina(PDDocument documento, String numero) throws IOException {
            this.documento = documento;
            this.numero = numero;
            nuevaPagina();
        }

        void nuevaPagina() throws IOException {
            if (salida != null) salida.close();
            PDPage pagina = new PDPage(PDRectangle.A4);
            documento.addPage(pagina);
            salida = new PDPageContentStream(documento, pagina);
            escribir("Frescura Total  |  " + numero + "  |  Página " + documento.getNumberOfPages(), MARGEN, 29, 8, normal);
            y = PDRectangle.A4.getHeight() - 48;
        }

        void reservar(float altura) throws IOException {
            if (y - altura < 48) nuevaPagina();
        }

        void espacio(float alto) {
            y -= alto;
        }

        void texto(String texto, int tamano, boolean destacado) throws IOException {
            if (texto == null || texto.isBlank()) return;
            PDType1Font fuente = destacado ? negrita : normal;
            String limpio = new String(texto.replaceAll("\\s+", " ").getBytes(java.nio.charset.Charset.forName("windows-1252")),
                    java.nio.charset.Charset.forName("windows-1252"));
            while (!limpio.isEmpty()) {
                int fin = 0;
                float ancho = 0;
                while (fin < limpio.length()) {
                    ancho += fuente.getStringWidth(limpio.substring(fin, fin + 1)) * tamano / 1000;
                    if (ancho > ANCHO) break;
                    fin++;
                }
                if (fin < limpio.length() && limpio.lastIndexOf(' ', fin - 1) > 0) {
                    fin = limpio.lastIndexOf(' ', fin - 1);
                }
                reservar(tamano + 5);
                escribir(limpio.substring(0, fin), MARGEN, y, tamano, fuente);
                y -= tamano + 5;
                limpio = limpio.substring(fin).stripLeading();
            }
        }

        void encabezadoTabla() throws IOException {
            reservar(39);
            salida.setNonStrokingColor(0.89f, 0.94f, 0.91f);
            salida.addRect(MARGEN - 4, y - 5, ANCHO + 8, 18);
            salida.fill();
            celdas(negrita, "Lote", "Cantidad", "Precio unit.", "Descuento", "IVA", "Total línea");
        }

        void fila(String... valores) throws IOException {
            celdas(normal, valores);
        }

        private void celdas(PDType1Font fuente, String... valores) throws IOException {
            float anchoColumna = ANCHO / valores.length;
            for (int i = 0; i < valores.length; i++) {
                escribir(valores[i], MARGEN + i * anchoColumna, y, 9, fuente);
            }
            y -= 19;
        }

        void qr(String enlace) throws IOException, WriterException {
            if (enlace == null || enlace.isBlank()) return;
            BitMatrix matriz = new QRCodeWriter().encode(enlace, BarcodeFormat.QR_CODE, 1, 1);
            salida.setNonStrokingColor(0, 0, 0);
            float modulo = 108f / matriz.getWidth();
            for (int fila = 0; fila < matriz.getHeight(); fila++) {
                for (int columna = 0; columna < matriz.getWidth(); columna++) {
                    if (matriz.get(columna, fila)) {
                        salida.addRect(MARGEN + columna * modulo, y - (fila + 1) * modulo, modulo, modulo);
                    }
                }
            }
            salida.fill();
        }

        private void escribir(String texto, float x, float altura, int tamano, PDType1Font fuente) throws IOException {
            salida.setNonStrokingColor(0.08f, 0.19f, 0.14f);
            salida.beginText();
            salida.setFont(fuente, tamano);
            salida.newLineAtOffset(x, altura);
            salida.showText(texto);
            salida.endText();
        }

        @Override
        public void close() throws IOException {
            if (salida != null) salida.close();
        }
    }
}
