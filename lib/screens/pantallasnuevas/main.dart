import 'dart:async';
import 'package:flutter/material.dart';

import 'models.dart';
import 'croquis_screen.dart';
import 'edificio_screen.dart';
import 'horario_salon_screen.dart';
import 'horarios_screen.dart';
import 'directorio_screen.dart';
import 'profesor_screen.dart';

/// ============================================================================
/// ARCHIVO 1: lib/main.dart
/// Punto de entrada principal que abre en el Mapa Virtual (Croquis Oficial
/// ESCOM), conecta la lupa con el Directorio paginado de 10 en 10 (con filtros
/// por Nombre/Apellido, ID Academia e ID Materia) e integra Edificios, Salón,
/// Horarios y Profesor.
/// ============================================================================

void main() {
  runApp(const EscomIntegralApp());
}

class EscomIntegralApp extends StatelessWidget {
  const EscomIntegralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Croquis y Directorio ESCOM - IPN',
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
      home: const HubPrincipalUnificado(),
    );
  }
}

class HubPrincipalUnificado extends StatefulWidget {
  const HubPrincipalUnificado({super.key});

  @override
  State<HubPrincipalUnificado> createState() => _HubPrincipalUnificadoState();
}

class _HubPrincipalUnificadoState extends State<HubPrincipalUnificado> {
  // Inicia en 0 (Mapa Virtual / Croquis ESCOM) tal como se solicitó
  int _indiceModulo = 0;
  bool _mostrandoTimelineSalon = false;

  late DateTime _fechaHoraDispositivo;
  Timer? _relojTimer;

  ProfesorDirectorio? _profesorUbicadoEnMapa;

  String _edificioSeleccionado = 'Edificio 2';
  String _nivelSeleccionado = 'Planta Baja';
  String _codigoEspacioSeleccionado = '2001';

  late List<EspacioEdificio> _todosLosEspacios;

  // Catálogo de Academias para el primer desplegable (idAcademia)
  final List<AcademiaItem> _catalogoAcademias = const [
    AcademiaItem(
      idAcademia: 'ISC',
      nombre: 'Dpto. Ing. Sistemas Computacionales',
    ),
    AcademiaItem(
      idAcademia: 'CB',
      nombre: 'Dpto. Ciencias Básicas',
    ),
    AcademiaItem(
      idAcademia: 'CC',
      nombre: 'Dpto. Ciencias de la Computación',
    ),
    AcademiaItem(
      idAcademia: 'IA',
      nombre: 'Dpto. Ciencia de Datos e IA',
    ),
    AcademiaItem(
      idAcademia: 'ISW',
      nombre: 'Academia de Ingeniería de Software',
    ),
  ];

  // Catálogo de Materias para el segundo desplegable (idMateria)
  final List<MateriaItem> _catalogoMaterias = const [
    MateriaItem(
      idMateria: 'MAT_ALG',
      nombre: 'Álgebra Lineal',
      idAcademia: 'CB',
    ),
    MateriaItem(
      idMateria: 'MAT_CAL',
      nombre: 'Cálculo Aplicado',
      idAcademia: 'CB',
    ),
    MateriaItem(
      idMateria: 'MAT_FP',
      nombre: 'Fundamentos de Programación',
      idAcademia: 'ISC',
    ),
    MateriaItem(
      idMateria: 'MAT_EDA',
      nombre: 'Estructuras y Algoritmos',
      idAcademia: 'CC',
    ),
    MateriaItem(
      idMateria: 'MAT_SO',
      nombre: 'Sistemas Operativos',
      idAcademia: 'ISC',
    ),
    MateriaItem(
      idMateria: 'MAT_ISW',
      nombre: 'Ingeniería de Software',
      idAcademia: 'ISW',
    ),
    MateriaItem(
      idMateria: 'MAT_BD',
      nombre: 'Bases de Datos',
      idAcademia: 'ISC',
    ),
    MateriaItem(
      idMateria: 'MAT_IA',
      nombre: 'Inteligencia Artificial',
      idAcademia: 'IA',
    ),
  ];

  final List<BloqueTimelineSalon> _bloquesTimeline = [
    const BloqueTimelineSalon(
      id: 'b1',
      horaInicio: '7:00',
      horaFin: '8:30',
      titulo: 'Materia 1',
      profesor: 'Prof. Alexis Pérez',
      grupo: '3CM4',
    ),
    const BloqueTimelineSalon(
      id: 'b2',
      horaInicio: '8:30',
      horaFin: '10:00',
      titulo: 'Materia 1',
      profesor: 'Prof. Alexis Pérez',
      grupo: '2CM1',
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
      grupo: '2CM2',
    ),
  ];

  // Base de datos con 24 profesores para demostrar la paginación de 10 en 10
  // (3 páginas: 1..10, 11..20 y 21..24) y los filtros combinados
  late List<ProfesorDirectorio> _profesores;

  EstadoDisponibilidad _disponibilidadProfesor = EstadoDisponibilidad.libre;
  String _cubiculoProfesor = 'Sala 1002';

  final List<CursoProfesor> _cursosProfesor = [
    const CursoProfesor(
      id: 'c1',
      nombreCorto: 'F. Prog.',
      nombreCompleto: 'Fundamentos de Programación',
      grupo: '2CM2',
      aula: 'Salón 2001',
    ),
    const CursoProfesor(
      id: 'c2',
      nombreCorto: 'E. y Alg.',
      nombreCompleto: 'Estructuras y Algoritmos',
      grupo: '3CM7',
      aula: 'Salón 1103',
    ),
    const CursoProfesor(
      id: 'c3',
      nombreCorto: 'Ing. Soft.',
      nombreCompleto: 'Ingeniería de Software',
      grupo: '4CM1',
      aula: 'Salón 3201',
    ),
  ];

  Map<String, List<BloqueHorarioProfesor>> _horariosProfesorPorDia = {
    'LUNES': const [
      BloqueHorarioProfesor(
        hora: '10:30',
        materia: 'F. Programación',
        grupo: '2CM2',
      ),
      BloqueHorarioProfesor(
        hora: '12:00',
        materia: 'E. y Alg.',
        grupo: '3CM7',
      ),
      BloqueHorarioProfesor(hora: '01:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:00', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:30', estaLibreParaAsesoria: false),
      BloqueHorarioProfesor(hora: '04:30', estaLibreParaAsesoria: true),
    ],
    'MARTES': const [
      BloqueHorarioProfesor(hora: '10:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(
        hora: '12:00',
        materia: 'Ing. Software',
        grupo: '4CM1',
      ),
      BloqueHorarioProfesor(
        hora: '01:30',
        materia: 'F. Programación',
        grupo: '2CM2',
      ),
      BloqueHorarioProfesor(hora: '03:00', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:30', estaLibreParaAsesoria: false),
      BloqueHorarioProfesor(hora: '04:30', estaLibreParaAsesoria: true),
    ],
    'MIÉRCOLES': const [
      BloqueHorarioProfesor(
        hora: '10:30',
        materia: 'F. Programación',
        grupo: '2CM2',
      ),
      BloqueHorarioProfesor(
        hora: '12:00',
        materia: 'E. y Alg.',
        grupo: '3CM7',
      ),
      BloqueHorarioProfesor(hora: '01:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:00', estaLibreParaAsesoria: false),
      BloqueHorarioProfesor(hora: '03:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '04:30', estaLibreParaAsesoria: true),
    ],
    'JUEVES': const [
      BloqueHorarioProfesor(hora: '10:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(
        hora: '12:00',
        materia: 'Ing. Software',
        grupo: '4CM1',
      ),
      BloqueHorarioProfesor(hora: '01:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:00', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:30', estaLibreParaAsesoria: false),
      BloqueHorarioProfesor(hora: '04:30', estaLibreParaAsesoria: true),
    ],
    'VIERNES': const [
      BloqueHorarioProfesor(
        hora: '10:30',
        materia: 'E. y Alg.',
        grupo: '3CM7',
      ),
      BloqueHorarioProfesor(hora: '12:00', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '01:30', estaLibreParaAsesoria: true),
      BloqueHorarioProfesor(hora: '03:00', estaLibreParaAsesoria: false),
      BloqueHorarioProfesor(hora: '03:30', estaLibreParaAsesoria: false),
      BloqueHorarioProfesor(hora: '04:30', estaLibreParaAsesoria: true),
    ],
  };

  @override
  void initState() {
    super.initState();
    _todosLosEspacios = _construirEspaciosTodosLosEdificiosYPisos();
    _profesores = _construirBaseDatosProfesores();
    _profesorUbicadoEnMapa = _profesores.firstWhere((p) => p.id == 'p3');
    _fechaHoraDispositivo = DateTime.now();
    _relojTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _fechaHoraDispositivo = DateTime.now();
        });
      }
    });
  }

  List<ProfesorDirectorio> _construirBaseDatosProfesores() {
    return const [
      ProfesorDirectorio(
        id: 'p1',
        nombres: 'Juan',
        apellidos: 'Díaz',
        idAcademia: 'ISC',
        departamento: 'Dpto. Ing. Sist. C.',
        idsMateriasActivas: ['MAT_FP', 'MAT_BD'],
        nombresMateriasActivas: ['Fundamentos de Programación', 'Bases de Datos'],
        cubiculo: 'Sala 2103',
        edificioUbicacion: 'Edificio 2',
        nivelUbicacion: 'Primer Piso',
        correo: 'jdiaz@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
        esFavorito: true,
      ),
      ProfesorDirectorio(
        id: 'p2',
        nombres: 'Pepe',
        apellidos: 'Armendiz',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_ALG', 'MAT_CAL'],
        nombresMateriasActivas: ['Álgebra Lineal', 'Cálculo Aplicado'],
        cubiculo: 'Sala 1104',
        edificioUbicacion: 'Edificio 1',
        nivelUbicacion: 'Primer Piso',
        correo: 'parmendiz@ipn.mx',
        disponibilidad: EstadoDisponibilidad.enClase,
        esFavorito: true,
      ),
      ProfesorDirectorio(
        id: 'p3',
        nombres: 'Juan',
        apellidos: 'Pérez',
        idAcademia: 'ISC',
        departamento: 'Dpto. Ing. Sist. C.',
        idsMateriasActivas: ['MAT_FP', 'MAT_SO'],
        nombresMateriasActivas: [
          'Fundamentos de Programación',
          'Sistemas Operativos',
        ],
        cubiculo: 'Sala 1002',
        edificioUbicacion: 'Edificio 1',
        nivelUbicacion: 'Planta Baja',
        correo: '123@gmail.com',
        disponibilidad: EstadoDisponibilidad.libre,
        esFavorito: true,
      ),
      ProfesorDirectorio(
        id: 'p4',
        nombres: 'Alexis',
        apellidos: 'Pérez',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_ALG', 'MAT_EDA'],
        nombresMateriasActivas: ['Álgebra Lineal', 'Estructuras y Algoritmos'],
        cubiculo: 'Sala 3202',
        edificioUbicacion: 'Edificio 3',
        nivelUbicacion: 'Segundo Piso',
        correo: 'aperez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.asesoria,
      ),
      ProfesorDirectorio(
        id: 'p5',
        nombres: 'Elena',
        apellidos: 'Aguilar Soto',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_ALG'],
        nombresMateriasActivas: ['Álgebra Lineal'],
        cubiculo: 'Sala 1102',
        edificioUbicacion: 'Edificio 1',
        correo: 'eaguilar@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p6',
        nombres: 'Roberto',
        apellidos: 'Bautista Mora',
        idAcademia: 'CC',
        departamento: 'Dpto. Ciencias de la Computación',
        idsMateriasActivas: ['MAT_EDA'],
        nombresMateriasActivas: ['Estructuras y Algoritmos'],
        cubiculo: 'Sala 2204',
        edificioUbicacion: 'Edificio 2',
        correo: 'rbautista@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p7',
        nombres: ' Sofía',
        apellidos: 'Cervantes Luna',
        idAcademia: 'IA',
        departamento: 'Dpto. Ciencia de Datos e IA',
        idsMateriasActivas: ['MAT_IA'],
        nombresMateriasActivas: ['Inteligencia Artificial'],
        cubiculo: 'Sala 4102',
        edificioUbicacion: 'Edificio 4',
        correo: 'scervantes@ipn.mx',
        disponibilidad: EstadoDisponibilidad.enClase,
      ),
      ProfesorDirectorio(
        id: 'p8',
        nombres: 'Fernando',
        apellidos: 'Domínguez Ríos',
        idAcademia: 'ISW',
        departamento: 'Academia de Ingeniería de Software',
        idsMateriasActivas: ['MAT_ISW'],
        nombresMateriasActivas: ['Ingeniería de Software'],
        cubiculo: 'Sala 3104',
        edificioUbicacion: 'Edificio 3',
        correo: 'fdominguez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p9',
        nombres: 'Gabriela',
        apellidos: 'Estrada Vega',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_CAL'],
        nombresMateriasActivas: ['Cálculo Aplicado'],
        cubiculo: 'Sala 1205',
        edificioUbicacion: 'Edificio 1',
        correo: 'gestrada@ipn.mx',
        disponibilidad: EstadoDisponibilidad.ocupado,
      ),
      ProfesorDirectorio(
        id: 'p10',
        nombres: 'Héctor',
        apellidos: 'Flores Méndez',
        idAcademia: 'ISC',
        departamento: 'Dpto. Ing. Sist. C.',
        idsMateriasActivas: ['MAT_BD', 'MAT_SO'],
        nombresMateriasActivas: ['Bases de Datos', 'Sistemas Operativos'],
        cubiculo: 'Sala 2002',
        edificioUbicacion: 'Edificio 2',
        correo: 'hflores@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p11',
        nombres: 'Lucía',
        apellidos: 'Gómez Pineda',
        idAcademia: 'IA',
        departamento: 'Dpto. Ciencia de Datos e IA',
        idsMateriasActivas: ['MAT_IA', 'MAT_ALG'],
        nombresMateriasActivas: ['Inteligencia Artificial', 'Álgebra Lineal'],
        cubiculo: 'Sala 4201',
        edificioUbicacion: 'Edificio 4',
        correo: 'lgomez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p12',
        nombres: 'Miguel',
        apellidos: 'Hernández Cruz',
        idAcademia: 'ISC',
        departamento: 'Dpto. Ing. Sist. C.',
        idsMateriasActivas: ['MAT_FP'],
        nombresMateriasActivas: ['Fundamentos de Programación'],
        cubiculo: 'Sala 2108',
        edificioUbicacion: 'Edificio 2',
        correo: 'mhernandez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.enClase,
      ),
      ProfesorDirectorio(
        id: 'p13',
        nombres: 'Patricia',
        apellidos: 'Ibarra Salazar',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_ALG', 'MAT_CAL'],
        nombresMateriasActivas: ['Álgebra Lineal', 'Cálculo Aplicado'],
        cubiculo: 'Sala 1008',
        edificioUbicacion: 'Edificio 1',
        correo: 'pibarra@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p14',
        nombres: 'Ricardo',
        apellidos: 'Juárez Ortega',
        idAcademia: 'CC',
        departamento: 'Dpto. Ciencias de la Computación',
        idsMateriasActivas: ['MAT_EDA'],
        nombresMateriasActivas: ['Estructuras y Algoritmos'],
        cubiculo: 'Sala 3002',
        edificioUbicacion: 'Edificio 3',
        correo: 'rjuarez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.asesoria,
      ),
      ProfesorDirectorio(
        id: 'p15',
        nombres: 'Valeria',
        apellidos: 'López Cano',
        idAcademia: 'ISW',
        departamento: 'Academia de Ingeniería de Software',
        idsMateriasActivas: ['MAT_ISW', 'MAT_BD'],
        nombresMateriasActivas: ['Ingeniería de Software', 'Bases de Datos'],
        cubiculo: 'Sala 3108',
        edificioUbicacion: 'Edificio 3',
        correo: 'vlopez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p16',
        nombres: 'Arturo',
        apellidos: 'Martínez Solís',
        idAcademia: 'ISC',
        departamento: 'Dpto. Ing. Sist. C.',
        idsMateriasActivas: ['MAT_SO'],
        nombresMateriasActivas: ['Sistemas Operativos'],
        cubiculo: 'Sala 2209',
        edificioUbicacion: 'Edificio 2',
        correo: 'amartinez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.ocupado,
      ),
      ProfesorDirectorio(
        id: 'p17',
        nombres: 'Claudia',
        apellidos: 'Nava Trejo',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_ALG'],
        nombresMateriasActivas: ['Álgebra Lineal'],
        cubiculo: 'Sala 1109',
        edificioUbicacion: 'Edificio 1',
        correo: 'cnava@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p18',
        nombres: 'Óscar',
        apellidos: 'Ortiz Rangel',
        idAcademia: 'IA',
        departamento: 'Dpto. Ciencia de Datos e IA',
        idsMateriasActivas: ['MAT_IA'],
        nombresMateriasActivas: ['Inteligencia Artificial'],
        cubiculo: 'Sala 5102',
        edificioUbicacion: 'Edificio 5',
        correo: 'oortiz@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p19',
        nombres: 'Daniela',
        apellidos: 'Pérez Montes',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_CAL', 'MAT_ALG'],
        nombresMateriasActivas: ['Cálculo Aplicado', 'Álgebra Lineal'],
        cubiculo: 'Sala 1202',
        edificioUbicacion: 'Edificio 1',
        correo: 'dperez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p20',
        nombres: 'Sergio',
        apellidos: 'Quintana Ruiz',
        idAcademia: 'CC',
        departamento: 'Dpto. Ciencias de la Computación',
        idsMateriasActivas: ['MAT_EDA', 'MAT_FP'],
        nombresMateriasActivas: [
          'Estructuras y Algoritmos',
          'Fundamentos de Programación',
        ],
        cubiculo: 'Sala 2010',
        edificioUbicacion: 'Edificio 2',
        correo: 'squintana@ipn.mx',
        disponibilidad: EstadoDisponibilidad.enClase,
      ),
      ProfesorDirectorio(
        id: 'p21',
        nombres: 'Mónica',
        apellidos: 'Ramírez Acosta',
        idAcademia: 'ISW',
        departamento: 'Academia de Ingeniería de Software',
        idsMateriasActivas: ['MAT_ISW'],
        nombresMateriasActivas: ['Ingeniería de Software'],
        cubiculo: 'Sala 3208',
        edificioUbicacion: 'Edificio 3',
        correo: 'mramirez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p22',
        nombres: 'Alejandro',
        apellidos: 'Sánchez Villa',
        idAcademia: 'ISC',
        departamento: 'Dpto. Ing. Sist. C.',
        idsMateriasActivas: ['MAT_BD'],
        nombresMateriasActivas: ['Bases de Datos'],
        cubiculo: 'Sala 2112',
        edificioUbicacion: 'Edificio 2',
        correo: 'asanchez@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
      ProfesorDirectorio(
        id: 'p23',
        nombres: 'Beatriz',
        apellidos: 'Torres Lara',
        idAcademia: 'CB',
        departamento: 'Dpto. Ciencias Básicas',
        idsMateriasActivas: ['MAT_CAL'],
        nombresMateriasActivas: ['Cálculo Aplicado'],
        cubiculo: 'Sala 1012',
        edificioUbicacion: 'Edificio 1',
        correo: 'btorres@ipn.mx',
        disponibilidad: EstadoDisponibilidad.asesoria,
      ),
      ProfesorDirectorio(
        id: 'p24',
        nombres: 'Jorge',
        apellidos: 'Vargas Nieto',
        idAcademia: 'IA',
        departamento: 'Dpto. Ciencia de Datos e IA',
        idsMateriasActivas: ['MAT_IA'],
        nombresMateriasActivas: ['Inteligencia Artificial'],
        cubiculo: 'Sala 5004',
        edificioUbicacion: 'Edificio 5',
        correo: 'jvargas@ipn.mx',
        disponibilidad: EstadoDisponibilidad.libre,
      ),
    ];
  }

  List<EspacioEdificio> _construirEspaciosTodosLosEdificiosYPisos() {
    final List<EspacioEdificio> resultado = [];
    const edificios = [
      'Edificio 1',
      'Edificio 2',
      'Edificio 3',
      'Edificio 4',
      'Edificio 5',
    ];
    const niveles = ['Planta Baja', 'Primer Piso', 'Segundo Piso'];

    for (final edif in edificios) {
      for (final niv in niveles) {
        for (int numSalon = 1; numSalon <= 14; numSalon++) {
          final codigo = NomenclaturaEscom.formarCodigo(edif, niv, numSalon);

          if (numSalon == 1) {
            resultado.add(
              EspacioEdificio(
                codigo: codigo,
                titulo: 'SALÓN',
                edificio: edif,
                nivel: niv,
                tipo: TipoEspacioEdificio.salon,
                estaLibre: true,
                profesorActual: 'Juan Pérez',
                horarioActual: '10:30 - 12:00',
                materiaActual: 'Fundamentos de programación',
                grupoActual: '2CM2',
              ),
            );
          } else if (numSalon == 2) {
            resultado.add(
              EspacioEdificio(
                codigo: codigo,
                titulo: 'CUBÍCULO\nPROFESORES',
                edificio: edif,
                nivel: niv,
                tipo: TipoEspacioEdificio.cubiculoProfesores,
                estaLibre: true,
              ),
            );
          } else if (numSalon == 3) {
            resultado.add(
              EspacioEdificio(
                codigo: codigo,
                titulo: 'LABORATORIO',
                edificio: edif,
                nivel: niv,
                tipo: TipoEspacioEdificio.laboratorio,
                estaLibre: true,
                profesorActual: 'Alexis Pérez',
                horarioActual: '08:30 - 10:00',
                materiaActual: 'Estructuras y Algoritmos',
                grupoActual: '3CM7',
              ),
            );
          } else if (numSalon == 4) {
            resultado.add(
              EspacioEdificio(
                codigo: codigo,
                titulo: 'DEPARTAMENTO',
                subtitulo: 'UNIDAD DE INF.',
                edificio: edif,
                nivel: niv,
                tipo: TipoEspacioEdificio.departamento,
                estaLibre: true,
              ),
            );
          } else {
            resultado.add(
              EspacioEdificio(
                codigo: codigo,
                titulo: 'SALÓN',
                edificio: edif,
                nivel: niv,
                tipo: TipoEspacioEdificio.salon,
                estaLibre: numSalon.isOdd,
                profesorActual:
                    numSalon.isEven ? 'Pepe Armendiz' : 'Juan Díaz',
                horarioActual: '12:00 - 13:30',
                materiaActual: numSalon.isEven
                    ? 'Cálculo Aplicado'
                    : 'Ingeniería de Software',
                grupoActual:
                    '${NomenclaturaEscom.digitoEdificio(edif)}CM$numSalon',
              ),
            );
          }
        }
      }
    }
    return resultado;
  }

  List<EspacioEdificio> get _espaciosFiltradosPorEdificioYPiso {
    return _todosLosEspacios
        .where(
          (e) =>
              e.edificio == _edificioSeleccionado &&
              e.nivel == _nivelSeleccionado,
        )
        .toList();
  }

  EspacioEdificio get _espacioActualSeleccionado {
    final lista = _espaciosFiltradosPorEdificioYPiso;
    if (lista.isEmpty) return _todosLosEspacios.first;
    final coincidente = lista.where(
      (e) => e.codigo == _codigoEspacioSeleccionado,
    );
    if (coincidente.isNotEmpty) return coincidente.first;
    return lista.first;
  }

  void _cambiarEdificioONivel({String? nuevoEdificio, String? nuevoNivel}) {
    setState(() {
      final edif = nuevoEdificio ?? _edificioSeleccionado;
      final niv = nuevoNivel ?? _nivelSeleccionado;

      int terminacion = 1;
      if (_codigoEspacioSeleccionado.length >= 2) {
        terminacion = int.tryParse(
              _codigoEspacioSeleccionado.substring(
                _codigoEspacioSeleccionado.length - 2,
              ),
            ) ??
            1;
      }

      _edificioSeleccionado = edif;
      _nivelSeleccionado = niv;
      _codigoEspacioSeleccionado =
          NomenclaturaEscom.formarCodigo(edif, niv, terminacion);
    });
  }

  @override
  void dispose() {
    _relojTimer?.cancel();
    super.dispose();
  }

  String get _horaFormateadaDispositivo {
    final h = _fechaHoraDispositivo.hour.toString().padLeft(2, '0');
    final m = _fechaHoraDispositivo.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _segundosFormateadosDispositivo {
    return _fechaHoraDispositivo.second.toString().padLeft(2, '0');
  }

  void _actualizarEstadoProfesorGlobal(
    EstadoDisponibilidad nuevoEstado, {
    String? nuevoCubiculo,
  }) {
    setState(() {
      _disponibilidadProfesor = nuevoEstado;
      if (nuevoCubiculo != null) {
        _cubiculoProfesor = nuevoCubiculo;
      }
      final idx = _profesores.indexWhere((p) => p.id == 'p3');
      if (idx != -1) {
        _profesores[idx] = _profesores[idx].copyWith(
          disponibilidad: nuevoEstado,
          cubiculo: nuevoCubiculo ?? _profesores[idx].cubiculo,
        );
        if (_profesorUbicadoEnMapa?.id == 'p3') {
          _profesorUbicadoEnMapa = _profesores[idx];
        }
      }
    });
  }

  void _seleccionarEdificioDesdeCroquis(String nombreEdificio) {
    final edifNormalizado = nombreEdificio == 'Edificio 5'
        ? 'Edificio 4'
        : nombreEdificio;
    _cambiarEdificioONivel(
      nuevoEdificio: edifNormalizado,
      nuevoNivel: 'Planta Baja',
    );
    setState(() {
      _codigoEspacioSeleccionado =
          NomenclaturaEscom.formarCodigo(edifNormalizado, 'Planta Baja', 1);
      _indiceModulo = 1;
    });
  }

  void _ubicarProfesorEnCroquis(ProfesorDirectorio profesor) {
    setState(() {
      _profesorUbicadoEnMapa = profesor;
      _indiceModulo = 0;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        content: Text(
          'Ubicando a ${profesor.nombre} en ${profesor.edificioUbicacion} (${profesor.cubiculo})',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final espaciosDelPiso = _espaciosFiltradosPorEdificioYPiso;
    final espacioActual = _espacioActualSeleccionado;
    final indiceEnPiso = espaciosDelPiso
        .indexWhere((e) => e.codigo == espacioActual.codigo)
        .clamp(0, espaciosDelPiso.isEmpty ? 0 : espaciosDelPiso.length - 1);

    Widget cuerpoActivo;

    if (_indiceModulo == 0) {
      cuerpoActivo = CroquisEscomScreen(
        profesores: _profesores,
        profesorUbicado: _profesorUbicadoEnMapa,
        horaOficial: _horaFormateadaDispositivo,
        onSeleccionarEdificio: _seleccionarEdificioDesdeCroquis,
        onIrADirectorio: () => setState(() => _indiceModulo = 3),
        onUbicarProfesor: _ubicarProfesorEnCroquis,
        onToggleFavorito: (id) {
          setState(() {
            final idx = _profesores.indexWhere((p) => p.id == id);
            if (idx != -1) {
              _profesores[idx] = _profesores[idx].copyWith(
                esFavorito: !_profesores[idx].esFavorito,
              );
            }
          });
        },
      );
    } else if (_indiceModulo == 1) {
      cuerpoActivo = VistaPorEdificioScreen(
        edificioSeleccionado: _edificioSeleccionado,
        nivelSeleccionado: _nivelSeleccionado,
        espaciosDelPiso: espaciosDelPiso,
        indiceSeleccionado: indiceEnPiso,
        horaOficial: _horaFormateadaDispositivo,
        onIrACroquis: () => setState(() => _indiceModulo = 0),
        onEdificioChanged: (nuevoEdif) =>
            _cambiarEdificioONivel(nuevoEdificio: nuevoEdif),
        onNivelChanged: (nuevoNiv) =>
            _cambiarEdificioONivel(nuevoNivel: nuevoNiv),
        onIndiceChanged: (nuevoIdx) {
          if (nuevoIdx >= 0 && nuevoIdx < espaciosDelPiso.length) {
            setState(() {
              _codigoEspacioSeleccionado = espaciosDelPiso[nuevoIdx].codigo;
            });
          }
        },
        onToggleEstadoEspacio: (idx) {
          final codigoObjetivo = espaciosDelPiso[idx].codigo;
          final masterIdx = _todosLosEspacios.indexWhere(
            (e) => e.codigo == codigoObjetivo,
          );
          if (masterIdx != -1) {
            setState(() {
              final actual = _todosLosEspacios[masterIdx];
              _todosLosEspacios[masterIdx] = actual.copyWith(
                estaLibre: !actual.estaLibre,
              );
            });
          }
        },
        onAgregarEspacio: (nuevo) {
          setState(() {
            _todosLosEspacios.add(nuevo);
            _codigoEspacioSeleccionado = nuevo.codigo;
          });
        },
        onEliminarEspacio: (idx) {
          if (espaciosDelPiso.length <= 1) return;
          final eliminado = espaciosDelPiso[idx];
          final masterIdx = _todosLosEspacios.indexWhere(
            (e) => e.codigo == eliminado.codigo,
          );
          if (masterIdx == -1) return;

          setState(() {
            _todosLosEspacios.removeAt(masterIdx);
            final restantes = _espaciosFiltradosPorEdificioYPiso;
            if (restantes.isNotEmpty) {
              _codigoEspacioSeleccionado =
                  restantes[idx.clamp(0, restantes.length - 1)].codigo;
            }
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Espacio ${eliminado.codigo} eliminado'),
              action: SnackBarAction(
                label: 'DESHACER',
                onPressed: () {
                  setState(() {
                    _todosLosEspacios.insert(masterIdx, eliminado);
                    _codigoEspacioSeleccionado = eliminado.codigo;
                  });
                },
              ),
            ),
          );
        },
        onAbrirHorarioEspacio: (idx) {
          setState(() {
            _codigoEspacioSeleccionado = espaciosDelPiso[idx].codigo;
            _mostrandoTimelineSalon = false;
            _indiceModulo = 2;
          });
        },
        onAbrirDirectorioEspacio: (idx) {
          setState(() {
            _codigoEspacioSeleccionado = espaciosDelPiso[idx].codigo;
            _indiceModulo = 3;
          });
        },
      );
    } else if (_indiceModulo == 2) {
      final nombreSalon =
          '${espacioActual.titulo.replaceAll('\n', ' ')} ${espacioActual.codigo}';

      if (_mostrandoTimelineSalon) {
        cuerpoActivo = HorariosScreen(
          salon: nombreSalon,
          bloques: _bloquesTimeline,
          onBack: () => setState(() => _mostrandoTimelineSalon = false),
          onAgregarBloque: (nuevo) {
            setState(() => _bloquesTimeline.add(nuevo));
          },
          onActualizarBloque: (index, actualizado) {
            setState(() => _bloquesTimeline[index] = actualizado);
          },
          onEliminarBloque: (index) {
            final eliminado = _bloquesTimeline[index];
            setState(() => _bloquesTimeline.removeAt(index));
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Bloque "${eliminado.titulo}" eliminado'),
                action: SnackBarAction(
                  label: 'DESHACER',
                  onPressed: () {
                    setState(() => _bloquesTimeline.insert(index, eliminado));
                  },
                ),
              ),
            );
          },
        );
      } else {
        cuerpoActivo = HorarioSalonScreen(
          espacios: espaciosDelPiso,
          indiceEspacioActual: indiceEnPiso,
          horaReloj: _horaFormateadaDispositivo,
          segundosReloj: _segundosFormateadosDispositivo,
          onBackToEdificio: () => setState(() => _indiceModulo = 1),
          onEspacioChanged: (nuevoIdx) {
            setState(() {
              _codigoEspacioSeleccionado = espaciosDelPiso[nuevoIdx].codigo;
            });
          },
          onToggleSalonLibre: (libre) {
            final masterIdx = _todosLosEspacios.indexWhere(
              (e) => e.codigo == espacioActual.codigo,
            );
            if (masterIdx != -1) {
              setState(() {
                _todosLosEspacios[masterIdx] =
                    _todosLosEspacios[masterIdx].copyWith(estaLibre: libre);
              });
            }
          },
          onActualizarDatosSalon: ({
            required String profesor,
            required String horario,
            required String materia,
          }) {
            final masterIdx = _todosLosEspacios.indexWhere(
              (e) => e.codigo == espacioActual.codigo,
            );
            if (masterIdx != -1) {
              setState(() {
                _todosLosEspacios[masterIdx] =
                    _todosLosEspacios[masterIdx].copyWith(
                  profesorActual: profesor,
                  horarioActual: horario,
                  materiaActual: materia,
                  estaLibre: false,
                );
              });
            }
          },
          onVerLineaTiempo: () =>
              setState(() => _mostrandoTimelineSalon = true),
          onVerProfesorEnDirectorio: () => setState(() => _indiceModulo = 3),
        );
      }
    } else if (_indiceModulo == 3) {
      cuerpoActivo = DirectorioDepartamentoScreen(
        profesores: _profesores,
        academias: _catalogoAcademias,
        materias: _catalogoMaterias,
        onBack: () => setState(() => _indiceModulo = 0),
        onUbicarEnMapa: _ubicarProfesorEnCroquis,
        onCambiarDisponibilidad: (id, nuevoEstado) {
          setState(() {
            final idx = _profesores.indexWhere((p) => p.id == id);
            if (idx != -1) {
              _profesores[idx] = _profesores[idx].copyWith(
                disponibilidad: nuevoEstado,
              );
              if (id == 'p3') {
                _disponibilidadProfesor = nuevoEstado;
              }
              if (_profesorUbicadoEnMapa?.id == id) {
                _profesorUbicadoEnMapa = _profesores[idx];
              }
            }
          });
        },
        onToggleFavorito: (id) {
          setState(() {
            final idx = _profesores.indexWhere((p) => p.id == id);
            if (idx != -1) {
              _profesores[idx] = _profesores[idx].copyWith(
                esFavorito: !_profesores[idx].esFavorito,
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
      );
    } else {
      cuerpoActivo = InicioProfesorScreen(
        disponibilidad: _disponibilidadProfesor,
        cubiculo: _cubiculoProfesor,
        cursos: _cursosProfesor,
        horariosPorDia: _horariosProfesorPorDia,
        horaOficial: _horaFormateadaDispositivo,
        onDisponibilidadChanged: (nuevo) =>
            _actualizarEstadoProfesorGlobal(nuevo),
        onActualizarDatosCompletos: ({
          required EstadoDisponibilidad disponibilidad,
          required String cubiculo,
          required Map<String, List<BloqueHorarioProfesor>> horarios,
        }) {
          _actualizarEstadoProfesorGlobal(
            disponibilidad,
            nuevoCubiculo: cubiculo,
          );
          setState(() {
            _horariosProfesorPorDia = horarios;
          });
        },
        onAgregarCurso: (curso) {
          setState(() => _cursosProfesor.add(curso));
        },
        onEliminarCurso: (idx) {
          final eliminado = _cursosProfesor[idx];
          setState(() => _cursosProfesor.removeAt(idx));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Curso "${eliminado.nombreCorto} (${eliminado.grupo})" eliminado',
              ),
              action: SnackBarAction(
                label: 'DESHACER',
                onPressed: () {
                  setState(() => _cursosProfesor.insert(idx, eliminado));
                },
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: cuerpoActivo,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceModulo,
        onDestinationSelected: (idx) {
          setState(() {
            _indiceModulo = idx;
            if (idx != 2) {
              _mostrandoTimelineSalon = false;
            }
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: const Color(0xFF026AA7).withOpacity(0.14),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: Color(0xFF026AA7)),
            label: 'Croquis',
          ),
          NavigationDestination(
            icon: Icon(Icons.domain_outlined),
            selectedIcon: Icon(Icons.domain_rounded, color: Color(0xFF026AA7)),
            label: 'Edificios',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(
              Icons.meeting_room_rounded,
              color: Color(0xFF026AA7),
            ),
            label: 'Salón',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded, color: Color(0xFF026AA7)),
            label: 'Directorio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF026AA7)),
            label: 'Profesor',
          ),
        ],
      ),
    );
  }
}