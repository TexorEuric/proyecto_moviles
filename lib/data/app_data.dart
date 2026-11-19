import 'package:flutter/material.dart';

const kAzul = Color(0xFF0369A1);
const kFondo = Color(0xFFF1F5F9);

enum Estado { libre, enClase, asesoria, ocupado }

extension EstadoX on Estado {
  String get label => switch (this) {
        Estado.libre => 'Libre',
        Estado.enClase => 'En clase',
        Estado.asesoria => 'Asesoría',
        Estado.ocupado => 'Ocupado',
      };

  Color get color => switch (this) {
        Estado.libre => const Color(0xFF16A34A),
        Estado.enClase => const Color(0xFFF59E0B),
        Estado.asesoria => const Color(0xFFEA580C),
        Estado.ocupado => const Color(0xFFDC2626),
      };

  String get descripcion => switch (this) {
        Estado.libre => 'Disponible en cubículo para atender alumnos',
        Estado.enClase => 'Impartiendo clase en este momento',
        Estado.asesoria => 'Atendiendo una asesoría',
        Estado.ocupado => 'No disponible por el momento',
      };
}

class Curso {
  final String grupo, materia, lugar;
  Curso(this.grupo, this.materia, this.lugar);
}

enum TipoSlot { clase, libre, sinClase }

class Slot {
  String hora;
  TipoSlot tipo;
  String materia, grupo, lugar;

  Slot(this.hora, this.tipo, {this.materia = '', this.grupo = '', this.lugar = ''});

  Slot copy() => Slot(hora, tipo, materia: materia, grupo: grupo, lugar: lugar);

  /// Minutos desde medianoche (horas < 7 se toman como tarde: 01:30 => 13:30).
  int get minutos {
    final p = hora.split(':');
    var h = int.parse(p[0]);
    final m = int.parse(p[1]);
    if (h < 7) h += 12;
    return h * 60 + m;
  }

  /// Fin de la sesión (1 h 30 min después).
  String get fin {
    final total = minutos + 90;
    var h = (total ~/ 60) % 12;
    if (h == 0) h = 12;
    final m = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class Profesor {
  final String id, nombre, correo, academia;
  final List<String> materias;
  final int zona; // edificio en el mapa (1-4)
  final double dx, dy; // posición dentro del edificio (-1 a 1)
  final bool demoLive; // si es true, refleja los cambios del portal docente
  final Estado _estado;
  final String _ubicacion;

  Profesor({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.academia,
    required this.materias,
    required this.zona,
    this.dx = 0,
    this.dy = 0,
    this.demoLive = false,
    Estado estado = Estado.libre,
    String ubicacion = '',
  })  : _estado = estado,
        _ubicacion = ubicacion;

  Estado get estado => demoLive ? AppData.docenteEstado.value : _estado;
  String get ubicacion => demoLive ? AppData.docenteCubiculo.value : _ubicacion;
}

/// Datos de ejemplo en memoria. Sustituir por API / base de datos después.
class AppData {
  static const alumnoNombre = 'Juancho P.';

  // ---- Docente ----
  static final docenteEstado = ValueNotifier<Estado>(Estado.libre);
  static final docenteCubiculo = ValueNotifier<String>('Sala 2103');

  static final cursos = ValueNotifier<List<Curso>>([
    Curso('2CM2', 'F. Prog.', 'Lab. Cómputo 2'),
    Curso('3CM7', 'E. y Alg.', 'Salón 2105'),
    Curso('4CM1', 'Ing. Soft.', 'Salón 1204'),
  ]);

  static final Map<String, List<Slot>> horario = {
    'LUNES': [
      Slot('10:30', TipoSlot.clase, materia: 'F. Programación', grupo: '2CM2', lugar: 'Lab. Cómputo 2'),
      Slot('12:00', TipoSlot.clase, materia: 'E. y Alg.', grupo: '3CM7', lugar: 'Salón 2105'),
      Slot('01:30', TipoSlot.libre),
      Slot('03:00', TipoSlot.libre),
      Slot('03:30', TipoSlot.sinClase),
      Slot('04:30', TipoSlot.libre),
    ],
    'MARTES': [
      Slot('09:00', TipoSlot.clase, materia: 'Ing. Software', grupo: '4CM1', lugar: 'Salón 1204'),
      Slot('10:30', TipoSlot.libre),
      Slot('12:00', TipoSlot.libre),
    ],
    'MIÉRCOLES': [
      Slot('10:30', TipoSlot.clase, materia: 'F. Programación', grupo: '2CM2', lugar: 'Lab. Cómputo 2'),
      Slot('12:00', TipoSlot.libre),
    ],
    'JUEVES': [
      Slot('09:00', TipoSlot.clase, materia: 'Ing. Software', grupo: '4CM1', lugar: 'Salón 1204'),
      Slot('10:30', TipoSlot.libre),
    ],
    'VIERNES': [
      Slot('12:00', TipoSlot.clase, materia: 'E. y Alg.', grupo: '3CM7', lugar: 'Salón 2105'),
      Slot('01:30', TipoSlot.libre),
    ],
  };

  // ---- Alumno ----
  static final favoritos = ValueNotifier<Set<String>>({});

  static void toggleFavorito(String id) {
    final s = {...favoritos.value};
    if (s.contains(id)) {
      s.remove(id);
    } else {
      s.add(id);
    }
    favoritos.value = s;
  }

  static final List<Profesor> profesores = [
    Profesor(
      id: 'p1',
      nombre: 'Juan Pérez',
      correo: '123@gmail.com',
      academia: 'Ing. Sist. Computacionales',
      materias: ['F. Programación', 'E. y Alg.', 'Ing. Software'],
      zona: 4,
      dx: 0.3,
      dy: -0.2,
      demoLive: true, // este es el profesor del portal docente
    ),
    Profesor(
      id: 'p2',
      nombre: 'Pepe Armendiz',
      correo: 'pepe.armendiz@escuela.mx',
      academia: 'Ciencias Básicas',
      materias: ['Cálculo', 'Álgebra'],
      zona: 2,
      dx: -0.2,
      dy: 0.4,
      estado: Estado.ocupado,
      ubicacion: '2003',
    ),
    Profesor(
      id: 'p3',
      nombre: 'María López',
      correo: 'maria.lopez@escuela.mx',
      academia: 'Ing. Sist. Computacionales',
      materias: ['Bases de Datos', 'Redes'],
      zona: 1,
      dx: 0.1,
      dy: 0,
      estado: Estado.asesoria,
      ubicacion: '1002',
    ),
    Profesor(
      id: 'p4',
      nombre: 'Carlos Ruiz',
      correo: 'carlos.ruiz@escuela.mx',
      academia: 'Ciencias Básicas',
      materias: ['Física', 'Cálculo'],
      zona: 3,
      dx: -0.3,
      dy: 0.1,
      estado: Estado.enClase,
      ubicacion: '3004',
    ),
  ];
}