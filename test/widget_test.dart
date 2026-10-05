import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_moviles/main.dart';

void main() {
  testWidgets('Login screen loads inputs and buttons smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify presence of title and fields
    expect(find.text('Iniciar Sesión'), findsWidgets);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Verify there is NO registration button
    expect(find.widgetWithText(ElevatedButton, 'Registrarse'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Registrarse'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Registrarse'), findsNothing);

    // Verify presence of login button
    expect(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'), findsOneWidget);

    // Verify private system notice
    expect(find.textContaining('Sistema institucional privado'), findsOneWidget);
  });
}
