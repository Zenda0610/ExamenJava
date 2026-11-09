-- *** Script Proyecto ERP Frescura Total **

-- Script de Creación de Base de Datos: erp_frescura_total
-- El estudiante puede agregar elementos a la base de datos si considera que hace falta la modelo actual


DROP DATABASE IF EXISTS erp_frescura_total;
CREATE DATABASE erp_frescura_total CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE erp_frescura_total;

-- TABLAS DE CATÁLOGO (LOOKUP TABLES)

CREATE TABLE estados_lote (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE tipos_cliente (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE estados_venta (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;

-- INFORMACIÓN DE LA EMPRESA

CREATE TABLE informacion_empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(255) NOT NULL,
    nit VARCHAR(20) NOT NULL UNIQUE,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100)
) ENGINE=InnoDB;

-- MÓDULO: PROVEEDORES

CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    nit VARCHAR(20) NOT NULL UNIQUE,
    persona_contacto VARCHAR(100),
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- MÓDULO: PRODUCTOS

CREATE TABLE categorias_producto (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    id_categoria INT NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL COMMENT 'Ej: kg, litro, unidad',
    precio_base DECIMAL(10, 2),
    FOREIGN KEY (id_categoria) REFERENCES categorias_producto(id_categoria)
) ENGINE=InnoDB;

CREATE TABLE productos_proveedor (
    id_proveedor INT NOT NULL,
    id_producto INT NOT NULL,
    PRIMARY KEY (id_proveedor, id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE
) ENGINE=InnoDB;

-- MÓDULO: INVENTARIO Y CALIDAD

CREATE TABLE lotes_inventario (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    numero_lote VARCHAR(50) NOT NULL UNIQUE,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    fecha_ingreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento DATE NOT NULL,
    cantidad_inicial DECIMAL(10, 2) NOT NULL,
    cantidad DECIMAL(10, 2) NOT NULL,
    precio_compra DECIMAL(10, 2) NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    pasillo VARCHAR(50),
    estante VARCHAR(50),
    id_estado INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    FOREIGN KEY (id_estado) REFERENCES estados_lote(id_estado),
    INDEX idx_fecha_vencimiento (fecha_vencimiento),
    INDEX idx_estado (id_estado),
    INDEX idx_producto (id_producto)
) ENGINE=InnoDB;

CREATE TABLE registro_cuarentena (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT NOT NULL,
    motivo TEXT NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha_resolucion DATETIME NULL,
    notas_resolucion TEXT,
    FOREIGN KEY (id_lote) REFERENCES lotes_inventario(id_lote),
    INDEX idx_resuelta (resuelta)
) ENGINE=InnoDB;

CREATE TABLE inspecciones_calidad (
    id_inspeccion INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT NOT NULL,
    fecha_inspeccion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resultado ENUM('Aprobado', 'Rechazado') NOT NULL,
    nombre_inspector VARCHAR(100) NOT NULL,
    motivo_rechazo TEXT COMMENT 'Motivo detallado si el resultado es Rechazado',
    notas TEXT,
    FOREIGN KEY (id_lote) REFERENCES lotes_inventario(id_lote),
    INDEX idx_resultado (resultado)
) ENGINE=InnoDB;

CREATE TABLE registro_mermas (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT NOT NULL,
    id_inspeccion INT COMMENT 'Inspección que generó esta merma (si aplica)',
    cantidad_perdida DECIMAL(10, 2) NOT NULL,
    motivo TEXT NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_registro VARCHAR(100),
    FOREIGN KEY (id_lote) REFERENCES lotes_inventario(id_lote),
    FOREIGN KEY (id_inspeccion) REFERENCES inspecciones_calidad(id_inspeccion) ON DELETE SET NULL,
    INDEX idx_fecha (fecha_registro)
) ENGINE=InnoDB;

-- MÓDULO: PROMOCIONES

CREATE TABLE promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    tasa_descuento DECIMAL(5, 2) NOT NULL COMMENT 'Ej: 0.50 para 50%',
    aplica_estado_lote INT,
    aplica_categoria_producto INT,
    activa BOOLEAN DEFAULT TRUE,
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (aplica_estado_lote) REFERENCES estados_lote(id_estado),
    FOREIGN KEY (aplica_categoria_producto) REFERENCES categorias_producto(id_categoria),
    INDEX idx_activa (activa)
) ENGINE=InnoDB;

-- MÓDULO: CLIENTES Y VENTAS

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    id_tipo INT NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_tipo) REFERENCES tipos_cliente(id_tipo)
) ENGINE=InnoDB;

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    numero_venta VARCHAR(50) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(12, 2) NOT NULL,
    total_descuento DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_impuesto DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    monto_total DECIMAL(12, 2) NOT NULL,
    id_estado INT NOT NULL,
    usuario_registro VARCHAR(100) COMMENT 'Usuario que registró la venta',
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_estado) REFERENCES estados_venta(id_estado),
    INDEX idx_estado (id_estado),
    INDEX idx_fecha (fecha_venta)
) ENGINE=InnoDB;

CREATE TABLE detalles_venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad_vendida DECIMAL(10, 2) NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento_aplicado DECIMAL(5, 2) DEFAULT 0.00,
    monto_descuento DECIMAL(10, 2) DEFAULT 0.00,
    tasa_impuesto DECIMAL(5, 2) DEFAULT 0.00,
    monto_impuesto DECIMAL(10, 2) DEFAULT 0.00,
    subtotal DECIMAL(10, 2) NOT NULL,
    total_linea DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE,
    FOREIGN KEY (id_lote) REFERENCES lotes_inventario(id_lote)
) ENGINE=InnoDB;

CREATE TABLE facturas (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    numero_factura VARCHAR(50) NOT NULL UNIQUE,
    cufe VARCHAR(255) NOT NULL UNIQUE COMMENT 'Código simulado para factura electrónica',
    enlace_qr VARCHAR(255) COMMENT 'URL o datos para generar código QR',
    fecha_emision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(12, 2) NOT NULL,
    total_descuento DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    monto_impuesto DECIMAL(12, 2) NOT NULL,
    monto_total DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    INDEX idx_numero (numero_factura)
) ENGINE=InnoDB;

-- MÓDULO: LOGÍSTICA Y ENTREGAS

CREATE TABLE conductores (
    id_conductor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    numero_licencia VARCHAR(50) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE vehiculos (
    id_vehiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(20) NOT NULL UNIQUE,
    modelo VARCHAR(100),
    capacidad DECIMAL(10, 2) COMMENT 'Capacidad en kg o unidades',
    estado ENUM('Activo', 'Inactivo', 'Mantenimiento') DEFAULT 'Activo'
) ENGINE=InnoDB;

CREATE TABLE rutas_entrega (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_ruta VARCHAR(255) NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(100) COMMENT 'Usuario logístico que creó la ruta',
    hora_salida_estimada DATETIME,
    hora_llegada_estimada DATETIME,
    hora_salida_real DATETIME,
    hora_llegada_real DATETIME,
    estado ENUM('Planificada', 'En Transito', 'Completada', 'Cancelada') DEFAULT 'Planificada',
    INDEX idx_estado (estado),
    INDEX idx_fecha_creacion (fecha_creacion)
) ENGINE=InnoDB;

CREATE TABLE asignaciones_entrega (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_vehiculo INT NOT NULL,
    id_conductor INT NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_asignacion VARCHAR(100) COMMENT 'Usuario que realizó la asignación',
    notas TEXT,
    FOREIGN KEY (id_ruta) REFERENCES rutas_entrega(id_ruta),
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (id_conductor) REFERENCES conductores(id_conductor),
    INDEX idx_ruta (id_ruta)
) ENGINE=InnoDB;

CREATE TABLE ventas_ruta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT NOT NULL,
    id_venta INT NOT NULL,
    orden_entrega INT COMMENT 'Orden de entrega en la ruta',
    direccion_destino TEXT NOT NULL,
    fecha_entrega DATETIME,
    recibido_por VARCHAR(255),
    observaciones TEXT,
    FOREIGN KEY (id_ruta) REFERENCES rutas_entrega(id_ruta),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    UNIQUE KEY (id_ruta, id_venta),
    INDEX idx_ruta (id_ruta),
    INDEX idx_venta (id_venta)
) ENGINE=InnoDB;

-- DATOS INICIALES (SOLO CATÁLOGOS ESENCIALES)

INSERT INTO estados_lote (nombre, descripcion) VALUES
('Disponible', 'Lote disponible para venta'),
('Proximo a Vencer', 'Lote próximo a vencer (7 días o menos)'),
('Vencido', 'Lote vencido, no apto para venta'),
('En Cuarentena', 'Lote en cuarentena pendiente de inspección');

INSERT INTO tipos_cliente (nombre, descripcion) VALUES
('Mayorista', 'Cliente que compra en grandes cantidades'),
('Minorista', 'Cliente que compra en pequeñas cantidades');

INSERT INTO estados_venta (nombre, descripcion) VALUES
('Registrada', 'Venta registrada, pendiente de preparación'),
('En Preparacion', 'Pedido en preparación para despacho'),
('En Transito', 'Pedido en tránsito hacia el cliente'),
('Entregada', 'Pedido entregado al cliente'),
('Cancelada', 'Venta cancelada'),
('Devuelta', 'Venta devuelta por el cliente');

INSERT INTO informacion_empresa (nombre_empresa, nit, direccion, ciudad, telefono, email) VALUES
('Frescura Total S.A.S.', '900123456-7', 'Calle 123 #45-67', 'Bogotá', '(601) 234-5678', 'contacto@frescuratotal.com');

INSERT INTO categorias_producto (nombre, descripcion) VALUES
('Frutas', 'Frutas frescas'),
('Verduras', 'Verduras y hortalizas'),
('Lacteos', 'Productos lácteos'),
('Carnes', 'Carnes y derivados'),
('Granos', 'Granos y cereales'),
('Bebidas', 'Bebidas y líquidos'),
('Enlatados', 'Productos enlatados'),
('Panaderia', 'Productos de panadería');



-- Ejecutar una vez después de cargar los catálogos del esquema original.
-- 10 filas por tabla operativa. Se usan claves autogeneradas y los catálogos existentes.
USE erp_frescura_total;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO proveedores
    (nombre, nit, persona_contacto, email, telefono, direccion, activo, fecha_registro)
VALUES
    ('Huertas del Tequendama', '901746381-7', 'Valentina Ríos', 'pedidos1@example.com', '6015127301', 'Carrera 11 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Agroservicios El Roble', '901746382-4', 'Mateo Vargas', 'pedidos2@example.com', '6015127302', 'Carrera 12 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Lácteos Alto del Río', '901746383-1', 'Camila Ruiz', 'pedidos3@example.com', '6015127303', 'Carrera 13 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Avícola La Arboleda', '901746384-8', 'Santiago Peña', 'pedidos4@example.com', '6015127304', 'Carrera 14 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Molinos de la Sabana', '901746385-5', 'Lucía Medina', 'pedidos5@example.com', '6015127305', 'Carrera 15 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Bebidas Agua Clara', '901746386-2', 'Samuel Arias', 'pedidos6@example.com', '6015127306', 'Carrera 16 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Conservas La Campiña', '901746387-9', 'Isabella Díaz', 'pedidos7@example.com', '6015127307', 'Carrera 17 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Panadería La Estación', '901746388-6', 'Daniel Castro', 'pedidos8@example.com', '6015127308', 'Carrera 18 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Cultivos Monteverde', '901746389-3', 'Sofía Herrera', 'pedidos9@example.com', '6015127309', 'Carrera 19 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00')),
    ('Lácteos Los Nogales', '901746390-0', 'Nicolás Salazar', 'pedidos10@example.com', '6015127310', 'Carrera 20 # 18-45, Bogotá', 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '09:00:00'));

INSERT INTO productos
    (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES
    ('Granadilla', 'Granadilla de Huertas del Tequendama', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 8200.00),
    ('Acelga', 'Acelga de Agroservicios El Roble', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 4500.00),
    ('Kumis natural 500 ml', 'Kumis natural 500 ml de Lácteos Alto del Río', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 5100.00),
    ('Muslos de pollo', 'Muslos de pollo de Avícola La Arboleda', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'kg', 14900.00),
    ('Arroz integral 1 kg', 'Arroz integral 1 kg de Molinos de la Sabana', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 7900.00),
    ('Agua con gas 500 ml', 'Agua con gas 500 ml de Bebidas Agua Clara', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Bebidas'), 'unidad', 2900.00),
    ('Duraznos en conserva 410 g', 'Duraznos en conserva 410 g de Conservas La Campiña', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Enlatados'), 'unidad', 9800.00),
    ('Pan de centeno 500 g', 'Pan de centeno 500 g de Panadería La Estación', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Panaderia'), 'unidad', 9600.00),
    ('Curuba', 'Curuba de Cultivos Monteverde', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 6400.00),
    ('Queso pera 250 g', 'Queso pera 250 g de Lácteos Los Nogales', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 11800.00);

INSERT INTO productos_proveedor
    (id_proveedor, id_producto)
VALUES
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746381-7'), (SELECT id_producto FROM productos WHERE nombre = 'Granadilla' AND descripcion = 'Granadilla de Huertas del Tequendama' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746382-4'), (SELECT id_producto FROM productos WHERE nombre = 'Acelga' AND descripcion = 'Acelga de Agroservicios El Roble' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746383-1'), (SELECT id_producto FROM productos WHERE nombre = 'Kumis natural 500 ml' AND descripcion = 'Kumis natural 500 ml de Lácteos Alto del Río' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746384-8'), (SELECT id_producto FROM productos WHERE nombre = 'Muslos de pollo' AND descripcion = 'Muslos de pollo de Avícola La Arboleda' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746385-5'), (SELECT id_producto FROM productos WHERE nombre = 'Arroz integral 1 kg' AND descripcion = 'Arroz integral 1 kg de Molinos de la Sabana' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746386-2'), (SELECT id_producto FROM productos WHERE nombre = 'Agua con gas 500 ml' AND descripcion = 'Agua con gas 500 ml de Bebidas Agua Clara' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746387-9'), (SELECT id_producto FROM productos WHERE nombre = 'Duraznos en conserva 410 g' AND descripcion = 'Duraznos en conserva 410 g de Conservas La Campiña' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746388-6'), (SELECT id_producto FROM productos WHERE nombre = 'Pan de centeno 500 g' AND descripcion = 'Pan de centeno 500 g de Panadería La Estación' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746389-3'), (SELECT id_producto FROM productos WHERE nombre = 'Curuba' AND descripcion = 'Curuba de Cultivos Monteverde' LIMIT 1)),
    ((SELECT id_proveedor FROM proveedores WHERE nit = '901746390-0'), (SELECT id_producto FROM productos WHERE nombre = 'Queso pera 250 g' AND descripcion = 'Queso pera 250 g de Lácteos Los Nogales' LIMIT 1));

INSERT INTO clientes
    (nombre, documento, email, telefono, direccion, id_tipo, fecha_registro)
VALUES
    ('Valentina Ríos', '1032679501', 'cliente1@example.com', '3208657301', 'Calle 61 # 19-31, Kennedy, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Mateo Vargas', '1032679502', 'cliente2@example.com', '3208657302', 'Calle 62 # 20-32, Bosa, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Camila Ruiz', '1032679503', 'cliente3@example.com', '3208657303', 'Calle 63 # 21-33, Fontibón, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Santiago Peña', '1032679504', 'cliente4@example.com', '3208657304', 'Calle 64 # 22-34, Engativá, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Lucía Medina', '1032679505', 'cliente5@example.com', '3208657305', 'Calle 65 # 23-35, Suba, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Samuel Arias', '1032679506', 'cliente6@example.com', '3208657306', 'Calle 66 # 24-36, Usaquén, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Isabella Díaz', '1032679507', 'cliente7@example.com', '3208657307', 'Calle 67 # 25-37, Chapinero, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Daniel Castro', '1032679508', 'cliente8@example.com', '3208657308', 'Calle 68 # 26-38, Teusaquillo, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Sofía Herrera', '1032679509', 'cliente9@example.com', '3208657309', 'Calle 69 # 27-39, Puente Aranda, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00')),
    ('Nicolás Salazar', '1032679510', 'cliente10@example.com', '3208657310', 'Calle 70 # 28-40, Barrios Unidos, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00'));

INSERT INTO lotes_inventario
    (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES
    ('LOT-7301', (SELECT id_producto FROM productos WHERE nombre = 'Granadilla' AND descripcion = 'Granadilla de Huertas del Tequendama' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746381-7'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 13 DAY), 40.00, 34.00, 5740.00, 8200.00, 'A', '01', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible')),
    ('LOT-7302', (SELECT id_producto FROM productos WHERE nombre = 'Acelga' AND descripcion = 'Acelga de Agroservicios El Roble' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746382-4'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 44.00, 36.00, 3150.00, 4500.00, 'A', '02', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible')),
    ('LOT-7303', (SELECT id_producto FROM productos WHERE nombre = 'Kumis natural 500 ml' AND descripcion = 'Kumis natural 500 ml de Lácteos Alto del Río' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746383-1'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 48.00, 41.00, 3570.00, 5100.00, 'A', '03', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible')),
    ('LOT-7304', (SELECT id_producto FROM productos WHERE nombre = 'Muslos de pollo' AND descripcion = 'Muslos de pollo de Avícola La Arboleda' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746384-8'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 16 DAY), 52.00, 43.00, 10430.00, 14900.00, 'B', '04', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible')),
    ('LOT-7305', (SELECT id_producto FROM productos WHERE nombre = 'Arroz integral 1 kg' AND descripcion = 'Arroz integral 1 kg de Molinos de la Sabana' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746385-5'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 17 DAY), 56.00, 50.00, 5530.00, 7900.00, 'B', '05', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible')),
    ('LOT-7306', (SELECT id_producto FROM productos WHERE nombre = 'Agua con gas 500 ml' AND descripcion = 'Agua con gas 500 ml de Bebidas Agua Clara' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746386-2'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 18 DAY), 60.00, 55.00, 2030.00, 2900.00, 'B', '06', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible')),
    ('LOT-7307', (SELECT id_producto FROM productos WHERE nombre = 'Duraznos en conserva 410 g' AND descripcion = 'Duraznos en conserva 410 g de Conservas La Campiña' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746387-9'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 64.00, 57.00, 6860.00, 9800.00, 'C', '07', (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer')),
    ('LOT-7308', (SELECT id_producto FROM productos WHERE nombre = 'Pan de centeno 500 g' AND descripcion = 'Pan de centeno 500 g de Panadería La Estación' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746388-6'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 68.00, 59.00, 6720.00, 9600.00, 'C', '08', (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer')),
    ('LOT-7309', (SELECT id_producto FROM productos WHERE nombre = 'Curuba' AND descripcion = 'Curuba de Cultivos Monteverde' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746389-3'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 72.00, 64.00, 4480.00, 6400.00, 'C', '09', (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer')),
    ('LOT-7310', (SELECT id_producto FROM productos WHERE nombre = 'Queso pera 250 g' AND descripcion = 'Queso pera 250 g de Lácteos Los Nogales' LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '901746390-0'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '07:00:00'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 76.00, 71.00, 8260.00, 11800.00, 'D', '10', (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'));

INSERT INTO registro_cuarentena
    (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7301'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7302'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7303'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7304'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7305'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7306'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7307'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7308'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7309'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7310'), 'Unidades con empaque deteriorado', 'Laura Blanco', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '08:00:00'), 1, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:30:00'), 'Se retiraron las unidades dañadas y se liberó el saldo');

INSERT INTO inspecciones_calidad
    (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7301'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7302'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7303'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7304'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7305'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7306'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7307'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7308'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7309'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7310'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00'), 'Aprobado', 'Marcela Gil', NULL, 'El saldo del lote cumple los controles de calidad');

INSERT INTO registro_mermas
    (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7301'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7301') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 2.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7302'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7302') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 3.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7303'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7303') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 1.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7304'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7304') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 2.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7305'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7305') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 3.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7306'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7306') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 1.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7307'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7307') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 2.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7308'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7308') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 3.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7309'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7309') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 1.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco'),
    ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7310'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7310') AND fecha_inspeccion = TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:00:00')), 2.00, 'Empaque deteriorado', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '10:15:00'), 'Laura Blanco');

INSERT INTO promociones
    (nombre, descripcion, tasa_descuento, aplica_estado_lote, aplica_categoria_producto, activa, fecha_inicio, fecha_fin)
VALUES
    ('Rotación de Frutas - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Verduras - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Lacteos - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Carnes - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Granos - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Bebidas - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Bebidas'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Enlatados - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Enlatados'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Panaderia - campaña vigente', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Panaderia'), 1, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
    ('Rotación de Frutas - campaña anterior', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 0, DATE_ADD(CURDATE(), INTERVAL -60 DAY), DATE_ADD(CURDATE(), INTERVAL -31 DAY)),
    ('Rotación de Lacteos - campaña anterior', 'Descuento para lotes próximos a vencer', 0.50, (SELECT id_estado FROM estados_lote WHERE nombre = 'Proximo a Vencer'), (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 0, DATE_ADD(CURDATE(), INTERVAL -60 DAY), DATE_ADD(CURDATE(), INTERVAL -31 DAY));

INSERT INTO ventas
    (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES
    ('VEN-7301', (SELECT id_cliente FROM clientes WHERE documento = '1032679501'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 32800.00, 0.00, 6232.00, 39032.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'Entregada'), 'Elena Cruz'),
    ('VEN-7302', (SELECT id_cliente FROM clientes WHERE documento = '1032679502'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 22500.00, 0.00, 4275.00, 26775.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'Entregada'), 'Elena Cruz'),
    ('VEN-7303', (SELECT id_cliente FROM clientes WHERE documento = '1032679503'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 30600.00, 0.00, 5814.00, 36414.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'Entregada'), 'Elena Cruz'),
    ('VEN-7304', (SELECT id_cliente FROM clientes WHERE documento = '1032679504'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 104300.00, 0.00, 19817.00, 124117.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'Entregada'), 'Elena Cruz'),
    ('VEN-7305', (SELECT id_cliente FROM clientes WHERE documento = '1032679505'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 23700.00, 0.00, 4503.00, 28203.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'Entregada'), 'Elena Cruz'),
    ('VEN-7306', (SELECT id_cliente FROM clientes WHERE documento = '1032679506'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 11600.00, 0.00, 2204.00, 13804.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'Elena Cruz'),
    ('VEN-7307', (SELECT id_cliente FROM clientes WHERE documento = '1032679507'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 49000.00, 24500.00, 4655.00, 29155.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'Elena Cruz'),
    ('VEN-7308', (SELECT id_cliente FROM clientes WHERE documento = '1032679508'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 57600.00, 28800.00, 5472.00, 34272.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'Elena Cruz'),
    ('VEN-7309', (SELECT id_cliente FROM clientes WHERE documento = '1032679509'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 44800.00, 22400.00, 4256.00, 26656.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'Elena Cruz'),
    ('VEN-7310', (SELECT id_cliente FROM clientes WHERE documento = '1032679510'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:00:00'), 35400.00, 17700.00, 3363.00, 21063.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'Elena Cruz');

INSERT INTO detalles_venta
    (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7301'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7301'), 4.00, 8200.00, 0.00, 0.00, 19.00, 6232.00, 32800.00, 39032.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7302'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7302'), 5.00, 4500.00, 0.00, 0.00, 19.00, 4275.00, 22500.00, 26775.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7303'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7303'), 6.00, 5100.00, 0.00, 0.00, 19.00, 5814.00, 30600.00, 36414.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7304'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7304'), 7.00, 14900.00, 0.00, 0.00, 19.00, 19817.00, 104300.00, 124117.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7305'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7305'), 3.00, 7900.00, 0.00, 0.00, 19.00, 4503.00, 23700.00, 28203.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7306'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7306'), 4.00, 2900.00, 0.00, 0.00, 19.00, 2204.00, 11600.00, 13804.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7307'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7307'), 5.00, 9800.00, 50.00, 24500.00, 19.00, 4655.00, 24500.00, 29155.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7308'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7308'), 6.00, 9600.00, 50.00, 28800.00, 19.00, 5472.00, 28800.00, 34272.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7309'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7309'), 7.00, 6400.00, 50.00, 22400.00, 19.00, 4256.00, 22400.00, 26656.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7310'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-7310'), 3.00, 11800.00, 50.00, 17700.00, 19.00, 3363.00, 17700.00, 21063.00);

INSERT INTO facturas
    (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7301'), 'FAC-7301', 'CUFE-SIMULADO-7301', 'https://example.com/facturas/FAC-7301', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 32800.00, 0.00, 6232.00, 39032.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7302'), 'FAC-7302', 'CUFE-SIMULADO-7302', 'https://example.com/facturas/FAC-7302', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 22500.00, 0.00, 4275.00, 26775.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7303'), 'FAC-7303', 'CUFE-SIMULADO-7303', 'https://example.com/facturas/FAC-7303', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 30600.00, 0.00, 5814.00, 36414.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7304'), 'FAC-7304', 'CUFE-SIMULADO-7304', 'https://example.com/facturas/FAC-7304', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 104300.00, 0.00, 19817.00, 124117.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7305'), 'FAC-7305', 'CUFE-SIMULADO-7305', 'https://example.com/facturas/FAC-7305', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 23700.00, 0.00, 4503.00, 28203.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7306'), 'FAC-7306', 'CUFE-SIMULADO-7306', 'https://example.com/facturas/FAC-7306', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 11600.00, 0.00, 2204.00, 13804.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7307'), 'FAC-7307', 'CUFE-SIMULADO-7307', 'https://example.com/facturas/FAC-7307', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 49000.00, 24500.00, 4655.00, 29155.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7308'), 'FAC-7308', 'CUFE-SIMULADO-7308', 'https://example.com/facturas/FAC-7308', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 57600.00, 28800.00, 5472.00, 34272.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7309'), 'FAC-7309', 'CUFE-SIMULADO-7309', 'https://example.com/facturas/FAC-7309', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 44800.00, 22400.00, 4256.00, 26656.00),
    ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7310'), 'FAC-7310', 'CUFE-SIMULADO-7310', 'https://example.com/facturas/FAC-7310', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:05:00'), 35400.00, 17700.00, 3363.00, 21063.00);

INSERT INTO conductores
    (nombre, numero_licencia, telefono, email, activo)
VALUES
    ('Óscar Pardo', '1100679101', '3158417301', 'conductor1@example.com', 1),
    ('Julián Rojas', '1100679102', '3158417302', 'conductor2@example.com', 1),
    ('Sandra Ortiz', '1100679103', '3158417303', 'conductor3@example.com', 1),
    ('Iván Torres', '1100679104', '3158417304', 'conductor4@example.com', 1),
    ('Diana Mora', '1100679105', '3158417305', 'conductor5@example.com', 1),
    ('Hugo León', '1100679106', '3158417306', 'conductor6@example.com', 1),
    ('Nora Lara', '1100679107', '3158417307', 'conductor7@example.com', 1),
    ('Rafael Silva', '1100679108', '3158417308', 'conductor8@example.com', 1),
    ('Adriana Cano', '1100679109', '3158417309', 'conductor9@example.com', 1),
    ('Miguel Nieto', '1100679110', '3158417310', 'conductor10@example.com', 1);

INSERT INTO vehiculos
    (placa, modelo, capacidad, estado)
VALUES
    ('NQJ571', 'Furgón refrigerado', 1000.00, 'Activo'),
    ('NQJ572', 'Furgón refrigerado', 1100.00, 'Activo'),
    ('NQJ573', 'Furgón refrigerado', 1200.00, 'Activo'),
    ('NQJ574', 'Furgón refrigerado', 900.00, 'Activo'),
    ('NQJ575', 'Furgón refrigerado', 1000.00, 'Activo'),
    ('NQJ576', 'Furgón refrigerado', 1100.00, 'Activo'),
    ('NQJ577', 'Furgón refrigerado', 1200.00, 'Activo'),
    ('NQJ578', 'Furgón refrigerado', 900.00, 'Activo'),
    ('NQJ579', 'Furgón refrigerado', 1000.00, 'Activo'),
    ('NQJ580', 'Furgón refrigerado', 1100.00, 'Activo');

INSERT INTO rutas_entrega
    (nombre_ruta, fecha_creacion, usuario_creacion, hora_salida_estimada, hora_llegada_estimada, hora_salida_real, hora_llegada_real, estado)
VALUES
    ('Ruta Kennedy 7301', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '11:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:40:00'), 'Completada'),
    ('Ruta Bosa 7302', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '11:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:40:00'), 'Completada'),
    ('Ruta Fontibón 7303', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '11:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:40:00'), 'Completada'),
    ('Ruta Engativá 7304', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '11:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:40:00'), 'Completada'),
    ('Ruta Suba 7305', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '11:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '08:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:40:00'), 'Completada'),
    ('Ruta Usaquén 7306', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00:00'), NULL, NULL, 'Planificada'),
    ('Ruta Chapinero 7307', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00:00'), NULL, NULL, 'Planificada'),
    ('Ruta Teusaquillo 7308', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00:00'), NULL, NULL, 'Planificada'),
    ('Ruta Puente Aranda 7309', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00:00'), NULL, NULL, 'Planificada'),
    ('Ruta Barrios Unidos 7310', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '13:00:00'), 'Andrés Cárdenas', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00:00'), NULL, NULL, 'Planificada');

INSERT INTO asignaciones_entrega
    (id_ruta, id_vehiculo, id_conductor, fecha_asignacion, usuario_asignacion, notas)
VALUES
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Kennedy 7301'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ571'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679101'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Bosa 7302'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ572'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679102'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Fontibón 7303'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ573'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679103'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Engativá 7304'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ574'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679104'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Suba 7305'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ575'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679105'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Usaquén 7306'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ576'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679106'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Chapinero 7307'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ577'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679107'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Teusaquillo 7308'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ578'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679108'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Puente Aranda 7309'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ579'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679109'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Barrios Unidos 7310'), (SELECT id_vehiculo FROM vehiculos WHERE placa = 'NQJ580'), (SELECT id_conductor FROM conductores WHERE numero_licencia = '1100679110'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:00:00'), 'Andrés Cárdenas', 'Traslado de mercancía en furgón refrigerado');

INSERT INTO ventas_ruta
    (id_ruta, id_venta, orden_entrega, direccion_destino, fecha_entrega, recibido_por, observaciones)
VALUES
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Kennedy 7301'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7301'), 1, 'Calle 61 # 19-31, Kennedy, Bogotá', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:20:00'), 'Valentina Ríos', 'Entrega recibida'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Bosa 7302'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7302'), 1, 'Calle 62 # 20-32, Bosa, Bogotá', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:20:00'), 'Mateo Vargas', 'Entrega recibida'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Fontibón 7303'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7303'), 1, 'Calle 63 # 21-33, Fontibón, Bogotá', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:20:00'), 'Camila Ruiz', 'Entrega recibida'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Engativá 7304'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7304'), 1, 'Calle 64 # 22-34, Engativá, Bogotá', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:20:00'), 'Santiago Peña', 'Entrega recibida'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Suba 7305'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7305'), 1, 'Calle 65 # 23-35, Suba, Bogotá', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:20:00'), 'Lucía Medina', 'Entrega recibida'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Usaquén 7306'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7306'), 1, 'Calle 66 # 24-36, Usaquén, Bogotá', NULL, NULL, 'Pendiente de despacho'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Chapinero 7307'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7307'), 1, 'Calle 67 # 25-37, Chapinero, Bogotá', NULL, NULL, 'Pendiente de despacho'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Teusaquillo 7308'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7308'), 1, 'Calle 68 # 26-38, Teusaquillo, Bogotá', NULL, NULL, 'Pendiente de despacho'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Puente Aranda 7309'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7309'), 1, 'Calle 69 # 27-39, Puente Aranda, Bogotá', NULL, NULL, 'Pendiente de despacho'),
    ((SELECT id_ruta FROM rutas_entrega WHERE nombre_ruta = 'Ruta Barrios Unidos 7310'), (SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-7310'), 1, 'Calle 70 # 28-40, Barrios Unidos, Bogotá', NULL, NULL, 'Pendiente de despacho');

COMMIT;


-- Carga adicional para completar 50 filas en las tablas principales.

-- Mantiene intactos los 10 registros de la carga inicial.

START TRANSACTION;

-- proveedores: 40 registros adicionales

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Bogotá S.A.S.', '900800001-1', 'Contacto 1', 'proveedor01@example.com', '3000000001', 'Centro de distribución Cosechas Bogotá S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Medellín S.A.S.', '900800002-2', 'Contacto 2', 'proveedor02@example.com', '3000000002', 'Centro de distribución Cosechas Medellín S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Cali S.A.S.', '900800003-3', 'Contacto 3', 'proveedor03@example.com', '3000000003', 'Centro de distribución Cosechas Cali S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Barranquilla S.A.S.', '900800004-4', 'Contacto 4', 'proveedor04@example.com', '3000000004', 'Centro de distribución Cosechas Barranquilla S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Bucaramanga S.A.S.', '900800005-5', 'Contacto 5', 'proveedor05@example.com', '3000000005', 'Centro de distribución Cosechas Bucaramanga S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Pereira S.A.S.', '900800006-6', 'Contacto 6', 'proveedor06@example.com', '3000000006', 'Centro de distribución Cosechas Pereira S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Manizales S.A.S.', '900800007-7', 'Contacto 7', 'proveedor07@example.com', '3000000007', 'Centro de distribución Cosechas Manizales S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Ibagué S.A.S.', '900800008-8', 'Contacto 8', 'proveedor08@example.com', '3000000008', 'Centro de distribución Cosechas Ibagué S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Tunja S.A.S.', '900800009-9', 'Contacto 9', 'proveedor09@example.com', '3000000009', 'Centro de distribución Cosechas Tunja S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Cosechas Villavicencio S.A.S.', '900800010-0', 'Contacto 10', 'proveedor10@example.com', '3000000010', 'Centro de distribución Cosechas Villavicencio S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Bogotá S.A.S.', '900800011-1', 'Contacto 11', 'proveedor11@example.com', '3000000011', 'Centro de distribución Alimentos Bogotá S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Medellín S.A.S.', '900800012-2', 'Contacto 12', 'proveedor12@example.com', '3000000012', 'Centro de distribución Alimentos Medellín S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Cali S.A.S.', '900800013-3', 'Contacto 13', 'proveedor13@example.com', '3000000013', 'Centro de distribución Alimentos Cali S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Barranquilla S.A.S.', '900800014-4', 'Contacto 14', 'proveedor14@example.com', '3000000014', 'Centro de distribución Alimentos Barranquilla S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Bucaramanga S.A.S.', '900800015-5', 'Contacto 15', 'proveedor15@example.com', '3000000015', 'Centro de distribución Alimentos Bucaramanga S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Pereira S.A.S.', '900800016-6', 'Contacto 16', 'proveedor16@example.com', '3000000016', 'Centro de distribución Alimentos Pereira S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Manizales S.A.S.', '900800017-7', 'Contacto 17', 'proveedor17@example.com', '3000000017', 'Centro de distribución Alimentos Manizales S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Ibagué S.A.S.', '900800018-8', 'Contacto 18', 'proveedor18@example.com', '3000000018', 'Centro de distribución Alimentos Ibagué S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Tunja S.A.S.', '900800019-9', 'Contacto 19', 'proveedor19@example.com', '3000000019', 'Centro de distribución Alimentos Tunja S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Alimentos Villavicencio S.A.S.', '900800020-0', 'Contacto 20', 'proveedor20@example.com', '3000000020', 'Centro de distribución Alimentos Villavicencio S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Bogotá S.A.S.', '900800021-1', 'Contacto 21', 'proveedor21@example.com', '3000000021', 'Centro de distribución Abastos Bogotá S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Medellín S.A.S.', '900800022-2', 'Contacto 22', 'proveedor22@example.com', '3000000022', 'Centro de distribución Abastos Medellín S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Cali S.A.S.', '900800023-3', 'Contacto 23', 'proveedor23@example.com', '3000000023', 'Centro de distribución Abastos Cali S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Barranquilla S.A.S.', '900800024-4', 'Contacto 24', 'proveedor24@example.com', '3000000024', 'Centro de distribución Abastos Barranquilla S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Bucaramanga S.A.S.', '900800025-5', 'Contacto 25', 'proveedor25@example.com', '3000000025', 'Centro de distribución Abastos Bucaramanga S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Pereira S.A.S.', '900800026-6', 'Contacto 26', 'proveedor26@example.com', '3000000026', 'Centro de distribución Abastos Pereira S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Manizales S.A.S.', '900800027-7', 'Contacto 27', 'proveedor27@example.com', '3000000027', 'Centro de distribución Abastos Manizales S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Ibagué S.A.S.', '900800028-8', 'Contacto 28', 'proveedor28@example.com', '3000000028', 'Centro de distribución Abastos Ibagué S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Tunja S.A.S.', '900800029-9', 'Contacto 29', 'proveedor29@example.com', '3000000029', 'Centro de distribución Abastos Tunja S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Abastos Villavicencio S.A.S.', '900800030-0', 'Contacto 30', 'proveedor30@example.com', '3000000030', 'Centro de distribución Abastos Villavicencio S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Bogotá S.A.S.', '900800031-1', 'Contacto 31', 'proveedor31@example.com', '3000000031', 'Centro de distribución Agrocomercial Bogotá S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Medellín S.A.S.', '900800032-2', 'Contacto 32', 'proveedor32@example.com', '3000000032', 'Centro de distribución Agrocomercial Medellín S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Cali S.A.S.', '900800033-3', 'Contacto 33', 'proveedor33@example.com', '3000000033', 'Centro de distribución Agrocomercial Cali S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Barranquilla S.A.S.', '900800034-4', 'Contacto 34', 'proveedor34@example.com', '3000000034', 'Centro de distribución Agrocomercial Barranquilla S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Bucaramanga S.A.S.', '900800035-5', 'Contacto 35', 'proveedor35@example.com', '3000000035', 'Centro de distribución Agrocomercial Bucaramanga S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Pereira S.A.S.', '900800036-6', 'Contacto 36', 'proveedor36@example.com', '3000000036', 'Centro de distribución Agrocomercial Pereira S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Manizales S.A.S.', '900800037-7', 'Contacto 37', 'proveedor37@example.com', '3000000037', 'Centro de distribución Agrocomercial Manizales S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Ibagué S.A.S.', '900800038-8', 'Contacto 38', 'proveedor38@example.com', '3000000038', 'Centro de distribución Agrocomercial Ibagué S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Tunja S.A.S.', '900800039-9', 'Contacto 39', 'proveedor39@example.com', '3000000039', 'Centro de distribución Agrocomercial Tunja S.A.S.', TRUE);

INSERT INTO proveedores (nombre, nit, persona_contacto, email, telefono, direccion, activo)
VALUES ('Agrocomercial Villavicencio S.A.S.', '900800040-0', 'Contacto 40', 'proveedor40@example.com', '3000000040', 'Centro de distribución Agrocomercial Villavicencio S.A.S.', TRUE);

-- productos: 40 registros adicionales

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Manzana roja', 'Producto para distribución: Manzana roja', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 6800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Manzana verde', 'Producto para distribución: Manzana verde', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 7200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Banano criollo', 'Producto para distribución: Banano criollo', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 3600.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Pera conferencia', 'Producto para distribución: Pera conferencia', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 8500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Naranja valencia', 'Producto para distribución: Naranja valencia', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 3900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Mandarina arrayana', 'Producto para distribución: Mandarina arrayana', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 4200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Mango tommy', 'Producto para distribución: Mango tommy', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 6500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Piña oro miel', 'Producto para distribución: Piña oro miel', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'unidad', 7800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Papaya maradol', 'Producto para distribución: Papaya maradol', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 4800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Uva verde', 'Producto para distribución: Uva verde', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Frutas'), 'kg', 13500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Tomate chonto', 'Producto para distribución: Tomate chonto', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 4300.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Tomate cherry', 'Producto para distribución: Tomate cherry', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 9200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Cebolla cabezona', 'Producto para distribución: Cebolla cabezona', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 3600.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Cebolla larga', 'Producto para distribución: Cebolla larga', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 4100.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Zanahoria', 'Producto para distribución: Zanahoria', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 3200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Papa pastusa', 'Producto para distribución: Papa pastusa', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 2900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Papa criolla', 'Producto para distribución: Papa criolla', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 5400.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Lechuga crespa', 'Producto para distribución: Lechuga crespa', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'unidad', 3800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Espinaca', 'Producto para distribución: Espinaca', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 6500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Brócoli', 'Producto para distribución: Brócoli', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Verduras'), 'kg', 7200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Leche entera 1 L', 'Producto para distribución: Leche entera 1 L', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 4800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Leche deslactosada 1 L', 'Producto para distribución: Leche deslactosada 1 L', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 5600.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Yogur natural 1 L', 'Producto para distribución: Yogur natural 1 L', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 8900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Queso campesino', 'Producto para distribución: Queso campesino', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'kg', 19800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Queso mozzarella', 'Producto para distribución: Queso mozzarella', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'kg', 24800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Mantequilla 250 g', 'Producto para distribución: Mantequilla 250 g', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 11200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Crema de leche 200 ml', 'Producto para distribución: Crema de leche 200 ml', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'unidad', 5200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Cuajada', 'Producto para distribución: Cuajada', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Lacteos'), 'kg', 15600.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Pollo entero', 'Producto para distribución: Pollo entero', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'kg', 13600.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Pechuga de pollo', 'Producto para distribución: Pechuga de pollo', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'kg', 18500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Carne molida de res', 'Producto para distribución: Carne molida de res', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'kg', 24900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Lomo de cerdo', 'Producto para distribución: Lomo de cerdo', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'kg', 22900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Filete de tilapia', 'Producto para distribución: Filete de tilapia', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'kg', 21500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Huevos AA docena', 'Producto para distribución: Huevos AA docena', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Carnes'), 'unidad', 13500.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Arroz blanco 1 kg', 'Producto para distribución: Arroz blanco 1 kg', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 4800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Fríjol cargamanto 1 kg', 'Producto para distribución: Fríjol cargamanto 1 kg', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 10900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Lenteja 1 kg', 'Producto para distribución: Lenteja 1 kg', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 7800.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Garbanzo 1 kg', 'Producto para distribución: Garbanzo 1 kg', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 8900.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Avena en hojuelas 1 kg', 'Producto para distribución: Avena en hojuelas 1 kg', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 9200.00);

INSERT INTO productos (nombre, descripcion, id_categoria, unidad_medida, precio_base)
VALUES ('Quinua 500 g', 'Producto para distribución: Quinua 500 g', (SELECT id_categoria FROM categorias_producto WHERE nombre = 'Granos'), 'unidad', 14500.00);

-- productos_proveedor: 40 registros adicionales

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800001-1'), (SELECT id_producto FROM productos WHERE nombre = 'Manzana roja' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800002-2'), (SELECT id_producto FROM productos WHERE nombre = 'Manzana verde' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800003-3'), (SELECT id_producto FROM productos WHERE nombre = 'Banano criollo' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800004-4'), (SELECT id_producto FROM productos WHERE nombre = 'Pera conferencia' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800005-5'), (SELECT id_producto FROM productos WHERE nombre = 'Naranja valencia' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800006-6'), (SELECT id_producto FROM productos WHERE nombre = 'Mandarina arrayana' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800007-7'), (SELECT id_producto FROM productos WHERE nombre = 'Mango tommy' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800008-8'), (SELECT id_producto FROM productos WHERE nombre = 'Piña oro miel' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800009-9'), (SELECT id_producto FROM productos WHERE nombre = 'Papaya maradol' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800010-0'), (SELECT id_producto FROM productos WHERE nombre = 'Uva verde' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800011-1'), (SELECT id_producto FROM productos WHERE nombre = 'Tomate chonto' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800012-2'), (SELECT id_producto FROM productos WHERE nombre = 'Tomate cherry' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800013-3'), (SELECT id_producto FROM productos WHERE nombre = 'Cebolla cabezona' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800014-4'), (SELECT id_producto FROM productos WHERE nombre = 'Cebolla larga' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800015-5'), (SELECT id_producto FROM productos WHERE nombre = 'Zanahoria' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800016-6'), (SELECT id_producto FROM productos WHERE nombre = 'Papa pastusa' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800017-7'), (SELECT id_producto FROM productos WHERE nombre = 'Papa criolla' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800018-8'), (SELECT id_producto FROM productos WHERE nombre = 'Lechuga crespa' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800019-9'), (SELECT id_producto FROM productos WHERE nombre = 'Espinaca' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800020-0'), (SELECT id_producto FROM productos WHERE nombre = 'Brócoli' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800021-1'), (SELECT id_producto FROM productos WHERE nombre = 'Leche entera 1 L' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800022-2'), (SELECT id_producto FROM productos WHERE nombre = 'Leche deslactosada 1 L' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800023-3'), (SELECT id_producto FROM productos WHERE nombre = 'Yogur natural 1 L' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800024-4'), (SELECT id_producto FROM productos WHERE nombre = 'Queso campesino' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800025-5'), (SELECT id_producto FROM productos WHERE nombre = 'Queso mozzarella' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800026-6'), (SELECT id_producto FROM productos WHERE nombre = 'Mantequilla 250 g' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800027-7'), (SELECT id_producto FROM productos WHERE nombre = 'Crema de leche 200 ml' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800028-8'), (SELECT id_producto FROM productos WHERE nombre = 'Cuajada' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800029-9'), (SELECT id_producto FROM productos WHERE nombre = 'Pollo entero' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800030-0'), (SELECT id_producto FROM productos WHERE nombre = 'Pechuga de pollo' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800031-1'), (SELECT id_producto FROM productos WHERE nombre = 'Carne molida de res' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800032-2'), (SELECT id_producto FROM productos WHERE nombre = 'Lomo de cerdo' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800033-3'), (SELECT id_producto FROM productos WHERE nombre = 'Filete de tilapia' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800034-4'), (SELECT id_producto FROM productos WHERE nombre = 'Huevos AA docena' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800035-5'), (SELECT id_producto FROM productos WHERE nombre = 'Arroz blanco 1 kg' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800036-6'), (SELECT id_producto FROM productos WHERE nombre = 'Fríjol cargamanto 1 kg' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800037-7'), (SELECT id_producto FROM productos WHERE nombre = 'Lenteja 1 kg' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800038-8'), (SELECT id_producto FROM productos WHERE nombre = 'Garbanzo 1 kg' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800039-9'), (SELECT id_producto FROM productos WHERE nombre = 'Avena en hojuelas 1 kg' ORDER BY id_producto LIMIT 1));

INSERT INTO productos_proveedor (id_proveedor, id_producto)
VALUES ((SELECT id_proveedor FROM proveedores WHERE nit = '900800040-0'), (SELECT id_producto FROM productos WHERE nombre = 'Quinua 500 g' ORDER BY id_producto LIMIT 1));

-- clientes: 40 registros adicionales

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('María Gómez', '1020000001', 'cliente01@example.com', '3100000001', 'Dirección 1, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Carlos Gómez', '1020000002', 'cliente02@example.com', '3100000002', 'Dirección 2, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Ana Gómez', '1020000003', 'cliente03@example.com', '3100000003', 'Dirección 3, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Juan Gómez', '1020000004', 'cliente04@example.com', '3100000004', 'Dirección 4, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Laura Gómez', '1020000005', 'cliente05@example.com', '3100000005', 'Dirección 5, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Andrés Gómez', '1020000006', 'cliente06@example.com', '3100000006', 'Dirección 6, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Paula Gómez', '1020000007', 'cliente07@example.com', '3100000007', 'Dirección 7, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Jorge Gómez', '1020000008', 'cliente08@example.com', '3100000008', 'Dirección 8, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Diana Gómez', '1020000009', 'cliente09@example.com', '3100000009', 'Dirección 9, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Felipe Gómez', '1020000010', 'cliente10@example.com', '3100000010', 'Dirección 10, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('María Rodríguez', '1020000011', 'cliente11@example.com', '3100000011', 'Dirección 11, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Carlos Rodríguez', '1020000012', 'cliente12@example.com', '3100000012', 'Dirección 12, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Ana Rodríguez', '1020000013', 'cliente13@example.com', '3100000013', 'Dirección 13, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Juan Rodríguez', '1020000014', 'cliente14@example.com', '3100000014', 'Dirección 14, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Laura Rodríguez', '1020000015', 'cliente15@example.com', '3100000015', 'Dirección 15, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Andrés Rodríguez', '1020000016', 'cliente16@example.com', '3100000016', 'Dirección 16, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Paula Rodríguez', '1020000017', 'cliente17@example.com', '3100000017', 'Dirección 17, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Jorge Rodríguez', '1020000018', 'cliente18@example.com', '3100000018', 'Dirección 18, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Diana Rodríguez', '1020000019', 'cliente19@example.com', '3100000019', 'Dirección 19, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Felipe Rodríguez', '1020000020', 'cliente20@example.com', '3100000020', 'Dirección 20, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('María Martínez', '1020000021', 'cliente21@example.com', '3100000021', 'Dirección 21, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Carlos Martínez', '1020000022', 'cliente22@example.com', '3100000022', 'Dirección 22, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Ana Martínez', '1020000023', 'cliente23@example.com', '3100000023', 'Dirección 23, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Juan Martínez', '1020000024', 'cliente24@example.com', '3100000024', 'Dirección 24, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Laura Martínez', '1020000025', 'cliente25@example.com', '3100000025', 'Dirección 25, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Andrés Martínez', '1020000026', 'cliente26@example.com', '3100000026', 'Dirección 26, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Paula Martínez', '1020000027', 'cliente27@example.com', '3100000027', 'Dirección 27, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Jorge Martínez', '1020000028', 'cliente28@example.com', '3100000028', 'Dirección 28, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Diana Martínez', '1020000029', 'cliente29@example.com', '3100000029', 'Dirección 29, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Felipe Martínez', '1020000030', 'cliente30@example.com', '3100000030', 'Dirección 30, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('María López', '1020000031', 'cliente31@example.com', '3100000031', 'Dirección 31, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Carlos López', '1020000032', 'cliente32@example.com', '3100000032', 'Dirección 32, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Ana López', '1020000033', 'cliente33@example.com', '3100000033', 'Dirección 33, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Juan López', '1020000034', 'cliente34@example.com', '3100000034', 'Dirección 34, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Laura López', '1020000035', 'cliente35@example.com', '3100000035', 'Dirección 35, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Andrés López', '1020000036', 'cliente36@example.com', '3100000036', 'Dirección 36, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Paula López', '1020000037', 'cliente37@example.com', '3100000037', 'Dirección 37, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Jorge López', '1020000038', 'cliente38@example.com', '3100000038', 'Dirección 38, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Diana López', '1020000039', 'cliente39@example.com', '3100000039', 'Dirección 39, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Minorista'));

INSERT INTO clientes (nombre, documento, email, telefono, direccion, id_tipo)
VALUES ('Felipe López', '1020000040', 'cliente40@example.com', '3100000040', 'Dirección 40, Bogotá', (SELECT id_tipo FROM tipos_cliente WHERE nombre = 'Mayorista'));

-- lotes_inventario: 40 registros adicionales

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0001', (SELECT id_producto FROM productos WHERE nombre = 'Manzana roja' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800001-1'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 100.00, 93.00, 4760.00, 6800.00, 'P-01', 'E-01', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0002', (SELECT id_producto FROM productos WHERE nombre = 'Manzana verde' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800002-2'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 16 DAY), 100.00, 93.00, 5040.00, 7200.00, 'P-02', 'E-02', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0003', (SELECT id_producto FROM productos WHERE nombre = 'Banano criollo' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800003-3'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 17 DAY), 100.00, 93.00, 2520.00, 3600.00, 'P-03', 'E-03', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0004', (SELECT id_producto FROM productos WHERE nombre = 'Pera conferencia' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800004-4'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 18 DAY), 100.00, 93.00, 5950.00, 8500.00, 'P-04', 'E-04', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0005', (SELECT id_producto FROM productos WHERE nombre = 'Naranja valencia' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800005-5'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 19 DAY), 100.00, 93.00, 2730.00, 3900.00, 'P-05', 'E-05', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0006', (SELECT id_producto FROM productos WHERE nombre = 'Mandarina arrayana' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800006-6'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 100.00, 93.00, 2940.00, 4200.00, 'P-01', 'E-06', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0007', (SELECT id_producto FROM productos WHERE nombre = 'Mango tommy' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800007-7'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 100.00, 93.00, 4550.00, 6500.00, 'P-02', 'E-07', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0008', (SELECT id_producto FROM productos WHERE nombre = 'Piña oro miel' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800008-8'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 100.00, 93.00, 5460.00, 7800.00, 'P-03', 'E-08', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0009', (SELECT id_producto FROM productos WHERE nombre = 'Papaya maradol' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800009-9'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 100.00, 93.00, 3360.00, 4800.00, 'P-04', 'E-09', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0010', (SELECT id_producto FROM productos WHERE nombre = 'Uva verde' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800010-0'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 100.00, 93.00, 9450.00, 13500.00, 'P-05', 'E-10', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0011', (SELECT id_producto FROM productos WHERE nombre = 'Tomate chonto' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800011-1'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 100.00, 95.00, 3010.00, 4300.00, 'P-01', 'E-01', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0012', (SELECT id_producto FROM productos WHERE nombre = 'Tomate cherry' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800012-2'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 100.00, 95.00, 6440.00, 9200.00, 'P-02', 'E-02', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0013', (SELECT id_producto FROM productos WHERE nombre = 'Cebolla cabezona' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800013-3'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 100.00, 95.00, 2520.00, 3600.00, 'P-03', 'E-03', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0014', (SELECT id_producto FROM productos WHERE nombre = 'Cebolla larga' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800014-4'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 100.00, 95.00, 2870.00, 4100.00, 'P-04', 'E-04', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0015', (SELECT id_producto FROM productos WHERE nombre = 'Zanahoria' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800015-5'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 100.00, 95.00, 2240.00, 3200.00, 'P-05', 'E-05', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0016', (SELECT id_producto FROM productos WHERE nombre = 'Papa pastusa' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800016-6'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 100.00, 95.00, 2030.00, 2900.00, 'P-01', 'E-06', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0017', (SELECT id_producto FROM productos WHERE nombre = 'Papa criolla' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800017-7'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 100.00, 95.00, 3780.00, 5400.00, 'P-02', 'E-07', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0018', (SELECT id_producto FROM productos WHERE nombre = 'Lechuga crespa' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800018-8'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 100.00, 95.00, 2660.00, 3800.00, 'P-03', 'E-08', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0019', (SELECT id_producto FROM productos WHERE nombre = 'Espinaca' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800019-9'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 100.00, 95.00, 4550.00, 6500.00, 'P-04', 'E-09', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0020', (SELECT id_producto FROM productos WHERE nombre = 'Brócoli' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800020-0'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 100.00, 95.00, 5040.00, 7200.00, 'P-05', 'E-10', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0021', (SELECT id_producto FROM productos WHERE nombre = 'Leche entera 1 L' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800021-1'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 100.00, 95.00, 3360.00, 4800.00, 'P-01', 'E-01', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0022', (SELECT id_producto FROM productos WHERE nombre = 'Leche deslactosada 1 L' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800022-2'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 100.00, 95.00, 3920.00, 5600.00, 'P-02', 'E-02', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0023', (SELECT id_producto FROM productos WHERE nombre = 'Yogur natural 1 L' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800023-3'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 100.00, 95.00, 6230.00, 8900.00, 'P-03', 'E-03', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0024', (SELECT id_producto FROM productos WHERE nombre = 'Queso campesino' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800024-4'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 100.00, 95.00, 13860.00, 19800.00, 'P-04', 'E-04', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0025', (SELECT id_producto FROM productos WHERE nombre = 'Queso mozzarella' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800025-5'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 100.00, 95.00, 17360.00, 24800.00, 'P-05', 'E-05', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0026', (SELECT id_producto FROM productos WHERE nombre = 'Mantequilla 250 g' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800026-6'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 100.00, 95.00, 7840.00, 11200.00, 'P-01', 'E-06', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0027', (SELECT id_producto FROM productos WHERE nombre = 'Crema de leche 200 ml' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800027-7'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 100.00, 95.00, 3640.00, 5200.00, 'P-02', 'E-07', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0028', (SELECT id_producto FROM productos WHERE nombre = 'Cuajada' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800028-8'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 100.00, 95.00, 10920.00, 15600.00, 'P-03', 'E-08', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0029', (SELECT id_producto FROM productos WHERE nombre = 'Pollo entero' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800029-9'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 100.00, 95.00, 9520.00, 13600.00, 'P-04', 'E-09', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0030', (SELECT id_producto FROM productos WHERE nombre = 'Pechuga de pollo' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800030-0'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 100.00, 95.00, 12950.00, 18500.00, 'P-05', 'E-10', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0031', (SELECT id_producto FROM productos WHERE nombre = 'Carne molida de res' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800031-1'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 100.00, 95.00, 17430.00, 24900.00, 'P-01', 'E-01', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0032', (SELECT id_producto FROM productos WHERE nombre = 'Lomo de cerdo' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800032-2'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 16 DAY), 100.00, 95.00, 16030.00, 22900.00, 'P-02', 'E-02', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0033', (SELECT id_producto FROM productos WHERE nombre = 'Filete de tilapia' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800033-3'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 17 DAY), 100.00, 95.00, 15050.00, 21500.00, 'P-03', 'E-03', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0034', (SELECT id_producto FROM productos WHERE nombre = 'Huevos AA docena' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800034-4'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 18 DAY), 100.00, 95.00, 9450.00, 13500.00, 'P-04', 'E-04', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0035', (SELECT id_producto FROM productos WHERE nombre = 'Arroz blanco 1 kg' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800035-5'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 19 DAY), 100.00, 95.00, 3360.00, 4800.00, 'P-05', 'E-05', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0036', (SELECT id_producto FROM productos WHERE nombre = 'Fríjol cargamanto 1 kg' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800036-6'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 100.00, 95.00, 7630.00, 10900.00, 'P-01', 'E-06', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0037', (SELECT id_producto FROM productos WHERE nombre = 'Lenteja 1 kg' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800037-7'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 100.00, 95.00, 5460.00, 7800.00, 'P-02', 'E-07', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0038', (SELECT id_producto FROM productos WHERE nombre = 'Garbanzo 1 kg' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800038-8'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 100.00, 95.00, 6230.00, 8900.00, 'P-03', 'E-08', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0039', (SELECT id_producto FROM productos WHERE nombre = 'Avena en hojuelas 1 kg' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800039-9'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 100.00, 95.00, 6440.00, 9200.00, 'P-04', 'E-09', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

INSERT INTO lotes_inventario (numero_lote, id_producto, id_proveedor, fecha_ingreso, fecha_vencimiento, cantidad_inicial, cantidad, precio_compra, precio_venta, pasillo, estante, id_estado)
VALUES ('LOT-0040', (SELECT id_producto FROM productos WHERE nombre = 'Quinua 500 g' ORDER BY id_producto LIMIT 1), (SELECT id_proveedor FROM proveedores WHERE nit = '900800040-0'), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 100.00, 95.00, 10150.00, 14500.00, 'P-05', 'E-10', (SELECT id_estado FROM estados_lote WHERE nombre = 'Disponible'));

-- registro_cuarentena: 10 registros adicionales

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0001'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0002'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0003'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0004'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0005'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0006'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0007'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0008'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0009'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

INSERT INTO registro_cuarentena (id_lote, motivo, usuario, fecha_registro, resuelta, fecha_resolucion, notas_resolucion)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0010'), 'Empaque con unidades dañadas', 'operario_bodega', DATE_SUB(NOW(), INTERVAL 3 DAY), TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Inspección aprobada; dos unidades retiradas');

-- inspecciones_calidad: 10 registros adicionales

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0001'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0002'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0003'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0004'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0005'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0006'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0007'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0008'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0009'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

INSERT INTO inspecciones_calidad (id_lote, fecha_inspeccion, resultado, nombre_inspector, motivo_rechazo, notas)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0010'), DATE_SUB(NOW(), INTERVAL 2 DAY), 'Aprobado', 'Inspector de calidad', NULL, 'Lote apto tras retirar dos unidades dañadas');

-- registro_mermas: 10 registros adicionales

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0001'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0001') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0002'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0002') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0003'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0003') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0004'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0004') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0005'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0005') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0006'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0006') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0007'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0007') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0008'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0008') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0009'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0009') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

INSERT INTO registro_mermas (id_lote, id_inspeccion, cantidad_perdida, motivo, fecha_registro, usuario_registro)
VALUES ((SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0010'), (SELECT id_inspeccion FROM inspecciones_calidad WHERE id_lote = (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0010') AND nombre_inspector = 'Inspector de calidad' ORDER BY id_inspeccion LIMIT 1), 2.00, 'Unidades con empaque dañado', DATE_SUB(NOW(), INTERVAL 2 DAY), 'operario_bodega');

-- ventas: 40 registros adicionales

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0001', (SELECT id_cliente FROM clientes WHERE documento = '1020000001'), DATE_SUB(NOW(), INTERVAL 1 DAY), 34000.00, 0.00, 6460.00, 40460.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0002', (SELECT id_cliente FROM clientes WHERE documento = '1020000002'), DATE_SUB(NOW(), INTERVAL 1 DAY), 36000.00, 0.00, 6840.00, 42840.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0003', (SELECT id_cliente FROM clientes WHERE documento = '1020000003'), DATE_SUB(NOW(), INTERVAL 1 DAY), 18000.00, 0.00, 3420.00, 21420.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0004', (SELECT id_cliente FROM clientes WHERE documento = '1020000004'), DATE_SUB(NOW(), INTERVAL 1 DAY), 42500.00, 0.00, 8075.00, 50575.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0005', (SELECT id_cliente FROM clientes WHERE documento = '1020000005'), DATE_SUB(NOW(), INTERVAL 1 DAY), 19500.00, 0.00, 3705.00, 23205.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0006', (SELECT id_cliente FROM clientes WHERE documento = '1020000006'), DATE_SUB(NOW(), INTERVAL 1 DAY), 21000.00, 0.00, 3990.00, 24990.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0007', (SELECT id_cliente FROM clientes WHERE documento = '1020000007'), DATE_SUB(NOW(), INTERVAL 1 DAY), 32500.00, 0.00, 6175.00, 38675.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0008', (SELECT id_cliente FROM clientes WHERE documento = '1020000008'), DATE_SUB(NOW(), INTERVAL 1 DAY), 39000.00, 0.00, 7410.00, 46410.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0009', (SELECT id_cliente FROM clientes WHERE documento = '1020000009'), DATE_SUB(NOW(), INTERVAL 1 DAY), 24000.00, 0.00, 4560.00, 28560.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0010', (SELECT id_cliente FROM clientes WHERE documento = '1020000010'), DATE_SUB(NOW(), INTERVAL 1 DAY), 67500.00, 0.00, 12825.00, 80325.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0011', (SELECT id_cliente FROM clientes WHERE documento = '1020000011'), DATE_SUB(NOW(), INTERVAL 1 DAY), 21500.00, 0.00, 4085.00, 25585.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0012', (SELECT id_cliente FROM clientes WHERE documento = '1020000012'), DATE_SUB(NOW(), INTERVAL 1 DAY), 46000.00, 0.00, 8740.00, 54740.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0013', (SELECT id_cliente FROM clientes WHERE documento = '1020000013'), DATE_SUB(NOW(), INTERVAL 1 DAY), 18000.00, 0.00, 3420.00, 21420.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0014', (SELECT id_cliente FROM clientes WHERE documento = '1020000014'), DATE_SUB(NOW(), INTERVAL 1 DAY), 20500.00, 0.00, 3895.00, 24395.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0015', (SELECT id_cliente FROM clientes WHERE documento = '1020000015'), DATE_SUB(NOW(), INTERVAL 1 DAY), 16000.00, 0.00, 3040.00, 19040.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0016', (SELECT id_cliente FROM clientes WHERE documento = '1020000016'), DATE_SUB(NOW(), INTERVAL 1 DAY), 14500.00, 0.00, 2755.00, 17255.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0017', (SELECT id_cliente FROM clientes WHERE documento = '1020000017'), DATE_SUB(NOW(), INTERVAL 1 DAY), 27000.00, 0.00, 5130.00, 32130.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0018', (SELECT id_cliente FROM clientes WHERE documento = '1020000018'), DATE_SUB(NOW(), INTERVAL 1 DAY), 19000.00, 0.00, 3610.00, 22610.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0019', (SELECT id_cliente FROM clientes WHERE documento = '1020000019'), DATE_SUB(NOW(), INTERVAL 1 DAY), 32500.00, 0.00, 6175.00, 38675.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0020', (SELECT id_cliente FROM clientes WHERE documento = '1020000020'), DATE_SUB(NOW(), INTERVAL 1 DAY), 36000.00, 0.00, 6840.00, 42840.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0021', (SELECT id_cliente FROM clientes WHERE documento = '1020000021'), DATE_SUB(NOW(), INTERVAL 1 DAY), 24000.00, 0.00, 4560.00, 28560.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0022', (SELECT id_cliente FROM clientes WHERE documento = '1020000022'), DATE_SUB(NOW(), INTERVAL 1 DAY), 28000.00, 0.00, 5320.00, 33320.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0023', (SELECT id_cliente FROM clientes WHERE documento = '1020000023'), DATE_SUB(NOW(), INTERVAL 1 DAY), 44500.00, 0.00, 8455.00, 52955.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0024', (SELECT id_cliente FROM clientes WHERE documento = '1020000024'), DATE_SUB(NOW(), INTERVAL 1 DAY), 99000.00, 0.00, 18810.00, 117810.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0025', (SELECT id_cliente FROM clientes WHERE documento = '1020000025'), DATE_SUB(NOW(), INTERVAL 1 DAY), 124000.00, 0.00, 23560.00, 147560.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0026', (SELECT id_cliente FROM clientes WHERE documento = '1020000026'), DATE_SUB(NOW(), INTERVAL 1 DAY), 56000.00, 0.00, 10640.00, 66640.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0027', (SELECT id_cliente FROM clientes WHERE documento = '1020000027'), DATE_SUB(NOW(), INTERVAL 1 DAY), 26000.00, 0.00, 4940.00, 30940.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0028', (SELECT id_cliente FROM clientes WHERE documento = '1020000028'), DATE_SUB(NOW(), INTERVAL 1 DAY), 78000.00, 0.00, 14820.00, 92820.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0029', (SELECT id_cliente FROM clientes WHERE documento = '1020000029'), DATE_SUB(NOW(), INTERVAL 1 DAY), 68000.00, 0.00, 12920.00, 80920.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0030', (SELECT id_cliente FROM clientes WHERE documento = '1020000030'), DATE_SUB(NOW(), INTERVAL 1 DAY), 92500.00, 0.00, 17575.00, 110075.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0031', (SELECT id_cliente FROM clientes WHERE documento = '1020000031'), DATE_SUB(NOW(), INTERVAL 1 DAY), 124500.00, 0.00, 23655.00, 148155.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0032', (SELECT id_cliente FROM clientes WHERE documento = '1020000032'), DATE_SUB(NOW(), INTERVAL 1 DAY), 114500.00, 0.00, 21755.00, 136255.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0033', (SELECT id_cliente FROM clientes WHERE documento = '1020000033'), DATE_SUB(NOW(), INTERVAL 1 DAY), 107500.00, 0.00, 20425.00, 127925.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0034', (SELECT id_cliente FROM clientes WHERE documento = '1020000034'), DATE_SUB(NOW(), INTERVAL 1 DAY), 67500.00, 0.00, 12825.00, 80325.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0035', (SELECT id_cliente FROM clientes WHERE documento = '1020000035'), DATE_SUB(NOW(), INTERVAL 1 DAY), 24000.00, 0.00, 4560.00, 28560.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0036', (SELECT id_cliente FROM clientes WHERE documento = '1020000036'), DATE_SUB(NOW(), INTERVAL 1 DAY), 54500.00, 0.00, 10355.00, 64855.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0037', (SELECT id_cliente FROM clientes WHERE documento = '1020000037'), DATE_SUB(NOW(), INTERVAL 1 DAY), 39000.00, 0.00, 7410.00, 46410.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0038', (SELECT id_cliente FROM clientes WHERE documento = '1020000038'), DATE_SUB(NOW(), INTERVAL 1 DAY), 44500.00, 0.00, 8455.00, 52955.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0039', (SELECT id_cliente FROM clientes WHERE documento = '1020000039'), DATE_SUB(NOW(), INTERVAL 1 DAY), 46000.00, 0.00, 8740.00, 54740.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

INSERT INTO ventas (numero_venta, id_cliente, fecha_venta, subtotal, total_descuento, total_impuesto, monto_total, id_estado, usuario_registro)
VALUES ('VEN-0040', (SELECT id_cliente FROM clientes WHERE documento = '1020000040'), DATE_SUB(NOW(), INTERVAL 1 DAY), 72500.00, 0.00, 13775.00, 86275.00, (SELECT id_estado FROM estados_venta WHERE nombre = 'En Preparacion'), 'vendedor');

-- detalles_venta: 40 registros adicionales

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0001'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0001'), 5.00, 6800.00, 0.00, 0.00, 19.00, 6460.00, 34000.00, 40460.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0002'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0002'), 5.00, 7200.00, 0.00, 0.00, 19.00, 6840.00, 36000.00, 42840.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0003'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0003'), 5.00, 3600.00, 0.00, 0.00, 19.00, 3420.00, 18000.00, 21420.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0004'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0004'), 5.00, 8500.00, 0.00, 0.00, 19.00, 8075.00, 42500.00, 50575.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0005'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0005'), 5.00, 3900.00, 0.00, 0.00, 19.00, 3705.00, 19500.00, 23205.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0006'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0006'), 5.00, 4200.00, 0.00, 0.00, 19.00, 3990.00, 21000.00, 24990.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0007'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0007'), 5.00, 6500.00, 0.00, 0.00, 19.00, 6175.00, 32500.00, 38675.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0008'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0008'), 5.00, 7800.00, 0.00, 0.00, 19.00, 7410.00, 39000.00, 46410.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0009'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0009'), 5.00, 4800.00, 0.00, 0.00, 19.00, 4560.00, 24000.00, 28560.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0010'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0010'), 5.00, 13500.00, 0.00, 0.00, 19.00, 12825.00, 67500.00, 80325.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0011'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0011'), 5.00, 4300.00, 0.00, 0.00, 19.00, 4085.00, 21500.00, 25585.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0012'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0012'), 5.00, 9200.00, 0.00, 0.00, 19.00, 8740.00, 46000.00, 54740.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0013'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0013'), 5.00, 3600.00, 0.00, 0.00, 19.00, 3420.00, 18000.00, 21420.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0014'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0014'), 5.00, 4100.00, 0.00, 0.00, 19.00, 3895.00, 20500.00, 24395.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0015'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0015'), 5.00, 3200.00, 0.00, 0.00, 19.00, 3040.00, 16000.00, 19040.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0016'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0016'), 5.00, 2900.00, 0.00, 0.00, 19.00, 2755.00, 14500.00, 17255.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0017'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0017'), 5.00, 5400.00, 0.00, 0.00, 19.00, 5130.00, 27000.00, 32130.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0018'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0018'), 5.00, 3800.00, 0.00, 0.00, 19.00, 3610.00, 19000.00, 22610.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0019'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0019'), 5.00, 6500.00, 0.00, 0.00, 19.00, 6175.00, 32500.00, 38675.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0020'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0020'), 5.00, 7200.00, 0.00, 0.00, 19.00, 6840.00, 36000.00, 42840.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0021'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0021'), 5.00, 4800.00, 0.00, 0.00, 19.00, 4560.00, 24000.00, 28560.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0022'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0022'), 5.00, 5600.00, 0.00, 0.00, 19.00, 5320.00, 28000.00, 33320.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0023'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0023'), 5.00, 8900.00, 0.00, 0.00, 19.00, 8455.00, 44500.00, 52955.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0024'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0024'), 5.00, 19800.00, 0.00, 0.00, 19.00, 18810.00, 99000.00, 117810.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0025'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0025'), 5.00, 24800.00, 0.00, 0.00, 19.00, 23560.00, 124000.00, 147560.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0026'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0026'), 5.00, 11200.00, 0.00, 0.00, 19.00, 10640.00, 56000.00, 66640.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0027'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0027'), 5.00, 5200.00, 0.00, 0.00, 19.00, 4940.00, 26000.00, 30940.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0028'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0028'), 5.00, 15600.00, 0.00, 0.00, 19.00, 14820.00, 78000.00, 92820.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0029'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0029'), 5.00, 13600.00, 0.00, 0.00, 19.00, 12920.00, 68000.00, 80920.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0030'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0030'), 5.00, 18500.00, 0.00, 0.00, 19.00, 17575.00, 92500.00, 110075.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0031'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0031'), 5.00, 24900.00, 0.00, 0.00, 19.00, 23655.00, 124500.00, 148155.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0032'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0032'), 5.00, 22900.00, 0.00, 0.00, 19.00, 21755.00, 114500.00, 136255.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0033'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0033'), 5.00, 21500.00, 0.00, 0.00, 19.00, 20425.00, 107500.00, 127925.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0034'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0034'), 5.00, 13500.00, 0.00, 0.00, 19.00, 12825.00, 67500.00, 80325.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0035'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0035'), 5.00, 4800.00, 0.00, 0.00, 19.00, 4560.00, 24000.00, 28560.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0036'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0036'), 5.00, 10900.00, 0.00, 0.00, 19.00, 10355.00, 54500.00, 64855.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0037'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0037'), 5.00, 7800.00, 0.00, 0.00, 19.00, 7410.00, 39000.00, 46410.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0038'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0038'), 5.00, 8900.00, 0.00, 0.00, 19.00, 8455.00, 44500.00, 52955.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0039'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0039'), 5.00, 9200.00, 0.00, 0.00, 19.00, 8740.00, 46000.00, 54740.00);

INSERT INTO detalles_venta (id_venta, id_lote, cantidad_vendida, precio_unitario, descuento_aplicado, monto_descuento, tasa_impuesto, monto_impuesto, subtotal, total_linea)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0040'), (SELECT id_lote FROM lotes_inventario WHERE numero_lote = 'LOT-0040'), 5.00, 14500.00, 0.00, 0.00, 19.00, 13775.00, 72500.00, 86275.00);

-- facturas: 40 registros adicionales

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0001'), 'FAC-0001', 'CUFE-SIMULADO-0001', 'https://example.com/qr/FAC-0001', DATE_SUB(NOW(), INTERVAL 1 DAY), 34000.00, 0.00, 6460.00, 40460.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0002'), 'FAC-0002', 'CUFE-SIMULADO-0002', 'https://example.com/qr/FAC-0002', DATE_SUB(NOW(), INTERVAL 1 DAY), 36000.00, 0.00, 6840.00, 42840.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0003'), 'FAC-0003', 'CUFE-SIMULADO-0003', 'https://example.com/qr/FAC-0003', DATE_SUB(NOW(), INTERVAL 1 DAY), 18000.00, 0.00, 3420.00, 21420.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0004'), 'FAC-0004', 'CUFE-SIMULADO-0004', 'https://example.com/qr/FAC-0004', DATE_SUB(NOW(), INTERVAL 1 DAY), 42500.00, 0.00, 8075.00, 50575.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0005'), 'FAC-0005', 'CUFE-SIMULADO-0005', 'https://example.com/qr/FAC-0005', DATE_SUB(NOW(), INTERVAL 1 DAY), 19500.00, 0.00, 3705.00, 23205.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0006'), 'FAC-0006', 'CUFE-SIMULADO-0006', 'https://example.com/qr/FAC-0006', DATE_SUB(NOW(), INTERVAL 1 DAY), 21000.00, 0.00, 3990.00, 24990.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0007'), 'FAC-0007', 'CUFE-SIMULADO-0007', 'https://example.com/qr/FAC-0007', DATE_SUB(NOW(), INTERVAL 1 DAY), 32500.00, 0.00, 6175.00, 38675.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0008'), 'FAC-0008', 'CUFE-SIMULADO-0008', 'https://example.com/qr/FAC-0008', DATE_SUB(NOW(), INTERVAL 1 DAY), 39000.00, 0.00, 7410.00, 46410.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0009'), 'FAC-0009', 'CUFE-SIMULADO-0009', 'https://example.com/qr/FAC-0009', DATE_SUB(NOW(), INTERVAL 1 DAY), 24000.00, 0.00, 4560.00, 28560.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0010'), 'FAC-0010', 'CUFE-SIMULADO-0010', 'https://example.com/qr/FAC-0010', DATE_SUB(NOW(), INTERVAL 1 DAY), 67500.00, 0.00, 12825.00, 80325.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0011'), 'FAC-0011', 'CUFE-SIMULADO-0011', 'https://example.com/qr/FAC-0011', DATE_SUB(NOW(), INTERVAL 1 DAY), 21500.00, 0.00, 4085.00, 25585.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0012'), 'FAC-0012', 'CUFE-SIMULADO-0012', 'https://example.com/qr/FAC-0012', DATE_SUB(NOW(), INTERVAL 1 DAY), 46000.00, 0.00, 8740.00, 54740.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0013'), 'FAC-0013', 'CUFE-SIMULADO-0013', 'https://example.com/qr/FAC-0013', DATE_SUB(NOW(), INTERVAL 1 DAY), 18000.00, 0.00, 3420.00, 21420.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0014'), 'FAC-0014', 'CUFE-SIMULADO-0014', 'https://example.com/qr/FAC-0014', DATE_SUB(NOW(), INTERVAL 1 DAY), 20500.00, 0.00, 3895.00, 24395.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0015'), 'FAC-0015', 'CUFE-SIMULADO-0015', 'https://example.com/qr/FAC-0015', DATE_SUB(NOW(), INTERVAL 1 DAY), 16000.00, 0.00, 3040.00, 19040.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0016'), 'FAC-0016', 'CUFE-SIMULADO-0016', 'https://example.com/qr/FAC-0016', DATE_SUB(NOW(), INTERVAL 1 DAY), 14500.00, 0.00, 2755.00, 17255.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0017'), 'FAC-0017', 'CUFE-SIMULADO-0017', 'https://example.com/qr/FAC-0017', DATE_SUB(NOW(), INTERVAL 1 DAY), 27000.00, 0.00, 5130.00, 32130.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0018'), 'FAC-0018', 'CUFE-SIMULADO-0018', 'https://example.com/qr/FAC-0018', DATE_SUB(NOW(), INTERVAL 1 DAY), 19000.00, 0.00, 3610.00, 22610.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0019'), 'FAC-0019', 'CUFE-SIMULADO-0019', 'https://example.com/qr/FAC-0019', DATE_SUB(NOW(), INTERVAL 1 DAY), 32500.00, 0.00, 6175.00, 38675.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0020'), 'FAC-0020', 'CUFE-SIMULADO-0020', 'https://example.com/qr/FAC-0020', DATE_SUB(NOW(), INTERVAL 1 DAY), 36000.00, 0.00, 6840.00, 42840.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0021'), 'FAC-0021', 'CUFE-SIMULADO-0021', 'https://example.com/qr/FAC-0021', DATE_SUB(NOW(), INTERVAL 1 DAY), 24000.00, 0.00, 4560.00, 28560.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0022'), 'FAC-0022', 'CUFE-SIMULADO-0022', 'https://example.com/qr/FAC-0022', DATE_SUB(NOW(), INTERVAL 1 DAY), 28000.00, 0.00, 5320.00, 33320.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0023'), 'FAC-0023', 'CUFE-SIMULADO-0023', 'https://example.com/qr/FAC-0023', DATE_SUB(NOW(), INTERVAL 1 DAY), 44500.00, 0.00, 8455.00, 52955.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0024'), 'FAC-0024', 'CUFE-SIMULADO-0024', 'https://example.com/qr/FAC-0024', DATE_SUB(NOW(), INTERVAL 1 DAY), 99000.00, 0.00, 18810.00, 117810.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0025'), 'FAC-0025', 'CUFE-SIMULADO-0025', 'https://example.com/qr/FAC-0025', DATE_SUB(NOW(), INTERVAL 1 DAY), 124000.00, 0.00, 23560.00, 147560.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0026'), 'FAC-0026', 'CUFE-SIMULADO-0026', 'https://example.com/qr/FAC-0026', DATE_SUB(NOW(), INTERVAL 1 DAY), 56000.00, 0.00, 10640.00, 66640.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0027'), 'FAC-0027', 'CUFE-SIMULADO-0027', 'https://example.com/qr/FAC-0027', DATE_SUB(NOW(), INTERVAL 1 DAY), 26000.00, 0.00, 4940.00, 30940.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0028'), 'FAC-0028', 'CUFE-SIMULADO-0028', 'https://example.com/qr/FAC-0028', DATE_SUB(NOW(), INTERVAL 1 DAY), 78000.00, 0.00, 14820.00, 92820.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0029'), 'FAC-0029', 'CUFE-SIMULADO-0029', 'https://example.com/qr/FAC-0029', DATE_SUB(NOW(), INTERVAL 1 DAY), 68000.00, 0.00, 12920.00, 80920.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0030'), 'FAC-0030', 'CUFE-SIMULADO-0030', 'https://example.com/qr/FAC-0030', DATE_SUB(NOW(), INTERVAL 1 DAY), 92500.00, 0.00, 17575.00, 110075.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0031'), 'FAC-0031', 'CUFE-SIMULADO-0031', 'https://example.com/qr/FAC-0031', DATE_SUB(NOW(), INTERVAL 1 DAY), 124500.00, 0.00, 23655.00, 148155.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0032'), 'FAC-0032', 'CUFE-SIMULADO-0032', 'https://example.com/qr/FAC-0032', DATE_SUB(NOW(), INTERVAL 1 DAY), 114500.00, 0.00, 21755.00, 136255.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0033'), 'FAC-0033', 'CUFE-SIMULADO-0033', 'https://example.com/qr/FAC-0033', DATE_SUB(NOW(), INTERVAL 1 DAY), 107500.00, 0.00, 20425.00, 127925.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0034'), 'FAC-0034', 'CUFE-SIMULADO-0034', 'https://example.com/qr/FAC-0034', DATE_SUB(NOW(), INTERVAL 1 DAY), 67500.00, 0.00, 12825.00, 80325.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0035'), 'FAC-0035', 'CUFE-SIMULADO-0035', 'https://example.com/qr/FAC-0035', DATE_SUB(NOW(), INTERVAL 1 DAY), 24000.00, 0.00, 4560.00, 28560.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0036'), 'FAC-0036', 'CUFE-SIMULADO-0036', 'https://example.com/qr/FAC-0036', DATE_SUB(NOW(), INTERVAL 1 DAY), 54500.00, 0.00, 10355.00, 64855.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0037'), 'FAC-0037', 'CUFE-SIMULADO-0037', 'https://example.com/qr/FAC-0037', DATE_SUB(NOW(), INTERVAL 1 DAY), 39000.00, 0.00, 7410.00, 46410.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0038'), 'FAC-0038', 'CUFE-SIMULADO-0038', 'https://example.com/qr/FAC-0038', DATE_SUB(NOW(), INTERVAL 1 DAY), 44500.00, 0.00, 8455.00, 52955.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0039'), 'FAC-0039', 'CUFE-SIMULADO-0039', 'https://example.com/qr/FAC-0039', DATE_SUB(NOW(), INTERVAL 1 DAY), 46000.00, 0.00, 8740.00, 54740.00);

INSERT INTO facturas (id_venta, numero_factura, cufe, enlace_qr, fecha_emision, subtotal, total_descuento, monto_impuesto, monto_total)
VALUES ((SELECT id_venta FROM ventas WHERE numero_venta = 'VEN-0040'), 'FAC-0040', 'CUFE-SIMULADO-0040', 'https://example.com/qr/FAC-0040', DATE_SUB(NOW(), INTERVAL 1 DAY), 72500.00, 0.00, 13775.00, 86275.00);

COMMIT;
