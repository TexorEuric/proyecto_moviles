import 'package:flutter/material.dart';
import 'models.dart';

/// ============================================================================
/// ARCHIVO 3: lib/croquis_screen.dart
/// Mapa Virtual basado fielmente en la mampara física oficial de ESCOM:
/// - Fila superior: Área de estudio (guinda con círculos), Edificio 5 (turquesa),
///   Área Deportiva (verde) y Cafetería (gris oscuro).
/// - Zona media-alta: Edificio 4 (azul, 2 bloques con escaleras), Edificio de
///   Laboratorios (turquesa central conectado con puentes) y Edificio 3 (azul,
///   2 bloques con escaleras y etiqueta DEC).
/// - Zona media-baja: Edificio 2 (azul, 2 bloques), Explanada central y
///   Edificio 1 (azul marino, 2 bloques).
/// - Zona inferior: ENTRADA/SALIDA con pin "Usted está aquí", Edificio de
///   Gobierno (con insignias GE y DIR), Auditorio, Área de estudio inferior,
///   Barra de Café y Área Deportiva inferior.
/// - Botón de lupa que lleva directo al Directorio de Profesores.
/// ============================================================================

class CroquisEscomScreen extends StatelessWidget {
  final List<ProfesorDirectorio> profesores;
  final ProfesorDirectorio? profesorUbicado;
  final String horaOficial;
  final ValueChanged<String> onSeleccionarEdificio;
  final VoidCallback onIrADirectorio;
  final ValueChanged<ProfesorDirectorio> onUbicarProfesor;
  final ValueChanged<String> onToggleFavorito;

  const CroquisEscomScreen({
    super.key,
    required this.profesores,
    required this.profesorUbicado,
    required this.horaOficial,
    required this.onSeleccionarEdificio,
    required this.onIrADirectorio,
    required this.onUbicarProfesor,
    required this.onToggleFavorito,
  });

  void _mostrarModalFavoritos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final favoritos = profesores.where((p) => p.esFavorito).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF026AA7),
                    child: Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBBF24),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Favoritos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona algún profesor para ubicarlo en el mapa.',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              if (favoritos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('Aún no tienes profesores en favoritos.'),
                  ),
                )
              else
                ...favoritos.map((prof) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prof.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.5,
                                ),
                              ),
                              Text(
                                prof.departamento,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.pop(context);
                            onUbicarProfesor(prof);
                          },
                          icon: const Icon(Icons.my_location_rounded, size: 16),
                          label: const Text('Ubicar en mapa'),
                        ),
                        IconButton(
                          tooltip: 'Quitar de favoritos',
                          onPressed: () {
                            onToggleFavorito(prof.id);
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _mostrarModalPerfilAlumno(BuildContext context) {
    final nombreCtrl = TextEditingController(text: 'Juancho P.');
    final usuarioCtrl = TextEditingController(text: '2024630123');
    final passCtrl = TextEditingController(text: '••••••••');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_rounded, size: 26, color: Color(0xFF0F172A)),
                SizedBox(width: 8),
                Text(
                  'Perfil • Alumno',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usuarioCtrl,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Actualizar contraseña',
                border: OutlineInputBorder(),
                isDense: true,
                suffixIcon: Icon(
                  Icons.check_box_rounded,
                  color: Color(0xFF026AA7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Agregar'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores oficiales de la mampara física de ESCOM
    const colorFondoMapa = Color(0xFFEDEFF2);
    const colorTurquesa = Color(0xFF15858E); // Edificio 5 y Edificio de Labs
    const colorAzulEdif4y2 = Color(0xFF237BB6); // Edificio 4 y Edificio 2
    const colorAzulEdif3 = Color(0xFF1A6CA3); // Edificio 3
    const colorAzulEdif1yGob = Color(0xFF134E80); // Edificio 1 y Gobierno
    const colorAreaEstudio = Color(0xFF7D225B); // Área de estudio (guinda)
    const colorAreaDeportiva = Color(0xFF429829); // Área Deportiva (verde)
    const colorCafeteria = Color(0xFF635F5E); // Cafetería y Barra de Café
    const colorAuditorio = Color(0xFFB8B4B1); // Auditorio

    return Scaffold(
      backgroundColor: colorFondoMapa,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visualizar mapa virtual',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              'Croquis oficial ESCOM • $horaOficial',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ------------------------------------------------------------------
          // PLANO INTERACTIVO FIEL A LA MAMPARA OFICIAL DE ESCOM (SIN QRs)
          // ------------------------------------------------------------------
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 96),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              ),
              child: Column(
                children: [
                  // Banner flotante si hay un profesor ubicado en el mapa
                  if (profesorUbicado != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: profesorUbicado!.disponibilidad.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${profesorUbicado!.nombre} • ${profesorUbicado!.cubiculo} (${profesorUbicado!.edificioUbicacion})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => onSeleccionarEdificio(
                              profesorUbicado!.edificioUbicacion,
                            ),
                            child: const Text('Ver edificio'),
                          ),
                        ],
                      ),
                    ),

                  // ==========================================================
                  // 1. FILA SUPERIOR:
                  // [Área de estudio] | [Edificio 5] | [Área Deportiva] | [Cafetería]
                  // ==========================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna izquierda superior: Área de estudio (guinda con círculos)
                      Expanded(
                        flex: 26,
                        child: _BloqueAreaEstudio(
                          altura: 125,
                          color: colorAreaEstudio,
                          filasCirculos: 5,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Columna central superior: Edificio 5 (turquesa)
                      Expanded(
                        flex: 34,
                        child: _BloqueEdificioCentral(
                          titulo: 'Edificio\n5',
                          altura: 165,
                          color: colorTurquesa,
                          mostrarBanosArriba: true,
                          mostrarBanosAbajo: true,
                          tienePin: profesorUbicado?.edificioUbicacion ==
                              'Edificio 5',
                          colorPin: profesorUbicado?.disponibilidad.color ??
                              const Color(0xFF16A34A),
                          onTap: () => onSeleccionarEdificio('Edificio 5'),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Columna derecha superior: Área Deportiva + Cafetería
                      Expanded(
                        flex: 36,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: _BloqueSimpleMapa(
                                  titulo: 'Área\nDeportiva',
                                  altura: 102,
                                  color: colorAreaDeportiva,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 4,
                              child: _BloqueSimpleMapa(
                                titulo: 'Cafetería',
                                altura: 68,
                                color: colorCafeteria,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ==========================================================
                  // 2. ZONA MEDIA (EDIFICIO 4 | EDIFICIO DE LABORATORIOS + EXPLANADA | EDIFICIO 3)
                  //    Y ABAJO (EDIFICIO 2 | EXPLANADA | EDIFICIO 1)
                  // ==========================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------------
                      // COLUMNA IZQUIERDA: Edificio 4 (arriba) y Edificio 2 (abajo)
                      // ------------------------------------------------------
                      Expanded(
                        flex: 26,
                        child: Column(
                          children: [
                            _EdificioDobleBloque(
                              titulo: 'Edificio\n4',
                              color: colorAzulEdif4y2,
                              tienePin: profesorUbicado?.edificioUbicacion ==
                                  'Edificio 4',
                              colorPin: profesorUbicado?.disponibilidad.color ??
                                  const Color(0xFF16A34A),
                              onTap: () => onSeleccionarEdificio('Edificio 4'),
                            ),
                            const SizedBox(height: 14),
                            _EdificioDobleBloque(
                              titulo: 'Edificio\n2',
                              color: colorAzulEdif4y2,
                              tienePin: profesorUbicado?.edificioUbicacion ==
                                  'Edificio 2',
                              colorPin: profesorUbicado?.disponibilidad.color ??
                                  const Color(0xFF16A34A),
                              onTap: () => onSeleccionarEdificio('Edificio 2'),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------------
                      // COLUMNA CENTRAL: Puentes + Edificio de Laboratorios + Explanada
                      // ------------------------------------------------------
                      Expanded(
                        flex: 34,
                        child: Column(
                          children: [
                            const SizedBox(height: 36),
                            // Puente superior que conecta Edif 4 - Labs - Edif 3
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 7,
                                  color: const Color(0xFF334155),
                                ),
                                Expanded(
                                  child: _BloqueEdificioCentral(
                                    titulo: 'Edificio de\nLaboratorios',
                                    altura: 175,
                                    color: colorTurquesa,
                                    mostrarEscalerasAbajo: true,
                                    tienePin: false,
                                    colorPin: const Color(0xFF16A34A),
                                    onTap: () =>
                                        onSeleccionarEdificio('Edificio 2'),
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 7,
                                  color: const Color(0xFF334155),
                                ),
                              ],
                            ),
                            // Puente inferior entre Edif 4/2 - Labs - Edif 3/1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 10,
                                  height: 7,
                                  color: const Color(0xFF334155),
                                ),
                                Container(
                                  width: 10,
                                  height: 7,
                                  color: const Color(0xFF334155),
                                ),
                              ],
                            ),
                            const SizedBox(height: 38),
                            // EXPLANADA CENTRAL
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Explanada',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------------
                      // COLUMNA DERECHA: Edificio 3 (con DEC) y Edificio 1
                      // ------------------------------------------------------
                      Expanded(
                        flex: 26,
                        child: Column(
                          children: [
                            _EdificioDobleBloque(
                              titulo: 'Edificio\n3',
                              color: colorAzulEdif3,
                              insigniaInferiorIzquierda: 'DEC',
                              tienePin: profesorUbicado?.edificioUbicacion ==
                                  'Edificio 3',
                              colorPin: profesorUbicado?.disponibilidad.color ??
                                  const Color(0xFF16A34A),
                              onTap: () => onSeleccionarEdificio('Edificio 3'),
                            ),
                            const SizedBox(height: 14),
                            _EdificioDobleBloque(
                              titulo: 'Edificio\n1',
                              color: colorAzulEdif1yGob,
                              tienePin: profesorUbicado?.edificioUbicacion ==
                                  'Edificio 1',
                              colorPin: profesorUbicado?.disponibilidad.color ??
                                  const Color(0xFF16A34A),
                              onTap: () => onSeleccionarEdificio('Edificio 1'),
                            ),
                          ],
                        ),
                      ),

                      // Espacio derecho para alinear con Cafetería / Área Deportiva
                      const Expanded(flex: 10, child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ==========================================================
                  // 3. ZONA INFERIOR:
                  // [ENTRADA/SALIDA + Usted está aquí] | [Edificio de Gobierno + Auditorio] | [Área de estudio] | [Barra de Café + Área Deportiva]
                  // ==========================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ENTRADA / SALIDA + Pin "Usted está aquí"
                      Expanded(
                        flex: 26,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'ENTRADA',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    width: 22,
                                    height: 6,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                  const Text(
                                    'SALIDA',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Column(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFF237BB6),
                                    size: 28,
                                  ),
                                  Text(
                                    'Usted\nestá aquí',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF237BB6),
                                      height: 1.05,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // EDIFICIO DE GOBIERNO (con GE y DIR) + AUDITORIO debajo
                      Expanded(
                        flex: 34,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => onSeleccionarEdificio('Edificio 1'),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: double.infinity,
                                height: 112,
                                decoration: BoxDecoration(
                                  color: colorAzulEdif1yGob,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Stack(
                                  children: [
                                    // Escaleras arriba al centro
                                    const Align(
                                      alignment: Alignment.topCenter,
                                      child: _IconoEscaleras(ancho: 22),
                                    ),
                                    const Center(
                                      child: Text(
                                        'Edificio de\nGobierno',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                    // Etiqueta GE a la derecha
                                    Positioned(
                                      right: 0,
                                      bottom: 24,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        color: const Color(0xFFD6D3D1),
                                        child: const Text(
                                          'GE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Etiqueta DIR abajo al centro
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        color: const Color(0xFFD6D3D1),
                                        child: const Text(
                                          'DIR',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // AUDITORIO (gris claro debajo de Gobierno)
                            Container(
                              width: double.infinity,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorAuditorio,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Auditorio',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // ÁREA DE ESTUDIO INFERIOR (guinda con círculos)
                      Expanded(
                        flex: 20,
                        child: _BloqueAreaEstudio(
                          altura: 170,
                          color: const Color(0xFF681D4A),
                          filasCirculos: 6,
                          etiquetaAlFinal: true,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // BARRA DE CAFÉ + ÁREA DEPORTIVA INFERIOR DERECHA
                      Expanded(
                        flex: 16,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 22,
                                    color: colorCafeteria,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'Barra\nde Café',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF334155),
                                    height: 1.05,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const _BloqueSimpleMapa(
                              titulo: 'Área\nDeportiva',
                              altura: 140,
                              color: colorAreaDeportiva,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // BOTONES FLOTANTES DEL BOCETO:
          // Arriba izquierda: ★ (Favoritos) y 👤 (Perfil Alumno)
          // Abajo derecha: Lupa 🔍 que lleva directo al Directorio de Profesores
          // ------------------------------------------------------------------
          Positioned(
            top: 14,
            left: 14,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_favoritos',
                  tooltip: 'Favoritos',
                  backgroundColor: const Color(0xFF026AA7),
                  onPressed: () => _mostrarModalFavoritos(context),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFBBF24),
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'fab_perfil',
                  tooltip: 'Perfil del Alumno',
                  backgroundColor: const Color(0xFF026AA7),
                  onPressed: () => _mostrarModalPerfilAlumno(context),
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'fab_lupa_directorio',
              tooltip: 'Abrir Directorio de Profesores',
              backgroundColor: const Color(0xFF026AA7),
              foregroundColor: Colors.white,
              onPressed: onIrADirectorio,
              child: const Icon(Icons.search_rounded, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para los edificios laterales divididos en 2 bloques por escaleras (Edif 1, 2, 3 y 4)
/// Sin íconos de códigos QR en el bloque inferior.
class _EdificioDobleBloque extends StatelessWidget {
  final String titulo;
  final Color color;
  final String? insigniaInferiorIzquierda;
  final bool tienePin;
  final Color colorPin;
  final VoidCallback onTap;

  const _EdificioDobleBloque({
    required this.titulo,
    required this.color,
    this.insigniaInferiorIzquierda,
    required this.tienePin,
    required this.colorPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: tienePin
              ? Border.all(color: const Color(0xFFFACC15), width: 2.5)
              : null,
        ),
        child: Column(
          children: [
            // Bloque superior con íconos de baños arriba y nombre del edificio
            Container(
              width: double.infinity,
              height: 82,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 4,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.wc_rounded, color: Colors.white70, size: 12),
                        Icon(Icons.wc_rounded, color: Colors.white70, size: 12),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        height: 1.15,
                      ),
                    ),
                  ),
                  if (tienePin)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorPin, width: 2),
                        ),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorPin,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Franja divisoria de escaleras (|||||||)
            Container(
              height: 10,
              width: double.infinity,
              color: Colors.white,
              child: CustomPaint(painter: _RayasEscalerasPainter(color: color)),
            ),
            // Bloque inferior limpio (sin QR, solo etiqueta DEC si aplica)
            Container(
              width: double.infinity,
              height: 68,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(5),
                ),
              ),
              child: Stack(
                children: [
                  if (insigniaInferiorIzquierda != null)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        color: const Color(0xFFD6D3D1),
                        child: Text(
                          insigniaInferiorIzquierda!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloque para Edificio 5 y Edificio de Laboratorios (color turquesa al centro)
class _BloqueEdificioCentral extends StatelessWidget {
  final String titulo;
  final double altura;
  final Color color;
  final bool mostrarBanosArriba;
  final bool mostrarBanosAbajo;
  final bool mostrarEscalerasAbajo;
  final bool tienePin;
  final Color colorPin;
  final VoidCallback onTap;

  const _BloqueEdificioCentral({
    required this.titulo,
    required this.altura,
    required this.color,
    this.mostrarBanosArriba = false,
    this.mostrarBanosAbajo = false,
    this.mostrarEscalerasAbajo = false,
    required this.tienePin,
    required this.colorPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        height: altura,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: tienePin
              ? Border.all(color: const Color(0xFFFACC15), width: 2.5)
              : null,
        ),
        child: Stack(
          children: [
            if (mostrarBanosArriba)
              const Positioned(
                top: 4,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.wc_rounded, color: Colors.white70, size: 12),
                    Icon(Icons.stairs_rounded, color: Colors.white70, size: 13),
                    Icon(Icons.wc_rounded, color: Colors.white70, size: 12),
                  ],
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.15,
                  ),
                ),
              ),
            ),
            if (mostrarBanosAbajo)
              const Positioned(
                bottom: 4,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.wc_rounded, color: Colors.white70, size: 12),
                    Icon(Icons.stairs_rounded, color: Colors.white70, size: 13),
                    Icon(Icons.wc_rounded, color: Colors.white70, size: 12),
                  ],
                ),
              ),
            if (mostrarEscalerasAbajo)
              const Align(
                alignment: Alignment.bottomCenter,
                child: _IconoEscaleras(ancho: 22),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bloque guinda de "Área de estudio" con los círculos blancos de las palapas
class _BloqueAreaEstudio extends StatelessWidget {
  final double altura;
  final Color color;
  final int filasCirculos;
  final bool etiquetaAlFinal;

  const _BloqueAreaEstudio({
    required this.altura,
    required this.color,
    required this.filasCirculos,
    this.etiquetaAlFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: altura,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: List.generate(filasCirculos, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (_) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 1.2),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
          const Text(
            'Área de\nestudio',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BloqueSimpleMapa extends StatelessWidget {
  final String titulo;
  final double altura;
  final Color color;
  final double fontSize;

  const _BloqueSimpleMapa({
    required this.titulo,
    required this.altura,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: altura,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        titulo,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          height: 1.15,
        ),
      ),
    );
  }
}

class _IconoEscaleras extends StatelessWidget {
  final double ancho;
  const _IconoEscaleras({required this.ancho});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white70, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (_) => Container(height: 1, color: Colors.white70),
        ),
      ),
    );
  }
}

class _RayasEscalerasPainter extends CustomPainter {
  final Color color;
  const _RayasEscalerasPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6;
    const step = 5.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}