import 'package:flutter/material.dart';
import 'package:proyecto_moviles/data/app_data.dart';

class ActualizarHorarioScreen extends StatefulWidget {
  const ActualizarHorarioScreen({super.key});

  @override
  State<ActualizarHorarioScreen> createState() => _ActualizarHorarioScreenState();
}

class _ActualizarHorarioScreenState extends State<ActualizarHorarioScreen> {
  static const _dias = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES'];

  Estado _estado = AppData.docenteEstado.value;
  final _cubiculo = TextEditingController(text: AppData.docenteCubiculo.value);
  bool _editandoCubiculo = false;
  String _dia = 'LUNES';

  // Copia de trabajo: solo se guarda al presionar "Guardar cambios".
  final Map<String, List<Slot>> _horario = {
    for (final e in AppData.horario.entries) e.key: [for (final s in e.value) s.copy()],
  };

  List<Slot> get _slots => _horario[_dia]!;

  @override
  void dispose() {
    _cubiculo.dispose();
    super.dispose();
  }

  // ---------- Acciones ----------
  Future<Curso?> _elegirCurso() {
    final cursos = AppData.cursos.value;
    return showDialog<Curso>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Asignar curso'),
        children: cursos.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('Primero agrega un curso en la pantalla de Inicio.'),
                ),
              ]
            : [
                for (final c in cursos)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, c),
                    child: Text('${c.materia} · ${c.grupo}'),
                  ),
              ],
      ),
    );
  }

  Future<void> _asignar(Slot s) async {
    final c = await _elegirCurso();
    if (c == null) return;
    setState(() {
      s.tipo = TipoSlot.clase;
      s.materia = c.materia;
      s.grupo = c.grupo;
      s.lugar = c.lugar;
    });
  }

  void _quitarClase(Slot s) => setState(() {
        s.tipo = TipoSlot.sinClase;
        s.materia = s.grupo = s.lugar = '';
      });

  void _quitarHora(Slot s) => setState(() => _slots.remove(s));

  Future<void> _agregarHora() async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (t == null) return;
    var h = t.hourOfPeriod;
    if (h == 0) h = 12;
    final hora = '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (_slots.any((s) => s.hora == hora)) return;
    setState(() {
      _slots.add(Slot(hora, TipoSlot.libre));
      _slots.sort((a, b) => a.minutos.compareTo(b.minutos));
    });
  }

  Future<void> _solicitarMod() async {
    final ctrl = TextEditingController();
    final enviar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Solicitar modificación'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe el cambio que necesitas en tu horario…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enviar')),
        ],
      ),
    );
    if (enviar == true && ctrl.text.trim().isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada a la administración.')),
      );
    }
  }

  void _guardar() {
    AppData.docenteEstado.value = _estado;
    final c = _cubiculo.text.trim();
    if (c.isNotEmpty) AppData.docenteCubiculo.value = c;
    AppData.horario
      ..clear()
      ..addAll(_horario);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cambios guardados'),
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Actualizar datos y horario',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _tarjetaDatos(),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('HORARIO CLASE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: _agregarHora,
                    icon: const Icon(Icons.alarm_add_outlined, color: kAzul, size: 20),
                    label: const Text('Agregar hora', style: TextStyle(color: kAzul)),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black87, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dia,
                        items: [for (final d in _dias) DropdownMenuItem(value: d, child: Text(d))],
                        onChanged: (v) => setState(() => _dia = v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _solicitarMod,
                        icon: const Icon(Icons.edit_note, color: Color(0xFF334155)),
                        label: const Text('Solicitar mod',
                            style: TextStyle(color: Color(0xFF334155), fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _slots.isEmpty
                      ? const Center(
                          child: Text('Sin horas para este día',
                              style: TextStyle(color: Color(0xFF64748B))))
                      : ListView.builder(
                          itemCount: _slots.length,
                          itemBuilder: (_, i) => _fila(_slots[i]),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar cambios',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAzul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaDatos() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 112,
                child: Text('Disponibilidad:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _estado.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _estado.color, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Estado>(
                      value: _estado,
                      isExpanded: true,
                      items: [
                        for (final e in Estado.values)
                          DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Text(e.label),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _estado = v!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(
                width: 112,
                child: Text('Cubículo:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: TextField(
                  controller: _cubiculo,
                  readOnly: !_editandoCubiculo,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: IconButton(
                  icon: Icon(_editandoCubiculo ? Icons.check : Icons.edit),
                  onPressed: () => setState(() => _editandoCubiculo = !_editandoCubiculo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fila(Slot s) {
    const verde = Color(0xFF16A34A);
    Widget tile;
    List<Widget> externos = [];

    switch (s.tipo) {
      case TipoSlot.clase:
        tile = Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kAzul),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.materia, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text('Grupo ${s.grupo}', style: const TextStyle(fontSize: 12, color: kAzul)),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF475569)),
                onPressed: () => _asignar(s),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                onPressed: () => _quitarClase(s),
              ),
            ],
          ),
        );
        break;
      case TipoSlot.libre:
        tile = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: verde),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: verde, size: 20),
              SizedBox(width: 8),
              Text('Hora Libre (Disponible)',
                  style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w500)),
            ],
          ),
        );
        break;
      case TipoSlot.sinClase:
        tile = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: const Row(
            children: [
              Icon(Icons.remove_circle_outline, color: Color(0xFF64748B), size: 20),
              SizedBox(width: 8),
              Text('Sin clase (No disponible)', style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        );
        break;
    }

    if (s.tipo != TipoSlot.clase) {
      externos = [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline, color: kAzul),
          onPressed: () => _asignar(s),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
          onPressed: () => _quitarHora(s),
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(s.hora,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: tile),
          if (externos.isEmpty) const SizedBox(width: 4) else ...externos,
        ],
      ),
    );
  }
}