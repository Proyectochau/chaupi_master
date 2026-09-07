import 'package:flutter/material.dart';

import '../models/proforma_ferreteria.dart';
import '../models/solicitud_materiales.dart';
import '../services/proforma_ferreteria_storage.dart';
import '../services/solicitud_materiales_storage.dart';
import 'solicitud_maestro_detalle_page.dart';

double _totalProforma(ProformaFerreteria proforma) {
  final materiales = proforma.items.fold<double>(
    0,
    (total, item) => total + (item.cantidadDisponible * item.precioUnitario),
  );
  return materiales + proforma.costoEntrega;
}

String _nombreFerreteria(ProformaFerreteria proforma) {
  final nombre = proforma.ferreteriaNombre.trim();
  return nombre.isEmpty ? 'Ferretería sin identificar' : nombre;
}

class SolicitudesMaestroPage extends StatefulWidget {
  const SolicitudesMaestroPage({super.key});

  @override
  State<SolicitudesMaestroPage> createState() => _SolicitudesMaestroPageState();
}

class _SolicitudesMaestroPageState extends State<SolicitudesMaestroPage> {
  late Future<_SolicitudesMaestroData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_SolicitudesMaestroData> _loadData() async {
    final solicitudesFuture = SolicitudMaterialesStorage().obtenerTodos();
    final proformasFuture = ProformaFerreteriaStorage().obtenerTodos();
    final solicitudes = await solicitudesFuture;
    final proformas = await proformasFuture;
    return _SolicitudesMaestroData(solicitudes, proformas);
  }

  Future<void> _recargar() async {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes de proforma'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<_SolicitudesMaestroData>(
        future: _dataFuture,
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

          final data = snapshot.data!;
          final solicitudes = [...data.solicitudes]
            ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
          if (solicitudes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Todavía no tienes solicitudes de proforma.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final solicitud = solicitudes[index];
                final respuestas = data.proformas
                    .where((proforma) => proforma.solicitudId == solicitud.id)
                    .toList();
                final proformaSeleccionada = respuestas
                    .cast<ProformaFerreteria?>()
                    .firstWhere(
                      (proforma) =>
                          proforma?.id == solicitud.proformaSeleccionadaId,
                      orElse: () => null,
                    );
                final respondida =
                    respuestas.isNotEmpty ||
                    solicitud.estado == EstadoSolicitudMateriales.respondida;
                final pedidoConfirmado =
                    solicitud.estado ==
                    EstadoSolicitudMateriales.pedidoConfirmado;
                final seleccionada =
                    solicitud.proformaSeleccionadaId != null &&
                    (solicitud.estado ==
                            EstadoSolicitudMateriales.proformaSeleccionada ||
                        pedidoConfirmado);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: pedidoConfirmado
                          ? Colors.green.shade200
                          : respondida
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      child: Icon(
                        pedidoConfirmado
                            ? Icons.shopping_cart_checkout
                            : respondida
                            ? Icons.mark_email_read_outlined
                            : Icons.hourglass_empty,
                        color: respondida
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                    title: Text(
                      solicitud.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Materiales: ${solicitud.materiales.length}'),
                          const SizedBox(height: 4),
                          Text(
                            'Estado: ${pedidoConfirmado
                                ? 'Pedido confirmado'
                                : seleccionada
                                ? 'Proforma seleccionada'
                                : respondida
                                ? 'Respondida'
                                : 'Pendiente'}',
                          ),
                          if (proformaSeleccionada != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Elegida: ${_nombreFerreteria(proformaSeleccionada)} - '
                              '\$${_totalProforma(proformaSeleccionada).toStringAsFixed(2)}',
                            ),
                          ],
                          if (respuestas.length > 1) ...[
                            const SizedBox(height: 4),
                            Text('Respuestas: ${respuestas.length}'),
                          ],
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SolicitudMaestroDetallePage(
                            solicitud: solicitud,
                            proformas: respuestas,
                          ),
                        ),
                      );
                      await _recargar();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SolicitudesMaestroData {
  final List<SolicitudMateriales> solicitudes;
  final List<ProformaFerreteria> proformas;

  _SolicitudesMaestroData(this.solicitudes, this.proformas);
}
