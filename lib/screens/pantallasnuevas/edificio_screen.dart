import 'package:flutter/material.dart';
import 'models.dart';


class VistaPorEdificioScreen extends StatefulWidget {
  final String edificioSeleccionado;
  final String nivelSeleccionado;
  final List<EspacioEdificio> espaciosDelPiso;
  final int indiceSeleccionado;
  final String horaOficial;
  final VoidCallback onIrACroquis;
  final ValueChanged<String> onEdificioChanged;
  final ValueChanged<String> onNivelChanged;
  final ValueChanged<int> onIndiceChanged;
  final ValueChanged<int> onToggleEstadoEspacio;
  final ValueChanged<EspacioEdificio> onAgregarEspacio;
  final ValueChanged<int> onEliminarEspacio;
  final ValueChanged<int> onAbrirHorarioEspacio;
  final ValueChanged<int> onAbrirDirectorioEspacio;

  const VistaPorEdificioScreen({
    super.key,
    required this.edificioSeleccionado,
    required this.nivelSeleccionado,
    required this.espaciosDelPiso,
    required this.indiceSeleccionado,
    required this.horaOficial,
    required this.onIrACroquis,
    required this.onEdificioChanged,
    required this.onNivelChanged,
    required this.onIndiceChanged,
    required this.onToggleEstadoEspacio,
    required this.onAgregarEspacio,
    required this.onEliminarEspacio,
    required this.onAbrirHorarioEspacio,
    required this.onAbrirDirectorioEspacio,
  });

  @override
  State<VistaPorEdificioScreen> createState() => _VistaPorEdificioScreenState();
}

class _VistaPorEdificioScreenState extends State<VistaPorEdificioScreen> {
  late PageController _pageController;

  final List<String> _edificios = const [
    'Edificio 1',
    'Edificio 2',
    'Edificio 3',
    'Edificio 4',
    'Edificio 5',
  ];

  final List<String> _niveles = const [
    'Planta Baja',
    'Primer Piso',
    'Segundo Piso',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.indiceSeleccionado,
      viewportFraction: 0.84,
    );
  }

  @override
  void didUpdateWidget(covariant VistaPorEdificioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.indiceSeleccionado != widget.indiceSeleccionado &&
        _pageController.hasClients) {
      final paginaActual = _pageController.page?.round() ?? 0;
      if (paginaActual != widget.indiceSeleccionado) {
        _pageController.animateToPage(
          widget.indiceSeleccionado,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irAEspacio(int index) {
    widget.onIndiceChanged(index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _mostrarDialogoAgregarEspacio() {
    final prefijo =
        '${NomenclaturaEscom.digitoEdificio(widget.edificioSeleccionado)}${NomenclaturaEscom.digitoNivel(widget.nivelSeleccionado)}';
    final siguienteNumero = (widget.espaciosDelPiso.length + 1)
        .toString()
        .padLeft(2, '0');

    final codigoCtrl = TextEditingController(text: '$prefijo$siguienteNumero');
    final tituloCtrl = TextEditingController(text: 'SALÓN');
    final subtituloCtrl = TextEditingController();
    TipoEspacioEdificio tipoSeleccionado = TipoEspacioEdificio.salon;
    bool libreInicial = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Agregar espacio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codigoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Código',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<TipoEspacioEdificio>(
                        value: tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TipoEspacioEdificio.salon,
                            child: Text('Salón'),
                          ),
                          DropdownMenuItem(
                            value: TipoEspacioEdificio.cubiculoProfesores,
                            child: Text('Cubículo'),
                          ),
                          DropdownMenuItem(
                            value: TipoEspacioEdificio.laboratorio,
                            child: Text('Laboratorio'),
                          ),
                          DropdownMenuItem(
                            value: TipoEspacioEdificio.departamento,
                            child: Text('Depto.'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              tipoSeleccionado = val;
                              if (val == TipoEspacioEdificio.salon) {
                                tituloCtrl.text = 'SALÓN';
                              } else if (val ==
                                  TipoEspacioEdificio.cubiculoProfesores) {
                                tituloCtrl.text = 'CUBÍCULO\nPROFESORES';
                              } else if (val ==
                                  TipoEspacioEdificio.laboratorio) {
                                tituloCtrl.text = 'LABORATORIO';
                              } else {
                                tituloCtrl.text = 'DEPARTAMENTO';
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subtítulo opcional',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                if (tipoSeleccionado.muestraEstado) ...[
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Marcar inicialmente como Libre'),
                    value: libreInicial,
                    onChanged: (v) => setModalState(() => libreInicial = v),
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
                if (codigoCtrl.text.trim().isEmpty) return;
                widget.onAgregarEspacio(
                  EspacioEdificio(
                    codigo: codigoCtrl.text.trim(),
                    titulo: tituloCtrl.text.trim().isEmpty
                        ? 'SALÓN'
                        : tituloCtrl.text.trim(),
                    subtitulo: subtituloCtrl.text.trim().isEmpty
                        ? null
                        : subtituloCtrl.text.trim(),
                    edificio: widget.edificioSeleccionado,
                    nivel: widget.nivelSeleccionado,
                    tipo: tipoSeleccionado,
                    estaLibre: libreInicial,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final espacioActual = widget.espaciosDelPiso[widget.indiceSeleccionado];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.edificioSeleccionado,
            isDense: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF0F172A),
              size: 22,
            ),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
            onChanged: (nuevo) {
              if (nuevo != null) widget.onEdificioChanged(nuevo);
            },
            items: _edificios.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e.replaceFirst('Edificio ', 'Edificio: ')),
              );
            }).toList(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar espacio',
            onPressed: _mostrarDialogoAgregarEspacio,
            icon: const Icon(
              Icons.add_business_rounded,
              color: Color(0xFF026AA7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Volver al Croquis',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
              ),
              onPressed: widget.onIrACroquis,
              icon: const Icon(
                Icons.home_outlined,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FILA DE DROPDOWNS: [Planta Baja ▼] y [2001 ▼]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.6,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.nivelSeleccionado,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Color(0xFF0F172A),
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            onChanged: (nuevo) {
                              if (nuevo != null) widget.onNivelChanged(nuevo);
                            },
                            items: _niveles.map((nivel) {
                              return DropdownMenuItem(
                                value: nivel,
                                child: Text(nivel),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.6,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: widget.indiceSeleccionado,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Color(0xFF0F172A),
                            ),
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF026AA7),
                            ),
                            onChanged: (nuevoIdx) {
                              if (nuevoIdx != null) _irAEspacio(nuevoIdx);
                            },
                            items: List.generate(
                              widget.espaciosDelPiso.length,
                              (i) {
                                return DropdownMenuItem(
                                  value: i,
                                  child: Text(widget.espaciosDelPiso[i].codigo),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. BOTÓN CONTEXTUAL ([HORARIOS] / [DIRECTORIO] / [HORARIO])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        if (espacioActual.tipo.abreDirectorio) {
                          widget.onAbrirDirectorioEspacio(
                            widget.indiceSeleccionado,
                          );
                        } else {
                          widget.onAbrirHorarioEspacio(
                            widget.indiceSeleccionado,
                          );
                        }
                      },
                      icon: Icon(espacioActual.tipo.iconoBoton, size: 18),
                      label: Text(
                        espacioActual.tipo.etiquetaBoton,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF026AA7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (espacioActual.tipo.muestraEstado)
                          ActionChip(
                            avatar: CircleAvatar(
                              radius: 5,
                              backgroundColor: espacioActual.estaLibre
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                            label: Text(
                              espacioActual.estaLibre
                                  ? 'Marcar Ocupado'
                                  : 'Marcar Libre',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () => widget.onToggleEstadoEspacio(
                              widget.indiceSeleccionado,
                            ),
                          ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Eliminar espacio',
                          onPressed: () => widget.onEliminarEspacio(
                            widget.indiceSeleccionado,
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. CARRUSEL LIMPIO DE VISTAS DEL PISO ACTUAL
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    itemCount: widget.espaciosDelPiso.length,
                    onPageChanged: widget.onIndiceChanged,
                    itemBuilder: (context, index) {
                      final esp = widget.espaciosDelPiso[index];
                      final seleccionado = index == widget.indiceSeleccionado;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: EdgeInsets.only(
                          left: index == 0 ? 18 : 8,
                          right: 10,
                          top: seleccionado ? 4 : 14,
                          bottom: seleccionado ? 4 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? const Color(0xFFF8FAFC)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: seleccionado
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                            width: seleccionado ? 2.2 : 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (!seleccionado) {
                              _irAEspacio(index);
                              return;
                            }
                            if (esp.tipo.abreDirectorio) {
                              widget.onAbrirDirectorioEspacio(index);
                            } else {
                              widget.onAbrirHorarioEspacio(index);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  esp.codigo,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3.0,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  esp.titulo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    height: 1.2,
                                  ),
                                ),
                                if (esp.subtitulo != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    esp.subtitulo!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                                if (esp.tipo.muestraEstado) ...[
                                  const SizedBox(height: 16),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        widget.onToggleEstadoEspacio(index),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Estado ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: esp.estaLibre
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFDC2626),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 4. Cápsula indicadora de página inferior ( • • • )
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 1.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < 4; i++)
                        GestureDetector(
                          onTap: () => _irAEspacio(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: (widget.indiceSeleccionado == i ||
                                    (i == 3 && widget.indiceSeleccionado >= 3))
                                ? 18
                                : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: (widget.indiceSeleccionado == i ||
                                      (i == 3 &&
                                          widget.indiceSeleccionado >= 3))
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}