import 'package:flutter/material.dart';

import '../models/solicitud_materiales.dart';
import '../services/solicitud_materiales_storage.dart';
import 'responder_proforma_page.dart';

String _codigoSolicitud(String id) {
  final limpio = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  if (limpio.isEmpty) {
    return 'A1A1';
  }

  var codigoNumerico = 0;
  for (final rune in limpio.runes) {
    codigoNumerico = ((codigoNumerico * 131) + rune) & 0x7fffffff;
  }

  var codigo = codigoNumerico.toRadixString(36).toUpperCase();
  if (codigo.length < 4) {
    codigo = codigo.padRight(4, 'A');
  }

  return codigo.substring(0, 4);
}

class SolicitudFerreteriaDetallePage extends StatefulWidget {
  final SolicitudMateriales solicitud;

  const SolicitudFerreteriaDetallePage({super.key, required this.solicitud});

  @override
  State<SolicitudFerreteriaDetallePage> createState() =>
      _SolicitudFerreteriaDetallePageState();
}

class _SolicitudFerreteriaDetallePageState
    extends State<SolicitudFerreteriaDetallePage> {
  late SolicitudMateriales solicitud;

  @override
  void initState() {
    super.initState();
    solicitud = widget.solicitud;
  }

  Future<void> _recargarSolicitud() async {
    final solicitudes = await SolicitudMaterialesStorage().obtenerTodos();
    final encontrada = solicitudes.firstWhere(
      (item) => item.id == solicitud.id,
      orElse: () => solicitud,
    );

    if (!mounted) return;
    setState(() {
      solicitud = encontrada;
    });
  }

  String _formatFecha(DateTime fecha) {
    final fechaLocal = fecha.toLocal();
    return '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year}';
  }

  String _estadoTexto(EstadoSolicitudMateriales estado) {
    switch (estado) {
      case EstadoSolicitudMateriales.borrador:
        return 'Borrador';
      case EstadoSolicitudMateriales.pendiente:
        return 'Pendiente';
      case EstadoSolicitudMateriales.enviada:
        return 'Enviada';
      case EstadoSolicitudMateriales.respondida:
        return 'Respondida';
      case EstadoSolicitudMateriales.proformaSeleccionada:
        return 'Proforma seleccionada';
      case EstadoSolicitudMateriales.cancelada:
        return 'Cancelada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de solicitud'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solicitud #${_codigoSolicitud(solicitud.id)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Fecha',
              value: _formatFecha(solicitud.fechaCreacion),
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Estado', value: _estadoTexto(solicitud.estado)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResponderProformaPage(solicitud: solicitud),
                    ),
                  );
                  await _recargarSolicitud();
                },
                icon: const Icon(Icons.reply_all),
                label: const Text('RESPONDER PROFORMA'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Materiales solicitados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (solicitud.materiales.isEmpty)
              const Text('No hay materiales en esta solicitud.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: solicitud.materiales.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final material = solicitud.materiales[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Cantidad solicitada: ${material.cantidad}'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          material.precio > 0
                              ? 'Precio ref.: \$${material.precio.toStringAsFixed(2)}'
                              : 'Sin precio',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
