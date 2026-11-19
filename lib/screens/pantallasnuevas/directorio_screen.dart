import 'package:flutter/material.dart';
import 'models.dart';

/// ============================================================================
/// ARCHIVO 7: lib/directorio_screen.dart
/// Directorio de Profesores con las especificaciones solicitadas:
/// 1) Orden alfabético por apellidos de todos los profesores en la base de datos.
/// 2) Buscador por nombre o apellido (acepta "Apellido Nombre" o "Nombre Apellido").
/// 3) Dos listas desplegables (Dropdowns):
///    - Desplegable 1: Filtrar por Academia (idAcademia, ej. Ciencias Básicas, ISC...)
///    - Desplegable 2: Filtrar por Materia activa (idMateria, ej. Álgebra Lineal...)
/// 4) Paginación de máximo 10 profesores por página con índices de página en la
///    parte inferior estilo Google (< 1  2  3 >).
/// ============================================================================

class DirectorioDepartamentoScreen extends StatefulWidget {
  final List<ProfesorDirectorio> profesores;
  final List<AcademiaItem> academias;
  final List<MateriaItem> materias;
  final VoidCallback onBack;
  final ValueChanged<ProfesorDirectorio> onUbicarEnMapa;
  final void Function(String id, EstadoDisponibilidad nuevoEstado)
      onCambiarDisponibilidad;
  final ValueChanged<String> onToggleFavorito;
  final ValueChanged<ProfesorDirectorio> onAgregarProfesor;
  final ValueChanged<int> onEliminarProfesor;

  const DirectorioDepartamentoScreen({
    super.key,
    required this.profesores,
    required this.academias,
    required this.materias,
    required this.onBack,
    required this.onUbicarEnMapa,
    required this.onCambiarDisponibilidad,
    required this.onToggleFavorito,
    required this.onAgregarProfesor,
    required this.onEliminarProfesor,
  });

  @override
  State<DirectorioDepartamentoScreen> createState() =>
      _DirectorioDepartamentoScreenState();
}

class _DirectorioDepartamentoScreenState
    extends State<DirectorioDepartamentoScreen> {
  static const int _profesoresPorPagina = 10;

  final TextEditingController _nombreCtrl = TextEditingController();
  String _busquedaNombre = '';
  String? _idAcademiaSeleccionada; // null = Todas las academias
  String? _idMateriaSeleccionada; // null = Todas las materias
  bool _soloLibres = false;
  int _paginaActual = 1;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  /// Normaliza acentos y mayúsculas para que buscar "Perez Juan" o "Juan Pérez"
  /// funcione sin importar el orden ni las tildes.
  String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
  }

  /// Función principal de filtrado y ordenamiento alfabético por apellidos
  /// equivalente a la consulta de base de datos con parámetros:
  /// (nombre/apellido, idAcademia, idMateria)
  List<ProfesorDirectorio> _obtenerProfesoresFiltradosYOrdenados() {
    final tokensBusqueda = _normalizar(_busquedaNombre)
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    final filtrados = widget.profesores.where((prof) {
      // 1. Filtro por nombre y/o apellidos (en cualquier orden)
      if (tokensBusqueda.isNotEmpty) {
        final nombreCompletoNorm =
            _normalizar('${prof.nombres} ${prof.apellidos}');
        final coincideNombre = tokensBusqueda.every(
          (token) => nombreCompletoNorm.contains(token),
        );
        if (!coincideNombre) return false;
      }

      // 2. Filtro por parámetro idAcademia (Desplegable 1)
      if (_idAcademiaSeleccionada != null &&
          prof.idAcademia != _idAcademiaSeleccionada) {
        return false;
      }

      // 3. Filtro por parámetro idMateria (Desplegable 2)
      if (_idMateriaSeleccionada != null &&
          !prof.idsMateriasActivas.contains(_idMateriaSeleccionada)) {
        return false;
      }

      // 4. Filtro opcional de solo profesores libres
      if (_soloLibres && prof.disponibilidad != EstadoDisponibilidad.libre) {
        return false;
      }

      return true;
    }).toList();

    // Orden alfabético por apellidos (y luego por nombres en caso de empate)
    filtrados.sort((a, b) {
      final compApellido = _normalizar(a.apellidos).compareTo(
        _normalizar(b.apellidos),
      );
      if (compApellido != 0) return compApellido;
      return _normalizar(a.nombres).compareTo(_normalizar(b.nombres));
    });

    return filtrados;
  }

  void _reiniciarAPaginaUno() {
    setState(() {
      _paginaActual = 1;
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _nombreCtrl.clear();
      _busquedaNombre = '';
      _idAcademiaSeleccionada = null;
      _idMateriaSeleccionada = null;
      _soloLibres = false;
      _paginaActual = 1;
    });
  }

  void _mostrarFichaProfesor(ProfesorDirectorio prof) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Profesor: ${prof.nombre}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contacto: ${prof.correo}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Academia: ${prof.departamento}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Materias activas: ${prof.nombresMateriasActivas.isEmpty ? "Sin asignar" : prof.nombresMateriasActivas.join(", ")}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF026AA7),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Disponibilidad:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: prof.disponibilidad.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  prof.disponibilidad.etiqueta,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: prof.disponibilidad.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ubicación: ${prof.cubiculo} (${prof.edificioUbicacion})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onUbicarEnMapa(prof);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF026AA7),
            ),
            icon: const Icon(Icons.my_location_rounded, size: 18),
            label: const Text('Ubicar en mapa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalFiltrados = _obtenerProfesoresFiltradosYOrdenados();
    final totalPaginas = (totalFiltrados.length / _profesoresPorPagina)
        .ceil()
        .clamp(1, 999);
    final paginaSegura = _paginaActual.clamp(1, totalPaginas);

    final indiceInicio = (paginaSegura - 1) * _profesoresPorPagina;
    final indiceFin = (indiceInicio + _profesoresPorPagina).clamp(
      0,
      totalFiltrados.length,
    );
    final profesoresPaginaActual = totalFiltrados.isEmpty
        ? <ProfesorDirectorio>[]
        : totalFiltrados.sublist(indiceInicio, indiceFin);

    final hayFiltrosActivos = _busquedaNombre.isNotEmpty ||
        _idAcademiaSeleccionada != null ||
        _idMateriaSeleccionada != null ||
        _soloLibres;

    // Título dinámico según la academia seleccionada en el desplegable
    final nombreAcademiaActiva = _idAcademiaSeleccionada == null
        ? 'DIRECTORIO GENERAL DE PROFESORES'
        : widget.academias
            .firstWhere(
              (a) => a.idAcademia == _idAcademiaSeleccionada,
              orElse: () => const AcademiaItem(
                idAcademia: '',
                nombre: 'DEPARTAMENTO ING. SIST. COMP.',
              ),
            )
            .nombre
            .toUpperCase();

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
          onPressed: widget.onBack,
        ),
        title: const Text(
          'DIRECTORIO',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          if (hayFiltrosActivos)
            TextButton.icon(
              onPressed: _limpiarFiltros,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Limpiar'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // PANEL DE FILTROS DEL DIRECTORIO:
              // 1) Buscador por Nombre / Apellido
              // 2) Lista desplegable: Filtrar Academia (idAcademia)
              // 3) Lista desplegable: Filtrar Materia (idMateria)
              // ==============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nombreAcademiaActiva,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        FilterChip(
                          visualDensity: VisualDensity.compact,
                          selected: _soloLibres,
                          selectedColor: const Color(0xFFDCFCE7),
                          label: const Text(
                            'Solo Libres',
                            style: TextStyle(fontSize: 12),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _soloLibres = val;
                              _paginaActual = 1;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 1. Buscador por nombre o apellido
                    TextField(
                      controller: _nombreCtrl,
                      onChanged: (val) {
                        setState(() {
                          _busquedaNombre = val;
                          _paginaActual = 1;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Filtrar por apellido o nombre (ej. Pérez Juan)...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _busquedaNombre.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _nombreCtrl.clear();
                                  setState(() {
                                    _busquedaNombre = '';
                                    _paginaActual = 1;
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2 y 3. Listas desplegables: Filtrar Academia e ID Materia
                    Row(
                      children: [
                        // Desplegable 1: Filtrar Academia (idAcademia)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _idAcademiaSeleccionada != null
                                    ? const Color(0xFF026AA7)
                                    : const Color(0xFFCBD5E1),
                                width: _idAcademiaSeleccionada != null
                                    ? 1.6
                                    : 1.0,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _idAcademiaSeleccionada,
                                isExpanded: true,
                                hint: const Text(
                                  'Filtrar Academia',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: Color(0xFF0F172A),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      'Todas las Academias',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  ...widget.academias.map((acad) {
                                    return DropdownMenuItem<String?>(
                                      value: acad.idAcademia,
                                      child: Text(
                                        acad.nombre,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (nuevoIdAcademia) {
                                  setState(() {
                                    _idAcademiaSeleccionada = nuevoIdAcademia;
                                    _paginaActual = 1;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Desplegable 2: Filtrar Materia (idMateria)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _idMateriaSeleccionada != null
                                    ? const Color(0xFF026AA7)
                                    : const Color(0xFFCBD5E1),
                                width: _idMateriaSeleccionada != null
                                    ? 1.6
                                    : 1.0,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _idMateriaSeleccionada,
                                isExpanded: true,
                                hint: const Text(
                                  'Filtrar Materia',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: Color(0xFF0F172A),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      'Todas las Materias',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  ...widget.materias.map((mat) {
                                    return DropdownMenuItem<String?>(
                                      value: mat.idMateria,
                                      child: Text(
                                        mat.nombre,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (nuevoIdMateria) {
                                  setState(() {
                                    _idMateriaSeleccionada = nuevoIdMateria;
                                    _paginaActual = 1;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Contador de resultados y orden alfabético por apellidos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalFiltrados.isEmpty
                          ? '0 profesores encontrados'
                          : 'Mostrando ${indiceInicio + 1}–$indiceFin de ${totalFiltrados.length} (Orden A-Z por apellidos)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'Pág. $paginaSegura/$totalPaginas',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF026AA7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ==============================================================
              // LISTA PAGINADA (MÁXIMO 10 PROFESORES POR PÁGINA)
              // ==============================================================
              Expanded(
                child: profesoresPaginaActual.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 46,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No se encontraron profesores con esos filtros.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _limpiarFiltros,
                              child: const Text('Mostrar todos'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: profesoresPaginaActual.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final prof = profesoresPaginaActual[index];
                          final indiceOriginal = widget.profesores.indexWhere(
                            (p) => p.id == prof.id,
                          );
                          final estaLibre = prof.disponibilidad ==
                              EstadoDisponibilidad.libre;

                          return InkWell(
                            onTap: () => _mostrarFichaProfesor(prof),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF0F172A),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    prof.nombrePorApellidos,
                                                    style: const TextStyle(
                                                      fontSize: 16.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                InkWell(
                                                  onTap: () => widget
                                                      .onToggleFavorito(
                                                          prof.id),
                                                  child: Icon(
                                                    prof.esFavorito
                                                        ? Icons.star_rounded
                                                        : Icons
                                                            .star_border_rounded,
                                                    color: prof.esFavorito
                                                        ? const Color(
                                                            0xFFF59E0B)
                                                        : const Color(
                                                            0xFF94A3B8),
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              prof.departamento,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                            if (prof.nombresMateriasActivas
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Materias: ${prof.nombresMateriasActivas.join(" • ")}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF026AA7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
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
                                          size: 28,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          final sig = estaLibre
                                              ? EstadoDisponibilidad.ocupado
                                              : EstadoDisponibilidad.libre;
                                          widget.onCambiarDisponibilidad(
                                            prof.id,
                                            sig,
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 9,
                                              height: 9,
                                              decoration: BoxDecoration(
                                                color:
                                                    prof.disponibilidad.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              prof.disponibilidad.etiqueta,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    prof.disponibilidad.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () =>
                                                widget.onUbicarEnMapa(prof),
                                            icon: const Icon(
                                              Icons.my_location_rounded,
                                              size: 16,
                                            ),
                                            label:
                                                const Text('Ubicar en mapa'),
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () =>
                                                widget.onEliminarProfesor(
                                              indiceOriginal,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 19,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ==============================================================
              // BARRA DE PAGINACIÓN ESTILO GOOGLE (< 1 2 3 >) HASTA ABAJO
              // ==============================================================
              if (totalFiltrados.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Página anterior',
                        visualDensity: VisualDensity.compact,
                        onPressed: paginaSegura > 1
                            ? () => setState(() => _paginaActual = paginaSegura - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      const SizedBox(width: 4),
                      ...List.generate(totalPaginas, (index) {
                        final numPag = index + 1;
                        final activa = numPag == paginaSegura;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () =>
                                setState(() => _paginaActual = numPag),
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: activa
                                    ? const Color(0xFF026AA7)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: activa
                                      ? const Color(0xFF026AA7)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Text(
                                '$numPag',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: activa
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Página siguiente',
                        visualDensity: VisualDensity.compact,
                        onPressed: paginaSegura < totalPaginas
                            ? () => setState(() => _paginaActual = paginaSegura + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}