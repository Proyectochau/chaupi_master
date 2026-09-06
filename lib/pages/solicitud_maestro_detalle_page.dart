import 'package:flutter/material.dart';

import '../models/proforma_ferreteria.dart';
import '../models/solicitud_materiales.dart';

class SolicitudMaestroDetallePage extends StatelessWidget {
  final SolicitudMateriales solicitud;
  final List<ProformaFerreteria> proformas;

  const SolicitudMaestroDetallePage({
    super.key,
    required this.solicitud,
    required this.proformas,
  });

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

  @override
  Widget build(BuildContext context) {
    final respuestas = [...proformas]..sort((a, b) => _total(a).compareTo(_total(b)));
    final respondida = respuestas.isNotEmpty ||
        solicitud.estado == EstadoSolicitudMateriales.respondida;

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
          Text('Estado: ${respondida ? 'Respondida' : 'Pendiente'}'),
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
              ),
            ),
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

  const _ProformaCard({
    required this.proforma,
    required this.posicion,
    required this.total,
    required this.ferreteria,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text('$posicion'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ferreteria,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...proforma.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.materialNombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${item.cantidadDisponible} de ${item.cantidadSolicitada}  |  Unitario: \$${item.precioUnitario.toStringAsFixed(2)}',
                    ),
                    Text('Subtotal: \$${(item.cantidadDisponible * item.precioUnitario).toStringAsFixed(2)}'),
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
          ],
        ),
      ),
    );
  }
}
