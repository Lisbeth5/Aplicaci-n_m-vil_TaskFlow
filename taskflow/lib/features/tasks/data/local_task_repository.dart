import '../domain/task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [
    const Task(
      id: 1,
      title: 'Estudiar programación móvil',
      description:
          'Repasar manejo de estados y rutas en Flutter para el examen parcial',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 2,
      title: 'Completar informe de base de datos',
      description: 'Redactar el diagrama entidad-relación y normalizar las tablas del proyecto',
      priority: 'Alta',
      isCompleted: true,
      userId: 1,
    ),
    const Task(
      id: 3,
      title: 'Configurar entorno en GitHub',
      description: 'Crear ramas de desarrollo y documentar el archivo README del repositorio',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 4,
      title: 'Preparar exposición grupal',
      description: 'Diseñar las diapositivas sobre arquitectura de software y repartir los temas',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 5,
      title: 'Organizar horario semanal',
      description: 'Planificar bloques de estudio, gimnasio y descanso para la próxima semana',
      priority: 'Baja',
      isCompleted: false,
      userId: 1,
    ),
  ];

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

  @override
  void save(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
  }
}
