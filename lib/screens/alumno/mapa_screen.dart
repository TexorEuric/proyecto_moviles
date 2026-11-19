import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/alumno/directorio_screen.dart';
import 'package:proyecto_moviles/screens/alumno/favoritos_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horario_salon_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horarios_screen.dart';
import 'package:proyecto_moviles/screens/alumno/perfil_screen.dart';
import 'package:proyecto_moviles/screens/contenedor_interfaces_verdes.dart';
import 'package:proyecto_moviles/screens/profesor/directorio_screen.dart' as prof_dir;

/// Mapa virtual. Si [ubicar] no es null, muestra la ubicación de ese profesor.
class MapaScreen extends StatelessWidget {
  final Profesor? ubicar;
  const MapaScreen({super.key, this.ubicar});

  // Rectángulos relativos (left, top, width, height) del plano.
  static final Map<int, Rect> _zonas = {
    1: Rect.fromLTWH(.04, .03, .36, .14),
    3: Rect.fromLTWH(.60, .03, .36, .14),
    2: Rect.fromLTWH(.04, .20, .36, .50),
    4: Rect.fromLTWH(.60, .20, .36, .50),
  };
  static final Rect _gobierno = Rect.fromLTWH(.20, .78, .60, .12);

  void _ir(BuildContext context, Widget pantalla) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    final p = ubicar;
    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, p == null ? 16 : 110),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B), width: 2),
                  ),
                  child: _canvas(context),
                ),
              ),
            ),
            if (p == null) ...[
              Positioned(
                top: 24,
                left: 24,
                child: Column(
                  children: [
                    _boton(
                      Icons.star,
                      () => _ir(context, const FavoritosScreen()),
                      iconColor: Colors.amber,
                      tooltip: 'Favoritos',
                    ),
                    const SizedBox(height: 10),
                    _boton(
                      Icons.person,
                      () => _ir(context, const PerfilScreen()),
                      tooltip: 'Mi Perfil',
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: Column(
                  children: [
                    _boton(
                      Icons.meeting_room_rounded,
                      () => _ir(context, const HorarioSalonScreen()),
                      tooltip: 'Horario de Salón',
                    ),
                    const SizedBox(height: 10),
                    _boton(
                      Icons.timeline_rounded,
                      () => _ir(context, const HorariosScreen()),
                      tooltip: 'Línea de tiempo de horarios',
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                child: _boton(
                  Icons.dashboard_customize_outlined,
                  () => _ir(context, const ContenedorInterfacesVerdes()),
                  tooltip: 'Panel integrado de salones y directorio',
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: Column(
                  children: [
                    _boton(
                      Icons.badge_outlined,
                      () => _ir(context, const prof_dir.DirectorioScreen()),
                      tooltip: 'Directorio departamental',
                    ),
                    const SizedBox(height: 10),
                    _boton(
                      Icons.search,
                      () => _ir(context, const DirectorioScreen()),
                      tooltip: 'Directorio de profesores',
                    ),
                  ],
                ),
              ),
            ] else ...[
              Positioned(
                top: 24,
                left: 24,
                child: _boton(Icons.arrow_back, () => Navigator.of(context).pop(),
                    tooltip: 'Volver'),
              ),
              Positioned(top: 24, right: 24, child: _leyenda(p)),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _infoProfesor(p, context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _canvas(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        final p = ubicar;

        Widget caja(
          Rect r,
          String texto, {
          bool resaltar = false,
          VoidCallback? onTap,
        }) =>
            Positioned(
              left: r.left * w,
              top: r.top * h,
              width: r.width * w,
              height: r.height * h,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onTap,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: resaltar ? const Color(0xFFDBEAFE) : Colors.white,
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      texto,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );

        return Stack(
          children: [
            for (final e in _zonas.entries)
              caja(
                e.value,
                '${e.key}',
                resaltar: p?.zona == e.key,
                onTap: () => _ir(
                  context,
                  HorarioSalonScreen(salon: 'SALÓN ${e.key}001'),
                ),
              ),
            caja(
              _gobierno,
              'Gobierno',
              onTap: () => _ir(
                context,
                const prof_dir.DirectorioScreen(),
              ),
            ),
            if (p != null) _marcador(p, w, h),
          ],
        );
      },
    );
  }

  Widget _marcador(Profesor p, double w, double h) {
    final z = _zonas[p.zona]!;
    final cx = (z.center.dx + p.dx * z.width / 2) * w;
    final cy = (z.center.dy + p.dy * z.height / 2) * h;
    final color = p.estado.color;
    return Positioned(
      left: cx - 20,
      top: cy - 20,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _boton(
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = Colors.white,
    String? tooltip,
  }) {
    final btn = Material(
      color: kAzul,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: iconColor)),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }

  Widget _leyenda(Profesor p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 10, color: p.estado.color),
              const SizedBox(width: 6),
              const Text('Ubicación actual', style: TextStyle(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.square, size: 10, color: Color(0xFFBFDBFE)),
              SizedBox(width: 6),
              Text('Edificio del profesor', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoProfesor(Profesor p, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _ir(
          context,
          HorarioSalonScreen(
            salon: p.ubicacion.toUpperCase().contains('SAL')
                ? p.ubicacion
                : 'SALÓN ${p.zona}001',
            profesor: p.nombre,
            materia: p.materias.isNotEmpty ? p.materias.first : 'Asesoría / Clase',
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(Icons.person, color: kAzul),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('Ubicación: ${p.ubicacion} · Edificio ${p.zona}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: p.estado.color),
                      const SizedBox(width: 4),
                      Text(p.estado.label,
                          style: TextStyle(
                              color: p.estado.color, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver salón',
                        style: TextStyle(
                          fontSize: 11,
                          color: kAzul,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: kAzul),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
