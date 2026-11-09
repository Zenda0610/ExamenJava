-- Run on an existing installation of the original ERP.
USE erp_frescura_total;

INSERT INTO estados_venta (nombre, descripcion)
SELECT 'Devuelta', 'Venta devuelta por el cliente'
WHERE NOT EXISTS (SELECT 1 FROM estados_venta WHERE nombre = 'Devuelta');
