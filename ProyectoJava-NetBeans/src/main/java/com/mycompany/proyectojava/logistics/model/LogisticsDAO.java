
package com.mycompany.proyectojava.logistics.model;

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

public class LogisticsDAO {
    
    // =========================================================================
    // 1. GESTIÓN DE RUTAS DE ENTREGA (Tabla: rutas_entrega)
    // =========================================================================

    // Registrar una ruta completa usando los atributos de tu modelo (horas estimadas y estado)
    public int registrarRuta(DeliveryRoute ruta) {
        String sql = "INSERT INTO rutas_entrega (nombre_ruta, fecha_creacion, usuario_creacion, "
                   + "hora_salida_estimada, hora_llegada_estimada, estado) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, ruta.getNombreRuta());
            ps.setObject(2, ruta.getFechaCreacion() != null ? ruta.getFechaCreacion() : LocalDateTime.now());
            ps.setString(3, ruta.getUsuarioCreacion());
            ps.setObject(4, ruta.getHoraSalidaEstimada());
            ps.setObject(5, ruta.getHoraLlegadaEstimada());
            ps.setString(6, (ruta.getEstado() != null && !ruta.getEstado().isEmpty()) ? ruta.getEstado() : "Planificada");

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }

        } catch (SQLException e) {
            System.out.println("Error al registrar la ruta de entrega: " + e.getMessage());
            return -1;
        }
    }

    public boolean registrarSalidaRealRuta(int idRuta, LocalDateTime horaSalidaReal) {
        return actualizarRecorrido(idRuta, horaSalidaReal, false);
    }

    public boolean registrarLlegadaRealRuta(int idRuta, LocalDateTime horaLlegadaReal) {
        return actualizarRecorrido(idRuta, horaLlegadaReal, true);
    }

    private boolean actualizarRecorrido(int idRuta, LocalDateTime hora, boolean finaliza) {
        // Las columnas DATETIME del esquema guardan segundos enteros.
        LocalDateTime momento = (hora != null ? hora : LocalDateTime.now()).withNano(0);
        String sqlRuta = finaliza
                ? "UPDATE rutas_entrega SET hora_llegada_real = ?, estado = 'Completada' "
                    + "WHERE id_ruta = ? AND estado = 'En Transito' AND hora_salida_real <= ?"
                : "UPDATE rutas_entrega SET hora_salida_real = ?, estado = 'En Transito' "
                    + "WHERE id_ruta = ? AND estado = 'Planificada' "
                    + "AND EXISTS (SELECT 1 FROM asignaciones_entrega a JOIN vehiculos v ON v.id_vehiculo = a.id_vehiculo "
                    + "JOIN conductores c ON c.id_conductor = a.id_conductor "
                    + "WHERE a.id_ruta = rutas_entrega.id_ruta AND v.estado = 'Activo' AND c.activo)";
        String sqlVentas = "UPDATE ventas v JOIN ventas_ruta vr ON v.id_venta = vr.id_venta "
                + "JOIN estados_venta anterior ON anterior.id_estado = v.id_estado "
                + "JOIN estados_venta siguiente ON siguiente.nombre = ? "
                + "SET v.id_estado = siguiente.id_estado WHERE vr.id_ruta = ? AND anterior.nombre = ?";
        try (Connection conn = connectionBD.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ruta = conn.prepareStatement(sqlRuta);
                 PreparedStatement ventas = conn.prepareStatement(sqlVentas)) {
                ruta.setObject(1, momento);
                ruta.setInt(2, idRuta);
                if (finaliza) ruta.setObject(3, momento);
                if (ruta.executeUpdate() != 1) {
                    conn.rollback();
                    return false;
                }
                ventas.setString(1, finaliza ? "Entregada" : "En Transito");
                ventas.setInt(2, idRuta);
                ventas.setString(3, finaliza ? "En Transito" : "En Preparacion");
                ventas.executeUpdate();
                if (finaliza) {
                    try (PreparedStatement entregas = conn.prepareStatement(
                            "UPDATE ventas_ruta vr JOIN ventas v ON v.id_venta = vr.id_venta "
                            + "JOIN estados_venta e ON e.id_estado = v.id_estado "
                            + "SET vr.fecha_entrega = ? WHERE vr.id_ruta = ? AND e.nombre = 'Entregada' AND vr.fecha_entrega IS NULL")) {
                        entregas.setObject(1, momento);
                        entregas.setInt(2, idRuta);
                        entregas.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            System.out.println("Error al actualizar el recorrido: " + e.getMessage());
            return false;
        }
    }

    public List<String> listarPedidosPendientes() {
        List<String> pedidos = new ArrayList<>();
        String sql = "SELECT v.id_venta, v.numero_venta, c.nombre, c.direccion FROM ventas v "
                + "JOIN clientes c ON c.id_cliente = v.id_cliente "
                + "JOIN estados_venta e ON e.id_estado = v.id_estado "
                + "WHERE e.nombre = 'En Preparacion' "
                + "AND NOT EXISTS (SELECT 1 FROM ventas_ruta vr WHERE vr.id_venta = v.id_venta) ORDER BY v.fecha_venta";
        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                pedidos.add(String.format("[%d] %s | %s | %s", rs.getInt("id_venta"),
                        rs.getString("numero_venta"), rs.getString("nombre"), rs.getString("direccion")));
            }
        } catch (SQLException e) {
            System.out.println("Error al listar pedidos pendientes: " + e.getMessage());
        }
        return pedidos;
    }

    public boolean vincularPedido(int idRuta, int idVenta, int orden, String direccion) {
        if (orden < 1 || direccion == null || direccion.isBlank()) return false;
        String rutaSql = "SELECT id_ruta FROM rutas_entrega WHERE id_ruta = ? AND estado = 'Planificada' FOR UPDATE";
        String ventaSql = "SELECT v.id_venta FROM ventas v JOIN estados_venta e ON e.id_estado = v.id_estado "
                + "WHERE v.id_venta = ? AND e.nombre = 'En Preparacion' FOR UPDATE";
        String enlaceSql = "SELECT id FROM ventas_ruta WHERE id_venta = ? FOR UPDATE";
        try (Connection conn = connectionBD.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ruta = conn.prepareStatement(rutaSql);
                 PreparedStatement venta = conn.prepareStatement(ventaSql);
                 PreparedStatement enlace = conn.prepareStatement(enlaceSql);
                 PreparedStatement insertar = conn.prepareStatement(
                         "INSERT INTO ventas_ruta (id_ruta, id_venta, orden_entrega, direccion_destino) VALUES (?, ?, ?, ?)")) {
                ruta.setInt(1, idRuta);
                venta.setInt(1, idVenta);
                enlace.setInt(1, idVenta);
                if (!existe(ruta) || !existe(venta) || existe(enlace)) {
                    conn.rollback();
                    return false;
                }
                insertar.setInt(1, idRuta);
                insertar.setInt(2, idVenta);
                insertar.setInt(3, orden);
                insertar.setString(4, direccion);
                insertar.executeUpdate();
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            System.out.println("Error al vincular el pedido: " + e.getMessage());
            return false;
        }
    }

    private boolean existe(PreparedStatement consulta) throws SQLException {
        try (ResultSet resultado = consulta.executeQuery()) {
            return resultado.next();
        }
    }

    // Listar todas las rutas devolviendo objetos de tu clase para que funcione tu toString()
    public List<DeliveryRoute> listarTodasLasRutas() {
        List<DeliveryRoute> lista = new ArrayList<>();
        String sql = "SELECT * FROM rutas_entrega ORDER BY fecha_creacion DESC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearRuta(rs));
            }

        } catch (SQLException e) {
            System.out.println("Error al listar las rutas de entrega: " + e.getMessage());
        }
        return lista;
    }

    // =========================================================================
    // 2. GESTIÓN DE ASIGNACIONES DE ENTREGA (Tabla: asignaciones_entrega)
    // =========================================================================

    // Registrar asignación usando tu objeto con idRuta, idVehiculo, idConductor, fechaAsignacion, usuarioAsignacion y notas
    public int registrarAsignacion(DeliveryAssignment asignacion) {
        String sql = "INSERT INTO asignaciones_entrega (id_ruta, id_vehiculo, id_conductor, "
                   + "fecha_asignacion, usuario_asignacion, notas) "
                   + "SELECT r.id_ruta, v.id_vehiculo, c.id_conductor, ?, ?, ? "
                   + "FROM rutas_entrega r CROSS JOIN vehiculos v CROSS JOIN conductores c "
                   + "WHERE r.id_ruta = ? AND r.estado = 'Planificada' AND v.id_vehiculo = ? "
                   + "AND v.estado = 'Activo' AND c.id_conductor = ? AND c.activo";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setObject(1, asignacion.getFechaAsignacion() != null ? asignacion.getFechaAsignacion() : LocalDateTime.now());
            ps.setString(2, asignacion.getUsuarioAsignacion());
            ps.setString(3, asignacion.getNotas());
            ps.setInt(4, asignacion.getIdRuta());
            ps.setInt(5, asignacion.getIdVehiculo());
            ps.setInt(6, asignacion.getIdConductor());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }

        } catch (SQLException e) {
            System.out.println("Error al asignar vehículo y conductor a la ruta: " + e.getMessage());
            return -1;
        }
    }

    // Listar todas las asignaciones registradas (usa tu toString() con los 4 %d y 3 %s)
    public List<DeliveryAssignment> listarAsignaciones() {
        List<DeliveryAssignment> lista = new ArrayList<>();
        String sql = "SELECT * FROM asignaciones_entrega ORDER BY fecha_asignacion DESC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearAsignacion(rs));
            }

        } catch (SQLException e) {
            System.out.println("Error al listar las asignaciones de entrega: " + e.getMessage());
        }
        return lista;
    }

    // =========================================================================
    // 3. CONSULTA DETALLADA (JOIN de Ruta + Vehículo + Conductor)
    // =========================================================================

    public List<String> obtenerResumenDespachos() {
        List<String> resumen = new ArrayList<>();
        String sql = "SELECT a.id_asignacion, r.nombre_ruta, r.estado, v.placa, v.modelo, "
                   + "c.nombre AS conductor, a.fecha_asignacion, a.notas "
                   + "FROM asignaciones_entrega a "
                   + "JOIN rutas_entrega r ON a.id_ruta = r.id_ruta "
                   + "JOIN vehiculos v ON a.id_vehiculo = v.id_vehiculo "
                   + "JOIN conductores c ON a.id_conductor = c.id_conductor "
                   + "ORDER BY a.fecha_asignacion DESC";

        try (Connection conn = connectionBD.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String info = String.format("[%d] Ruta: %-18s | Estado: %-12s | Vehículo: %s (%s) | Conductor: %-18s | Fecha: %s | Notas: %s",
                        rs.getInt("id_asignacion"),
                        rs.getString("nombre_ruta"),
                        rs.getString("estado"),
                        rs.getString("placa"),
                        rs.getString("modelo"),
                        rs.getString("conductor"),
                        rs.getTimestamp("fecha_asignacion"),
                        rs.getString("notas") != null ? rs.getString("notas") : "Sin notas");
                resumen.add(info);
            }

        } catch (SQLException e) {
            System.out.println("Error al obtener el resumen de despachos: " + e.getMessage());
        }
        return resumen;
    }

    // =========================================================================
    // 4. MÉTODOS AUXILIARES PRIVADOS DE MAPEO (ResultSet -> Objetos Modelo)
    // =========================================================================

    private DeliveryRoute mapearRuta(ResultSet rs) throws SQLException {
        Timestamp tsCreacion = rs.getTimestamp("fecha_creacion");
        Timestamp tsSalidaEst = rs.getTimestamp("hora_salida_estimada");
        Timestamp tsLlegadaEst = rs.getTimestamp("hora_llegada_estimada");
        Timestamp tsSalidaReal = rs.getTimestamp("hora_salida_real");
        Timestamp tsLlegadaReal = rs.getTimestamp("hora_llegada_real");

        return new DeliveryRoute(
                rs.getInt("id_ruta"),
                rs.getString("nombre_ruta"),
                tsCreacion != null ? tsCreacion.toLocalDateTime() : null,
                rs.getString("usuario_creacion"),
                tsSalidaEst != null ? tsSalidaEst.toLocalDateTime() : null,
                tsLlegadaEst != null ? tsLlegadaEst.toLocalDateTime() : null,
                tsSalidaReal != null ? tsSalidaReal.toLocalDateTime() : null,
                tsLlegadaReal != null ? tsLlegadaReal.toLocalDateTime() : null,
                rs.getString("estado")
        );
    }

    private DeliveryAssignment mapearAsignacion(ResultSet rs) throws SQLException {
        Timestamp tsAsignacion = rs.getTimestamp("fecha_asignacion");

        return new DeliveryAssignment(
                rs.getInt("id_asignacion"),
                rs.getInt("id_ruta"),
                rs.getInt("id_vehiculo"),
                rs.getInt("id_conductor"),
                tsAsignacion != null ? tsAsignacion.toLocalDateTime() : null,
                rs.getString("usuario_asignacion"),
                rs.getString("notas")
        );
    }
}
    
    
