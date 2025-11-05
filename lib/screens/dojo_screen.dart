import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muaythai_app/widgets/image_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:muaythai_app/widgets/app_header.dart';
import 'package:muaythai_app/core/theme.dart';

// ============================================================================
// CONFIGURACIÓN FÁCIL DE MODIFICAR
// ============================================================================

class DojoConfig {
  // Información básica del dojo
  static const String dojoName = 'PUÑOS LIBERTARIOS';
  static const String dojoSubtitle = 'TEAM 16-12';
  static const String dojoSlogan = 'FIGHT FOR GLORY';

  // Contacto y ubicación
  static const String dojoAddress =
      'Av. López Mateos lote 3-mza 1170, San Isidro, 56617 Valle de Chalco Solidaridad, Méx.';
  static const String googleMapsUrl =
      'https://maps.app.goo.gl/oaHRS6Yp2jAcSp9m8';
  static const String whatsappPhone = '5215538668409';
  static const String whatsappMessage =
      'Hola profesor, estoy interesado en aprender a pelear siempre con respeto y cordialidad hacia usted y el arte marcial.';
  // Helper para obtener la imagen principal
  static String getMainImage(String instructorId) {
    final gallery = instructorGalleries[instructorId];
    return gallery?.isNotEmpty == true ? gallery!.first : '';
  }

  // Helper para obtener todas las imágenes
  static List<String> getGallery(String instructorId) {
    return instructorGalleries[instructorId] ?? [];
  }

  // Historia del dojo
  static const String dojoHistory =
      'Puños Libertarios nació con la misión de transmitir la esencia del Muay Thai: disciplina, respeto y superación personal.\n\n'
      'Fundado por el Profesor Israel Gómez, nuestro dojo se ha convertido en un hogar para guerreros de todas las edades y niveles.\n\n'
      'Hoy seguimos entrenando con la misma pasión, formando peleadores y personas más fuertes en cuerpo y espíritu.';

  static const Map<String, List<String>> instructorGalleries = {
    'israel': ['assets/images/israel.jpg'],
    'profesor2': [
      'https://via.placeholder.com/300/4A90E2/fff?text=Instructor+2',
      'https://via.placeholder.com/300/4A90E2/fff?text=Foto+2',
    ],
    'profesor3': [
      'https://via.placeholder.com/300/50C878/fff?text=Instructor+3',
    ],
  };
}

// ============================================================================
// MODELOS DE DATOS
// ============================================================================

class Instructor {
  final String id;
  final String name;
  final String specialty;
  final String description;
  final String trajectory;
  final Color color;
  final List<String> images;

  const Instructor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.description,
    required this.trajectory,
    required this.color,
    this.images = const [],
  });
}

class Discipline {
  final String name;
  final IconData icon;
  final Color color;

  const Discipline({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Session {
  final String time;
  final String className;
  final String type;

  const Session({
    required this.time,
    required this.className,
    required this.type,
  });
}

class DaySchedule {
  final String day;
  final List<Session> sessions;

  const DaySchedule({required this.day, required this.sessions});
}

// ============================================================================
// DATOS ESTÁTICOS
// ============================================================================

class DojoData {
  static const List<Instructor> instructors = [
    Instructor(
      id: 'israel',
      name: 'Israel Gómez Barragan',
      specialty: 'Muay Thai',
      description: 'Instructor principal del dojo.',
      trajectory: '',
      color: Color(0xFFFF4444),
    ),
    Instructor(
      id: '2',
      name: '',
      specialty: 'Jiu Jitsu Brasileño',
      description: '',
      trajectory: '',
      color: Color(0xFF4A90E2),
    ),
    Instructor(
      id: '3',
      name: '',
      specialty: 'MMA',
      description: '',
      trajectory: '',
      color: Color(0xFF50C878),
    ),
  ];

  static const List<Discipline> disciplines = [
    Discipline(
      name: 'Muay Thai',
      icon: Icons.sports_martial_arts,
      color: Color(0xFFFF4444),
    ),
    Discipline(
      name: 'Jiu Jitsu',
      icon: Icons.self_improvement,
      color: Color(0xFF4A90E2),
    ),
    Discipline(name: 'MMA', icon: Icons.sports_mma, color: Color(0xFF50C878)),
    Discipline(name: 'Boxeo', icon: Icons.sports, color: Color(0xFFFFD700)),
  ];

  static const List<DaySchedule> schedule = [
    DaySchedule(
      day: 'Lunes',
      sessions: [
        Session(time: '9:00-11:00', className: 'Muay Thai', type: 'general'),
        Session(time: '6:00-7:00', className: 'Muay Thai Kids', type: 'kids'),
        Session(time: '7:00-9:00', className: 'Muay Thai', type: 'muaythai'),
        Session(time: '9:00-10:00', className: 'MMA', type: 'mma'),
      ],
    ),
    DaySchedule(
      day: 'Martes',
      sessions: [
        Session(time: '9:00-11:00', className: 'Muay Thai', type: 'general'),
        Session(time: '6:00-7:00', className: 'Muay Thai Kids', type: 'kids'),
        Session(
          time: '7:00-9:00',
          className: 'Jiu Jitsu Brasileño',
          type: 'jiujitsu',
        ),
      ],
    ),
    DaySchedule(
      day: 'Miércoles',
      sessions: [
        Session(time: '9:00-11:00', className: 'Muay Thai', type: 'general'),
        Session(time: '6:00-7:00', className: 'Muay Thai Kids', type: 'kids'),
        Session(time: '7:00-9:00', className: 'Muay Thai', type: 'muaythai'),
      ],
    ),
    DaySchedule(
      day: 'Jueves',
      sessions: [
        Session(time: '9:00-11:00', className: 'Muay Thai', type: 'general'),
        Session(time: '6:00-7:00', className: 'Muay Thai Kids', type: 'kids'),
        Session(
          time: '7:00-9:00',
          className: 'Jiu Jitsu Brasileño',
          type: 'jiujitsu',
        ),
      ],
    ),
    DaySchedule(
      day: 'Viernes',
      sessions: [
        Session(time: '9:00-11:00', className: 'Muay Thai', type: 'general'),
        Session(time: '6:00-7:00', className: 'Muay Thai Kids', type: 'kids'),
        Session(time: '7:00-9:00', className: 'Muay Thai', type: 'muaythai'),
      ],
    ),
    DaySchedule(
      day: 'Sábado',
      sessions: [
        Session(
          time: 'Variable',
          className: 'Seminarios ocasionales',
          type: 'special',
        ),
      ],
    ),
    DaySchedule(
      day: 'Domingo',
      sessions: [
        Session(
          time: 'Cerrado',
          className: 'Eventos especiales',
          type: 'closed',
        ),
      ],
    ),
  ];
}

// ============================================================================
// UTILIDADES
// ============================================================================

class SessionTypeHelper {
  static Color getColor(String type) {
    switch (type) {
      case 'kids':
        return const Color(0xFF4CAF50);
      case 'muaythai':
        return const Color(0xFFFF5722);
      case 'jiujitsu':
        return const Color(0xFF2196F3);
      case 'mma':
        return const Color(0xFF9C27B0);
      case 'special':
        return const Color(0xFFFF9800);
      case 'closed':
        return const Color(0xFF757575);
      default:
        return const Color(0xFFE91E63);
    }
  }

  static IconData getIcon(String type) {
    switch (type) {
      case 'kids':
        return Icons.child_friendly;
      case 'muaythai':
        return Icons.sports_kabaddi;
      case 'jiujitsu':
        return Icons.sports_martial_arts;
      case 'mma':
        return Icons.sports_mma;
      case 'special':
        return Icons.event;
      case 'closed':
        return Icons.event_busy;
      default:
        return Icons.fitness_center;
    }
  }
}

class WhatsAppLauncher {
  static Future<void> launch(BuildContext context) async {
    final Uri whatsappUri = Uri.parse(
      'https://api.whatsapp.com/send?phone=${DojoConfig.whatsappPhone}&text=${Uri.encodeComponent(DojoConfig.whatsappMessage)}',
    );

    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }
}

// ============================================================================
// WIDGET ANIMADO
// ============================================================================

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedCard({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 40)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

// ============================================================================
// PANTALLA PRINCIPAL
// ============================================================================

class DojoScreen extends ConsumerWidget {
  const DojoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark =
        ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8F9FA),
      appBar: AppHeader(
        title: DojoConfig.dojoName,
        subtitle: DojoConfig.dojoSubtitle,
        showBackButton: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(isDark),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                AnimatedCard(
                  index: 0,
                  child: _SectionTitle(
                    'HISTORIA DEL DOJO',
                    Icons.history,
                    isDark,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedCard(index: 1, child: _HistoryCard(isDark)),
                const SizedBox(height: 32),
                AnimatedCard(
                  index: 2,
                  child: _SectionTitle('PROFESORES', Icons.people, isDark),
                ),
                const SizedBox(height: 16),
                ...DojoData.instructors.asMap().entries.map((entry) {
                  return AnimatedCard(
                    index: 3 + entry.key,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _InstructorCard(entry.value, isDark),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                AnimatedCard(
                  index: 7,
                  child: _SectionTitle(
                    'DISCIPLINAS',
                    Icons.sports_martial_arts,
                    isDark,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedCard(index: 8, child: _DisciplinesGrid(isDark)),
                const SizedBox(height: 32),
                AnimatedCard(
                  index: 9,
                  child: _SectionTitle('HORARIOS', Icons.schedule, isDark),
                ),
                const SizedBox(height: 16),
                AnimatedCard(index: 10, child: _ScheduleCard(isDark)),
                const SizedBox(height: 16),
                AnimatedCard(index: 11, child: _LocationCard(context, isDark)),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A0000),
                    const Color(0xFF330000),
                    const Color(0xFF0A0A0A),
                  ]
                : [
                    const Color(0xFFFFEBEE),
                    const Color(0xFFFFCDD2),
                    const Color(0xFFF8F9FA),
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_martial_arts,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                DojoConfig.dojoName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  shadows: [Shadow(color: Colors.red, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  DojoConfig.dojoSlogan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS DE SECCIÓN
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionTitle(this.title, this.icon, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF330000), const Color(0xFF1A0000)]
              : [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.red.withOpacity(0.3)
              : Colors.red.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final bool isDark;

  const _HistoryCard(this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.red.withOpacity(0.2)
              : Colors.red.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nuestra Historia',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            DojoConfig.dojoHistory,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  final Instructor instructor;
  final bool isDark;

  const _InstructorCard(this.instructor, this.isDark);

  @override
  Widget build(BuildContext context) {
    final gallery = DojoConfig.getGallery(instructor.id);
    final hasMultipleImages = gallery.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _buildCardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            _buildBackgroundGradient(),
            _buildMainContent(gallery, hasMultipleImages),
          ],
        ),
      ),
    );
  }

  // ============ DECORACIONES ============

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: instructor.color.withOpacity(0.15), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: instructor.color.withOpacity(isDark ? 0.15 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              instructor.color.withOpacity(0.08),
              instructor.color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  // ============ CONTENIDO PRINCIPAL ============

  Widget _buildMainContent(List<String> gallery, bool hasMultipleImages) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnailSection(gallery, hasMultipleImages),
          const SizedBox(width: 18),
          Expanded(child: _buildInfoSection(gallery, hasMultipleImages)),
        ],
      ),
    );
  }

  // ============ SECCIÓN DE IMAGEN PRINCIPAL ============

  Widget _buildThumbnailSection(List<String> gallery, bool hasMultipleImages) {
    return Stack(
      children: [
        _buildMainThumbnail(gallery),
        if (hasMultipleImages) _buildImageCountBadge(gallery.length),
      ],
    );
  }

  Widget _buildMainThumbnail(List<String> gallery) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: instructor.color.withOpacity(0.9), width: 3),
        boxShadow: [
          BoxShadow(
            color: instructor.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: PreviewThumbnail(
          src: gallery.isNotEmpty ? gallery[0] : '',
          heroTag: 'instructor_${instructor.id}_hero',
          index: 0,
          gallery: gallery,
          size: 95,
          borderColor:
              Colors.transparent, // El borde ya está en el Container padre
        ),
      ),
    );
  }

  Widget _buildImageCountBadge(int imageCount) {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: instructor.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library, color: Colors.white, size: 12),
            const SizedBox(width: 3),
            Text(
              '$imageCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ SECCIÓN DE INFORMACIÓN ============

  Widget _buildInfoSection(List<String> gallery, bool hasMultipleImages) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameHeader(),
        const SizedBox(height: 10),
        _buildSpecialtyBadge(),
        if (instructor.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDescription(),
        ],
        if (instructor.trajectory.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildTrajectory(),
        ],
        if (hasMultipleImages) ...[
          const SizedBox(height: 12),
          _buildGalleryThumbnails(gallery),
        ],
      ],
    );
  }

  Widget _buildNameHeader() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: instructor.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            instructor.name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            instructor.color.withOpacity(0.15),
            instructor.color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: instructor.color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: instructor.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              instructor.specialty,
              style: TextStyle(
                color: instructor.color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      instructor.description,
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 13,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTrajectory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.stars_rounded,
          size: 14,
          color: instructor.color.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            instructor.trajectory,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============ GALERÍA DE MINIATURAS ============

  Widget _buildGalleryThumbnails(List<String> gallery) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildGalleryThumbnail(gallery, index),
          );
        },
      ),
    );
  }

  Widget _buildGalleryThumbnail(List<String> gallery, int index) {
    final isFirst = index == 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: instructor.color.withOpacity(isFirst ? 0.9 : 0.5),
          width: 2.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.5),
        child: PreviewThumbnail(
          src: gallery[index],
          heroTag: 'instructor_${instructor.id}_gallery',
          index: index,
          gallery: gallery,
          size: 50,
          borderColor:
              Colors.transparent, // El borde ya está en el Container padre
        ),
      ),
    );
  }
}

class _DisciplinesGrid extends StatelessWidget {
  final bool isDark;

  const _DisciplinesGrid(this.isDark);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: DojoData.disciplines.length,
      itemBuilder: (context, index) {
        final discipline = DojoData.disciplines[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 80)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        discipline.color.withOpacity(0.15),
                        discipline.color.withOpacity(0.05),
                      ]
                    : [
                        discipline.color.withOpacity(0.1),
                        discipline.color.withOpacity(0.02),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: discipline.color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(discipline.icon, color: discipline.color, size: 32),
                const SizedBox(height: 8),
                Text(
                  discipline.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final bool isDark;

  const _ScheduleCard(this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horarios de Entrenamiento',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Encuentra tu horario perfecto',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...DojoData.schedule.map((day) => _DayCard(day, isDark)),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DaySchedule day;
  final bool isDark;

  const _DayCard(this.day, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  day.day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${day.sessions.length} clases',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black45,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...day.sessions.map((session) => _SessionCard(session, isDark)),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final bool isDark;

  const _SessionCard(this.session, this.isDark);

  @override
  Widget build(BuildContext context) {
    final color = SessionTypeHelper.getColor(session.type);
    final icon = SessionTypeHelper.getIcon(session.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.className,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.time,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final BuildContext context;
  final bool isDark;

  const _LocationCard(this.context, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ubicación del Dojo',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Imagen del dojo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                'assets/images/dojo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFE8F5E9),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dirección
          Text(
            DojoConfig.dojoAddress,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openMaps(),
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('Ver en Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => WhatsAppLauncher.launch(context),
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('Contactar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse(DojoConfig.googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
