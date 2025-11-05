// lib/screens/peleadores_screen.dart
// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muaythai_app/widgets/image_preview.dart';
import '../models/models.dart';
import '../services/peleadores_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import 'auth_screen.dart';
import 'peleador_form_screen.dart';

class PeleadoresScreen extends ConsumerStatefulWidget {
  const PeleadoresScreen({super.key});

  @override
  ConsumerState<PeleadoresScreen> createState() => _PeleadoresScreenState();
}

class _PeleadoresScreenState extends ConsumerState<PeleadoresScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peleadoresAsync = ref.watch(peleadoresProvider);
    final estadisticasAsync = ref.watch(estadisticasPeleadoresProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: peleadoresAsync.when(
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
                    onPressed: () => ref.refresh(peleadoresProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            data: (peleadores) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(context, ref, isAdmin),
                _buildStats(context, estadisticasAsync),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                _buildPeleadoresList(context, ref, peleadores, isAdmin),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFD32F2F).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text('🥋', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peleadores del Dojo',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nuestros guerreros del ring',
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin.value == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    AsyncValue<Map<String, int>> estadisticasAsync,
  ) {
    return estadisticasAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
      data: (stats) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    stats['total_peleadores'].toString(),
                    'Peleadores',
                    Icons.people_alt_rounded,
                    const Color(0xFFD32F2F),
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    stats['total_victorias'].toString(),
                    'Victorias',
                    Icons.emoji_events_rounded,
                    const Color(0xFFFFD700),
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    stats['total_kos'].toString(),
                    'KOs',
                    Icons.sports_mma_rounded,
                    const Color(0xFFFF5722),
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF2D2D2D) : Colors.white,
            isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeleadoresList(
    BuildContext context,
    WidgetRef ref,
    List<Peleador> peleadores,
    AsyncValue<bool> isAdmin,
  ) {
    if (peleadores.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'No hay peleadores registrados',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega el primer guerrero del dojo',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
          return PeleadorCard(
            peleador: peleadores[index],
            isAdmin: isAdmin.value == true,
            onEdit: () => _navigateToForm(context, ref, peleadores[index]),
            onDelete: () => _confirmDelete(context, ref, peleadores[index]),
          );
        }, childCount: peleadores.length),
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
      heroTag: null,
      onPressed: () =>
          _handleCreatePeleador(context, ref, isAuth, isAdmin.value == true),
      icon: const Icon(Icons.add_rounded, size: 24),
      label: const Text(
        'Nuevo Peleador',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      backgroundColor: const Color(0xFFD32F2F),
      elevation: 8,
    );
  }

  Future<void> _handleCreatePeleador(
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
    Peleador? peleador,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeleadorFormScreen(peleador: peleador),
      ),
    );
    ref.refresh(peleadoresProvider);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Peleador peleador,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Confirmar eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar a "${peleador.nombre}"? Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(fontSize: 15)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (peleador.imagenUrl != null && peleador.imagenUrl!.isNotEmpty) {
          await StorageService.deletePeleadorImage(peleador.imagenUrl!);
        }
        await PeleadoresService.deletePeleador(peleador.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Peleador eliminado exitosamente'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        ref.refresh(peleadoresProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}

// ============================================================================
// ============================================================================

class PeleadorCard extends StatefulWidget {
  final Peleador peleador;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PeleadorCard({
    super.key,
    required this.peleador,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PeleadorCard> createState() => _PeleadorCardState();
}

class _PeleadorCardState extends State<PeleadorCard>
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
    final color = Color(
      int.parse(widget.peleador.colorHex.replaceFirst('#', '0xFF')),
    );

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
                _buildEnhancedHeader(color, isDark),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(color, isDark),
                      const SizedBox(height: 16),
                      _buildQuickStats(isDark),

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
                                    : 'Ver información completa',
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
                            _buildExpandedInfo(isDark),
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

  Widget _buildEnhancedHeader(Color color, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detectar tamaño de pantalla
        final bool isSmallScreen = constraints.maxWidth < 360;
        final bool isVerySmallScreen = constraints.maxWidth < 320;

        return Container(
          height: isVerySmallScreen ? 150 : (isSmallScreen ? 160 : 180),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
          ),
          child: Stack(
            children: [
              // Patrón decorativo
              Positioned.fill(
                child: CustomPaint(
                  painter: _PatternPainter(color: color.withOpacity(0.1)),
                ),
              ),

              // Contenido del header
              Padding(
                padding: EdgeInsets.all(
                  isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildEnhancedAvatar(
                      color,
                      isSmallScreen: isSmallScreen,
                      isVerySmallScreen: isVerySmallScreen,
                    ),
                    SizedBox(
                      width: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
                    ),

                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Nombre - Tamaño responsive
                          Text(
                            widget.peleador.nombreCompleto,
                            style: TextStyle(
                              fontSize: isVerySmallScreen
                                  ? 18
                                  : (isSmallScreen ? 18 : 22),
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: -0.5,
                              height: 1.1, // Reducir altura de línea
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: isVerySmallScreen
                                ? 4
                                : (isSmallScreen ? 4 : 6),
                          ),

                          // Rango con badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isVerySmallScreen
                                  ? 8
                                  : (isSmallScreen ? 10 : 12),
                              vertical: isVerySmallScreen
                                  ? 4
                                  : (isSmallScreen ? 4 : 6),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.peleador.rango,
                              style: TextStyle(
                                fontSize: isVerySmallScreen
                                    ? 11
                                    : (isSmallScreen ? 12 : 13),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: isVerySmallScreen
                                ? 6
                                : (isSmallScreen ? 6 : 8),
                          ),

                          // Record destacado
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isVerySmallScreen
                                  ? 10
                                  : (isSmallScreen ? 10 : 12),
                              vertical: isVerySmallScreen
                                  ? 6
                                  : (isSmallScreen ? 4 : 6),
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sports_mma,
                                  size: isVerySmallScreen
                                      ? 11
                                      : (isSmallScreen ? 12 : 14),
                                  color: color,
                                ),
                                SizedBox(
                                  width: isVerySmallScreen
                                      ? 4
                                      : (isSmallScreen ? 4 : 6),
                                ),
                                Flexible(
                                  child: Text(
                                    widget.peleador.record,
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen
                                          ? 11
                                          : (isSmallScreen ? 12 : 14),
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedAvatar(
    Color color, {
    bool isSmallScreen = false,
    bool isVerySmallScreen = false,
  }) {
    final double avatarSize = isVerySmallScreen
        ? 100
        : (isSmallScreen ? 90 : 110);

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.transparent, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child:
            widget.peleador.imagenUrl != null &&
                widget.peleador.imagenUrl!.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  // IMPORTANTE: No usar Hero aquí si ya se usa en image_preview
                  _openImagePreview(context, widget.peleador.imagenUrl!);
                },
                child: Image.network(
                  widget.peleador.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildEmojiAvatar(color, avatarSize),
                ),
              )
            : _buildEmojiAvatar(color, avatarSize),
      ),
    );
  }

  Widget _buildEmojiAvatar(Color color, double size) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.person,
          color: color.withOpacity(0.5),
          size: size * 0.4,
        ),
      ),
    );
  }

  void _openImagePreview(BuildContext context, String imageUrl) {
    ImagePreview.open(
      context,
      images: [imageUrl],
      initialIndex: 0,
      heroTag: 'peleador_${widget.peleador.id}_avatar', // Tag único
      showCloseButton: true,
    );
  }

  Widget _buildMainInfo(Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.peleador.descripcion != null &&
            widget.peleador.descripcion!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.peleador.descripcion!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            Icons.cake_rounded,
            '${widget.peleador.edad} años',
            const Color(0xFF2196F3),
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            Icons.monitor_weight_rounded,
            '${widget.peleador.peso} kg',
            const Color(0xFF4CAF50),
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            Icons.flash_on_rounded,
            '${widget.peleador.kos} KOs',
            const Color(0xFFFF9800),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección: Datos Personales
        _buildInfoSection(
          'Datos Personales',
          Icons.person_rounded,
          const Color(0xFF2196F3),
          isDark,
          [
            _buildInfoRow(
              Icons.flag,
              'Nacionalidad',
              widget.peleador.nacionalidad,
              isDark,
            ),
            if (widget.peleador.altura != null)
              _buildInfoRow(
                Icons.height,
                'Altura',
                '${widget.peleador.altura} m',
                isDark,
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Sección: Experiencia y Record
        _buildInfoSection(
          'Experiencia y Record',
          Icons.emoji_events_rounded,
          const Color(0xFFFFD700),
          isDark,
          [
            _buildInfoRow(
              Icons.timer,
              'Experiencia',
              '${widget.peleador.experienciaAnos} años',
              isDark,
            ),
            _buildInfoRow(
              Icons.thumb_up,
              'Victorias',
              widget.peleador.victorias.toString(),
              isDark,
            ),
            _buildInfoRow(
              Icons.thumb_down,
              'Derrotas',
              widget.peleador.derrotas.toString(),
              isDark,
            ),
            _buildInfoRow(
              Icons.horizontal_rule,
              'Empates',
              widget.peleador.empates.toString(),
              isDark,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sección: Entrenamiento
        if (widget.peleador.estilo != null ||
            widget.peleador.entrenador != null ||
            widget.peleador.gimnasio != null)
          _buildInfoSection(
            'Entrenamiento',
            Icons.school_rounded,
            const Color(0xFF9C27B0),
            isDark,
            [
              if (widget.peleador.estilo != null)
                _buildInfoRow(
                  Icons.style,
                  'Estilo',
                  widget.peleador.estilo!,
                  isDark,
                ),
              if (widget.peleador.entrenador != null)
                _buildInfoRow(
                  Icons.person_pin,
                  'Entrenador',
                  widget.peleador.entrenador!,
                  isDark,
                ),
              if (widget.peleador.gimnasio != null)
                _buildInfoRow(
                  Icons.home_work,
                  'Gimnasio',
                  widget.peleador.gimnasio!,
                  isDark,
                ),
            ],
          ),

        // Sección: Logros
        if (widget.peleador.logros.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildLogrosSection(isDark),
        ],
      ],
    );
  }

  Widget _buildInfoSection(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    List<Widget> children,
  ) {
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
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogrosSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.1),
            const Color(0xFFFFD700).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logros Destacados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.peleador.logros.map(
            (logro) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      logro,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8 + i * 20, size.height * 0.3 + i * 15),
        10 + i * 5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
