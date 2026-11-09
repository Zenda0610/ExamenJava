# ERP para la Bodega de Alimentos "Frescura Total"

## Descripción

Frescura Total es un ERP de consola desarrollado en Java para una bodega que distribuye alimentos perecederos. Centraliza la recepción de mercancía por lote, el control de vencimientos, cuarentenas y mermas, el catálogo de proveedores, las ventas y los despachos. Al confirmar una venta, el sistema asigna primero los lotes aptos que vencen antes mediante la estrategia FEFO, actualiza las existencias y genera una factura PDF simulada. La trazabilidad por lote permite consultar el origen de la mercancía y las ventas asociadas.

## Autores

- David Leonardo Martinez Perez
- Maria Gabriela Rincón Leon

## Requerimientos previos

| Herramienta | Requisito |
| --- | --- |
| JDK | Java 26, según la versión de compilación declarada en `pom.xml`. |
| IDE | Apache NetBeans con soporte para Java 26 y proyectos Maven. |
| Construcción | Apache Maven, ya sea el incluido en NetBeans o una instalación para usar desde la terminal. |
| Base de datos | MySQL Server 8.0 y un cliente como MySQL Workbench, DBeaver o la consola `mysql`. |
| Control de versiones | Git para clonar el repositorio. |

En la primera compilación, Maven descarga MySQL Connector/J, Apache PDFBox y ZXing. Estas bibliotecas permiten conectar con MySQL, crear el PDF y generar el código QR, respectivamente.

## Configuración de la base de datos

1. Inicia MySQL Server y verifica el puerto en el que escucha. El proyecto está configurado inicialmente para usar el puerto **3307**. Si tu instancia usa **3306**, ajusta la URL de conexión.
2. Abre tu cliente MySQL y conéctate a la instancia local con una cuenta que tenga permisos para crear el esquema y sus tablas.
3. Abre [`docs/database.sql`](docs/database.sql) y ejecútalo completo. La sección **DDL** crea el esquema `erp_frescura_total`, las tablas y sus claves. La sección **DML** carga los catálogos y los registros de prueba. **El script comienza con `DROP DATABASE IF EXISTS` y reemplaza el esquema y sus datos si ya existen.** Úsalo para una instalación nueva o sobre una base de pruebas cuyo contenido puedas reemplazar.
4. Comprueba que la carga terminó y que se pueden consultar las tablas.

   ```sql
   USE erp_frescura_total;
   SELECT COUNT(*) AS productos_registrados FROM productos;
   SELECT COUNT(*) AS ventas_registradas FROM ventas;
   ```

5. Ajusta la conexión de Java en `src/main/java/com/mycompany/proyectojava/common/connectionBD.java`. Los valores `URL`, `USER` y `PASSWORD` sirven como configuración predeterminada. También se pueden pasar propiedades a la JVM para usar valores locales.

   | Dato | Propiedad de Java | Valor de ejemplo |
   | --- | --- | --- |
   | URL de conexión | `erp.jdbc.url` | `jdbc:mysql://localhost:3307/erp_frescura_total` |
   | Usuario | `erp.jdbc.user` | `erp_local` |
   | Contraseña | `erp.jdbc.password` | `TU_CONTRASEÑA_LOCAL` |

   Sustituye el usuario y la contraseña del ejemplo por los de tu instancia. La cuenta con la que se ejecuta el ERP debe poder consultar, insertar y actualizar datos en el esquema. Mantén las credenciales personales fuera del repositorio.

El script incluye 50 proveedores, 50 productos, 50 clientes, 50 lotes y 50 ventas. También carga sus relaciones, 50 detalles de venta y 50 facturas. Los catálogos, las inspecciones y las rutas incluyen datos para recorrer los demás módulos.

### Configuración del inspector

Para restringir la opción de inspección a una cuenta de inspector, configura las variables de entorno locales `ERP_INSPECTOR_USER` y `ERP_INSPECTOR_PASSWORD` antes de iniciar NetBeans o la aplicación. La opción **9** de inventario pedirá la clave de la cuenta antes de registrar el resultado. El usuario y la clave son valores definidos por quien configura el entorno. Mantén la clave fuera del repositorio.

Con ambas variables sin definir, la aplicación conserva la opción de demostración original, que registra el nombre del inspector. El control de acceso se activa en cuanto se configura alguna de las variables. Define ambas para autorizar la cuenta.

## Instalación y ejecución

### Desde Apache NetBeans

1. Extrae el ZIP en tu equipo.

2. En NetBeans, selecciona **File > Open Project**. Abre la carpeta extraída `ProyectoJava-NetBeans/`, que contiene el archivo `pom.xml`.
3. Verifica que el proyecto use JDK 26. Si el IDE no lo detecta, agrega ese JDK desde **Tools > Java Platforms** y selecciónalo para el proyecto.
4. Con la base configurada, selecciona el proyecto y usa **Run > Clean and Build Project** para compilar y empaquetar.
5. Ejecuta **Run > Run Project** o presiona **F6**. Si NetBeans pide elegir la clase principal, selecciona `com.mycompany.proyectojava.ProyectoJava`.
6. Usa la ventana **Output** para escribir las opciones del menú. Las facturas PDF quedan en la carpeta `facturas/` del directorio de ejecución. Al generarlas, la aplicación muestra su ruta completa.

### Desde la terminal

Con JDK 26 activo y Maven instalado, ejecuta estos comandos desde la raíz del repositorio. Sustituye los datos de conexión por los de tu instancia local.

```bash
mvn -f pom.xml clean package
mvn -f pom.xml "-Derp.jdbc.url=jdbc:mysql://localhost:3307/erp_frescura_total" "-Derp.jdbc.user=erp_local" "-Derp.jdbc.password=TU_CONTRASEÑA_LOCAL" compile exec:java
```

Maven genera el archivo JAR en `target/`. El comando `exec:java` ejecuta la clase principal con las dependencias del proyecto.

### Flujo de uso

1. En **Proveedores y compras**, registra un proveedor y asocia los productos que puede suministrar.
2. En **Inventarios y calidad**, registra el ingreso de un lote y consulta sus existencias y vencimiento.
3. En **Ventas y facturación**, registra o selecciona un cliente y vende un producto. La aplicación distribuye la cantidad entre los lotes aptos por orden de vencimiento. El PDF resultante es una factura de demostración sin validez fiscal.
4. En **Logística y entregas**, crea una ruta, asigna un vehículo y un conductor, vincula un pedido en preparación y registra la salida y la llegada.

También puedes usar la opción **5** de ventas para agregar varios productos, revisar las cantidades y confirmar un único pedido con su factura. Esa opción consulta `promociones` para los lotes próximos a vencer. Una promoción vigente puede filtrar por categoría y estado de lote. La tasa se guarda como fracción, por ejemplo `0.25` para el 25 %. Si no hay una promoción aplicable, se conserva el descuento base del 50 %.

La revisión de vencimientos se ejecuta al iniciar la aplicación y se repite cada 24 horas mientras permanece abierta. La opción **4** de inventario permite lanzarla manualmente. La opción **11** distingue las entregas confirmadas del historial general de ventas por lote.

## Estructura del proyecto

El proyecto agrupa el código por módulo. La clase `ProyectoJava` abre el menú principal. Dentro de cada componente, `view` contiene los menús y formularios de consola, `controller` coordina las operaciones y `model` contiene las entidades y el acceso a datos.

```text
ProyectoJava-NetBeans/
├── pom.xml
├── nbactions.xml
├── README.txt                          # Ubicación y pruebas de las integraciones
├── clientes_importar.txt
├── docs/                               # SQL y diagramas
└── src/main/java/com/mycompany/proyectojava/
    ├── ProyectoJava.java
    ├── common/
    ├── inventory/
    ├── suppliers/
    ├── sales/
    └── logistics/
```

## Principios y patrones de diseño

### MVC por componentes

En ventas, `SalesView` recibe el cliente, los productos y las cantidades desde la consola. `SalesController` coordina la selección FEFO y calcula los importes. `SalesDAO` guarda la operación en MySQL. En inventario, `InventoryView` también pasa sus consultas al controlador. La separación permite cambiar los mensajes o la navegación de la vista sin reescribir las operaciones sobre los datos.

### DAO (Data Access Object)

Clases como `SalesDAO`, `inventoryDAO` y `LogisticsDAO` agrupan las consultas JDBC de sus módulos. Usan sentencias preparadas para pasar parámetros a MySQL y convierten los resultados en objetos del modelo. Esto concentra el SQL y el manejo de conexiones en clases concretas, mientras que los controladores trabajan con operaciones como registrar una venta o actualizar el recorrido de una ruta.

### Principio de responsabilidad única (SRP)

`InvoicePdf` se ocupa de componer y guardar el PDF, incluidos el detalle de la venta, los totales y el QR. La selección de lotes y el cálculo de importes quedan en `SalesController`, y la persistencia corresponde a `SalesDAO`. Así, cambiar el formato de la factura se puede hacer en el generador sin tocar la lógica que descuenta las existencias.

### Transacción para el registro de una venta

`SalesDAO` registra la cabecera de venta, sus detalles, el descuento de existencias y la factura en una transacción. Si una escritura falla, la transacción se revierte para evitar pedidos incompletos o inventario descontado sin su venta correspondiente. El PDF se genera después de confirmar la transacción. Si el archivo no se puede escribir, el sistema informa que la venta y la factura siguen registradas en la base de datos.

