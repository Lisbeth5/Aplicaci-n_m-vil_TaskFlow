# taskflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Alcance de TaskFlow

Problema: necesito gestionar mis entregas universitarias de desarrollo de software, exposiciones y rutinas semanales para evitar retrasos y priorizar lo urgente.
Usuario objetivo: estudiante universitario de ingeniería/desarrollo de software que organiza sus proyectos académicos, exámenes y actividades personales de la semana.

### Historias de usuario y criterios de aceptación
1. Como estudiante universitario, quiero visualizar mis actividades académicas y personales en una lista para identificar rápidamente qué entregas son urgentes.
   Criterio: la pantalla principal muestra las tarjetas con el título, nivel de prioridad (Alta, Media o Baja) y el estado de cada tarea.
2. Como estudiante universitario, quiero seleccionar una actividad de mi lista para revisar los detalles técnicos o entregables específicos (como diagramas o temas de exposición).
   Criterio: al tocar cualquier tarjeta se abre la pantalla de detalle mostrando su descripción completa, prioridad, estado y el identificador de usuario (`userId: 1`).
3. Como estudiante universitario, quiero registrar nuevas tareas académicas o personales para mantener actualizado mi cronograma semanal.
   Criterio: el formulario futuro permite ingresar título, descripción y prioridad, guardando la nueva tarea y reflejándola en la lista principal.
4. Como estudiante universitario, quiero actualizar la prioridad o marcar como completada una entrega (como el informe de base de datos) para llevar un control real de mi avance.
   Criterio: al editar una tarea o cambiar su estado, la modificación se refleja tanto en la tarjeta de la lista como en su vista de detalle.
5. Como estudiante universitario, quiero eliminar actividades que ya fueron entregadas o evaluadas para mantener enfocada mi lista en los pendientes activos.
   Criterio: tras confirmar la eliminación, la tarea desaparece definitivamente de la lista principal.

### Modelo de datos
* **Task:** `id` (entero único del 1 al 5), `title` (texto con el nombre de la actividad), `description` (texto con el detalle del entregable), `priority` (Alta, Media o Baja), `isCompleted` (booleano verdadero/falso) y `userId` (entero `1` que identifica al estudiante).

### Pantallas previstas
* **Lista:** Muestra las tarjetas de las cinco actividades actuales (estudio móvil, informe de base de datos, configuración de GitHub, exposición grupal y horario semanal) junto con el botón de acción para crear nuevas.
* **Detalle:** Presenta toda la información específica de la actividad seleccionada (título, descripción extensa, prioridad, estado y usuario) y el espacio para futuras acciones de edición o borrado.
* **Formulario (futuro):** Interfaz con campos de entrada para título, descripción y selector de prioridad para agregar o modificar tareas.

### Requisitos no funcionales
* La interfaz y la navegación deben emplear etiquetas claras y comprensibles en español.
* Si se intenta consultar una tarea con un `id` inexistente, la aplicación debe mostrar un mensaje informativo controlado en pantalla en lugar de cerrarse inesperadamente.

### Contrato de API que necesitaremos
* `GET /tasks` — Obtener el listado completo de tareas del estudiante.
* `GET /tasks/:id` — Consultar el detalle de una actividad específica mediante su identificador.
* `POST /tasks` — Registrar una nueva tarea académica o personal.
* `PATCH /tasks/:id` — Actualizar el estado (`isCompleted`), prioridad o descripción de una tarea existente.
* `DELETE /tasks/:id` — Eliminar una tarea de la lista.

La API concreta se elegirá después. Estas rutas son requisitos, no
direcciones de un servidor ya conectado.


## API de tareas
TaskFlow consulta tareas remotas mediante `Dio`, `Future` y `async/await` siguiendo la arquitectura **Service → Repository → ViewModel**.

- **URL exacta:** `https://jsonplaceholder.typicode.com/todos`[cite: 3, 4]
- **Parámetro `userId`:** Se envía como parámetro de consulta (`?userId=3`) para filtrar las tareas de un usuario específico[cite: 3, 4]. Para este proyecto se cambió la constante `userId` de `TaskApiService` al valor **`3`** y se comprobaron sus tareas[cite: 3, 4].
- **Campos que llegan desde la API:** `id`, `title`, `completed` (mapeado a `isCompleted` en `Task.fromJson`) y `userId`[cite: 3, 4].
- **Valores que TaskFlow completa por defecto:** Cuando la API remota no incluye estos campos, `Task.fromJson` asigna `'Sin descripción (API)'` en `description` y `'Sin prioridad (API)'` en `priority`[cite: 2, 3].
- **Marcado de tareas local:** Marcar o desmarcar una tarea como completada sigue siendo **local (en memoria)**; el cambio no se envía ni persiste en el servidor remoto al reiniciar la aplicación[cite: 2, 3].

### Cadena Service → Repository → ViewModel

- **Qué parte conoce la URL:** `TaskApiService` conoce la base `https://jsonplaceholder.typicode.com` y consulta el endpoint `/todos` pasando el parámetro `userId` mediante `Dio`[cite: 3, 4].
- **Qué parte convierte el JSON:** `TaskApiService` recibe la lista de mapas JSON y `Task.fromJson` convierte cada elemento en un objeto `Task` (completando los campos faltantes por defecto), mientras `RemoteTaskRepository` expone el resultado como `Future<List<Task>>`[cite: 2, 3, 4].
- **Qué parte avisa a la vista:** `TasksViewModel` invoca al repositorio de forma asíncrona (`async`/`await`), actualiza su estado interno y notifica a la vista para refrescar la pantalla[cite: 2, 3].


## Sesión 8: Estados asíncronos en TaskFlow

Para verificar el manejo de estados de la lista remota (`ChangeNotifier`), se provocaron los siguientes escenarios:

- **Estado de Éxito:** Con conexión a internet activa y un `userId` válido (`userId = 3`), la aplicación obtiene y muestra la lista de tareas desde la API, permitiendo navegar al detalle correspondiente de cada tarea.
- **Estado de Carga:** Desde las herramientas de desarrollador de Chrome (*DevTools > Network*), se limitó la velocidad de red a **3G** y se pulsó el botón de recarga (`↻`) para visualizar el indicador circular de carga durante la petición.
- **Estado Vacío:** En `TaskApiService`, se cambió temporalmente la constante `userId` por `9999` y se reinició la aplicación (*Hot Restart*), comprobando el mensaje *"Todavía no hay tareas"* junto con el botón **Actualizar**. Posteriormente se restauró el `userId = 3`.
- **Estado de Error y Reintento:** Se desactivó la conexión a internet (modo *Offline*) y se recargó la lista para verificar el mensaje *"No se pudieron cargar las tareas."* y el botón **Reintentar**. Al reactivar la conexión y pulsar **Reintentar**, la lista se recuperó sin necesidad de reiniciar la aplicación.