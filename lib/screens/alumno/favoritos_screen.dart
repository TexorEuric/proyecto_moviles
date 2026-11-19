import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';
import 'package:proyecto_moviles/screens/alumno/mapa_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  String? _seleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Text('Favoritos'),
            SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber),
          ],
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: AppData.favoritos,
          builder: (context, favs, _) {
            final lista = AppData.profesores.where((p) => favs.contains(p.id)).toList();
            if (_seleccionado != null && !favs.contains(_seleccionado)) _seleccionado = null;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona algún profesor para ubicar en mapa.',
                      style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 14),
                  Expanded(
                    child: lista.isEmpty
                        ? const Center(
                            child: Text(
                              'Aún no tienes favoritos.\nAgrégalos desde el directorio.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: lista.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _tarjeta(lista[i]),
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _seleccionado == null
                          ? null
                          : () {
                              final p = AppData.profesores
                                  .firstWhere((x) => x.id == _seleccionado);
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => MapaScreen(ubicar: p)),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAzul,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ubicar en mapa',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tarjeta(Profesor p) {
    final sel = _seleccionado == p.id;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      decoration: BoxDecoration(
        color: sel ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sel ? kAzul : const Color(0xFF334155), width: sel ? 2 : 1),
      ),
      child: Row(
        children: [
          Checkbox(
            value: sel,
            onChanged: (v) => setState(() => _seleccionado = v == true ? p.id : null),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Dpto. ${p.academia}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, color: Color(0xFF334155)),
          ),
          IconButton(
            tooltip: 'Quitar',
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => AppData.toggleFavorito(p.id),
          ),
        ],
      ),
    );
  }
}