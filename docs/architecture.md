# RoomOps — Arquitectura Técnica

## 1. Descripción general

RoomOps es una plataforma web para gestionar las operaciones diarias de empresas dedicadas a los juegos de escape.

El sistema centraliza la gestión de salas, clientes, reservas, pagos, gastos y herramientas de operación.

La arquitectura separa las interfaces de usuario, la lógica de negocio y la persistencia de datos para favorecer el mantenimiento, las pruebas y la posibilidad de ampliar el sistema en el futuro.

## 2. Tecnologías

### Frontend
- **React:** biblioteca para construir las interfaces de usuario.
- **TypeScript:** lenguaje que incorpora tipado estático a JavaScript.

### Backend
- **Java 21:** lenguaje y entorno de ejecución del backend.
- **Spring Boot:** framework para desarrollar la aplicación backend y su API REST.

### Base de datos
- **PostgreSQL:** sistema de gestión de bases de datos relacionales utilizado para almacenar los datos de la aplicación.

### Desarrollo y control de versiones
- **Git:** herramienta de control de versiones.
- **GitHub:** alojamiento remoto del repositorio y seguimiento de los cambios.
- **Docker:** herramienta para ejecutar servicios en entornos reproducibles.

## 3. Arquitectura general

RoomOps utiliza una arquitectura cliente-servidor.

El sistema contempla los siguientes componentes:

1. **Sitio web público de reservas:** interfaz destinada a los clientes, donde pueden consultar salas, disponibilidad y realizar reservas.
2. **Panel interno de gestión:** interfaz utilizada por administradores y operadores para gestionar las operaciones diarias de la empresa.
3. **API backend:** aplicación desarrollada con Spring Boot que expone endpoints, aplica las reglas de negocio, valida las operaciones y controla los accesos.
4. **Base de datos PostgreSQL:** almacena la información persistente del sistema.

Las interfaces pueden comunicarse con el mismo backend mediante una API. Ninguna de ellas accede directamente a la base de datos.

## 4. Responsabilidades de cada componente

### Frontend

- Mostrar las interfaces de usuario.
- Recopilar los datos ingresados y realizar validaciones orientadas a la usabilidad.
- Mostrar la información recibida del backend.
- Enviar solicitudes a la API.
- Presentar los horarios y las opciones de reserva disponibles según la información de disponibilidad calculada por RoomOps.

El frontend no será responsable de garantizar por sí solo el cumplimiento de las reglas de negocio ni de la seguridad.

### Backend

- Autenticar usuarios y autorizar acciones según sus roles.
- Gestionar salas, clientes, reservas, pagos y gastos.
- Aplicar las reglas de negocio y validar las operaciones.
- Exponer endpoints mediante una API REST.
- Coordinar las operaciones sobre la base de datos.
- Integrar RoomOps con plataformas externas de reservas cuando corresponda.

### Base de datos

- Persistir los datos de la aplicación.
- Garantizar la integridad referencial mediante claves primarias y foráneas.
- Aplicar restricciones de unicidad y validaciones compatibles con la base de datos.
- Mantener las relaciones entre las entidades.

### Integraciones externas

La arquitectura permitirá incorporar integraciones con plataformas externas de reservas, como Booknetic, en versiones futuras.

La V1 no incluirá conectores externos ni sincronización automática de disponibilidad, creación, modificación o cancelación de reservas.

Durante V1, RoomOps gestionará la disponibilidad a partir de las reservas registradas en su propia base de datos. Las reservas realizadas en plataformas externas no se reflejarán automáticamente en RoomOps.

Las futuras integraciones deberán aislarse en componentes específicos y respetar las capacidades, limitaciones y mecanismos de validación del proveedor correspondiente.

## 5. Principios de arquitectura

- Separar la presentación, la lógica de negocio y la persistencia.
- Mantener las reglas de negocio en el backend y no depender exclusivamente de las validaciones del frontend.
- Utilizar un modelo relacional con restricciones explícitas.
- Almacenar los importes monetarios mediante tipos decimales exactos, evitando los tipos de punto flotante.
- Conservar el precio acordado de una reserva como dato histórico.
- Mantener RoomOps independiente de una empresa específica.
- Evitar complejidad innecesaria y priorizar un diseño modular y mantenible.
- Aislar las integraciones externas para evitar que las particularidades de un proveedor condicionen todo el sistema.
- La disponibilidad de V1 se calculará con las reservas registradas en RoomOps; no se asumirá que representa la disponibilidad de sistemas externos no integrados.

## 6. Alcance inicial

La primera versión de RoomOps incluirá:

- Autenticación y control de acceso por roles.
- Gestión de usuarios.
- Gestión de salas y precios.
- Gestión de clientes.
- Gestión de reservas.
- Registro de pagos.
- Registro de gastos.
- Dashboard operativo.
- Grilla de reservas.

Quedan fuera del alcance inicial:

- Procesamiento real de pagos.
- Integración con Mercado Pago para procesar cobros.
- Facturación electrónica.
- Integración con WhatsApp.
- Integraciones con plataformas externas de reservas, incluida Booknetic.
- Sincronización automática de reservas y disponibilidad con sistemas externos.
- Aplicación móvil.
- Políticas automáticas de devolución.

## 7. Enfoque de desarrollo

El desarrollo se realizará de manera incremental:

1. Definición de requisitos y modelado conceptual de datos.
2. Diseño de la arquitectura técnica y del esquema físico de la base de datos.
3. Implementación del backend y pruebas automatizadas.
4. Implementación del frontend e integración con la API.
5. Pruebas de integración y de extremo a extremo.
6. Preparación del despliegue y documentación final.

Los cambios significativos se registrarán mediante Git y se publicarán en GitHub.

## 8. Estado actual

- Requisitos funcionales documentados.
- Diagrama Entidad-Relación conceptual creado.
- Stack tecnológico seleccionado.
- Arquitectura técnica documentada.
- Diseño físico de la base de datos en elaboración.

El siguiente paso es completar el diseño físico de PostgreSQL y preparar su implementación.