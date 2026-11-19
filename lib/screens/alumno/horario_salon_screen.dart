import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/screens/alumno/horarios_screen.dart';
import 'package:proyecto_moviles/screens/profesor/directorio_screen.dart';

/// ============================================================================
/// INTERFAZ 1: HORARIO SALÓN
/// ============================================================================

class HorarioSalonScreen extends StatefulWidget {
  final String salon;
  final List<String> salonesDisponibles;
  final String? horaReloj;
  final String? segundosReloj;
  final bool salonLibre;
  final String profesor;
  final String horario;
  final String materia;
  final ValueChanged<String>? onSalonChanged;
  final ValueChanged<bool>? onToggleSalonLibre;
  final void Function({
    required String profesor,
    required String horario,
    required String materia,
  })? onActualizarDatosSalon;
  final VoidCallback? onVerHorariosTimeline;
  final VoidCallback? onVerDirectorio;

  const HorarioSalonScreen({
    super.key,
    this.salon = 'SALÓN 2001',
    this.salonesDisponibles = const [
      'SALÓN 1001',
      'SALÓN 1101',
      'SALÓN 1201',
      'SALÓN 2001',
      'SALÓN 2101',
      'SALÓN 2201',
      'SALÓN 3001',
      'SALÓN 4001',
    ],
    this.horaReloj,
    this.segundosReloj,
    this.salonLibre = false,
    this.profesor = 'Juan Pérez',
    this.horario = '10:30 - 12:00',
    this.materia = 'Fundamentos de programación',
    this.onSalonChanged,
    this.onToggleSalonLibre,
    this.onActualizarDatosSalon,
    this.onVerHorariosTimeline,
    this.onVerDirectorio,
  });

  @override
  State<HorarioSalonScreen> createState() => _HorarioSalonScreenState();
}

class _HorarioSalonScreenState extends State<HorarioSalonScreen> {
  late String _salonSeleccionado;
  late bool _salonEstaLibre;
  late String _profesorActual;
  late String _horarioActual;
  late String _materiaActual;

  Timer? _relojTimer;
  late DateTime _fechaHora;

  @override
  void initState() {
    super.initState();
    _salonSeleccionado = widget.salon;
    _salonEstaLibre = widget.salonLibre;
    _profesorActual = widget.profesor;
    _horarioActual = widget.horario;
    _materiaActual = widget.materia;

    _fechaHora = DateTime.now();
    if (widget.horaReloj == null) {
      _relojTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _fechaHora = DateTime.now();
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant HorarioSalonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.salon != oldWidget.salon) {
      _salonSeleccionado = widget.salon;
    }
    if (widget.salonLibre != oldWidget.salonLibre) {
      _salonEstaLibre = widget.salonLibre;
    }
    if (widget.profesor != oldWidget.profesor) {
      _profesorActual = widget.profesor;
    }
    if (widget.horario != oldWidget.horario) {
      _horarioActual = widget.horario;
    }
    if (widget.materia != oldWidget.materia) {
      _materiaActual = widget.materia;
    }
  }

  @override
  void dispose() {
    _relojTimer?.cancel();
    super.dispose();
  }

  String get _horaDisplay {
    if (widget.horaReloj != null) return widget.horaReloj!;
    final h = _fechaHora.hour.toString().padLeft(2, '0');
    final m = _fechaHora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _segundosDisplay {
    if (widget.segundosReloj != null) return widget.segundosReloj!;
    return _fechaHora.second.toString().padLeft(2, '0');
  }

  List<String> get _salonesOpciones {
    if (!widget.salonesDisponibles.contains(_salonSeleccionado)) {
      return [_salonSeleccionado, ...widget.salonesDisponibles];
    }
    return widget.salonesDisponibles;
  }

  void _mostrarDialogoEditar(BuildContext context) {
    final profCtrl = TextEditingController(text: _profesorActual);
    final horCtrl = TextEditingController(text: _horarioActual);
    final matCtrl = TextEditingController(text: _materiaActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar datos del salón'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: profCtrl,
                decoration: const InputDecoration(
                  labelText: 'Profesor',
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
              final nuevoProf = profCtrl.text.trim().isEmpty
                  ? _profesorActual
                  : profCtrl.text.trim();
              final nuevoHor = horCtrl.text.trim().isEmpty
                  ? _horarioActual
                  : horCtrl.text.trim();
              final nuevaMat = matCtrl.text.trim().isEmpty
                  ? _materiaActual
                  : matCtrl.text.trim();

              setState(() {
                _profesorActual = nuevoProf;
                _horarioActual = nuevoHor;
                _materiaActual = nuevaMat;
                _salonEstaLibre = false;
              });

              widget.onActualizarDatosSalon?.call(
                profesor: nuevoProf,
                horario: nuevoHor,
                materia: nuevaMat,
              );

              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _abrirHorariosTimeline() {
    if (widget.onVerHorariosTimeline != null) {
      widget.onVerHorariosTimeline!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HorariosScreen(salon: _salonSeleccionado),
        ),
      );
    }
  }

  void _abrirDirectorio() {
    if (widget.onVerDirectorio != null) {
      widget.onVerDirectorio!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DirectorioScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () {
            if (widget.onVerHorariosTimeline != null) {
              widget.onVerHorariosTimeline!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              _abrirHorariosTimeline();
            }
          },
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
            tooltip: 'Línea de tiempo de horarios',
            icon: const Icon(Icons.timeline_rounded, color: Color(0xFF0F172A)),
            onPressed: _abrirHorariosTimeline,
          ),
          IconButton(
            tooltip: 'Directorio departamental',
            icon: const Icon(Icons.badge_outlined, color: Color(0xFF0F172A)),
            onPressed: _abrirDirectorio,
          ),
          IconButton(
            tooltip: 'Editar información',
            onPressed: () => _mostrarDialogoEditar(context),
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
              // 1. Reloj vinculado a la hora oficial del dispositivo + SALÓN 2001
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _horaDisplay,
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
                          ':$_segundosDisplay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.7),
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
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _salonSeleccionado,
                          dropdownColor: const Color(0xFF0F172A),
                          isDense: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white,
                          ),
                          onChanged: (nuevo) {
                            if (nuevo != null) {
                              setState(() {
                                _salonSeleccionado = nuevo;
                              });
                              widget.onSalonChanged?.call(nuevo);
                            }
                          },
                          items: _salonesOpciones.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _salonEstaLibre
                              ? 'Estado: Salón Libre'
                              : 'Estado: Ocupado (En clase)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        Switch.adaptive(
                          value: _salonEstaLibre,
                          activeThumbColor: const Color(0xFF4ADE80),
                          onChanged: (libre) {
                            setState(() {
                              _salonEstaLibre = libre;
                            });
                            widget.onToggleSalonLibre?.call(libre);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 2. Recuadro de PROFESOR, HORARIO y MATERIA (como en el boceto)
              if (_salonEstaLibre)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF16A34A)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 46,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_salonSeleccionado está LIBRE en este momento',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                )
              else
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SESIÓN ACTUAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF026AA7),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _salonEstaLibre = true;
                              });
                              widget.onToggleSalonLibre?.call(true);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Liberar salón'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Recuadro con borde: "PROFESOR: Juan Pérez"
                      InkWell(
                        onTap: _abrirDirectorio,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            'PROFESOR: $_profesorActual',
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // HORARIO: 10:30 - 12:00
                      Text(
                        'HORARIO: $_horarioActual',
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // MATERIA: Fundamentos de programación
                      Text(
                        'MATERIA: $_materiaActual',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
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
}
