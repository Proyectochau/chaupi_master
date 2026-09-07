import 'package:flutter/material.dart';

import '../models/proforma_ferreteria.dart';
import '../models/solicitud_materiales.dart';
import '../services/solicitud_materiales_storage.dart';

class SolicitudMaestroDetallePage extends StatefulWidget {
  final SolicitudMateriales solicitud;
  final List<ProformaFerreteria> proformas;

  const SolicitudMaestroDetallePage({
    super.key,
    required this.solicitud,
    required this.proformas,
  });

  @override
  State<SolicitudMaestroDetallePage> createState() =>
      _SolicitudMaestroDetallePageState();
}

class _SolicitudMaestroDetallePageState
    extends State<SolicitudMaestroDetallePage> {
  late SolicitudMateriales solicitud;
  bool _confirmandoSeleccion = false;
  bool _guardandoSeleccion = false;
  bool _confirmandoPedido = false;

  @override
  void initState() {
    super.initState();
    solicitud = widget.solicitud;
  }

  double _total(ProformaFerreteria proforma) {
    final materiales = proforma.items.fold<double>(
      0,
      (total, item) => total + (item.cantidadDisponible * item.precioUnitario),
    );
    return materiales + proforma.costoEntrega;
  }

  String _ferreteria(ProformaFerreteria proforma) {
    final nombre = proforma.ferreteriaNombre.trim();
    return nombre.isEmpty ? 'Ferretería sin identificar' : nombre;
  }

  bool get _pedidoConfirmado =>
      solicitud.estado == EstadoSolicitudMateriales.pedidoConfirmado;

  ProformaFerreteria? get _proformaSeleccionada {
    final id = solicitud.proformaSeleccionadaId;
    if (id == null) return null;
    for (final proforma in widget.proformas) {
      if (proforma.id == id) return proforma;
    }
    return null;
  }

  Future<void> _seleccionarProforma(ProformaFerreteria proforma) async {
    if (_pedidoConfirmado || _confirmandoSeleccion || _guardandoSeleccion) {
      return;
    }

    setState(() => _confirmandoSeleccion = true);
    final total = _total(proforma);
    final confirmada = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar selección'),
        content: Text(
          '${_ferreteria(proforma)}\n'
          'Total: \$${total.toStringAsFixed(2)}\n\n'
          'Esta será la propuesta elegida para esta solicitud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() => _confirmandoSeleccion = false);
    if (confirmada != true || _guardandoSeleccion) return;

    setState(() => _guardandoSeleccion = true);
    final idAnterior = solicitud.proformaSeleccionadaId;
    final estadoAnterior = solicitud.estado;
    solicitud.proformaSeleccionadaId = proforma.id;
    solicitud.estado = EstadoSolicitudMateriales.proformaSeleccionada;
    final guardada = await SolicitudMaterialesStorage().actualizar(solicitud);

    if (!mounted) return;
    if (!guardada) {
      solicitud.proformaSeleccionadaId = idAnterior;
      solicitud.estado = estadoAnterior;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la selección.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proforma seleccionada correctamente.')),
      );
    }
    setState(() => _guardandoSeleccion = false);
  }

  Future<void> _confirmarPedido() async {
    final proforma = _proformaSeleccionada;
    if (proforma == null || _pedidoConfirmado || _confirmandoPedido) return;

    setState(() => _confirmandoPedido = true);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar pedido'),
        content: Text(
          'Ferretería: ${_ferreteria(proforma)}\n'
          'Total elegido: \$${_total(proforma).toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() => _confirmandoPedido = false);
    if (confirmado != true || _pedidoConfirmado) return;

    final estadoAnterior = solicitud.estado;
    final fechaAnterior = solicitud.fechaPedidoConfirmado;
    solicitud.estado = EstadoSolicitudMateriales.pedidoConfirmado;
    solicitud.fechaPedidoConfirmado = DateTime.now();
    final guardada = await SolicitudMaterialesStorage().actualizar(solicitud);

    if (!mounted) return;
    if (!guardada) {
      solicitud.estado = estadoAnterior;
      solicitud.fechaPedidoConfirmado = fechaAnterior;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo confirmar el pedido.')),
      );
      return;
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido confirmado correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final respuestas = [...widget.proformas]
      ..sort((a, b) => _total(a).compareTo(_total(b)));
    final respondida =
        respuestas.isNotEmpty ||
        solicitud.estado == EstadoSolicitudMateriales.respondida ||
        solicitud.estado == EstadoSolicitudMateriales.proformaSeleccionada ||
        _pedidoConfirmado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de solicitud'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            solicitud.nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Estado: ${_pedidoConfirmado
                ? 'Pedido confirmado'
                : respondida
                ? 'Respondida'
                : 'Pendiente'}',
          ),
          const SizedBox(height: 20),
          const Text(
            'Materiales solicitados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...solicitud.materiales.map(
            (material) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(material.nombre),
              subtitle: Text('Cantidad: ${material.cantidad}'),
              trailing: Text(
                material.precio > 0
                    ? 'Ref. \$${material.precio.toStringAsFixed(2)}'
                    : 'Sin precio',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (respuestas.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no hay respuestas de ferreterías.'),
              ),
            )
          else ...[
            const Text(
              'Comparación de proformas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Ordenadas por total, de menor a mayor.'),
            const SizedBox(height: 12),
            ...respuestas.asMap().entries.map(
              (entry) => _ProformaCard(
                proforma: entry.value,
                posicion: entry.key + 1,
                total: _total(entry.value),
                ferreteria: _ferreteria(entry.value),
                seleccionada:
                    solicitud.proformaSeleccionadaId == entry.value.id,
                bloqueada:
                    _pedidoConfirmado ||
                    _confirmandoSeleccion ||
                    _guardandoSeleccion,
                onSeleccionar: () => _seleccionarProforma(entry.value),
              ),
            ),
            if (_proformaSeleccionada != null) ...[
              const SizedBox(height: 4),
              if (_pedidoConfirmado)
                const SizedBox(
                  width: double.infinity,
                  child: Chip(
                    avatar: Icon(Icons.check_circle),
                    label: Text('PEDIDO CONFIRMADO'),
                    backgroundColor: Colors.greenAccent,
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmandoPedido ? null : _confirmarPedido,
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('CONFIRMAR PEDIDO'),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ProformaCard extends StatelessWidget {
  final ProformaFerreteria proforma;
  final int posicion;
  final double total;
  final String ferreteria;
  final bool seleccionada;
  final bool bloqueada;
  final VoidCallback onSeleccionar;

  const _ProformaCard({
    required this.proforma,
    required this.posicion,
    required this.total,
    required this.ferreteria,
    required this.seleccionada,
    required this.bloqueada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: seleccionada ? Colors.green.shade50 : null,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: seleccionada ? Colors.green : Colors.transparent,
          width: seleccionada ? 2 : 0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, child: Text('$posicion')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ferreteria,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (seleccionada) ...[
              const SizedBox(height: 8),
              const SizedBox(
                width: double.infinity,
                child: Chip(
                  label: Text('PROFORMA SELECCIONADA'),
                  avatar: Icon(Icons.check, size: 16),
                  backgroundColor: Colors.greenAccent,
                ),
              ),
            ],
            const Divider(height: 24),
            ...proforma.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.materialNombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${item.cantidadDisponible} de ${item.cantidadSolicitada}  |  Unitario: \$${item.precioUnitario.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Subtotal: \$${(item.cantidadDisponible * item.precioUnitario).toStringAsFixed(2)}',
                    ),
                    if (item.observacion.trim().isNotEmpty)
                      Text('Observación: ${item.observacion}'),
                  ],
                ),
              ),
            ),
            if (proforma.costoEntrega > 0)
              Text('Entrega: \$${proforma.costoEntrega.toStringAsFixed(2)}'),
            if (proforma.tiempoEntrega.trim().isNotEmpty)
              Text('Tiempo de entrega: ${proforma.tiempoEntrega}'),
            const SizedBox(height: 8),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (proforma.observaciones.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Observaciones: ${proforma.observaciones}'),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: bloqueada ? null : onSeleccionar,
                icon: Icon(
                  seleccionada ? Icons.swap_horiz : Icons.check_circle_outline,
                ),
                label: Text(
                  seleccionada
                      ? 'CAMBIAR PROFORMA SELECCIONADA'
                      : 'SELECCIONAR PROFORMA',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
