import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/horario_salon_models.dart';

/// ============================================================================
/// INTERFAZ 2: HORARIOS (Línea de tiempo con puntos y RECESO)
/// ============================================================================

class HorariosScreen extends StatefulWidget {
  final String salon;
  final List<BloqueTimelineSalon>? bloques;
  final VoidCallback? onBack;
  final ValueChanged<BloqueTimelineSalon>? onAgregarBloque;
  final void Function(int index, BloqueTimelineSalon actualizado)?
      onActualizarBloque;
  final ValueChanged<int>? onEliminarBloque;

  const HorariosScreen({
    super.key,
    this.salon = 'SALÓN 2001',
    this.bloques,
    this.onBack,
    this.onAgregarBloque,
    this.onActualizarBloque,
    this.onEliminarBloque,
  });

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  late List<BloqueTimelineSalon> _bloques;

  @override
  void initState() {
    super.initState();
    _inicializarBloques();
  }

  @override
  void didUpdateWidget(covariant HorariosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bloques != null && widget.bloques != oldWidget.bloques) {
      _bloques = List.from(widget.bloques!);
    }
  }

  void _inicializarBloques() {
    if (widget.bloques != null) {
      _bloques = List.from(widget.bloques!);
    } else {
      _bloques = [
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
    }
  }

  void _mostrarDialogoNuevoBloque(BuildContext context) {
    final horaIniCtrl = TextEditingController(text: '12:00');
    final horaFinCtrl = TextEditingController(text: '13:30');
    final materiaCtrl = TextEditingController(text: 'Materia 1');
    final profCtrl = TextEditingController(text: 'Prof. Alexis Pérez');
    String tipo = 'clase';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Agregar bloque de horario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'clase', label: Text('Clase')),
                    ButtonSegment(value: 'receso', label: Text('Receso')),
                    ButtonSegment(value: 'libre', label: Text('Libre')),
                  ],
                  selected: {tipo},
                  onSelectionChanged: (s) {
                    setModalState(() => tipo = s.first);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: horaIniCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Inicio (ej. 7:00)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: horaFinCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Fin (ej. 8:30)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                if (tipo == 'clase') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: materiaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: profCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Profesor',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (horaIniCtrl.text.trim().isEmpty) return;
                final esReceso = tipo == 'receso';
                final esLibre = tipo == 'libre';
                final nuevoBloque = BloqueTimelineSalon(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  horaInicio: horaIniCtrl.text.trim(),
                  horaFin: horaFinCtrl.text.trim(),
                  titulo: esReceso
                      ? 'RECESO'
                      : esLibre
                          ? 'HORA LIBRE'
                          : materiaCtrl.text.trim(),
                  profesor: (esReceso || esLibre)
                      ? null
                      : profCtrl.text.trim(),
                  esReceso: esReceso,
                  esHoraLibre: esLibre,
                );

                setState(() {
                  _bloques.add(nuevoBloque);
                });
                widget.onAgregarBloque?.call(nuevoBloque);

                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleActualizarBloque(int index, BloqueTimelineSalon actualizado) {
    setState(() {
      _bloques[index] = actualizado;
    });
    widget.onActualizarBloque?.call(index, actualizado);
  }

  void _handleEliminarBloque(int index) {
    final eliminado = _bloques[index];
    setState(() {
      _bloques.removeAt(index);
    });
    widget.onEliminarBloque?.call(index);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Bloque "${eliminado.titulo}" eliminado'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            setState(() {
              _bloques.insert(index, eliminado);
            });
            widget.onAgregarBloque?.call(eliminado);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: const Text(
          'HORARIOS',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.6,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: () => _mostrarDialogoNuevoBloque(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Agregar'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: _bloques.length,
          itemBuilder: (context, index) {
            final bloque = _bloques[index];
            final esUltimo = index == _bloques.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Columna de horas (7:00, 8:30, 10:00, 10:30)
                  SizedBox(
                    width: 48,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        bloque.horaInicio,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Línea vertical con puntos (nodos) como en el boceto
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: bloque.esReceso
                              ? const Color(0xFFF59E0B)
                              : bloque.esHoraLibre
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF0F172A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!esUltimo)
                        Expanded(
                          child: Container(
                            width: 2.2,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Tarjeta derecha (Materia 1 / RECESO / Hora Libre)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bloque.esReceso
                              ? const Color(0xFFFEF3C7)
                              : bloque.esHoraLibre
                                  ? const Color(0xFFDCFCE7)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.6,
                          ),
                        ),
                        child: bloque.esReceso || bloque.esHoraLibre
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    bloque.titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _handleActualizarBloque(
                                            index,
                                            bloque.copyWith(
                                              esReceso: false,
                                              esHoraLibre: false,
                                              titulo: 'Materia 1',
                                              profesor: 'Prof. Alexis Pérez',
                                            ),
                                          );
                                        },
                                        child: const Text('Asignar clase'),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _handleEliminarBloque(index),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bloque.titulo,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          bloque.profesor ??
                                              'Prof. Alexis Pérez',
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${bloque.horaInicio} - ${bloque.horaFin}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF026AA7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip: 'Marcar como Hora Libre',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          _handleActualizarBloque(
                                            index,
                                            bloque.copyWith(
                                              esHoraLibre: true,
                                              titulo: 'HORA LIBRE',
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.event_available_rounded,
                                          color: Color(0xFF16A34A),
                                          size: 20,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Eliminar bloque',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _handleEliminarBloque(index),
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
                      ),
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
}
