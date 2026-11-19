import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/alumno/detalle_profesor_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horario_salon_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horarios_screen.dart';
import 'package:proyecto_moviles/screens/profesor/directorio_screen.dart' as prof_dir;

class DirectorioScreen extends StatefulWidget {
  const DirectorioScreen({super.key});

  @override
  State<DirectorioScreen> createState() => _DirectorioScreenState();
}

class _DirectorioScreenState extends State<DirectorioScreen> {
  static const _todasAcad = 'Todas las academias';
  static const _todasMat = 'Todas las materias';

  final _busqueda = TextEditingController();
  String _academia = _todasAcad;
  String _materia = _todasMat;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<String> get _academias =>
      [_todasAcad, ...{for (final p in AppData.profesores) p.academia}];
  List<String> get _materias =>
      [_todasMat, ...{for (final p in AppData.profesores) ...p.materias}];

  @override
  Widget build(BuildContext context) {
    final q = _busqueda.text.trim().toLowerCase();
    final lista = AppData.profesores.where((p) {
      final okNombre = q.isEmpty || p.nombre.toLowerCase().contains(q);
      final okAcad = _academia == _todasAcad || p.academia == _academia;
      final okMat = _materia == _todasMat || p.materias.contains(_materia);
      return okNombre && okAcad && okMat;
    }).toList();

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Directorio'),
        actions: [
          IconButton(
            tooltip: 'Horarios de Salón',
            icon: const Icon(Icons.meeting_room_outlined, color: kAzul),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HorarioSalonScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Línea de tiempo de horarios',
            icon: const Icon(Icons.timeline_rounded, color: kAzul),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HorariosScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Directorio departamental',
            icon: const Icon(Icons.badge_outlined, color: kAzul),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const prof_dir.DirectorioScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Filtrar por nombre',
                suffixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            _filtro(_academia, _academias, (v) => setState(() => _academia = v)),
            const SizedBox(height: 10),
            _filtro(_materia, _materias, (v) => setState(() => _materia = v)),
            const SizedBox(height: 14),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text('Sin resultados', style: TextStyle(color: Color(0xFF64748B))))
                  : ListView.separated(
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _tarjeta(lista[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtro(String valor, List<String> items, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _tarjeta(Profesor p) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetalleProfesorScreen(profesor: p)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Dpto. ${p.academia}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: p.estado.color),
                      const SizedBox(width: 6),
                      Text(p.estado.label,
                          style: TextStyle(fontSize: 12, color: p.estado.color)),
                    ],
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, size: 30, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}
