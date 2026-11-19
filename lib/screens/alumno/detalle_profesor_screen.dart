import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/alumno/horario_salon_screen.dart';
import 'package:proyecto_moviles/screens/alumno/mapa_screen.dart';

class DetalleProfesorScreen extends StatelessWidget {
  final Profesor profesor;
  const DetalleProfesorScreen({super.key, required this.profesor});

  @override
  Widget build(BuildContext context) {
    final p = profesor;
    final salonDestino = p.ubicacion.toUpperCase().contains('SAL')
        ? p.ubicacion
        : 'SALÓN ${p.zona}001';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Profesor'),
        actions: [
          IconButton(
            tooltip: 'Ver horario de salón',
            icon: const Icon(Icons.meeting_room_outlined, color: kAzul),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HorarioSalonScreen(
                  salon: salonDestino,
                  profesor: p.nombre,
                  materia: p.materias.isNotEmpty
                      ? p.materias.first
                      : 'Asesoría / Clase',
                ),
              ),
            ),
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: AppData.favoritos,
            builder: (_, favs, _) {
              final esFav = favs.contains(p.id);
              return IconButton(
                tooltip: esFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                icon: Icon(esFav ? Icons.star : Icons.star_border,
                    color: esFav ? Colors.amber : const Color(0xFF64748B)),
                onPressed: () => AppData.toggleFavorito(p.id),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: Icon(Icons.person, size: 52, color: Colors.blueGrey.shade700),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _dato('Profesor', p.nombre),
                      _dato('Contacto', p.correo),
                      _dato('Departamento', p.academia),
                      _dato('Materias', p.materias.join(', ')),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                          children: [
                            const Text('Disponibilidad: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            Icon(Icons.circle, size: 14, color: p.estado.color),
                            const SizedBox(width: 6),
                            Text(p.estado.label, style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      _dato('Ubicación', p.ubicacion),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MapaScreen(ubicar: p)),
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ubicar en mapa',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAzul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HorarioSalonScreen(
                        salon: salonDestino,
                        profesor: p.nombre,
                        materia: p.materias.isNotEmpty
                            ? p.materias.first
                            : 'Asesoría / Clase',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.meeting_room_outlined),
                  label: const Text('Ver horario de salón / clases',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kAzul,
                    side: const BorderSide(color: kAzul, width: 1.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: '$etiqueta: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: valor),
          ],
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
