import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/alumno/horario_salon_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horarios_screen.dart';
import 'package:proyecto_moviles/screens/contenedor_interfaces_verdes.dart';
import 'package:proyecto_moviles/screens/docente/actualizar_horario_screen.dart';
import 'package:proyecto_moviles/screens/login_screen.dart';
import 'package:proyecto_moviles/screens/profesor/directorio_screen.dart';

class DocenteHomeScreen extends StatefulWidget {
  const DocenteHomeScreen({super.key});

  @override
  State<DocenteHomeScreen> createState() => _DocenteHomeScreenState();
}

class _DocenteHomeScreenState extends State<DocenteHomeScreen> {
  String get _saludo {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días,';
    if (h < 19) return '¡Buenas tardes,';
    return '¡Buenas noches,';
  }

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _agregarCurso() async {
    final grupo = TextEditingController();
    final materia = TextEditingController();
    final lugar = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: grupo, decoration: const InputDecoration(labelText: 'Grupo (ej. 2CM2)')),
            TextField(controller: materia, decoration: const InputDecoration(labelText: 'Materia')),
            TextField(controller: lugar, decoration: const InputDecoration(labelText: 'Salón / Laboratorio')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Agregar')),
        ],
      ),
    );
    if (ok == true && grupo.text.trim().isNotEmpty && materia.text.trim().isNotEmpty) {
      AppData.cursos.value = [
        ...AppData.cursos.value,
        Curso(grupo.text.trim().toUpperCase(), materia.text.trim(), lugar.text.trim()),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  _tarjetaEstado(),
                  const SizedBox(height: 24),
                  _seccionSalonesYDirectorio(),
                  const SizedBox(height: 24),
                  _seccionCursos(),
                  const SizedBox(height: 24),
                  _seccionHorario(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ActualizarHorarioScreen()),
                        );
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: const Text('Actualizar datos y horario',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAzul,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
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

  Widget _header() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: kAzul),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inicio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                Text('Portal Docente • ESCOM',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: AppData.docenteCubiculo,
            builder: (_, cubiculo, _) => Tooltip(
              message: 'Ver horario del cubículo / salón',
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HorarioSalonScreen(
                      salon: cubiculo.toUpperCase().startsWith('CUB') ||
                              cubiculo.toUpperCase().startsWith('SAL')
                          ? cubiculo
                          : 'SALÓN $cubiculo',
                      profesor: 'Juan Pérez',
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 18, color: kAzul),
                      const SizedBox(width: 8),
                      Text(cubiculo, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Salones y Directorio (Pestañas)',
            icon: const Icon(Icons.dashboard_customize_outlined, color: kAzul),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContenedorInterfacesVerdes()),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
    );
  }

  Widget _seccionSalonesYDirectorio() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dashboard_outlined, color: kAzul, size: 22),
              SizedBox(width: 8),
              Text(
                'Salones y Directorio Departamental',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Consulta el horario de salones en vivo, líneas de tiempo y el directorio de profesores.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _botonAccesoRapido(
                  icon: Icons.meeting_room_rounded,
                  titulo: 'Horario Salón',
                  subtitulo: 'En tiempo real',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HorarioSalonScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botonAccesoRapido(
                  icon: Icons.timeline_rounded,
                  titulo: 'Horarios',
                  subtitulo: 'Línea de tiempo',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HorariosScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _botonAccesoRapido(
                  icon: Icons.badge_outlined,
                  titulo: 'Directorio',
                  subtitulo: 'Ing. Sistemas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DirectorioScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botonAccesoRapido(
                  icon: Icons.view_carousel_rounded,
                  titulo: 'Panel General',
                  subtitulo: 'Pestañas interactivas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ContenedorInterfacesVerdes()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonAccesoRapido({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: kAzul, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaEstado() {
    return ValueListenableBuilder<Estado>(
      valueListenable: AppData.docenteEstado,
      builder: (_, estado, _) {
        final libre = estado == Estado.libre;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '$_saludo\nprofesor Juan P.!',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                  ),
                  Column(
                    children: [
                      Switch(
                        value: libre,
                        thumbColor: WidgetStatePropertyAll(libre ? Estado.libre.color : Colors.white),
                        trackColor: WidgetStatePropertyAll(
                          libre ? Estado.libre.color.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
                        ),
                        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        onChanged: (v) =>
                            AppData.docenteEstado.value = v ? Estado.libre : Estado.ocupado,
                      ),
                      Text(
                        libre ? 'Estoy Libre' : 'No disponible',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: libre ? Estado.libre.color : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Gestiona tu estado en tiempo real para tus alumnos.',
                  style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: estado.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: estado.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    _punto(estado.color, 12),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Disponibilidad: ${estado.label}',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700, color: estado.color)),
                          const SizedBox(height: 2),
                          Text(estado.descripcion,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: estado.color, size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('CAMBIO RÁPIDO DE ESTADO:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final e in Estado.values) _chipEstado(e, estado)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _punto(Color c, double size) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _chipEstado(Estado e, Estado actual) {
    final sel = e == actual;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => AppData.docenteEstado.value = e,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? e.color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? e.color : const Color(0xFFE2E8F0), width: sel ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _punto(e.color, 10),
            const SizedBox(width: 8),
            Text(e.label,
                style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _seccionCursos() {
    return ValueListenableBuilder<List<Curso>>(
      valueListenable: AppData.cursos,
      builder: (_, cursos, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('CURSOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${cursos.length}', style: const TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _agregarCurso,
                icon: const Icon(Icons.add_circle_outline, color: kAzul),
                label: const Text('Agregar curso', style: TextStyle(color: kAzul)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in cursos)
                  Padding(padding: const EdgeInsets.only(right: 12), child: _cursoCard(c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cursoCard(Curso c) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HorarioSalonScreen(
            salon: c.lugar.toUpperCase().startsWith('SAL') ||
                    c.lugar.toUpperCase().startsWith('LAB')
                ? c.lugar
                : 'SALÓN ${c.lugar}',
            profesor: 'Juan Pérez',
            materia: c.materia,
          ),
        ),
      ),
      child: Container(
        width: 164,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(c.grupo,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kAzul)),
                ),
                InkWell(
                  onTap: () => AppData.cursos.value =
                      AppData.cursos.value.where((x) => x != c).toList(),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(c.materia, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(c.lugar,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionHorario() {
    final prox = AppData.horario['LUNES']
        ?.where((s) => s.tipo == TipoSlot.clase)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('HORARIO • PRÓXIMA SESIÓN',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: prox == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HorarioSalonScreen(
                        salon: prox.lugar.toUpperCase().startsWith('SAL') ||
                                prox.lugar.toUpperCase().startsWith('LAB')
                            ? prox.lugar
                            : 'SALÓN ${prox.lugar}',
                        profesor: 'Juan Pérez',
                        materia: prox.materia,
                      ),
                    ),
                  ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: prox == null
                ? const Text('Sin clases programadas', style: TextStyle(color: Color(0xFF64748B)))
                : Row(
                    children: [
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kAzul, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Text(prox.materia,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: kAzul, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: kAzul, borderRadius: BorderRadius.circular(8)),
                              child: Text(prox.grupo,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_filled, color: kAzul, size: 20),
                                const SizedBox(width: 8),
                                Text('${prox.hora} - ${prox.fin}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text('Próxima clase programada',
                                style: TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 6),
                            Text('Ubicación: ${prox.lugar}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
