import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nombre = TextEditingController(text: AppData.alumnoNombre);
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  bool _verPassword = false;
  bool _tieneFoto = true; // placeholder: conectar con image_picker más adelante

  @override
  void dispose() {
    _nombre.dispose();
    _usuario.dispose();
    _password.dispose();
    super.dispose();
  }

  void _actualizarPassword() {
    FocusScope.of(context).unfocus();
    final msg = _password.text.trim().length < 6
        ? 'La contraseña debe tener al menos 6 caracteres'
        : 'Contraseña actualizada';
    if (_password.text.trim().length >= 6) _password.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  InputDecoration _deco({String? hint, Widget? suffix}) => InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
      );

  Widget _etiqueta(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Row(
          children: [
            Text('Perfil', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(width: 8),
            Icon(Icons.person, color: kAzul),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Datos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            _etiqueta('Nombre'),
            TextField(controller: _nombre, decoration: _deco()),
            _etiqueta('Usuario'),
            TextField(controller: _usuario, decoration: _deco(hint: 'Número de boleta')),
            _etiqueta('Actualizar contraseña'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _password,
                    obscureText: !_verPassword,
                    decoration: _deco(
                      hint: 'Nueva contraseña',
                      suffix: IconButton(
                        icon: Icon(_verPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: kAzul),
                  onPressed: _actualizarPassword,
                  icon: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
            _etiqueta('Foto perfil'),
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: Icon(_tieneFoto ? Icons.face : Icons.person_outline,
                      size: 36, color: const Color(0xFF334155)),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _tieneFoto = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAzul,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Agregar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _tieneFoto ? () => setState(() => _tieneFoto = false) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAzul,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
              label: const Text('Cerrar sesión', style: TextStyle(color: Color(0xFFDC2626))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFDC2626)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
