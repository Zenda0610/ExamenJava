
package com.mycompany.proyectojava.inventory.model;

import com.mycompany.proyectojava.common.connectionBD;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;



public class inventoryDAO {
    
        public int registroProductos(product producto){
            String sql = "INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base) VALUES (?,?,?,?,?)";

            try(Connection conn = connectionBD.getConnection();
                    PreparedStatement ps = conn.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
                ps.setString(1, producto.getNombre());
                ps.setString(2, producto.getDescripcion());
                ps.setInt(3, producto.getIdCategoria());
                ps.setString(4,producto.getUnidadMedida());
                ps.setBigDecimal(5, producto.getPrecioBase());  

                ps.executeUpdate();

                try(ResultSet rs = ps.getGeneratedKeys()){
                    return rs.next() ? rs.getInt(1) : -1;
                }
            }catch (SQLException e){
                System.out.println("Error al registrar el producto" + e.getMessage());
                return -1;
            }
        }
        public int registrarLote(lot lote){
        String sql = "INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial,"
                + " cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)"
                + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        
        try(Connection conn = connectionBD.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1, lote.getNumeroLote());
            ps.setInt(2, lote.getIdProducto());
            ps.setInt(3, lote.getIdProveedor());
            ps.setObject(4,lote.getFechaIngreso());
            ps.setDate(5, Date.valueOf(lote.getFechaVencimiento().toLocalDate()));
            ps.setBigDecimal(6, lote.getCantidadInicial());  
            ps.setBigDecimal(7, lote.getCantidad()); 
            ps.setBigDecimal(8, lote.getPrecioCompra());
            ps.setBigDecimal(9, lote.getPrecioVenta());
            ps.setString(10, lote.getPasillo()); 
            ps.setString(11, lote.getEstante()); 
            ps.setInt(12, lote.getIdEstado()); 
            
            ps.executeUpdate();
            
            try(ResultSet rs = ps.getGeneratedKeys()){
                return rs.next() ? rs.getInt(1) : -1;
            }
        }catch (SQLException e){
            System.out.println("Error al registrar el Lote" + e.getMessage());
            return -1;
        }
    }
        public void actualizarEstadosVencimientoAutomatico() {
        actualizarEstadosVencimientoAutomatico(true);
    }

        public void actualizarEstadosVencimientoAutomatico(boolean showMessages) {
        // 1. Pasar a Vencido (id_estado = 3) los que ya vencieron
        String sqlVencidos = "UPDATE lotes_inventario SET id_estado = 3 "
                           + "WHERE fecha_vencimiento < CURDATE() AND cantidad > 0 AND id_estado IN (1, 2)";

        // 2. Pasar a Proximo a Vencer (id_estado = 2) los que vencen en 7 días o menos
        String sqlProximos = "UPDATE lotes_inventario SET id_estado = 2 "
                           + "WHERE fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) "
                           + "AND cantidad > 0 AND id_estado = 1";

        try (Connection conn = connectionBD.getConnection();
             Statement stmt = conn.createStatement()) {

            int vencidos = stmt.executeUpdate(sqlVencidos);
            int proximos = stmt.executeUpdate(sqlProximos);
            if (showMessages) {
                System.out.println("[Sistema] Revisión diaria completada -> Nuevos Próximos a Vencer: " + proximos + " | Nuevos Vencidos: " + vencidos);
            }

        } catch (SQLException e) {
            if (showMessages) System.out.println("Error al actualizar estados de vencimiento: " + e.getMessage());
        }
    }
        
        // Pregunta A: "¿De qué proveedor vino el lote que está en el pasillo X y estante Y?"
        public List<String> buscarLotesPorUbicacion(String pasillo, String estante) {
        List<String> resultados = new ArrayList<>();
        String sql = "SELECT l.numero_lote, p.nombre AS producto, pr.nombre AS proveedor, l.cantidad, l.fecha_vencimiento, e.nombre AS estado "
                   + "FROM lotes_inventario l "
                   + "JOIN productos p ON l.id_producto = p.id_producto "
                   + "JOIN proveedores pr ON l.id_proveedor = pr.id_proveedor "
                   + "JOIN estados_lote e ON l.id_estado = e.id_estado "
                   + "WHERE l.pasillo = ? AND l.estante = ?";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, pasillo);
            ps.setString(2, estante);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String info = String.format("Lote: %s | Producto: %s | Proveedor: %s | Stock: %.2f | Vence: %s | Estado: %s",
                            rs.getString("numero_lote"), rs.getString("producto"), rs.getString("proveedor"),
                            rs.getDouble("cantidad"), rs.getDate("fecha_vencimiento"), rs.getString("estado"));
                    resultados.add(info);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error en trazabilidad por ubicación: " + e.getMessage());
        }
        return resultados;
    }
        
        // Pregunta B: "¿Qué clientes recibieron productos del lote XYZ que ahora está en revisión?"
    public List<String> buscarClientesPorNumeroLote(String numeroLote) {
        return buscarClientesPorNumeroLote(numeroLote, false);
    }

    public List<String> buscarClientesPorNumeroLote(String numeroLote, boolean deliveredOnly) {
        List<String> clientesAfectados = new ArrayList<>();
        String sql = "SELECT c.nombre AS cliente, c.documento, c.telefono, v.numero_venta, v.fecha_venta, dv.cantidad_vendida "
                   + "FROM detalles_venta dv "
                   + "JOIN lotes_inventario l ON dv.id_lote = l.id_lote "
                   + "JOIN ventas v ON dv.id_venta = v.id_venta "
                   + "JOIN clientes c ON v.id_cliente = c.id_cliente "
                   + "WHERE l.numero_lote = ?"
                   + (deliveredOnly ? " AND EXISTS (SELECT 1 FROM estados_venta e "
                        + "WHERE e.id_estado = v.id_estado AND e.nombre = 'Entregada')" : "");

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, numeroLote);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String info = String.format("Cliente: %-20s | Doc: %s | Tel: %s | Venta: %s | Fecha: %s | Cantidad recibida: %.2f",
                            rs.getString("cliente"), rs.getString("documento"), rs.getString("telefono"),
                            rs.getString("numero_venta"), rs.getTimestamp("fecha_venta"), rs.getDouble("cantidad_vendida"));
                    clientesAfectados.add(info);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al buscar clientes por lote: " + e.getMessage());
        }
        return clientesAfectados;
    }
    
        // Pregunta C: "¿Cuántas unidades nos quedan de los lotes que vencen en los próximos X días?" (o por código de lote)
    public lot buscarPorNumeroLote(String numeroLote) {
        String sql = "SELECT * FROM lotes_inventario WHERE numero_lote = ?";
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, numeroLote);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearLote(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al buscar lote: " + e.getMessage());
        }
        return null;
    }
    
    private lot mapearLote(ResultSet rs) throws SQLException {
        Timestamp tsIngreso = rs.getTimestamp("fecha_ingreso");
        LocalDateTime fechaIngreso = (tsIngreso != null) ? tsIngreso.toLocalDateTime() : null;
        Timestamp tsVencimiento = rs.getTimestamp("fecha_vencimiento");
        LocalDateTime fechaVencimiento = (tsVencimiento != null) ? tsVencimiento.toLocalDateTime() : null;

        return new lot(
                rs.getInt("id_lote"),
                rs.getString("numero_lote"),
                rs.getInt("id_producto"),
                rs.getInt("id_proveedor"),
                fechaIngreso,
                fechaVencimiento,
                rs.getBigDecimal("cantidad_inicial"),
                rs.getBigDecimal("cantidad"),
                rs.getBigDecimal("precio_compra"),
                rs.getBigDecimal("precio_venta"),
                rs.getString("pasillo"),
                rs.getString("estante"),
                rs.getInt("id_estado")
        );
    }
    
    // Listar todos los lotes en bodega
    public List<lot> listarTodosLosLotes() {
        List<lot> lista = new ArrayList<>();
        String sql = "SELECT * FROM lotes_inventario ORDER BY fecha_vencimiento ASC";
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearLote(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error al listar lotes: " + e.getMessage());
        }
        return lista;
    }
    // A) Enviar un lote a Cuarentena (Cambia estado del lote a 4 = en cuarentena)
    public boolean enviarACuarentena(QuarantineRecord cuarentena) {
        String sqlInsert = "INSERT INTO registro_cuarentena (id_lote, motivo, usuario, resuelta) VALUES (?, ?, ?, false)";
        String sqlUpdateLote = "UPDATE lotes_inventario SET id_estado = 4 WHERE id_lote = ? AND cantidad > 0 AND id_estado <> 4";

        Connection conn = null;
        try {
            conn = connectionBD.getConnection();
            conn.setAutoCommit(false); // Iniciar transacción

            try (PreparedStatement ps1 = conn.prepareStatement(sqlInsert);
                 PreparedStatement ps2 = conn.prepareStatement(sqlUpdateLote)) {

                ps2.setInt(1, cuarentena.getIdLote());
                if (ps2.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
                ps1.setInt(1, cuarentena.getIdLote());
                ps1.setString(2, cuarentena.getMotivo());
                ps1.setString(3, cuarentena.getUsuario());
                ps1.executeUpdate();

            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.out.println("Error al poner lote en cuarentena: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    // B) Inspeccionar Lote en Cuarentena:
    // Si aprobado == true -> Vuelve a Available (id_estado = 1)
    // Si aprobado == false (Rechazado) -> Se convierte en merma total y el stock pasa a 0
    public boolean inspeccionarLoteEnCuarentena(int idLote, boolean aprobado, String nombreInspector, String motivoRechazo, String notas) {
        String resultadoEnum = aprobado ? "Aprobado" : "Rechazado";
        String sqlInspeccion = "INSERT INTO inspecciones_calidad (id_lote, resultado, nombre_inspector, motivo_rechazo, notas) VALUES (?,?,?,?,?)";
        String sqlResolverCuarentena = "UPDATE registro_cuarentena SET resuelta = true, fecha_resolucion = NOW(), notas_resolucion = ? WHERE id_lote = ? AND resuelta = false";

        Connection conn = null;
        try {
            conn = connectionBD.getConnection();
            conn.setAutoCommit(false);

            BigDecimal stockActual;
            try (PreparedStatement psStock = conn.prepareStatement(
                    "SELECT cantidad FROM lotes_inventario WHERE id_lote = ? AND id_estado = 4 AND cantidad > 0 FOR UPDATE")) {
                psStock.setInt(1, idLote);
                try (ResultSet rs = psStock.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    stockActual = rs.getBigDecimal("cantidad");
                }
            }
            int idInspeccionGenerada = -1;

            // 1. Insertar la inspección de calidad
            try (PreparedStatement psInsp = conn.prepareStatement(sqlInspeccion, Statement.RETURN_GENERATED_KEYS)) {
                psInsp.setInt(1, idLote);
                psInsp.setString(2, resultadoEnum);
                psInsp.setString(3, nombreInspector);
                psInsp.setString(4, aprobado ? null : motivoRechazo);
                psInsp.setString(5, notas);
                psInsp.executeUpdate();

                try (ResultSet rs = psInsp.getGeneratedKeys()) {
                    if (rs.next()) idInspeccionGenerada = rs.getInt(1);
                }
            }
            // 2. Marcar el registro de cuarentena como resuelto
            try (PreparedStatement psCuar = conn.prepareStatement(sqlResolverCuarentena)) {
                psCuar.setString(1, "Inspección: " + resultadoEnum + " - " + (notas != null ? notas : ""));
                psCuar.setInt(2, idLote);
                if (psCuar.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 3. Decidir el destino del lote según el resultado
            if (aprobado) {
                // Vuelve a disponible (1)
                String sqlAprobar = "UPDATE lotes_inventario SET id_estado = CASE "
                        + "WHEN fecha_vencimiento < CURDATE() THEN 3 "
                        + "WHEN fecha_vencimiento <= DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN 2 "
                        + "ELSE 1 END WHERE id_lote = ?";
                try (PreparedStatement psUpd = conn.prepareStatement(sqlAprobar)) {
                    psUpd.setInt(1, idLote);
                    psUpd.executeUpdate();
                }
            } else {
                // Rechazado: Consultar cuánto stock tenía, enviarlo a registro_mermas y dejar cantidad = 0

                String sqlMerma = "INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, usuario_registro) VALUES (?,?,?,?,?)";
                try (PreparedStatement psMerma = conn.prepareStatement(sqlMerma)) {
                    psMerma.setInt(1, idLote);
                    psMerma.setInt(2, idInspeccionGenerada);
                    psMerma.setBigDecimal(3, stockActual);
                    psMerma.setString(4, "Rechazado en inspección: " + motivoRechazo);
                    psMerma.setString(5, nombreInspector);
                    psMerma.executeUpdate();
                }

                // Mantener el lote bloqueado con saldo cero.
                String sqlBajaLote = "UPDATE lotes_inventario SET cantidad = 0 WHERE id_lote = ?";
                try (PreparedStatement psBaja = conn.prepareStatement(sqlBajaLote)) {
                    psBaja.setInt(1, idLote);
                    psBaja.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.out.println("Error al procesar la inspección de calidad: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    // C) Registrar Merma directa (por vencimiento o daño parcial sin cuarentena)
public boolean registrarMermaDirecta(int idLote, BigDecimal cantidadPerdida, String motivo, String usuario) {
    // 1. Incluimos explícitamente fecha_registro con NOW() para asegurar consistencia con LocalDateTime
    String sqlMerma = "INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro) VALUES (?, NULL, ?, ?, NOW(), ?)";
    
    if (cantidadPerdida.signum() <= 0 || cantidadPerdida.stripTrailingZeros().scale() > 2) {
        return false;
    }
    String sqlDescontar = "UPDATE lotes_inventario SET cantidad = cantidad - ? "
                        + "WHERE id_lote = ? AND cantidad >= ? AND id_estado <> 4";

    Connection conn = null;
    try {
        conn = connectionBD.getConnection();
        conn.setAutoCommit(false); // Inicio de transacción segura

        // Paso A: Descontar del inventario y validar que haya suficiente stock
        try (PreparedStatement psDescontar = conn.prepareStatement(sqlDescontar)) {
            psDescontar.setBigDecimal(1, cantidadPerdida);
            psDescontar.setInt(2, idLote);
            psDescontar.setBigDecimal(3, cantidadPerdida);

            int actualizados = psDescontar.executeUpdate();
            if (actualizados == 0) {
                conn.rollback();
                System.out.println("[Error] Lote inexistente, en cuarentena o sin suficiente stock.");
                return false;
            }
        }

        // Paso B: Registrar el historial en la tabla registro_mermas
        try (PreparedStatement psMerma = conn.prepareStatement(sqlMerma)) {
            psMerma.setInt(1, idLote);
            psMerma.setBigDecimal(2, cantidadPerdida);
            psMerma.setString(3, motivo);
            psMerma.setString(4, usuario);
            psMerma.executeUpdate();
        }

        conn.commit(); // Confirmar transacción completa
        return true;

    } catch (SQLException e) {
        if (conn != null) {
            try { 
                conn.rollback(); 
            } catch (SQLException ex) { 
                ex.printStackTrace(); 
            }
        }
        System.out.println("[Error de BD] Al registrar merma: " + e.getMessage());
        return false;
    } finally {
        if (conn != null) {
            try { 
                conn.setAutoCommit(true); 
                conn.close(); 
            } catch (SQLException e) { 
                e.printStackTrace(); 
            }
        }
    }
}

}
