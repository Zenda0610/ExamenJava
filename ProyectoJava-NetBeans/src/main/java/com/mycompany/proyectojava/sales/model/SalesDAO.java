
package com.mycompany.proyectojava.sales.model;

import com.mycompany.proyectojava.inventory.model.lot;

import com.mycompany.proyectojava.common.connectionBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class SalesDAO {

    public java.util.Optional<java.math.BigDecimal> findActiveDiscount(int productId, int lotStatus) throws SQLException {
        String sql = """
                SELECT promo.tasa_descuento
                FROM promociones promo JOIN productos p ON p.id_producto = ?
                WHERE promo.activa = TRUE
                  AND promo.tasa_descuento BETWEEN 0 AND 1
                  AND (promo.fecha_inicio IS NULL OR promo.fecha_inicio <= CURDATE())
                  AND (promo.fecha_fin IS NULL OR promo.fecha_fin >= CURDATE())
                  AND (promo.aplica_estado_lote IS NULL OR promo.aplica_estado_lote = ?)
                  AND (promo.aplica_categoria_producto IS NULL OR promo.aplica_categoria_producto = p.id_categoria)
                ORDER BY (promo.aplica_categoria_producto IS NOT NULL) DESC,
                         (promo.aplica_estado_lote IS NOT NULL) DESC,
                         promo.tasa_descuento DESC, promo.id_promocion
                LIMIT 1
                """;
        try (Connection connection = connectionBD.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            statement.setInt(2, lotStatus);
            try (ResultSet result = statement.executeQuery()) {
                return result.next()
                        ? java.util.Optional.of(result.getBigDecimal("tasa_descuento").movePointRight(2))
                        : java.util.Optional.empty();
            }
        }
    }

    public record DatosFactura(String empresa, String nit, String direccion, String producto) {}

    public DatosFactura obtenerDatosFactura(int idProducto) {
        String sql = "SELECT p.nombre AS producto, e.nombre_empresa, e.nit, e.direccion "
                + "FROM productos p LEFT JOIN informacion_empresa e "
                + "ON e.id_empresa = (SELECT MIN(id_empresa) FROM informacion_empresa) WHERE p.id_producto = ?";
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idProducto);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new DatosFactura(
                            java.util.Objects.toString(rs.getString("nombre_empresa"), "Frescura Total S.A.S."),
                            java.util.Objects.toString(rs.getString("nit"), "Sin NIT registrado"),
                            rs.getString("direccion"), rs.getString("producto"));
                }
            }
        } catch (SQLException e) {
            System.out.println("No se pudieron consultar los datos del emisor: " + e.getMessage());
        }
        return new DatosFactura("Frescura Total S.A.S.", "Sin NIT registrado", "", "Producto ID " + idProducto);
    }
    
    // =========================================================================
    // 1. GESTIÓN DE CLIENTES (Tabla: clientes)
    // =========================================================================


    public java.util.Optional<customer> findCustomerById(int id) throws SQLException {
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement statement = conn.prepareStatement("SELECT * FROM clientes WHERE id_cliente = ?")) {
            statement.setInt(1, id);
            try (ResultSet row = statement.executeQuery()) {
                if (!row.next()) return java.util.Optional.empty();
                Timestamp registered = row.getTimestamp("fecha_registro");
                return java.util.Optional.of(new customer(id, row.getString("nombre"),
                        row.getString("documento"), row.getString("email"), row.getString("telefono"),
                        row.getString("direccion"), row.getInt("id_tipo"),
                        registered == null ? null : registered.toLocalDateTime()));
            }
        }
    }

    public record CustomerImportRow(String name, String document, String email, String phone, String type) {}

    public int insertImportedCustomers(List<CustomerImportRow> customers) throws SQLException {
        if (customers.isEmpty()) return 0;
        String insertSql = """
                INSERT INTO clientes (nombre, documento, email, telefono, id_tipo)
                VALUES (?, ?, ?, ?, (SELECT id_tipo FROM tipos_cliente WHERE UPPER(nombre) = ?))
                """;
        try (Connection conn = connectionBD.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement exists = conn.prepareStatement("SELECT 1 FROM clientes WHERE documento = ?");
                 PreparedStatement insert = conn.prepareStatement(insertSql)) {
                for (CustomerImportRow row : customers) {
                    exists.setString(1, row.document());
                    try (ResultSet result = exists.executeQuery()) {
                        if (result.next()) {
                            throw new IllegalArgumentException("Documento ya registrado: " + row.document());
                        }
                    }
                }
                for (CustomerImportRow row : customers) {
                    insert.setString(1, row.name());
                    insert.setString(2, row.document());
                    insert.setString(3, row.email());
                    insert.setString(4, row.phone());
                    insert.setString(5, row.type());
                    insert.executeUpdate();
                }
                conn.commit();
                return customers.size();
            } catch (SQLException | RuntimeException failure) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackFailure) {
                    failure.addSuppressed(rollbackFailure);
                }
                throw failure;
            }
        }
    }

    public int registrarCliente(customer cliente) {
        String sql = "INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo, fecha_registro) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, cliente.getNombre());
            ps.setString(2, cliente.getDocumento());
            ps.setString(3, cliente.getEmail());
            ps.setString(4, cliente.getNumero());
            ps.setString(5, cliente.getDireccion());
            ps.setInt(6, cliente.getIdTipo());
            ps.setObject(7, cliente.getFechaRegistro());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }

        } catch (SQLException e) {
            System.out.println("Error al registrar el cliente: " + e.getMessage());
            return -1;
        }
    }

    public List<customer> listarClientesActivos() {
        List<customer> lista = new ArrayList<>();
        String sql = "SELECT * FROM clientes ORDER BY nombre ASC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Timestamp tsReg = rs.getTimestamp("fecha_registro");
                lista.add(new customer(
                        rs.getInt("id_cliente"),
                        rs.getString("nombre"),
                        rs.getString("documento"),
                        rs.getString("email"),                                              
                        rs.getString("telefono"),
                        rs.getString("direccion"),
                        rs.getInt("id_tipo"),
                        tsReg != null ? tsReg.toLocalDateTime() : null
                ));
            }
        } catch (SQLException e) {
            System.out.println("Error al listar clientes: " + e.getMessage());
        }
        return lista;
    }

    // =========================================================================
    // 2. CONSULTA FEFO (First Expired, First Out) PARA VENTAS
    // =========================================================================

    /**
     * Obtiene los lotes aptos para la venta de un producto ordenados por fecha de vencimiento más cercana (FEFO).
     * SOLO permite estados 1 (Available) y 2 (Near Expiry). Bloquea Vencidos (3) y En Cuarentena (4).
     */
    public List<lot> obtenerLotesDisponiblesFEFO(int idProducto) {
        List<lot> lotesDisponibles = new ArrayList<>();
        String sql = "SELECT * FROM lotes_inventario "
                   + "WHERE id_producto = ? AND cantidad > 0 AND id_estado IN (1, 2) AND fecha_vencimiento >= CURDATE() "
                   + "ORDER BY fecha_vencimiento ASC, fecha_ingreso ASC, id_lote ASC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idProducto);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp tsIng = rs.getTimestamp("fecha_ingreso");
                    Timestamp tsVen = rs.getTimestamp("fecha_vencimiento");

                    lotesDisponibles.add(new lot(
                            rs.getInt("id_lote"),
                            rs.getString("numero_lote"),
                            rs.getInt("id_producto"),
                            rs.getInt("id_proveedor"),
                            tsIng != null ? tsIng.toLocalDateTime() : null,
                            tsVen != null ? tsVen.toLocalDateTime() : null,
                            rs.getBigDecimal("cantidad_inicial"),
                            rs.getBigDecimal("cantidad"),
                            rs.getBigDecimal("precio_compra"),
                            rs.getBigDecimal("precio_venta"),
                            rs.getString("pasillo"),
                            rs.getString("estante"),
                            rs.getInt("id_estado")
                    ));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al buscar lotes bajo estrategia FEFO: " + e.getMessage());
        }
        return lotesDisponibles;
    }

    // =========================================================================
    // 3. PROCESAR VENTA CON TRANSACCIÓN Y DESCUENTO AUTOMÁTICO DE STOCK
    // =========================================================================

    
    public int registrarVentaCompleta(sale venta, List<saleDetail> detalles, Invoice factura) {
        if (factura == null || detalles.isEmpty() || detalles.stream().anyMatch(detalle ->
                detalle.getCantidadVendida() == null || detalle.getCantidadVendida().signum() <= 0
                        || detalle.getCantidadVendida().stripTrailingZeros().scale() > 2)) {
            return -1;
        }
        String sqlVenta = "INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String sqlDetalle = "INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea) "
                          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String sqlDescontarLote = "UPDATE lotes_inventario "
                                + "SET cantidad = cantidad - ? "
                                + "WHERE id_lote = ? AND cantidad >= ? AND id_estado IN (1, 2) "
                                + "AND fecha_vencimiento >= CURDATE()";

        Connection conn = null;
        try {
            conn = connectionBD.getConnection();
            conn.setAutoCommit(false); // Iniciar transacción atómica

            int idVentaGenerada = -1;

            // 1. Insertar la cabecera de la venta
            try (PreparedStatement psVenta = conn.prepareStatement(sqlVenta, Statement.RETURN_GENERATED_KEYS)) {
                psVenta.setString(1, venta.getNumeroVenta());
                psVenta.setInt(2, venta.getIdCliente());
                psVenta.setObject(3, venta.getFechaVenta() != null ? venta.getFechaVenta() : LocalDateTime.now());
                psVenta.setBigDecimal(4, venta.getSubTotal());
                psVenta.setBigDecimal(5, venta.getTotalDescuento());
                psVenta.setBigDecimal(6, venta.getTotalImpuesto());
                psVenta.setBigDecimal(7, venta.getMontoTotal());
                psVenta.setInt(8, venta.getIdEstado() > 0 ? venta.getIdEstado() : 1);
                psVenta.setString(9, venta.getUsuarioRegistro ());

                psVenta.executeUpdate();
                try (ResultSet rs = psVenta.getGeneratedKeys()) {
                    if (rs.next()) {
                        idVentaGenerada = rs.getInt(1);
                    }
                }
            }

            if (idVentaGenerada <= 0) {
                conn.rollback();
                return -1;
            }

            // 2. Insertar cada detalle y descontar del lote correspondiente
            try (PreparedStatement psDet = conn.prepareStatement(sqlDetalle);
                 PreparedStatement psLote = conn.prepareStatement(sqlDescontarLote)) {

                for (saleDetail det : detalles) {
                    // Descontar stock del lote verificando disponibilidad
                    psLote.setBigDecimal(1, det.getCantidadVendida());
                    psLote.setInt(2, det.getIdLote());
                    psLote.setBigDecimal(3, det.getCantidadVendida());

                    int filasActualizadas = psLote.executeUpdate();
                    if (filasActualizadas == 0) {
                        conn.rollback();
                        System.out.println("Error: Stock insuficiente o lote bloqueado para el Lote ID " + det.getIdLote());
                        return -1;
                    }

                    // Registrar el detalle de la venta vinculado al lote exacto (Trazabilidad)
                    psDet.setInt(1, idVentaGenerada);
                    psDet.setInt(2, det.getIdLote());
                    psDet.setBigDecimal(3, det.getCantidadVendida());
                    psDet.setBigDecimal(4, det.getPrecioUnitario());
                    psDet.setBigDecimal(5, det.getDescuentAplicado());
                    psDet.setBigDecimal(6, det.getMontoDescuento());
                    psDet.setBigDecimal(7, det.getTasaImpuesto());
                    psDet.setBigDecimal(8, det.getMontoImpuesto());
                    psDet.setBigDecimal(9, det.getSubTotal());
                    psDet.setBigDecimal(10, det.getTotalLinea());
                    psDet.executeUpdate();
                }
            }

            int idFactura = generarFactura(conn, factura, idVentaGenerada);
            if (idFactura <= 0) {
                throw new SQLException("La factura no devolvió un ID.");
            }
            conn.commit();
            factura.setIdVenta(idVentaGenerada);
            factura.setIdFactura(idFactura);
            return idVentaGenerada;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            System.out.println("Error al procesar la venta: " + e.getMessage());
            return -1;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        }
    }

    // =========================================================================
    // 4. GENERACIÓN DE FACTURA (Tabla: facturas)
    // =========================================================================

    private int generarFactura(Connection conn, Invoice factura, int idVenta) throws SQLException {
        String sql = "INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, idVenta);
            ps.setString(2, factura.getNumeroFactura());
            ps.setString(3, factura.getCufe());
            ps.setString(4, factura.getEnlaceQr());
            ps.setObject(5, factura.getFechaEmision() != null ? factura.getFechaEmision() : LocalDateTime.now());
            ps.setBigDecimal(6, factura.getSubtotal());
            ps.setBigDecimal(7, factura.getTotalDescuento());
            ps.setBigDecimal(8, factura.getMontoImpuesto());
            ps.setBigDecimal(9, factura.getMontoTotal());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }

        }
    }

    // =========================================================================
    // 5. HISTORIAL Y REPORTE DE VENTAS
    // =========================================================================


    public record CommercialRow(int saleId, java.math.BigDecimal quantity, String category,
                                int customerId, String customerName, String status) {}

    public List<CommercialRow> findCommercialRows() throws SQLException {
        String sql = """
                SELECT l.id_lote, p.nombre AS nombre_proveedor, l.cantidad_inicial AS cantidad_comprada,
                       e.nombre AS estado
                FROM lotes_inventario l
                JOIN proveedores p ON p.id_proveedor = l.id_proveedor
                JOIN estados_lote e ON l.id_estado = e.id_estado     
                """;
        List<CommercialRow> details = new ArrayList<>();
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement statement = conn.prepareStatement(sql);
             ResultSet rows = statement.executeQuery()) {
            while (rows.next()) {
                details.add(new CommercialRow(rows.getInt("id_lote"), rows.getBigDecimal("cantidad_comprada"),
                        rows.getString("estado")));
            }
        }
        return details;
    }

    public List<String> listarResumenVentas() {
        List<String> lista = new ArrayList<>();
        String sql = "SELECT l.id_lote, l.cantidad_inicial, e.nombre AS estado_lote, p.id_proveedor, "
           + "p.nombre AS nombre_proveedor "
           + "FROM lotes_inventario l "
           + "INNER JOIN proveedores p ON l.id_proveedor = p.id_proveedor "
           + "INNER JOIN estados_lote e ON l.id_estado = e.id_estado";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String info = String.format("[%d] Cantidad Inicial: $%.2f | Estado: %s | ID Proveedor: %-15s | Nombre Proveedor: %-20s ",
                        rs.getInt("id_lote"),
                        rs.getBigDecimal("cantidad_inicial"),
                        rs.getString("estado_lote"),
                        rs.getInt("id_proveedor"),
                        rs.getInt("nombre_proveedor"));
                lista.add(info);
            }

        } catch (SQLException e) {
            System.out.println("Error al listar el historial de ventas: " + e.getMessage());
        }
        return lista;
    }
}
    
