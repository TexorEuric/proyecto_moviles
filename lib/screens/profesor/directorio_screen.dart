import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/horario_salon_models.dart';

/// ============================================================================
/// INTERFAZ 3: DIRECTORIO (DEPARTAMENTO ING. SIST. COMP.)
/// ============================================================================

class DirectorioScreen extends StatefulWidget {
  final List<ProfesorDirectorio>? profesores;
  final void Function(String id, EstadoDisponibilidad nuevoEstado)?
      onCambiarDisponibilidad;
  final ValueChanged<ProfesorDirectorio>? onAgregarProfesor;
  final ValueChanged<int>? onEliminarProfesor;

  const DirectorioScreen({
    super.key,
    this.profesores,
    this.onCambiarDisponibilidad,
    this.onAgregarProfesor,
    this.onEliminarProfesor,
  });

  @override
  State<DirectorioScreen> createState() => _DirectorioScreenState();
}

class _DirectorioScreenState extends State<DirectorioScreen> {
  bool _soloLibres = false;
  late List<ProfesorDirectorio> _profesores;

  @override
  void initState() {
    super.initState();
    _inicializarProfesores();
  }

  @override
  void didUpdateWidget(covariant DirectorioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profesores != null &&
        widget.profesores != oldWidget.profesores) {
      _profesores = List.from(widget.profesores!);
    }
  }

  void _inicializarProfesores() {
    if (widget.profesores != null) {
      _profesores = List.from(widget.profesores!);
    } else {
      _profesores = [
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
    }
  }

  void _mostrarDialogoAgregarProfesor() {
    final nombreCtrl = TextEditingController();
    final deptoCtrl = TextEditingController(text: 'Dpto. Ing. Sist. C.');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Agregar Profesor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej. Juan Díaz)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deptoCtrl,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty) return;
              final nuevo = ProfesorDirectorio(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: nombreCtrl.text.trim(),
                departamento: deptoCtrl.text.trim(),
              );

              setState(() {
                _profesores.add(nuevo);
              });
              widget.onAgregarProfesor?.call(nuevo);

              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _alternarDisponibilidad(ProfesorDirectorio prof) {
    final estaLibre = prof.disponibilidad == EstadoDisponibilidad.libre;
    final siguiente = estaLibre
        ? EstadoDisponibilidad.ocupado
        : EstadoDisponibilidad.libre;

    setState(() {
      final idx = _profesores.indexWhere((p) => p.id == prof.id);
      if (idx != -1) {
        _profesores[idx] = _profesores[idx].copyWith(disponibilidad: siguiente);
      }
    });

    widget.onCambiarDisponibilidad?.call(prof.id, siguiente);
  }

  void _eliminarProfesor(int indexOriginal) {
    final eliminado = _profesores[indexOriginal];
    setState(() {
      _profesores.removeAt(indexOriginal);
    });
    widget.onEliminarProfesor?.call(indexOriginal);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Profesor "${eliminado.nombre}" eliminado'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            setState(() {
              _profesores.insert(indexOriginal, eliminado);
            });
            widget.onAgregarProfesor?.call(eliminado);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _profesores.where((p) {
      if (_soloLibres) {
        return p.disponibilidad == EstadoDisponibilidad.libre;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DIRECTORIO',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.6,
          ),
        ),
        actions: [
          FilterChip(
            selected: _soloLibres,
            selectedColor: const Color(0xFFDCFCE7),
            label: const Text('Solo Libres'),
            onSelected: (v) => setState(() => _soloLibres = v),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Agregar profesor',
            onPressed: _mostrarDialogoAgregarProfesor,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF026AA7),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado exacto del boceto: "DEPARTAMENTO ING. SIST. COMP."
              const Text(
                'DEPARTAMENTO ING.\nSIST. COMP.',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 18),

              // Lista de tarjetas de profesores (Juan Díaz, Pepe Armendiz...)
              Expanded(
                child: ListView.separated(
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final prof = lista[index];
                    final idxOriginal = _profesores.indexWhere(
                      (p) => p.id == prof.id,
                    );

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 1.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prof.nombre,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prof.departamento,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Ícono circular de persona a la derecha (como en el boceto)
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0F172A),
                                    width: 1.8,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 30,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Botón para alternar si el profesor está Libre u Ocupado
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _alternarDisponibilidad(prof),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: prof.disponibilidad.fondoSuave,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: prof.disponibilidad.color,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: prof.disponibilidad.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${prof.disponibilidad.etiqueta} (Cambiar)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: prof.disponibilidad.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Botón para eliminar profesor
                              IconButton(
                                tooltip: 'Eliminar profesor',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  if (idxOriginal != -1) {
                                    _eliminarProfesor(idxOriginal);
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
