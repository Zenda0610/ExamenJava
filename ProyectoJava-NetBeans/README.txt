ERP FRESCURA TOTAL — CINCO INTEGRACIONES DE PRÁCTICA
Base del proyecto: rama Gaby, commit 63df8c1.

ABRIR EN NETBEANS
1. Extrae el ZIP completo.
2. En NetBeans abre File > Open Project y selecciona ProyectoJava-NetBeans,
   la carpeta que contiene pom.xml, nbactions.xml, src y este README.txt.
3. Usa JDK 26, como en el proyecto original. Ejecuta Clean and Build y luego
   Run Project (F6). El proyecto usa Maven.
4. Configura MySQL 8 en src/main/java/com/mycompany/proyectojava/common/
   connectionBD.java o mediante las propiedades erp.jdbc.url, erp.jdbc.user
   y erp.jdbc.password. La configuración original apunta al puerto 3307.
5. Base nueva de pruebas: ejecuta docs/database.sql. Ese script elimina y
   vuelve a crear el esquema erp_frescura_total. Si ya tienes el ERP con datos
   que quieres conservar, ejecuta únicamente docs/practice-update.sql.

DÓNDE ESTÁ CADA INTEGRACIÓN
Las rutas Java empiezan en src/main/java/com/mycompany/proyectojava/.

1. CACHÉ SINGLETON DE CLIENTES
   Menú Ventas > 6. Consultar Cliente por ID. También se usa al comprar
   desde Ventas > 3 o 5, antes de procesar FEFO.
   Código: sales/model/CustomerCache.java, sales/controller/CustomerService.java,
   sales/controller/SalesController.java y SalesDAO.findCustomerById.
   Prueba: en una sesión nueva consulta 5, 5, 8 y 999. La consola indica SQL
   para 5 y 8 la primera vez, caché para la segunda consulta de 5 y cliente
   no encontrado para 999. Inicia después una venta para 5 y comprueba que
   usa la misma caché. El caché dura lo que dure el proceso Java.

2. REPORTE DIARIO DE COMPRAS EN CSV
   Menú Proveedores y Compras > 6. Generar Reporte Diario de Compras.
   Código: suppliers/view/SupplierView.java, SupplierController.exportDailyPurchases,
   suppliers/controller/PurchaseReportService.java y suppliersDAO.findPurchasesOn.
   En este esquema cada compra es una recepción de lote. Se exporta id_lote,
   proveedor y cantidad_inicial por precio_compra. El archivo compras_AAAA-MM-DD.csv
   se crea en el directorio de ejecución. Cabecera exacta:
   NumeroCompra;NombreProveedor;MontoTotal
   Prueba: registra una recepción hoy y verifica proveedor, importe decimal
   y exclusión de ingresos anteriores. Sin compras hoy queda solo la cabecera.

3. TARIFA DE ENTREGA CON STRATEGY
   Menú Ventas > 3 o 5. Escoge ESTANDAR o URGENTE y confirma el importe mostrado.
   Código: sales/model/DeliveryStrategy.java, StandardDelivery.java,
   UrgentDelivery.java, sales/controller/DeliveryPricingService.java y
   SalesController.processOrder. El recargo se muestra en consola y PDF
   (InvoiceGenerator, InvoicePdf) y está incluido en el total persistido.
   El 12 % se aplica al total de la compra después de descuento e IVA.
   Prueba de cálculo (original -> final): estándar 100000 -> 100000 y
   50000 -> 50000; urgente 100000 -> 112000, 250000 -> 280000 y 0 -> 0.
   Si rechazas la confirmación, la venta no se registra ni descuenta inventario.

4. IMPORTACIÓN MASIVA DE CLIENTES
   Menú Ventas > 7. Importar Clientes desde Archivo.
   Código: SalesView.importCustomers, CustomerService.importCustomers y
   SalesDAO.insertImportedCustomers. Se valida primero el archivo completo
   y se guardan los registros juntos en una transacción.
   Edita clientes_importar.txt, incluido junto a README.md y pom.xml, en UTF-8.
   Cabecera exacta: nombre;documento;correo;telefono;tipo_cliente
   Prueba: importa el ejemplo y verifica 2 registros. Repite el archivo para
   comprobar el rechazo por duplicados de BD. Prueba también cambiando la
   cabecera, quitando un campo, duplicando un documento dentro del archivo
   y renombrando temporalmente el archivo. La línea vacía del ejemplo se ignora.

5. ESTADÍSTICAS COMERCIALES CON STREAM API
   Menú Ventas > 8. Generar Estadísticas Comerciales.
   Código: SalesDAO.findCommercialRows, sales/controller/CommercialStatistics.java
   y SalesController.showCommercialStatistics. Se agrupan cantidades exactas
   por categoría con BigDecimal y se deduplican clientes por su ID.
   Una venta confirmada por el ERP nace En Preparacion y luego puede estar
   En Transito o Entregada. Se consideran esos tres estados y Confirmada
   si está en el catálogo. Devuelta y Cancelada quedan fuera del volumen.
   Devuelta se añade al catálogo con el SQL. Para ensayar en una base de
   pruebas puedes marcar ventas de un mismo cliente así, sustituyendo 1 y 2
   por IDs reales de sus ventas:
   UPDATE ventas SET id_estado =
       (SELECT id_estado FROM estados_venta WHERE nombre = 'Devuelta')
       WHERE id_venta IN (1, 2);
   Verifica que ese cliente aparezca una sola vez, que las ventas devueltas
   no sumen y que el reporte funcione con o sin devoluciones.
