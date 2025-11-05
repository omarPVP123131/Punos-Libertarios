// lib/screens/eventos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muaythai_app/widgets/image_preview.dart';
import '../models/models.dart';
import '../services/eventos_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import 'auth_screen.dart';
import 'evento_form_screen.dart';

class EventosScreen extends ConsumerWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      body: SafeArea(
        child: eventosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(eventosProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (eventos) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, ref, isAdmin),
              _buildEventosList(context, ref, eventos, isAdmin),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context, ref, isAdmin),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> isAdmin,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('🥊', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eventos',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Próximas peleas y torneos',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFE63946),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin.value == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventosList(
    BuildContext context,
    WidgetRef ref,
    List<Evento> eventos,
    AsyncValue<bool> isAdmin,
  ) {
    if (eventos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay eventos programados',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return EventoCard(
            evento: eventos[index],
            isAdmin: isAdmin.value == true,
            onEdit: () => _navigateToForm(context, ref, eventos[index]),
            onDelete: () => _confirmDelete(context, ref, eventos[index]),
          );
        }, childCount: eventos.length),
      ),
    );
  }

  Widget? _buildFAB(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> isAdmin,
  ) {
    final isAuth = ref.watch(isAuthenticatedProvider);

    return FloatingActionButton.extended(
      heroTag: null, // ✅ Desactiva hero animation
      onPressed: () =>
          _handleCreateEvento(context, ref, isAuth, isAdmin.value == true),
      icon: const Icon(Icons.add),
      label: const Text('Nuevo Evento'),
      backgroundColor: const Color(0xFFE63946),
    );
  }

  Future<void> _handleCreateEvento(
    BuildContext context,
    WidgetRef ref,
    bool isAuth,
    bool isAdmin,
  ) async {
    if (!isAuth) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(), // Sin redirectMessage
        ),
      );

      if (result != true) return;
    }

    if (context.mounted) {
      _navigateToForm(context, ref, null);
    }
  }

  Future<void> _navigateToForm(
    BuildContext context,
    WidgetRef ref,
    Evento? evento,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventoFormScreen(evento: evento)),
    );
    // ignore: unused_result
    ref.refresh(eventosProvider);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Evento evento,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar eliminación'),
        content: Text('¿Eliminar "${evento.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (evento.imagenUrl.isNotEmpty) {
          await StorageService.deleteEventoImage(evento.imagenUrl);
        }
        await EventosService.deleteEvento(evento.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('✅ Evento eliminado')));
        }
        // ignore: unused_result
        ref.refresh(eventosProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
        }
      }
    }
  }
}

// ============================================================================
// EVENTO CARD
// ============================================================================

class EventoCard extends StatefulWidget {
  final Evento evento;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventoCard({
    super.key,
    required this.evento,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EventoCard> createState() => _EventoCardState();
}

class _EventoCardState extends State<EventoCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getTypeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF2D2D2D) : Colors.white,
            isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative pattern
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.1), Colors.transparent],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                _buildEnhancedImage(color, isDark),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(color, isDark),
                      const SizedBox(height: 16),
                      _buildQuickInfo(isDark),

                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _toggleExpanded,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isExpanded
                                    ? 'Ver menos'
                                    : 'Ver detalles completos',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildExpandedInfo(color, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (widget.isAdmin) _buildModernAdminButtons(color),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedImage(Color color, bool isDark) {
    // baseTag seguro (usa id si lo tienes; sino sanitize el título)
    final baseTag = 'evento_${widget.evento.id}';
    final imageTag = '${baseTag}_0';

    // chequeo seguro: string no nulo y no vacío
    final imageUrl = widget.evento.imagenUrl;
    final hasImage = (imageUrl).isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () {
              // Verificamos si existe un Hero ancestro para evitar anidamiento

              // Llamamos al preview; pasamos baseTag (no-nulo). Si no hay hero en origen
              // la animación no provocará el error de Hero-anidado.
              ImagePreview.open(
                context,
                images: [imageUrl], // seguro no-nulo porque hasImage == true
                heroTag: baseTag,
              );
            }
          : null,
      child: Container(
        height: 220,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen o placeholder
            if (widget.evento.imagenUrl.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.evento.tipo.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              // Construimos la imagen; si NO hay un Hero ancestro, envolvemos con Hero.
              Builder(
                builder: (ctx) {
                  final image = Image.network(
                    widget.evento.imagenUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1)
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.evento.tipo.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );

                  final hasAncestorHero =
                      ctx.findAncestorWidgetOfExactType<Hero>() != null;

                  return hasAncestorHero
                      ? image
                      : Hero(tag: imageTag, child: image);
                },
              ),

            // Zoom indicator overlay
            if (widget.evento.imagenUrl.isNotEmpty)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Toca para ampliar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),

            // Type badge
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.evento.tipo.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.evento.tipo.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.evento.titulo,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.evento.participantes,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(bool isDark) {
    return Column(
      children: [
        _buildInfoChip(
          Icons.calendar_today,
          _formatDate(widget.evento.fecha),
          const Color(0xFF2196F3),
          isDark,
        ),
        const SizedBox(height: 8),
        _buildInfoChip(
          Icons.access_time,
          widget.evento.hora,
          const Color(0xFF4CAF50),
          isDark,
        ),
        const SizedBox(height: 8),
        _buildInfoChip(
          Icons.location_on,
          widget.evento.ubicacion,
          const Color(0xFFFF9800),
          isDark,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700).withOpacity(0.2),
                const Color(0xFFFFD700).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Text(
                '\$${widget.evento.precio.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedInfo(Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Información Adicional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.event,
            'Fecha completa',
            _formatDateLong(widget.evento.fecha),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.schedule,
            'Hora de inicio',
            widget.evento.hora,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.place,
            'Ubicación',
            widget.evento.ubicacion,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.people,
            'Participantes',
            widget.evento.participantes,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.category,
            'Tipo de evento',
            widget.evento.tipo.label,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernAdminButtons(Color color) {
    return Positioned(
      top: 16,
      right: 16,
      child: Row(
        children: [
          _buildAdminButton(
            Icons.edit_rounded,
            const Color(0xFF2196F3),
            widget.onEdit,
          ),
          const SizedBox(width: 8),
          _buildAdminButton(
            Icons.delete_rounded,
            const Color(0xFFFF5252),
            widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    return Color(int.parse(widget.evento.tipo.color.replaceFirst('#', '0xFF')));
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateLong(DateTime date) {
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
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
