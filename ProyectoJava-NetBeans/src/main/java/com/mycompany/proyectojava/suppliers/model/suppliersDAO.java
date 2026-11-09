
package com.mycompany.proyectojava.suppliers.model;


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


public class suppliersDAO {
    // =========================================================================
    // 1. REGISTRAR UN NUEVO PROVEEDOR
    // =========================================================================

    public record Purchase(int number, String supplier, java.math.BigDecimal total) {}

    public List<Purchase> findPurchasesOn(java.time.LocalDate date) throws SQLException {
        String sql = """
                SELECT l.id_lote, p.nombre, l.cantidad_inicial * l.precio_compra AS total
                FROM lotes_inventario l
                JOIN proveedores p ON p.id_proveedor = l.id_proveedor
                WHERE l.fecha_ingreso >= ? AND l.fecha_ingreso < ?
                ORDER BY l.id_lote
                """;
        List<Purchase> purchases = new ArrayList<>();
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement statement = conn.prepareStatement(sql)) {
            statement.setObject(1, date.atStartOfDay());
            statement.setObject(2, date.plusDays(1).atStartOfDay());
            try (ResultSet rows = statement.executeQuery()) {
                while (rows.next()) {
                    purchases.add(new Purchase(rows.getInt(1), rows.getString(2), rows.getBigDecimal(3)));
                }
            }
        }
        return purchases;
    }

    public int registrarProveedor(Supplier proveedor) {
        String sql = "INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, proveedor.getNombre());
            ps.setString(2, proveedor.getNit());
            ps.setString(3, proveedor.getPersonaContacto());
            ps.setString(4, proveedor.getEmail());
            ps.setString(5, proveedor.getTelefono());
            ps.setString(6, proveedor.getDireccion());
            ps.setBoolean(7, proveedor.isActivo());

            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }

        } catch (SQLException e) {
            System.out.println("Error al registrar el proveedor: " + e.getMessage());
            return -1;
        }
    }

    // =========================================================================
    // 2. CONSULTAR TODOS LOS PROVEEDORES ACTIVOS
    // =========================================================================
    public List<Supplier> listarProveedoresActivos() {
        List<Supplier> lista = new ArrayList<>();
        String sql = "SELECT * FROM proveedores WHERE activo = true ORDER BY nombre ASC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearProveedor(rs));
            }

        } catch (SQLException e) {
            System.out.println("Error al listar proveedores: " + e.getMessage());
        }
        return lista;
    }

    // =========================================================================
    // 3. ASOCIAR UN PRODUCTO A UN PROVEEDOR (Tabla intermedia productos_proveedor)
    // =========================================================================
    public boolean asociarProductoProveedor(int idProveedor, int idProducto) {
        String sql = "INSERT INTO productos_proveedor (id_proveedor, id_producto) VALUES (?, ?)";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idProveedor);
            ps.setInt(2, idProducto);
            
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error al asociar producto con proveedor (quizás ya está asociado): " + e.getMessage());
            return false;
        }
    }

    // =========================================================================
    // 4. CONSULTAR QUÉ PRODUCTOS SURTE UN PROVEEDOR ESPECÍFICO
    // =========================================================================
    public List<String> obtenerProductosDeProveedor(int idProveedor) {
        List<String> productos = new ArrayList<>();
        String sql = "SELECT p.id_producto, p.nombre, p.unidad_medida, p.precio_base "
                   + "FROM productos p "
                   + "JOIN productos_proveedor pp ON p.id_producto = pp.id_producto "
                   + "WHERE pp.id_proveedor = ?";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idProveedor);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String info = String.format("ID Prod: %d | Nombre: %-20s | Unidad: %s | P.Base: $%.2f",
                            rs.getInt("id_producto"),
                            rs.getString("nombre"),
                            rs.getString("unidad_medida"),
                            rs.getDouble("precio_base"));
                    productos.add(info);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error al consultar productos del proveedor: " + e.getMessage());
        }
        return productos;
    }

    // =========================================================================
    // MÉTODO AUXILIAR PRIVADO PARA MAPEAR EL RESULTSET A LA CLASE SUPPLIER
    // =========================================================================
    private Supplier mapearProveedor(ResultSet rs) throws SQLException {
        Timestamp tsRegistro = rs.getTimestamp("fecha_registro");
        LocalDateTime fechaRegistro = (tsRegistro != null) ? tsRegistro.toLocalDateTime() : null;

        // Asegúrate de que tu clase Supplier tenga un constructor que reciba estos campos
        return new Supplier(
                rs.getInt("id_proveedor"),
                rs.getString("nombre"),
                rs.getString("nit"),
                rs.getString("persona_contacto"),
                rs.getString("email"),
                rs.getString("telefono"),
                rs.getString("direccion"),
                rs.getBoolean("activo"),
                fechaRegistro
        );
    }
    
    
    // =========================================================================
    // 5. HISTORIAL DE COMPRAS Y ENTREGAS (Evaluación de fiabilidad del proveedor)
    // =========================================================================
    public List<String> obtenerHistorialCompras(int idProveedor) {
        List<String> historial = new ArrayList<>();
        // Relaciona los lotes que ingresaron a bodega con los productos y su estado actual
        String sql = "SELECT l.numero_lote, p.nombre AS producto, l.cantidad_inicial, l.fecha_ingreso, l.fecha_vencimiento, l.precio_compra, e.nombre AS estado "
                   + "FROM lotes_inventario l "
                   + "JOIN productos p ON l.id_producto = p.id_producto "
                   + "JOIN estados_lote e ON l.id_estado = e.id_estado "
                   + "WHERE l.id_proveedor = ? "
                   + "ORDER BY l.fecha_ingreso DESC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idProveedor);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String info = String.format("Lote: %s | Producto: %-18s | Cant. Ingresada: %7.2f | Ingreso: %s | Vence: %s | P.Compra: $%.2f | Estado Lote: %s",
                            rs.getString("numero_lote"),
                            rs.getString("producto"),
                            rs.getDouble("cantidad_inicial"),
                            rs.getTimestamp("fecha_ingreso"),
                            rs.getDate("fecha_vencimiento"),
                            rs.getDouble("precio_compra"),
                            rs.getString("estado"));
                    historial.add(info);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error al consultar el historial de compras del proveedor: " + e.getMessage());
        }
        return historial;
    }
}