import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/alumno/detalle_profesor_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horario_salon_screen.dart';
import 'package:proyecto_moviles/screens/alumno/horarios_screen.dart';
import 'package:proyecto_moviles/screens/alumno/mapa_screen.dart';
import 'package:proyecto_moviles/screens/alumno/perfil_screen.dart';
import 'package:proyecto_moviles/screens/contenedor_interfaces_verdes.dart';
import 'package:proyecto_moviles/screens/docente/docente_home_screen.dart';
import 'package:proyecto_moviles/screens/profesor/directorio_screen.dart';

void main() {
  testWidgets('HorarioSalonScreen renders correctly standalone', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HorarioSalonScreen(),
      ),
    );

    expect(find.text('HORARIO SALÓN'), findsOneWidget);
    expect(find.text('SALÓN 2001'), findsOneWidget);
    expect(find.textContaining('PROFESOR:'), findsOneWidget);
    expect(find.textContaining('HORARIO:'), findsOneWidget);
    expect(find.textContaining('MATERIA:'), findsOneWidget);
  });

  testWidgets('HorariosScreen renders correctly standalone', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HorariosScreen(),
      ),
    );

    expect(find.text('HORARIOS'), findsOneWidget);
    expect(find.text('RECESO'), findsOneWidget);
    expect(find.text('7:00'), findsOneWidget);
  });

  testWidgets('DirectorioScreen renders correctly standalone', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DirectorioScreen(),
      ),
    );

    expect(find.text('DIRECTORIO'), findsOneWidget);
    expect(find.textContaining('DEPARTAMENTO ING.'), findsOneWidget);
    expect(find.text('Juan Díaz'), findsOneWidget);
  });

  testWidgets('ContenedorInterfacesVerdes renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ContenedorInterfacesVerdes(),
      ),
    );

    expect(find.text('Horario Salón'), findsOneWidget);
    expect(find.text('Horarios'), findsOneWidget);
    expect(find.text('Directorio'), findsOneWidget);
  });

  testWidgets('PerfilScreen renders properly without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PerfilScreen(),
      ),
    );

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Datos'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Actualizar contraseña'), findsOneWidget);
    expect(find.text('Foto perfil'), findsOneWidget);
    expect(find.text('Agregar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('MapaScreen allows navigating to HorarioSalonScreen and Directorio', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MapaScreen(),
      ),
    );

    expect(find.byIcon(Icons.meeting_room_rounded), findsOneWidget);
    expect(find.byIcon(Icons.timeline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_customize_outlined), findsOneWidget);
    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);

    // Tap Horario de Salón button
    await tester.tap(find.byIcon(Icons.meeting_room_rounded));
    await tester.pumpAndSettle();

    expect(find.text('HORARIO SALÓN'), findsOneWidget);

    // Back to map
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.meeting_room_rounded), findsOneWidget);
  });

  testWidgets('DetalleProfesorScreen allows navigating to HorarioSalonScreen', (WidgetTester tester) async {
    final profesor = AppData.profesores.first;
    await tester.pumpWidget(
      MaterialApp(
        home: DetalleProfesorScreen(profesor: profesor),
      ),
    );

    expect(find.text('Ver horario de salón / clases'), findsOneWidget);
    await tester.tap(find.text('Ver horario de salón / clases'));
    await tester.pumpAndSettle();

    expect(find.text('HORARIO SALÓN'), findsOneWidget);
  });

  testWidgets('DocenteHomeScreen displays quick access to salon schedules and directory', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DocenteHomeScreen(),
      ),
    );

    expect(find.text('Salones y Directorio Departamental'), findsOneWidget);
    expect(find.text('Horario Salón'), findsOneWidget);
    expect(find.text('Línea de tiempo'), findsOneWidget);
    expect(find.text('Directorio'), findsOneWidget);
    expect(find.text('Panel General'), findsOneWidget);

    // Tap Horario Salón quick access
    await tester.tap(find.text('Horario Salón'));
    await tester.pumpAndSettle();

    expect(find.text('HORARIO SALÓN'), findsOneWidget);
  });
}
