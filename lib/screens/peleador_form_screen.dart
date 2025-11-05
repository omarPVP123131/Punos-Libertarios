// lib/screens/peleador_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/peleadores_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_providers.dart';
import '../widgets/ImagePickerWidget.dart';

class PeleadorFormScreen extends ConsumerStatefulWidget {
  final Peleador? peleador;

  const PeleadorFormScreen({super.key, this.peleador});

  @override
  ConsumerState<PeleadorFormScreen> createState() => _PeleadorFormScreenState();
}

class _PeleadorFormScreenState extends ConsumerState<PeleadorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apodoController;
  late TextEditingController _rangoController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;
  late TextEditingController _alturaController;
  late TextEditingController _experienciaController;
  late TextEditingController _victoriasController;
  late TextEditingController _derrotasController;
  late TextEditingController _empatesController;
  late TextEditingController _kosController;
  late TextEditingController _descripcionController;
  late TextEditingController _estiloController;
  late TextEditingController _entrenadorController;
  late TextEditingController _nacionalidadController;
  late TextEditingController _gimnasioController;

  String? _imageUrl;
  File? _imageFile;
  String _selectedEmoji = '🥊';
  String _selectedColor = '#D32F2F';
  final List<String> _logros = [];
  bool _isLoading = false;

  final List<String> _emojis = ['🥊', '👊', '🔥', '💎', '⚡', '🐯', '🦅', '🐉'];
  final List<String> _colors = [
    '#D32F2F',
    '#1976D2',
    '#FF9800',
    '#7B1FA2',
    '#388E3C',
    '#F57C00',
  ];

  @override
  void initState() {
    super.initState();
    final peleador = widget.peleador;

    _nombreController = TextEditingController(text: peleador?.nombre ?? '');
    _apodoController = TextEditingController(text: peleador?.apodo ?? '');
    _rangoController = TextEditingController(text: peleador?.rango ?? '');
    _edadController = TextEditingController(
      text: peleador?.edad.toString() ?? '',
    );
    _pesoController = TextEditingController(
      text: peleador?.peso.toString() ?? '',
    );
    _alturaController = TextEditingController(
      text: peleador?.altura?.toString() ?? '',
    );
    _experienciaController = TextEditingController(
      text: peleador?.experienciaAnos.toString() ?? '',
    );
    _victoriasController = TextEditingController(
      text: peleador?.victorias.toString() ?? '0',
    );
    _derrotasController = TextEditingController(
      text: peleador?.derrotas.toString() ?? '0',
    );
    _empatesController = TextEditingController(
      text: peleador?.empates.toString() ?? '0',
    );
    _kosController = TextEditingController(
      text: peleador?.kos.toString() ?? '0',
    );
    _descripcionController = TextEditingController(
      text: peleador?.descripcion ?? '',
    );
    _estiloController = TextEditingController(text: peleador?.estilo ?? '');
    _entrenadorController = TextEditingController(
      text: peleador?.entrenador ?? '',
    );
    _nacionalidadController = TextEditingController(
      text: peleador?.nacionalidad ?? 'México',
    );
    _gimnasioController = TextEditingController(text: peleador?.gimnasio ?? '');

    _imageUrl = peleador?.imagenUrl;
    _selectedEmoji = peleador?.imagenEmoji ?? '🥊';
    _selectedColor = peleador?.colorHex ?? '#D32F2F';
    if (peleador?.logros != null) {
      _logros.addAll(peleador!.logros);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apodoController.dispose();
    _rangoController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _experienciaController.dispose();
    _victoriasController.dispose();
    _derrotasController.dispose();
    _empatesController.dispose();
    _kosController.dispose();
    _descripcionController.dispose();
    _estiloController.dispose();
    _entrenadorController.dispose();
    _nacionalidadController.dispose();
    _gimnasioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await StorageService.showImageSourceDialog(context);
    if (imageFile != null) {
      setState(() => _imageFile = imageFile);
    }
  }

  void _addLogro() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Agregar Logro'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Logro o Reconocimiento',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _logros.add(controller.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePeleador() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await StorageService.uploadPeleadorImage(_imageFile!);
      }

      final peleadorData = {
        'nombre': _nombreController.text,
        'apodo': _apodoController.text.isEmpty ? null : _apodoController.text,
        'rango': _rangoController.text,
        'edad': int.parse(_edadController.text),
        'peso': double.parse(_pesoController.text),
        'altura': _alturaController.text.isEmpty
            ? null
            : double.parse(_alturaController.text),
        'experiencia_anos': int.parse(_experienciaController.text),
        'victorias': int.parse(_victoriasController.text),
        'derrotas': int.parse(_derrotasController.text),
        'empates': int.parse(_empatesController.text),
        'kos': int.parse(_kosController.text),
        'imagen_url': imageUrl,
        'imagen_emoji': _selectedEmoji,
        'color_hex': _selectedColor,
        'descripcion': _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        'logros': _logros,
        'estilo': _estiloController.text.isEmpty
            ? null
            : _estiloController.text,
        'entrenador': _entrenadorController.text.isEmpty
            ? null
            : _entrenadorController.text,
        'nacionalidad': _nacionalidadController.text,
        'gimnasio': _gimnasioController.text.isEmpty
            ? null
            : _gimnasioController.text,
        'activo': true,
      };

      final isAdmin = await ref.read(isAdminProvider.future);

      if (isAdmin) {
        if (widget.peleador == null) {
          await PeleadoresService.createPeleador(peleadorData);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('✅ Peleador creado')));
          }
        } else {
          await PeleadoresService.updatePeleador(
            widget.peleador!.id,
            peleadorData,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Peleador actualizado')),
            );
          }
        }
      } else {
        await PeleadoresService.createSolicitud(peleadorData);
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
        title: Text(
          widget.peleador == null ? 'Nuevo Peleador' : 'Editar Peleador',
        ),
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
              'Foto del Peleador',
              Icons.person_rounded,
              ImagePickerWidget(
                imageUrl: _imageUrl,
                imageFile: _imageFile,
                onTap: _pickImage,
                height: 200,
              ),
            ),

            const SizedBox(height: 24),

            // Emoji y Color
            _buildSection(
              'Avatar y Color',
              Icons.palette_rounded,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona un emoji:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _emojis.map((emoji) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emoji),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _selectedEmoji == emoji
                                ? const Color(0xFFD32F2F).withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedEmoji == emoji
                                  ? const Color(0xFFD32F2F)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selecciona un color:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colors.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(color.replaceFirst('#', '0xFF')),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: _selectedColor == color
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información Personal
            _buildSection(
              'Información Personal',
              Icons.badge_rounded,
              Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: _inputDecoration(
                      'Nombre Completo *',
                      Icons.person,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apodoController,
                    decoration: _inputDecoration(
                      'Apodo',
                      Icons.star,
                      hint: 'Ej: El Tigre',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nacionalidadController,
                          decoration: _inputDecoration(
                            'Nacionalidad',
                            Icons.flag,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _edadController,
                          decoration: _inputDecoration('Edad *', Icons.cake),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Requerido';
                            final edad = int.tryParse(v!);
                            if (edad == null || edad < 15 || edad > 60)
                              return '15-60';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Físico
            _buildSection(
              'Características Físicas',
              Icons.fitness_center_rounded,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pesoController,
                      decoration: _inputDecoration(
                        'Peso (kg) *',
                        Icons.monitor_weight,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _alturaController,
                      decoration: _inputDecoration('Altura (m)', Icons.height),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Experiencia y Rango
            _buildSection(
              'Experiencia',
              Icons.emoji_events_rounded,
              Column(
                children: [
                  TextFormField(
                    controller: _rangoController,
                    decoration: _inputDecoration(
                      'Rango *',
                      Icons.military_tech,
                      hint: 'Ej: Cinturón Negro',
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _experienciaController,
                    decoration: _inputDecoration(
                      'Años de Experiencia *',
                      Icons.timer,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Record de Peleas
            _buildSection(
              'Record de Peleas',
              Icons.sports_mma_rounded,
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _victoriasController,
                          decoration: _inputDecoration(
                            'Victorias',
                            Icons.thumb_up,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _derrotasController,
                          decoration: _inputDecoration(
                            'Derrotas',
                            Icons.thumb_down,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _empatesController,
                          decoration: _inputDecoration(
                            'Empates',
                            Icons.horizontal_rule,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _kosController,
                          decoration: _inputDecoration('KOs', Icons.flash_on),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Entrenamiento
            _buildSection(
              'Entrenamiento',
              Icons.school_rounded,
              Column(
                children: [
                  TextFormField(
                    controller: _estiloController,
                    decoration: _inputDecoration(
                      'Estilo de Pelea',
                      Icons.style,
                      hint: 'Ej: Muay Mat',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _entrenadorController,
                    decoration: _inputDecoration(
                      'Entrenador',
                      Icons.person_pin,
                      hint: 'Ej: Kru Chai',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gimnasioController,
                    decoration: _inputDecoration('Gimnasio', Icons.home_work),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Descripción
            _buildSection(
              'Descripción',
              Icons.description_rounded,
              TextFormField(
                controller: _descripcionController,
                decoration: _inputDecoration('Sobre el peleador', Icons.edit),
                maxLines: 4,
              ),
            ),

            const SizedBox(height: 24),

            // Logros
            _buildSection(
              'Logros y Reconocimientos',
              Icons.workspace_premium_rounded,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addLogro,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Logro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                      foregroundColor: const Color(0xFFD32F2F),
                    ),
                  ),
                  if (_logros.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._logros.asMap().entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(entry.value)),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _logros.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'No hay logros agregados',
                        style: TextStyle(color: Colors.grey),
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
                    onPressed: _isLoading ? null : _savePeleador,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
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
                                ? (widget.peleador == null
                                      ? 'Crear Peleador'
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
                  color: const Color(0xFFD32F2F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFD32F2F), size: 20),
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

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
    );
  }
}
