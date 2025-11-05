import 'package:flutter/material.dart';

class GlosarioScreen extends StatefulWidget {
  const GlosarioScreen({super.key});

  @override
  State<GlosarioScreen> createState() => _GlosarioScreenState();
}

class _GlosarioScreenState extends State<GlosarioScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  final Map<int, bool> _expandedItems = {};

  final List<String> _categories = [
    'Todos',
    'BJJ',
    'MMA',
    'Muay Thai',
    'Básico',
    'Intermedio',
    'Avanzado',
  ];

  final List<Map<String, dynamic>> _glosario = [
    // BJJ Terms
    {
      'termino': 'Armbar',
      'definicion':
          'Técnica de sumisión que presiona el brazo contra el cuerpo.',
      'detalles':
          'El armbar es una de las sumisiones más efectivas del BJJ. Se puede ejecutar desde múltiples posiciones: mount, side control, guardia. La presión se aplica en la articulación del codo contra la cadera o el pecho.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '💪',
      'dificultad': 'Intermedio',
      'color': Color(0xFF4CAF50),
    },
    {
      'termino': 'Guard (Guardia)',
      'definicion':
          'Posición fundamental en BJJ donde el luchador está boca arriba con las piernas controlando al oponente.',
      'detalles':
          'La guardia es la posición defensiva más importante en BJJ. Existen múltiples variaciones: guardia cerrada, guardia abierta, guardia de media, guardia de mariposa, etc. Cada una ofrece diferentes oportunidades de barrido y sumisión.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '🛡️',
      'dificultad': 'Básico',
      'color': Color(0xFF4CAF50),
    },
    {
      'termino': 'Mount Position',
      'definicion':
          'Posición controlada donde el luchador está sobre el pecho del oponente con ambas rodillas en el colchón.',
      'detalles':
          'El mount es la posición más dominante en BJJ después del back control. Permite aplicar golpes fuertes, presión y múltiples opciones de sumisión como armbar, triangulo y estrangulaciones.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '🏔️',
      'dificultad': 'Básico',
      'color': Color(0xFF4CAF50),
    },
    {
      'termino': 'Triangle Choke',
      'definicion':
          'Sumisión donde las piernas forman un triángulo estrangulando el cuello.',
      'detalles':
          'Técnica clásica ejecutada con las piernas. Se puede aplicar desde la guardia, mount, o posiciones de transición. Requiere precisión y control para evitar que el oponente escape.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '🔺',
      'dificultad': 'Intermedio',
      'color': Color(0xFF4CAF50),
    },
    {
      'termino': 'Back Control',
      'definicion':
          'Posición donde el luchador controla la espalda del oponente con ambas piernas enganches.',
      'detalles':
          'El back control es la posición más dominante en BJJ. Permite aplicar el rear naked choke, golpes y control total. El objetivo defensivo es evitar perder los enganches y escapar al lado.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '🔐',
      'dificultad': 'Intermedio',
      'color': Color(0xFF4CAF50),
    },
    {
      'termino': 'Sweep (Barrido)',
      'definicion':
          'Técnica defensiva que invierte la posición pasando de estar debajo a estar arriba.',
      'detalles':
          'Los barridos son cruciales en BJJ para recuperar posición. Existen numerosas variaciones según la posición inicial. Los barridos bien ejecutados pueden llevar directamente a posiciones dominantes.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '🌪️',
      'dificultad': 'Intermedio',
      'color': Color(0xFF4CAF50),
    },
    {
      'termino': 'Rear Naked Choke',
      'definicion':
          'Estrangulación ejecutada desde el back control sin usar las piernas.',
      'detalles':
          'El RNC es la sumisión más letal desde el back control. Se ejecuta abrazando el cuello con los brazos. Una vez bien posicionada, es muy difícil escapar. Muy común en competencia.',
      'categoria': 'BJJ',
      'disciplina': 'BJJ',
      'emoji': '🫁',
      'dificultad': 'Intermedio',
      'color': Color(0xFF4CAF50),
    },

    // MMA Terms
    {
      'termino': 'Takedown',
      'definicion': 'Técnica de llevar al oponente al suelo desde pie.',
      'detalles':
          'Los takedowns son fundamentales en MMA. Incluyen técnicas de lucha libre como doble pierna, simple pierna, y técnicas de judo como harai goshi. Un buen takedown defense es crítico en MMA moderno.',
      'categoria': 'MMA',
      'disciplina': 'MMA',
      'emoji': '⬇️',
      'dificultad': 'Intermedio',
      'color': Color(0xFF2196F3),
    },
    {
      'termino': 'Striking',
      'definicion': 'Golpeo combinado: puños, patadas, rodillas y codos.',
      'detalles':
          'El striking es el arte de golpear de pie. En MMA combina técnicas de boxeo, muay thai, karate y otros estilos. Una buena técnica de striking previene takedowns y puede ganar rondas.',
      'categoria': 'MMA',
      'disciplina': 'MMA',
      'emoji': '👊',
      'dificultad': 'Intermedio',
      'color': Color(0xFF2196F3),
    },
    {
      'termino': 'Clinch Control',
      'definicion': 'Posición de agarre cercano controlando al oponente.',
      'detalles':
          'El clinch en MMA es el puente entre pie y suelo. Permite ejecutar rodillazos, elbows, barridos y takedowns. Es crucial para fighters con buena lucha greco-romana.',
      'categoria': 'MMA',
      'disciplina': 'MMA',
      'emoji': '🤐',
      'dificultad': 'Intermedio',
      'color': Color(0xFF2196F3),
    },
    {
      'termino': 'Ground and Pound',
      'definicion': 'Golpear al oponente mientras está en el suelo.',
      'detalles':
          'Es la técnica de mantener posición dominante y golpear repetidamente. Muy efectiva desde mount, side control o back control. El árbitro puede detener la pelea si el oponente no puede defenderse.',
      'categoria': 'MMA',
      'disciplina': 'MMA',
      'emoji': '💣',
      'dificultad': 'Avanzado',
      'color': Color(0xFF2196F3),
    },
    {
      'termino': 'Submission Defense',
      'definicion': 'Técnicas para escapar o prevenir sumisiones.',
      'detalles':
          'La defensa de sumisión es crítica en MMA. Incluye técnicas de escape, posicionamiento y flexibilidad. Los mejores MMAistas pueden escapar de posiciones dominantes.',
      'categoria': 'MMA',
      'disciplina': 'MMA',
      'emoji': '🚫',
      'dificultad': 'Avanzado',
      'color': Color(0xFF2196F3),
    },
    {
      'termino': 'Gameplanning',
      'definicion':
          'Estrategia general diseñada para el combate específico contra un oponente.',
      'detalles':
          'El game plan es crucial en MMA. Incluye análisis del oponente, identificar fortalezas y debilidades, y adaptar el combate durante las rondas. Los mejores coaches crean game plans detallados.',
      'categoria': 'MMA',
      'disciplina': 'MMA',
      'emoji': '📋',
      'dificultad': 'Avanzado',
      'color': Color(0xFF2196F3),
    },

    // Muay Thai Terms
    {
      'termino': 'Teep',
      'definicion':
          'Patada frontal con la planta del pie, usada para mantener distancia.',
      'detalles':
          'El teep es fundamental en Muay Thai. Se ejecuta con la pierna delantera o trasera. Sirve para mantener al oponente a raya, interrumpir ataques y crear espacio. También conocida como push kick.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '🦵',
      'dificultad': 'Básico',
      'color': Color(0xFFFF9800),
    },
    {
      'termino': 'Roundhouse Kick',
      'definicion':
          'Patada circular ejecutada con la espinilla, una de las técnicas más poderosas.',
      'detalles':
          'El roundhouse es la técnica más icónica de Muay Thai. Se ejecuta girando la cadera y conectando con la espinilla. Puede dirigirse al cuerpo, cabeza o pierna. Es devastadora cuando se conecta correctamente.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '💥',
      'dificultad': 'Intermedio',
      'color': Color(0xFFFF9800),
    },
    {
      'termino': 'Clinch',
      'definicion':
          'Posición de agarre donde se controla al oponente con los brazos.',
      'detalles':
          'El clinch en Muay Thai es único. Se controla la cabeza y se ejecutan rodillazos devastadores. Es una posición muy importante en Muay Thai tailandés. Requiere mucha fuerza y técnica.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '🤝',
      'dificultad': 'Intermedio',
      'color': Color(0xFFFF9800),
    },
    {
      'termino': 'Elbow Strike',
      'definicion': 'Golpe con el codo, devastador en corta distancia.',
      'detalles':
          'Los codos son armas letales en Muay Thai. Pueden causar cortes profundos y knockouts. Se ejecutan en múltiples ángulos: hacia adelante, lateral, hacia atrás. Muy efectivos en el clinch.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '🔥',
      'dificultad': 'Intermedio',
      'color': Color(0xFFFF9800),
    },
    {
      'termino': 'Muay Khao',
      'definicion': 'Estilo de Muay Thai especializado en rodillazos.',
      'detalles':
          'Los peleadores Muay Khao son especialistas en rodillazos. Usan el clinch frecuentemente y atacan con rodillazos repetidos. Este estilo es muy ofensivo y directo.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '🦵💥',
      'dificultad': 'Avanzado',
      'color': Color(0xFFFF9800),
    },
    {
      'termino': 'Wai Kru',
      'definicion':
          'Ritual de respeto realizado antes del combate para honrar a los maestros.',
      'detalles':
          'El Wai Kru es una danza ceremonial que conecta al peleador con su linaje y tradición. Se realiza al ritmo de la música tradicional tailandesa. Es parte integral de la cultura de Muay Thai.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '🙏',
      'dificultad': 'Básico',
      'color': Color(0xFFFF9800),
    },
    {
      'termino': 'Southpaw',
      'definicion': 'Guardia zurda con el pie derecho adelante.',
      'detalles':
          'Los peleadores zurdos tienen ventaja táctica contra diestros. Requiere adaptación de técnicas y estrategias. Muchos campeones de Muay Thai son southpaw.',
      'categoria': 'Muay Thai',
      'disciplina': 'Muay Thai',
      'emoji': '👊',
      'dificultad': 'Básico',
      'color': Color(0xFFFF9800),
    },
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredGlosario {
    return _glosario.where((item) {
      final matchesSearch =
          item['termino'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['definicion'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesCategory =
          _selectedCategory == 'Todos' ||
          item['categoria'] == _selectedCategory ||
          item['disciplina'] == _selectedCategory ||
          item['dificultad'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Color _getDifficultyColor(String dificultad) {
    switch (dificultad) {
      case 'Básico':
        return const Color(0xFF4CAF50);
      case 'Intermedio':
        return const Color(0xFFFF9800);
      case 'Avanzado':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildEpicHeader(isDark),
            _buildSearchBar(isDark),
            _buildCategoryFilter(isDark),
            _buildGlossaryItems(isDark),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildEpicHeader(bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFD32F2F).withOpacity(0.15),
              const Color(0xFFFF6B6B).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
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
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text('📚', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFFF6B6B)],
                        ).createShader(bounds),
                        child: Text(
                          'Glosario de Combate',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'BJJ • MMA • Muay Thai 🥋',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D2D)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD32F2F).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${_glosario.length}', 'Términos', isDark),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  _buildStatItem('3', 'Disciplinas', isDark),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  _buildStatItem('3', 'Niveles', isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFFD32F2F),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF2D2D2D) : Colors.white,
                isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFD32F2F).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar armbar, teep, takedown...',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF2D2D2D) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFFD32F2F).withOpacity(0.4)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 15 : 10,
                      offset: Offset(0, isSelected ? 6 : 2),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFD32F2F).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlossaryItems(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _filteredGlosario[index];
          final isExpanded = _expandedItems[index] ?? false;

          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final animationProgress = Curves.easeOutCubic.transform(
                (_staggerController.value - (index * 0.1)).clamp(0.0, 1.0),
              );

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationProgress)),
                child: Opacity(
                  opacity: animationProgress,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark ? const Color(0xFF2D2D2D) : Colors.white,
                          isDark
                              ? const Color(0xFF252525)
                              : const Color(0xFFFAFAFA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (item['color'] as Color).withOpacity(0.15),
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
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expandedItems[index] = !isExpanded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (item['color'] as Color).withOpacity(0.1),
                                    (item['color'] as Color).withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              item['color'] as Color,
                                              (item['color'] as Color)
                                                  .withOpacity(0.7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (item['color'] as Color)
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            item['emoji'],
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['termino'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _getDifficultyColor(
                                                      item['disciplina'],
                                                    ).withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item['disciplina'],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          _getDifficultyColor(
                                                            item['disciplina'],
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _getDifficultyColor(
                                                      item['dificultad'],
                                                    ).withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item['dificultad'],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          _getDifficultyColor(
                                                            item['dificultad'],
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isExpanded ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: item['color'] as Color,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    item['definicion'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.black26
                                          : Colors.grey[100],
                                      border: Border(
                                        top: BorderSide(
                                          color: (item['color'] as Color)
                                              .withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: (item['color'] as Color)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.info_outline,
                                                color: item['color'] as Color,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Detalles Completos',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          item['detalles'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }, childCount: _filteredGlosario.length),
      ),
    );
  }
}
