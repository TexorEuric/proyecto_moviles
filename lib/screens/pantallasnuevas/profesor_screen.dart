import 'package:flutter/material.dart';
import 'models.dart';

/// ============================================================================
/// PANTALLAS DEL PORTAL DEL PROFESOR (INICIO Y ACTUALIZAR DATOS)
/// Archivo: lib/profesor_screen.dart
/// ============================================================================

class InicioProfesorScreen extends StatelessWidget {
  final EstadoDisponibilidad disponibilidad;
  final String cubiculo;
  final List<CursoProfesor> cursos;
  final Map<String, List<BloqueHorarioProfesor>> horariosPorDia;
  final String horaOficial;
  final ValueChanged<EstadoDisponibilidad> onDisponibilidadChanged;
  final void Function({
    required EstadoDisponibilidad disponibilidad,
    required String cubiculo,
    required Map<String, List<BloqueHorarioProfesor>> horarios,
  }) onActualizarDatosCompletos;
  final ValueChanged<CursoProfesor> onAgregarCurso;
  final ValueChanged<int> onEliminarCurso;

  const InicioProfesorScreen({
    super.key,
    required this.disponibilidad,
    required this.cubiculo,
    required this.cursos,
    required this.horariosPorDia,
    required this.horaOficial,
    required this.onDisponibilidadChanged,
    required this.onActualizarDatosCompletos,
    required this.onAgregarCurso,
    required this.onEliminarCurso,
  });

  BloqueHorarioProfesor? get _proximaClase {
    for (final lista in horariosPorDia.values) {
      for (final bloque in lista) {
        if (bloque.tieneClase) return bloque;
      }
    }
    return null;
  }

  Future<void> _irAActualizarDatos(BuildContext context) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ActualizarDatosProfesorScreen(
          disponibilidadInicial: disponibilidad,
          cubiculoInicial: cubiculo,
          cursosDisponibles: cursos,
          horariosIniciales: horariosPorDia,
        ),
      ),
    );

    if (resultado != null) {
      onActualizarDatosCompletos(
        disponibilidad: resultado['disponibilidad'] as EstadoDisponibilidad,
        cubiculo: resultado['cubiculo'] as String,
        horarios:
            resultado['horarios'] as Map<String, List<BloqueHorarioProfesor>>,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proxima = _proximaClase;
    final estaLibre = disponibilidad == EstadoDisponibilidad.libre;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inicio • Profesor',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            Text(
              'Hora oficial: $horaOficial • Cubículo: $cubiculo',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '¡Buenas tardes,\nprofesor Juan P.!',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: estaLibre,
                          activeColor: const Color(0xFF16A34A),
                          onChanged: (val) {
                            onDisponibilidadChanged(
                              val
                                  ? EstadoDisponibilidad.libre
                                  : EstadoDisponibilidad.ocupado,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EstadoDisponibilidad.values.map((estado) {
                        final sel = disponibilidad == estado;
                        return ChoiceChip(
                          selected: sel,
                          showCheckmark: false,
                          selectedColor: estado.fondoSuave,
                          avatar: CircleAvatar(
                            radius: 5,
                            backgroundColor: estado.color,
                          ),
                          label: Text(estado.etiqueta),
                          onSelected: (_) => onDisponibilidadChanged(estado),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'CURSOS',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cursos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final c = cursos[index];
                    return Container(
                      width: 130,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                c.grupo,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF026AA7),
                                ),
                              ),
                              InkWell(
                                onTap: () => onEliminarCurso(index),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            c.nombreCorto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            c.aula,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'HORARIO',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 96,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF026AA7),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            proxima?.materia ?? 'Sin clase',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFF026AA7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            proxima?.grupo ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proxima != null
                                ? '${proxima.hora} - 12:00'
                                : 'Horario Libre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Próxima clase',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _irAActualizarDatos(context),
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: const Text(
                    'Actualizar datos',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF026AA7),
                    foregroundColor: Colors.white,
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

class ActualizarDatosProfesorScreen extends StatefulWidget {
  final EstadoDisponibilidad disponibilidadInicial;
  final String cubiculoInicial;
  final List<CursoProfesor> cursosDisponibles;
  final Map<String, List<BloqueHorarioProfesor>> horariosIniciales;

  const ActualizarDatosProfesorScreen({
    super.key,
    required this.disponibilidadInicial,
    required this.cubiculoInicial,
    required this.cursosDisponibles,
    required this.horariosIniciales,
  });

  @override
  State<ActualizarDatosProfesorScreen> createState() =>
      _ActualizarDatosProfesorScreenState();
}

class _ActualizarDatosProfesorScreenState
    extends State<ActualizarDatosProfesorScreen> {
  late EstadoDisponibilidad _disponibilidadSeleccionada;
  late TextEditingController _cubiculoController;
  String _diaSeleccionado = 'LUNES';
  late Map<String, List<BloqueHorarioProfesor>> _horariosEditables;

  final List<String> _diasSemana = const [
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
  ];

  @override
  void initState() {
    super.initState();
    _disponibilidadSeleccionada = widget.disponibilidadInicial;
    _cubiculoController = TextEditingController(text: widget.cubiculoInicial);
    _horariosEditables = {
      for (final e in widget.horariosIniciales.entries)
        e.key: List<BloqueHorarioProfesor>.from(e.value),
    };
  }

  @override
  void dispose() {
    _cubiculoController.dispose();
    super.dispose();
  }

  void _guardar() {
    Navigator.pop(context, {
      'disponibilidad': _disponibilidadSeleccionada,
      'cubiculo': _cubiculoController.text.trim().isEmpty
          ? widget.cubiculoInicial
          : _cubiculoController.text.trim(),
      'horarios': _horariosEditables,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloques = _horariosEditables[_diaSeleccionado] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Actualizar datos y horario',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 115,
                    child: Text(
                      'Disponibilidad:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<EstadoDisponibilidad>(
                      value: _disponibilidadSeleccionada,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: EstadoDisponibilidad.values.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.etiqueta),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _disponibilidadSeleccionada = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 115,
                    child: Text(
                      'Cubículo:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _cubiculoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: Icon(Icons.edit_rounded, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'HORARIO CLASE',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _diaSeleccionado,
                    items: _diasSemana.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(
                          d,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      );
                    }).toList(),
                    onChanged: (d) {
                      if (d != null) setState(() => _diaSeleccionado = d);
                    },
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solicitud de modificación enviada.'),
                        ),
                      );
                    },
                    child: const Text('Solicitar mod'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: bloques.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final b = bloques[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 68,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          b.hora,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      title: Text(
                        b.tieneClase
                            ? b.materia!
                            : (b.estaLibreParaAsesoria
                                ? 'Hora Libre (Disponible)'
                                : 'Sin clase (No disponible)'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: b.tieneClase
                              ? const Color(0xFF0F172A)
                              : (b.estaLibreParaAsesoria
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF64748B)),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          b.tieneClase
                              ? Icons.delete_outline_rounded
                              : Icons.swap_horiz_rounded,
                          color: b.tieneClase
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF026AA7),
                        ),
                        onPressed: () {
                          setState(() {
                            if (b.tieneClase) {
                              bloques[index] = b.copyWith(
                                limpiarMateria: true,
                                estaLibreParaAsesoria: true,
                              );
                            } else {
                              bloques[index] = b.copyWith(
                                estaLibreParaAsesoria: !b.estaLibreParaAsesoria,
                              );
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF026AA7),
                    foregroundColor: Colors.white,
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