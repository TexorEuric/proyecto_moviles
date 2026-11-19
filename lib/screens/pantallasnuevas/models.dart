import 'package:flutter/material.dart';

/// ============================================================================
/// ARCHIVO 2: lib/models.dart
/// Modelos de datos globales compartidos por toda la aplicación:
/// Croquis Oficial ESCOM, Vista por Edificio (1-5), Horario Salón, Horarios,
/// Directorio (con filtro por Nombre, ID Academia, ID Materia y Paginación)
/// y Portal del Profesor.
/// ============================================================================

enum EstadoDisponibilidad {
  libre(
    etiqueta: 'Libre',
    descripcion: 'Disponible en cubículo o aula abierta',
    color: Color(0xFF16A34A),
    fondoSuave: Color(0xFFDCFCE7),
    icono: Icons.check_circle_rounded,
  ),
  enClase(
    etiqueta: 'En clase',
    descripcion: 'Impartiendo sesión académica frente a grupo',
    color: Color(0xFFF59E0B),
    fondoSuave: Color(0xFFFEF3C7),
    icono: Icons.school_rounded,
  ),
  asesoria(
    etiqueta: 'Asesoría',
    descripcion: 'Atendiendo asesoría o revisión de Trabajo Terminal',
    color: Color(0xFFEA580C),
    fondoSuave: Color(0xFFFFEDD5),
    icono: Icons.groups_rounded,
  ),
  ocupado(
    etiqueta: 'Ocupado',
    descripcion: 'No disponible temporalmente',
    color: Color(0xFFDC2626),
    fondoSuave: Color(0xFFFEE2E2),
    icono: Icons.do_not_disturb_on_rounded,
  );

  final String etiqueta;
  final String descripcion;
  final Color color;
  final Color fondoSuave;
  final IconData icono;

  const EstadoDisponibilidad({
    required this.etiqueta,
    required this.descripcion,
    required this.color,
    required this.fondoSuave,
    required this.icono,
  });
}

/// Catálogo de Academias / Departamentos para el desplegable (idAcademia)
class AcademiaItem {
  final String idAcademia;
  final String nombre;

  const AcademiaItem({
    required this.idAcademia,
    required this.nombre,
  });
}

/// Catálogo de Materias para el desplegable (idMateria)
class MateriaItem {
  final String idMateria;
  final String nombre;
  final String idAcademia;

  const MateriaItem({
    required this.idMateria,
    required this.nombre,
    required this.idAcademia,
  });
}

enum TipoEspacioEdificio {
  salon(
    etiquetaBoton: 'HORARIOS',
    iconoBoton: Icons.schedule_rounded,
    iconoEspacio: Icons.class_rounded,
    muestraEstado: true,
    abreDirectorio: false,
  ),
  cubiculoProfesores(
    etiquetaBoton: 'DIRECTORIO',
    iconoBoton: Icons.badge_rounded,
    iconoEspacio: Icons.groups_2_rounded,
    muestraEstado: false,
    abreDirectorio: true,
  ),
  laboratorio(
    etiquetaBoton: 'HORARIO',
    iconoBoton: Icons.biotech_rounded,
    iconoEspacio: Icons.computer_rounded,
    muestraEstado: true,
    abreDirectorio: false,
  ),
  departamento(
    etiquetaBoton: 'DIRECTORIO',
    iconoBoton: Icons.apartment_rounded,
    iconoEspacio: Icons.domain_rounded,
    muestraEstado: false,
    abreDirectorio: true,
  );

  final String etiquetaBoton;
  final IconData iconoBoton;
  final IconData iconoEspacio;
  final bool muestraEstado;
  final bool abreDirectorio;

  const TipoEspacioEdificio({
    required this.etiquetaBoton,
    required this.iconoBoton,
    required this.iconoEspacio,
    required this.muestraEstado,
    required this.abreDirectorio,
  });
}

class EspacioEdificio {
  final String codigo;
  final String titulo;
  final String? subtitulo;
  final String edificio;
  final String nivel;
  final TipoEspacioEdificio tipo;
  final bool estaLibre;
  final String profesorActual;
  final String horarioActual;
  final String materiaActual;
  final String grupoActual;

  const EspacioEdificio({
    required this.codigo,
    required this.titulo,
    this.subtitulo,
    required this.edificio,
    required this.nivel,
    required this.tipo,
    this.estaLibre = true,
    this.profesorActual = 'Juan Pérez',
    this.horarioActual = '10:30 - 12:00',
    this.materiaActual = 'Fundamentos de programación',
    this.grupoActual = '2CM2',
  });

  EspacioEdificio copyWith({
    String? codigo,
    String? titulo,
    String? subtitulo,
    String? edificio,
    String? nivel,
    TipoEspacioEdificio? tipo,
    bool? estaLibre,
    String? profesorActual,
    String? horarioActual,
    String? materiaActual,
    String? grupoActual,
  }) {
    return EspacioEdificio(
      codigo: codigo ?? this.codigo,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      edificio: edificio ?? this.edificio,
      nivel: nivel ?? this.nivel,
      tipo: tipo ?? this.tipo,
      estaLibre: estaLibre ?? this.estaLibre,
      profesorActual: profesorActual ?? this.profesorActual,
      horarioActual: horarioActual ?? this.horarioActual,
      materiaActual: materiaActual ?? this.materiaActual,
      grupoActual: grupoActual ?? this.grupoActual,
    );
  }
}

class BloqueTimelineSalon {
  final String id;
  final String horaInicio;
  final String horaFin;
  final String titulo;
  final String? profesor;
  final String? grupo;
  final bool esReceso;
  final bool esHoraLibre;

  const BloqueTimelineSalon({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.titulo,
    this.profesor,
    this.grupo,
    this.esReceso = false,
    this.esHoraLibre = false,
  });

  BloqueTimelineSalon copyWith({
    String? horaInicio,
    String? horaFin,
    String? titulo,
    String? profesor,
    String? grupo,
    bool? esReceso,
    bool? esHoraLibre,
  }) {
    return BloqueTimelineSalon(
      id: id,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      titulo: titulo ?? this.titulo,
      profesor: profesor ?? this.profesor,
      grupo: grupo ?? this.grupo,
      esReceso: esReceso ?? this.esReceso,
      esHoraLibre: esHoraLibre ?? this.esHoraLibre,
    );
  }
}

/// Modelo de Profesor con Apellidos, Nombres, idAcademia y lista de idMaterias
/// para soportar ordenamiento alfabético por apellidos y filtros combinados.
class ProfesorDirectorio {
  final String id;
  final String nombres;
  final String apellidos;
  final String idAcademia;
  final String departamento;
  final List<String> idsMateriasActivas;
  final List<String> nombresMateriasActivas;
  final String cubiculo;
  final String edificioUbicacion;
  final String nivelUbicacion;
  final int moduloVertical;
  final String correo;
  final EstadoDisponibilidad disponibilidad;
  final bool esFavorito;

  const ProfesorDirectorio({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.idAcademia,
    required this.departamento,
    this.idsMateriasActivas = const [],
    this.nombresMateriasActivas = const [],
    required this.cubiculo,
    required this.edificioUbicacion,
    this.nivelUbicacion = 'Primer Piso',
    this.moduloVertical = 1,
    required this.correo,
    required this.disponibilidad,
    this.esFavorito = false,
  });

  /// Nombre en formato "Nombre Apellido" (ej. Juan Pérez)
  String get nombre => '$nombres $apellidos';

  /// Nombre empezando por apellidos para orden alfabético (ej. Pérez, Juan)
  String get nombrePorApellidos => '$apellidos, $nombres';

  ProfesorDirectorio copyWith({
    String? nombres,
    String? apellidos,
    String? idAcademia,
    String? departamento,
    List<String>? idsMateriasActivas,
    List<String>? nombresMateriasActivas,
    String? cubiculo,
    String? edificioUbicacion,
    String? nivelUbicacion,
    int? moduloVertical,
    String? correo,
    EstadoDisponibilidad? disponibilidad,
    bool? esFavorito,
  }) {
    return ProfesorDirectorio(
      id: id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      idAcademia: idAcademia ?? this.idAcademia,
      departamento: departamento ?? this.departamento,
      idsMateriasActivas: idsMateriasActivas ?? this.idsMateriasActivas,
      nombresMateriasActivas:
          nombresMateriasActivas ?? this.nombresMateriasActivas,
      cubiculo: cubiculo ?? this.cubiculo,
      edificioUbicacion: edificioUbicacion ?? this.edificioUbicacion,
      nivelUbicacion: nivelUbicacion ?? this.nivelUbicacion,
      moduloVertical: moduloVertical ?? this.moduloVertical,
      correo: correo ?? this.correo,
      disponibilidad: disponibilidad ?? this.disponibilidad,
      esFavorito: esFavorito ?? this.esFavorito,
    );
  }
}

class CursoProfesor {
  final String id;
  final String nombreCorto;
  final String nombreCompleto;
  final String grupo;
  final String aula;

  const CursoProfesor({
    required this.id,
    required this.nombreCorto,
    required this.nombreCompleto,
    required this.grupo,
    this.aula = 'Salón 2001',
  });
}

class BloqueHorarioProfesor {
  final String hora;
  final String? materia;
  final String? grupo;
  final bool estaLibreParaAsesoria;

  const BloqueHorarioProfesor({
    required this.hora,
    this.materia,
    this.grupo,
    this.estaLibreParaAsesoria = true,
  });

  bool get tieneClase => materia != null && materia!.trim().isNotEmpty;

  BloqueHorarioProfesor copyWith({
    String? hora,
    String? materia,
    String? grupo,
    bool limpiarMateria = false,
    bool? estaLibreParaAsesoria,
  }) {
    return BloqueHorarioProfesor(
      hora: hora ?? this.hora,
      materia: limpiarMateria ? null : (materia ?? this.materia),
      grupo: limpiarMateria ? null : (grupo ?? this.grupo),
      estaLibreParaAsesoria:
          estaLibreParaAsesoria ?? this.estaLibreParaAsesoria,
    );
  }
}

/// Calcula los códigos de salón según edificio (1-5) y piso (0=PB, 1=Piso 1, 2=Piso 2)
class NomenclaturaEscom {
  static String digitoEdificio(String edificio) {
    if (edificio.contains('1')) return '1';
    if (edificio.contains('2')) return '2';
    if (edificio.contains('3')) return '3';
    if (edificio.contains('4')) return '4';
    if (edificio.contains('5')) return '5';
    return '2';
  }

  static String digitoNivel(String nivel) {
    if (nivel == 'Planta Baja') return '0';
    if (nivel == 'Primer Piso') return '1';
    if (nivel == 'Segundo Piso') return '2';
    return '0';
  }

  static String formarCodigo(String edificio, String nivel, int numeroSalon) {
    final numStr = numeroSalon.toString().padLeft(2, '0');
    return '${digitoEdificio(edificio)}${digitoNivel(nivel)}$numStr';
  }
}