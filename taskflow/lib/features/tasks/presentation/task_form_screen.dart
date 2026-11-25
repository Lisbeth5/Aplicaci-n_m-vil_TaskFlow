import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
  });

  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
}

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _priority;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(FormFieldState<DateTime> fieldState) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      fieldState.didChange(picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = TaskDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority!,
      dueDate: _dueDate,
    );
    context.pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _dueDate == null
        ? 'Seleccionar fecha límite'
        : '${_dueDate!.day.toString().padLeft(2, '0')}/'
              '${_dueDate!.month.toString().padLeft(2, '0')}/'
              '${_dueDate!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Crear nueva tarea')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la tarea',
                      hintText: 'Ej. Preparar presentación de Flutter',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'El título es obligatorio.';
                      }
                      if (text.length < 3) {
                        return 'El título debe tener al menos 3 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Agrega los detalles de la tarea',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'La descripción es obligatoria.';
                      }
                      if (text.length < 5) {
                        return 'La descripción debe tener al menos 5 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de prioridad',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Selecciona una prioridad'),
                    items: const [
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                    ],
                    onChanged: (value) {
                      setState(() => _priority = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes seleccionar una prioridad.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FormField<DateTime>(
                    initialValue: _dueDate,
                    validator: (value) {
                      if (value == null) {
                        return 'Debes elegir una fecha límite.';
                      }
                      return null;
                    },
                    builder: (fieldState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: fieldState.hasError
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            onPressed: () => _pickDueDate(fieldState),
                            icon: const Icon(Icons.calendar_today),
                            label: Text('Fecha límite: $dateText'),
                          ),
                          if (fieldState.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 6),
                              child: Text(
                                fieldState.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _submit,
                        child: const Text('Guardar tarea'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
