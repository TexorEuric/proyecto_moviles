import 'package:flutter/material.dart';
import 'models.dart';

/// ============================================================================
/// ARCHIVO 5: lib/horario_salon_screen.dart
/// Pantalla "HORARIO SALÓN" conectada con Vista por Edificio y Directorio.
/// ============================================================================

class HorarioSalonScreen extends StatelessWidget {
  final List<EspacioEdificio> espacios;
  final int indiceEspacioActual;
  final String horaReloj;
  final String segundosReloj;
  final VoidCallback onBackToEdificio;
  final ValueChanged<int> onEspacioChanged;
  final ValueChanged<bool> onToggleSalonLibre;
  final void Function({
    required String profesor,
    required String horario,
    required String materia,
  }) onActualizarDatosSalon;
  final VoidCallback onVerLineaTiempo;
  final VoidCallback onVerProfesorEnDirectorio;

  const HorarioSalonScreen({
    super.key,
    required this.espacios,
    required this.indiceEspacioActual,
    required this.horaReloj,
    required this.segundosReloj,
    required this.onBackToEdificio,
    required this.onEspacioChanged,
    required this.onToggleSalonLibre,
    required this.onActualizarDatosSalon,
    required this.onVerLineaTiempo,
    required this.onVerProfesorEnDirectorio,
  });

  void _mostrarDialogoEditarSesion(
    BuildContext context,
    EspacioEdificio espacio,
  ) {
    final profCtrl = TextEditingController(text: espacio.profesorActual);
    final horCtrl = TextEditingController(text: espacio.horarioActual);
    final matCtrl = TextEditingController(text: espacio.materiaActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Editar sesión de ${espacio.codigo}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: profCtrl,
                decoration: const InputDecoration(
                  labelText: 'Profesor asignado',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: horCtrl,
                decoration: const InputDecoration(
                  labelText: 'Horario (ej. 10:30 - 12:00)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: matCtrl,
                decoration: const InputDecoration(
                  labelText: 'Materia',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onActualizarDatosSalon(
                profesor: profCtrl.text.trim().isEmpty
                    ? espacio.profesorActual
                    : profCtrl.text.trim(),
                horario: horCtrl.text.trim().isEmpty
                    ? espacio.horarioActual
                    : horCtrl.text.trim(),
                materia: matCtrl.text.trim().isEmpty
                    ? espacio.materiaActual
                    : matCtrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final espacio = espacios[indiceEspacioActual];
    final etiquetaSalon =
        '${espacio.titulo.replaceAll('\n', ' ')} ${espacio.codigo}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver a Vista por edificio',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: onBackToEdificio,
        ),
        title: const Text(
          'HORARIO SALÓN',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.6,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Editar datos del salón',
            onPressed: () => _mostrarDialogoEditarSesion(context, espacio),
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF026AA7)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Reloj vinculado a la hora oficial del dispositivo + Selector de Salón
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          horaReloj,
                          style: const TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ':$segundosReloj',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: indiceEspacioActual,
                          dropdownColor: const Color(0xFF0F172A),
                          isDense: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          onChanged: (nuevoIdx) {
                            if (nuevoIdx != null) onEspacioChanged(nuevoIdx);
                          },
                          items: List.generate(espacios.length, (i) {
                            final e = espacios[i];
                            return DropdownMenuItem(
                              value: i,
                              child: Text(
                                '${e.titulo.replaceAll('\n', ' ')} ${e.codigo}',
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          espacio.estaLibre
                              ? 'Estado: Salón Libre'
                              : 'Estado: Ocupado (En clase)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        Switch.adaptive(
                          value: espacio.estaLibre,
                          activeColor: const Color(0xFF4ADE80),
                          onChanged: onToggleSalonLibre,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 2. Recuadro de PROFESOR, HORARIO y MATERIA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onVerProfesorEnDirectorio,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.6,
                          ),
                        ),
                        child: Text(
                          'PROFESOR: ${espacio.profesorActual}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'HORARIO: ${espacio.horarioActual}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'MATERIA: ${espacio.materiaActual}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Botón para ir a la línea de tiempo completa ("HORARIOS")
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onVerLineaTiempo,
                  icon: const Icon(Icons.view_timeline_rounded),
                  label: Text('Ver línea de tiempo de $etiquetaSalon'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF026AA7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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