# RoomOps — Requirements

## 1. Descripción del sistema

RoomOps es una plataforma web para la gestión operativa de negocios de escape rooms.

El sistema busca centralizar en una única plataforma la información relacionada con salas, clientes, reservas, pagos, gastos y operaciones diarias del negocio.

El producto se plantea como una solución genérica e independiente, aplicable a distintos negocios del sector y no vinculada a un establecimiento específico.

---

## 2. Objetivo

El sistema deberá permitir:

* Gestionar reservas.
* Controlar la disponibilidad de las salas.
* Gestionar clientes.
* Registrar y consultar pagos.
* Registrar y consultar gastos.
* Facilitar la operación diaria de las reservas.
* Proporcionar una visión general del negocio mediante un dashboard.

---

## 3. Usuarios y roles

El sistema tendrá dos roles principales:

### 3.1 ADMIN

El administrador podrá:

* Gestionar usuarios.
* Gestionar salas.
* Gestionar clientes.
* Gestionar reservas.
* Gestionar pagos.
* Gestionar gastos.
* Consultar el dashboard.
* Consultar la grilla de reservas.

### 3.2 OPERATOR

El operador podrá:

* Gestionar clientes.
* Gestionar reservas.
* Registrar pagos.
* Consultar el detalle de una reserva y sus pagos asociados.
* Consultar el dashboard.
* Consultar la grilla de reservas.
* Registrar gastos.

El operador no podrá gestionar usuarios.

---

## 4. Requisitos funcionales

### 4.1 Autenticación y usuarios

Cada usuario deberá contar con:

* Nombre de usuario o email.
* Contraseña.
* Rol.
* Estado activo/inactivo.

Los usuarios inactivos no podrán iniciar sesión.

---

### 4.2 Salas

El sistema deberá permitir:

* Crear salas.
* Editar salas.
* Consultar salas.
* Activar o desactivar salas.

Cada sala deberá contar con:

* Nombre.
* Descripción.
* Temática.
* Dificultad.
* Capacidad mínima.
* Capacidad máxima.
* Estado.
* Configuración de precios según cantidad de jugadores.
* Configuración de duración.

La dificultad tendrá los siguientes valores:

* FÁCIL
* INTERMEDIO
* DIFÍCIL
* EXPERTO

La duración estándar de V1 será:

* 60 minutos de juego.
* 30 minutos de intervalo operativo entre turnos.

El modelo deberá permitir soportar diferentes duraciones e intervalos en el futuro.

Una sala inactiva conservará su historial, pero no podrá recibir nuevas reservas.

---

### 4.3 Precios de salas

El precio dependerá de la cantidad de jugadores.

Por ejemplo:

* 2 jugadores → precio A.
* 3 jugadores → precio B.
* 4 jugadores → precio C.
* 5 jugadores → precio D.

Cuando una reserva sea confirmada, el precio correspondiente deberá quedar registrado en la reserva.

Los cambios posteriores en los precios de la sala no deberán modificar el precio de reservas ya confirmadas.

---

### 4.4 Clientes

El sistema deberá permitir:

* Crear clientes.
* Editar clientes.
* Consultar clientes.
* Consultar el historial de reservas de un cliente.

Cada cliente deberá contar con:

* Nombre.
* Apellido.
* Teléfono obligatorio.
* Email opcional.

Un mismo cliente podrá tener múltiples reservas, incluso varias reservas o salas durante el mismo día.

---

### 4.5 Reservas

El sistema deberá permitir:

* Crear reservas.
* Consultar reservas.
* Modificar reservas.
* Cancelar reservas.
* Completar reservas.
* Consultar el detalle de una reserva.
* Consultar los pagos asociados.
* Consultar el saldo pendiente.

Cada reserva deberá registrar:

* Cliente/responsable.
* Sala.
* Fecha.
* Hora de inicio.
* Cantidad de jugadores.
* Precio acordado.
* Estado.
* Notas.

Los estados serán:

* CONFIRMED
* COMPLETED
* CANCELLED

Una nueva reserva comenzará en estado `CONFIRMED`.

Las transiciones permitidas serán:

```text
CONFIRMED → COMPLETED
CONFIRMED → CANCELLED
```

Una reserva cancelada liberará el horario correspondiente.

Una reserva cancelada no podrá volver a confirmarse. Si el cliente desea realizar otra reserva, deberá crearse una nueva.

---

### 4.6 Disponibilidad

El sistema deberá garantizar que:

* No existan reservas confirmadas superpuestas para una misma sala.
* Una reserva confirmada ocupe el horario correspondiente.
* Una reserva cancelada no bloquee el horario.
* La cantidad de jugadores no supere la capacidad máxima de la sala.
* Una sala inactiva no pueda recibir nuevas reservas.

Las excepciones de capacidad quedan fuera del alcance de V1.

---

### 4.7 Modificación de reservas

Una reserva confirmada podrá modificarse.

Por ejemplo, si una reserva fue realizada para 6 jugadores y posteriormente asisten 7, siempre que la sala permita 7 jugadores:

* La cantidad de jugadores podrá modificarse a 7.
* Se deberá recalcular el precio correspondiente.
* Si existe una diferencia pendiente, deberá registrarse el pago correspondiente.

Toda modificación deberá respetar la capacidad máxima de la sala.

---

### 4.8 Pagos

Una reserva podrá tener múltiples pagos.

Relación conceptual:

```text
RESERVATION 1 ───── N PAYMENT
```

Cada pago pertenecerá a una única reserva.

Cada pago deberá registrar:

* Monto.
* Medio de pago.
* Fecha y hora.
* Usuario que registró el pago.

Los medios de pago de V1 serán:

* EFECTIVO
* MERCADO_PAGO

RoomOps no procesará pagos reales. El sistema únicamente registrará pagos realizados externamente.

No se podrá registrar un pago cuyo importe supere el saldo pendiente de la reserva.

---

### 4.9 Cancelaciones

Al cancelar una reserva:

* El horario deberá quedar disponible.
* La reserva deberá conservarse como historial.
* Los pagos asociados deberán conservarse.
* No se implementará una política automática de reembolsos en V1.

La política de reembolsos podrá configurarse en una futura versión para adaptarse a las reglas particulares de cada negocio.

---

### 4.10 Gastos

El sistema deberá permitir:

* Registrar gastos.
* Consultar gastos.
* Editar gastos.
* Categorizar gastos.

Cada gasto deberá registrar:

* Fecha.
* Concepto.
* Importe.
* Categoría.
* Usuario que lo registró.

Las categorías de V1 serán:

* INSUMOS
* MANTENIMIENTO
* VARIOS

---

### 4.11 Dashboard

El dashboard deberá proporcionar una visión general del negocio.

Deberá mostrar información como:

* Reservas del día.
* Próximas reservas.
* Cantidad de reservas.
* Ingresos.
* Gastos.
* Resultado.
* Información de ocupación de las salas.

El dashboard será principalmente informativo y de alto nivel.

---

### 4.12 Grilla operativa de reservas

La grilla de reservas será una de las funcionalidades centrales de RoomOps.

Deberá mostrar las reservas organizadas por:

* Horario.
* Sala.

La información visible deberá permitir identificar rápidamente:

* Horario.
* Sala.
* Cliente/responsable.
* Cantidad de jugadores.
* Estado de la reserva.
* Información relevante sobre pagos.

Al seleccionar una reserva, el sistema deberá permitir acceder a su detalle.

Desde el detalle se podrá:

* Consultar la información completa de la reserva.
* Consultar los pagos realizados.
* Consultar el saldo pendiente.
* Registrar pagos pendientes.

---

## 5. Reglas de negocio

1. Toda reserva deberá estar asociada a un cliente.
2. Toda reserva deberá estar asociada a una sala.
3. Toda reserva deberá tener fecha y hora de inicio.
4. Toda reserva deberá indicar la cantidad de jugadores.
5. La cantidad de jugadores no podrá superar la capacidad máxima de la sala.
6. Una sala inactiva no podrá recibir nuevas reservas.
7. No podrán existir reservas confirmadas superpuestas para una misma sala.
8. Una reserva cancelada deberá liberar el horario.
9. Una reserva cancelada no podrá volver a confirmarse.
10. Una reserva podrá tener múltiples pagos.
11. Cada pago pertenecerá a una única reserva.
12. El total de pagos no podrá superar el precio de la reserva.
13. El precio de una reserva confirmada deberá mantenerse aunque posteriormente cambie el precio de la sala.
14. Los pagos y gastos deberán registrar qué usuario los ingresó.
15. Los pagos deberán conservarse como historial aunque la reserva sea cancelada.
16. Una reserva completada deberá conservarse como registro histórico.
17. Las modificaciones de una reserva deberán respetar la capacidad máxima de la sala.
18. Si una modificación cambia el precio de una reserva, el sistema deberá reflejar la nueva diferencia pendiente.

---

## 6. Alcance de V1

La primera versión de RoomOps incluirá:

* Autenticación.
* Usuarios y roles.
* Salas.
* Temática y dificultad de salas.
* Precios según cantidad de jugadores.
* Configuración de duración.
* Clientes.
* Reservas.
* Pagos.
* Gastos.
* Dashboard.
* Grilla operativa de reservas.

---

## 7. Fuera del alcance de V1

Las siguientes funcionalidades no serán implementadas inicialmente:

* Procesamiento real de pagos.
* Integración con Mercado Pago.
* Integración con WhatsApp.
* Facturación electrónica.
* Integración con AFIP.
* Aplicación móvil.
* Integración con Booknetic u otros sistemas externos.
* Reembolsos automáticos.
* Excepciones de capacidad.
* Sistema avanzado de precios.
* Configuración avanzada de duración por sala.

---

## 8. Posibles mejoras futuras

Entre las posibles mejoras posteriores se encuentran:

* Políticas de reembolso configurables por negocio.
* Motivos de cancelación.
* Duraciones e intervalos diferentes por sala.
* Excepciones de capacidad.
* Diferenciación de subtipos de Mercado Pago.
* Integraciones con sistemas externos.
* Reportes financieros avanzados.
* Comunicación con clientes.
* Sistema avanzado de precios.
