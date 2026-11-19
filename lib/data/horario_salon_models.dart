import 'package:flutter/material.dart';

/// Estados de disponibilidad para los profesores en el directorio de horarios.
enum EstadoDisponibilidad {
  libre(
    etiqueta: 'Libre',
    color: Color(0xFF16A34A),
    fondoSuave: Color(0xFFDCFCE7),
  ),
  enClase(
    etiqueta: 'En clase',
    color: Color(0xFFF59E0B),
    fondoSuave: Color(0xFFFEF3C7),
  ),
  asesoria(
    etiqueta: 'Asesoría',
    color: Color(0xFFEA580C),
    fondoSuave: Color(0xFFFFEDD5),
  ),
  ocupado(
    etiqueta: 'Ocupado',
    color: Color(0xFFDC2626),
    fondoSuave: Color(0xFFFEE2E2),
  );

  final String etiqueta;
  final Color color;
  final Color fondoSuave;

  const EstadoDisponibilidad({
    required this.etiqueta,
    required this.color,
    required this.fondoSuave,
  });
}

/// Modelo para cada bloque en la pantalla de HORARIOS (línea de tiempo del salón).
class BloqueTimelineSalon {
  final String id;
  final String horaInicio;
  final String horaFin;
  final String titulo;
  final String? profesor;
  final bool esReceso;
  final bool esHoraLibre;

  const BloqueTimelineSalon({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.titulo,
    this.profesor,
    this.esReceso = false,
    this.esHoraLibre = false,
  });

  BloqueTimelineSalon copyWith({
    String? horaInicio,
    String? horaFin,
    String? titulo,
    String? profesor,
    bool? esReceso,
    bool? esHoraLibre,
  }) {
    return BloqueTimelineSalon(
      id: id,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      titulo: titulo ?? this.titulo,
      profesor: profesor ?? this.profesor,
      esReceso: esReceso ?? this.esReceso,
      esHoraLibre: esHoraLibre ?? this.esHoraLibre,
    );
  }
}

/// Modelo para cada profesor en la pantalla de DIRECTORIO de departamento.
class ProfesorDirectorio {
  final String id;
  final String nombre;
  final String departamento;
  final EstadoDisponibilidad disponibilidad;

  const ProfesorDirectorio({
    required this.id,
    required this.nombre,
    required this.departamento,
    this.disponibilidad = EstadoDisponibilidad.libre,
  });

  ProfesorDirectorio copyWith({
    String? nombre,
    String? departamento,
    EstadoDisponibilidad? disponibilidad,
  }) {
    return ProfesorDirectorio(
      id: id,
      nombre: nombre ?? this.nombre,
      departamento: departamento ?? this.departamento,
      disponibilidad: disponibilidad ?? this.disponibilidad,
    );
  }
}
