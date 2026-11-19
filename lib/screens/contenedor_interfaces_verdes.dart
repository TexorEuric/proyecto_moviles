import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/horario_salon_models.dart';
import 'package:proyecto_moviles/screens/alumno/horario_salon_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horarios_screen.dart';
import 'package:proyecto_moviles/screens/profesor/directorio_screen.dart';

/// ============================================================================
/// APLICACIÓN Y CONTENEDOR DE LAS 3 PANTALLAS
/// ============================================================================

class InterfacesVerdesApp extends StatelessWidget {
  const InterfacesVerdesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horarios y Directorio ESCOM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF026AA7),
          primary: const Color(0xFF026AA7),
          secondary: const Color(0xFF0F172A),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        fontFamily: 'Roboto',
      ),
      home: const ContenedorInterfacesVerdes(),
    );
  }
}

class ContenedorInterfacesVerdes extends StatefulWidget {
  const ContenedorInterfacesVerdes({super.key});

  @override
  State<ContenedorInterfacesVerdes> createState() =>
      _ContenedorInterfacesVerdesState();
}

class _ContenedorInterfacesVerdesState
    extends State<ContenedorInterfacesVerdes> {
  int _pestanaActual = 0;

  // Reloj vinculado a la hora oficial del dispositivo en tiempo real
  late DateTime _fechaHoraDispositivo;
  Timer? _relojTimer;

  // Estado para Pantalla 1: HORARIO SALÓN
  String _salonSeleccionado = 'SALÓN 2001';
  final List<String> _salonesDisponibles = const [
    'SALÓN 1001',
    'SALÓN 1101',
    'SALÓN 1201',
    'SALÓN 2001',
    'SALÓN 2101',
    'SALÓN 2201',
    'SALÓN 3001',
    'SALÓN 4001',
  ];
  bool _salonEstaLibre = false;
  String _profesorActual = 'Juan Pérez';
  String _horarioActual = '10:30 - 12:00';
  String _materiaActual = 'Fundamentos de programación';

  // Estado para Pantalla 2: HORARIOS (Línea de tiempo vertical)
  final List<BloqueTimelineSalon> _bloquesHorario = [
    const BloqueTimelineSalon(
      id: 'b1',
      horaInicio: '7:00',
      horaFin: '8:30',
      titulo: 'Materia 1',
      profesor: 'Prof. Alexis Pérez',
    ),
    const BloqueTimelineSalon(
      id: 'b2',
      horaInicio: '8:30',
      horaFin: '10:00',
      titulo: 'Materia 1',
      profesor: 'Prof. Alexis Pérez',
    ),
    const BloqueTimelineSalon(
      id: 'b3',
      horaInicio: '10:00',
      horaFin: '10:30',
      titulo: 'RECESO',
      esReceso: true,
    ),
    const BloqueTimelineSalon(
      id: 'b4',
      horaInicio: '10:30',
      horaFin: '12:00',
      titulo: 'Materia 1',
      profesor: 'Prof. Alexis Pérez',
    ),
  ];

  // Estado para Pantalla 3: DIRECTORIO
  final List<ProfesorDirectorio> _profesores = [
    const ProfesorDirectorio(
      id: 'p1',
      nombre: 'Juan Díaz',
      departamento: 'Dpto. Ing. Sist. C.',
      disponibilidad: EstadoDisponibilidad.libre,
    ),
    const ProfesorDirectorio(
      id: 'p2',
      nombre: 'Pepe Armendiz',
      departamento: 'Dpto. Ciencias Básicas',
      disponibilidad: EstadoDisponibilidad.ocupado,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fechaHoraDispositivo = DateTime.now();
    _relojTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _fechaHoraDispositivo = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _relojTimer?.cancel();
    super.dispose();
  }

  String get _horaFormateada {
    final h = _fechaHoraDispositivo.hour.toString().padLeft(2, '0');
    final m = _fechaHoraDispositivo.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _segundosFormateados {
    return _fechaHoraDispositivo.second.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      // 1. Primera interfaz: HORARIO SALÓN
      HorarioSalonScreen(
        salon: _salonSeleccionado,
        salonesDisponibles: _salonesDisponibles,
        horaReloj: _horaFormateada,
        segundosReloj: _segundosFormateados,
        salonLibre: _salonEstaLibre,
        profesor: _profesorActual,
        horario: _horarioActual,
        materia: _materiaActual,
        onSalonChanged: (nuevo) => setState(() => _salonSeleccionado = nuevo),
        onToggleSalonLibre: (libre) => setState(() => _salonEstaLibre = libre),
        onActualizarDatosSalon: ({
          required String profesor,
          required String horario,
          required String materia,
        }) {
          setState(() {
            _profesorActual = profesor;
            _horarioActual = horario;
            _materiaActual = materia;
            _salonEstaLibre = false;
          });
        },
        onVerHorariosTimeline: () => setState(() => _pestanaActual = 1),
        onVerDirectorio: () => setState(() => _pestanaActual = 2),
      ),

      // 2. Segunda interfaz: HORARIOS
      HorariosScreen(
        salon: _salonSeleccionado,
        bloques: _bloquesHorario,
        onBack: () => setState(() => _pestanaActual = 0),
        onAgregarBloque: (nuevo) {
          setState(() => _bloquesHorario.add(nuevo));
        },
        onActualizarBloque: (index, actualizado) {
          setState(() => _bloquesHorario[index] = actualizado);
        },
        onEliminarBloque: (index) {
          final eliminado = _bloquesHorario[index];
          setState(() => _bloquesHorario.removeAt(index));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Bloque "${eliminado.titulo}" eliminado'),
              action: SnackBarAction(
                label: 'DESHACER',
                onPressed: () {
                  setState(() => _bloquesHorario.insert(index, eliminado));
                },
              ),
            ),
          );
        },
      ),

      // 3. Tercera interfaz: DIRECTORIO
      DirectorioScreen(
        profesores: _profesores,
        onCambiarDisponibilidad: (id, nuevoEstado) {
          setState(() {
            final idx = _profesores.indexWhere((p) => p.id == id);
            if (idx != -1) {
              _profesores[idx] = _profesores[idx].copyWith(
                disponibilidad: nuevoEstado,
              );
            }
          });
        },
        onAgregarProfesor: (nuevo) {
          setState(() => _profesores.add(nuevo));
        },
        onEliminarProfesor: (index) {
          final eliminado = _profesores[index];
          setState(() => _profesores.removeAt(index));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Profesor "${eliminado.nombre}" eliminado'),
              action: SnackBarAction(
                label: 'DESHACER',
                onPressed: () {
                  setState(() => _profesores.insert(index, eliminado));
                },
              ),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      body: pantallas[_pestanaActual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestanaActual,
        onDestinationSelected: (idx) => setState(() => _pestanaActual = idx),
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: const Color(0xFF026AA7).withValues(alpha: 0.14),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(
              Icons.meeting_room_rounded,
              color: Color(0xFF026AA7),
            ),
            label: 'Horario Salón',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(
              Icons.timeline_rounded,
              color: Color(0xFF026AA7),
            ),
            label: 'Horarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(
              Icons.badge_rounded,
              color: Color(0xFF026AA7),
            ),
            label: 'Directorio',
          ),
        ],
      ),
    );
  }
}
