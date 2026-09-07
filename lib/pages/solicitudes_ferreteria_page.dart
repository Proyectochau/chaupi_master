import 'package:flutter/material.dart';

import '../models/solicitud_materiales.dart';
import '../services/solicitud_materiales_storage.dart';
import 'solicitud_ferreteria_detalle_page.dart';

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

class SolicitudesFerreteriaPage extends StatefulWidget {
  const SolicitudesFerreteriaPage({super.key});

  @override
  State<SolicitudesFerreteriaPage> createState() =>
      _SolicitudesFerreteriaPageState();
}

class _SolicitudesFerreteriaPageState extends State<SolicitudesFerreteriaPage> {
  late Future<List<SolicitudMateriales>> _solicitudesFuture;

  @override
  void initState() {
    super.initState();
    _solicitudesFuture = SolicitudMaterialesStorage().obtenerTodos();
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
      case EstadoSolicitudMateriales.pedidoConfirmado:
        return 'Pedido confirmado';
      case EstadoSolicitudMateriales.cancelada:
        return 'Cancelada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de proforma'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SolicitudMateriales>>(
        future: _solicitudesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No se pudieron cargar las solicitudes: ${snapshot.error}',
                ),
              ),
            );
          }

          final solicitudes = snapshot.data ?? [];
          final solicitudesOrdenadas = [...solicitudes]
            ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

          if (solicitudesOrdenadas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Todavía no hay solicitudes de proforma recibidas.',
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: solicitudesOrdenadas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final solicitud = solicitudesOrdenadas[index];
              final codigoSolicitud = _codigoSolicitud(solicitud.id);
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SolicitudFerreteriaDetallePage(
                          solicitud: solicitud,
                        ),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.request_quote, color: Colors.blue),
                  ),
                  title: Text(
                    'Solicitud #$codigoSolicitud',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${_formatFecha(solicitud.fechaCreacion)}'),
                        const SizedBox(height: 4),
                        Text('Materiales: ${solicitud.materiales.length}'),
                        const SizedBox(height: 4),
                        Text('Estado: ${_estadoTexto(solicitud.estado)}'),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
