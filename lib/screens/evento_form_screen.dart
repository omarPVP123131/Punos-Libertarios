// lib/screens/evento_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/eventos_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_providers.dart';
import '../widgets/ImagePickerWidget.dart';
import '../widgets/image_preview.dart';

class EventoFormScreen extends ConsumerStatefulWidget {
  final Evento? evento;

  const EventoFormScreen({super.key, this.evento});

  @override
  ConsumerState<EventoFormScreen> createState() => _EventoFormScreenState();
}

class _EventoFormScreenState extends ConsumerState<EventoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _participantesController;
  late TextEditingController _horaController;
  late TextEditingController _ubicacionController;
  late TextEditingController _precioController;
  late TextEditingController _asistentesController;
  late TextEditingController _descripcionController;

  late DateTime _selectedDate;
  late EventType _selectedType;
  late EventStatus _selectedStatus;
  String? _imageUrl;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final evento = widget.evento;

    _tituloController = TextEditingController(text: evento?.titulo ?? '');
    _participantesController = TextEditingController(
      text: evento?.participantes ?? '',
    );
    _horaController = TextEditingController(text: evento?.hora ?? '20:00');
    _ubicacionController = TextEditingController(text: evento?.ubicacion ?? '');
    _precioController = TextEditingController(
      text: evento?.precio.toString() ?? '0.0',
    );
    _asistentesController = TextEditingController(
      text: evento?.asistentes.toString() ?? '0',
    );
    _descripcionController = TextEditingController(
      text: evento?.descripcion ?? '',
    );

    _selectedDate = evento?.fecha ?? DateTime.now();
    _selectedType = evento?.tipo ?? EventType.profesional;
    _selectedStatus = evento?.estado ?? EventStatus.proximo;
    _imageUrl = evento?.imagenUrl;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _participantesController.dispose();
    _horaController.dispose();
    _ubicacionController.dispose();
    _precioController.dispose();
    _asistentesController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await StorageService.showImageSourceDialog(context);
    if (imageFile != null) {
      setState(() => _imageFile = imageFile);
    }
  }

  Future<void> _saveEvento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await StorageService.uploadEventoImage(_imageFile!);
      }

      final eventoData = {
        'titulo': _tituloController.text,
        'fecha': _selectedDate.toIso8601String(),
        'hora': _horaController.text,
        'ubicacion': _ubicacionController.text,
        'tipo': _selectedType.name,
        'participantes': _participantesController.text,
        'imagen_url': imageUrl ?? '',
        'precio': double.parse(_precioController.text),
        'estado': _selectedStatus.name,
        'asistentes': int.parse(_asistentesController.text),
        'descripcion': _descripcionController.text,
      };

      final isAdmin = await ref.read(isAdminProvider.future);

      if (isAdmin) {
        if (widget.evento == null) {
          await EventosService.createEvento(eventoData);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('✅ Evento creado')));
          }
        } else {
          await EventosService.updateEvento(widget.evento!.id, eventoData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Evento actualizado')),
            );
          }
        }
      } else {
        await EventosService.createSolicitud(eventoData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Solicitud enviada. Pendiente de aprobación.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1a1a1a)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.evento == null ? 'Nuevo Evento' : 'Editar Evento'),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Imagen
            _buildSection(
              'Imagen del Evento',
              Icons.image_rounded,
              ImagePickerWidget(
                imageUrl: _imageUrl,
                imageFile: _imageFile,
                onTap: _pickImage,
                height: 200,
              ),
            ),

            const SizedBox(height: 24),

            // Información Básica
            _buildSection(
              'Información Básica',
              Icons.info_outline_rounded,
              Column(
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título del Evento *',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _participantesController,
                    decoration: InputDecoration(
                      labelText: 'Participantes *',
                      hintText: 'Ej: Juan Pérez vs Pedro García',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Detalles adicionales del evento',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fecha y Hora
            _buildSection(
              'Fecha y Hora',
              Icons.schedule_rounded,
              Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFE63946),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha del Evento',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _horaController,
                    decoration: InputDecoration(
                      labelText: 'Hora *',
                      hintText: '20:00',
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ubicación
            _buildSection(
              'Ubicación',
              Icons.location_on_rounded,
              TextFormField(
                controller: _ubicacionController,
                decoration: InputDecoration(
                  labelText: 'Lugar del Evento *',
                  hintText: 'Arena Ciudad de México',
                  prefixIcon: const Icon(Icons.place),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),

            const SizedBox(height: 24),

            // Tipo y Estado
            _buildSection(
              'Categorización',
              Icons.category_rounded,
              Column(
                children: [
                  DropdownButtonFormField<EventType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Evento',
                      prefixIcon: const Icon(Icons.sports_mma),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                    items: EventType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(type.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EventStatus>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Estado del Evento',
                      prefixIcon: const Icon(Icons.flag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                    items: EventStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedStatus = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Precio y Asistentes
            _buildSection(
              'Detalles Adicionales',
              Icons.attach_money_rounded,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioController,
                      decoration: InputDecoration(
                        labelText: 'Precio (USD)',
                        prefixIcon: const Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _asistentesController,
                      decoration: InputDecoration(
                        labelText: 'Asistentes',
                        prefixIcon: const Icon(Icons.people_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63946),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isAdmin.value == true
                                ? (widget.evento == null
                                      ? 'Crear Evento'
                                      : 'Guardar Cambios')
                                : 'Enviar Solicitud',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFE63946), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}
