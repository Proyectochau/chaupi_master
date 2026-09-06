import 'package:flutter/material.dart';

import '../models/proforma_ferreteria.dart';
import '../models/solicitud_materiales.dart';
import '../services/proforma_ferreteria_storage.dart';
import '../services/solicitud_materiales_storage.dart';

class ResponderProformaPage extends StatefulWidget {
  final SolicitudMateriales solicitud;

  const ResponderProformaPage({super.key, required this.solicitud});

  @override
  State<ResponderProformaPage> createState() => _ResponderProformaPageState();
}

class _ResponderProformaPageState extends State<ResponderProformaPage> {
  final ProformaFerreteriaStorage _storage = ProformaFerreteriaStorage();
  final TextEditingController _costoEntregaController = TextEditingController();
  final TextEditingController _tiempoEntregaController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _ferreteriaController = TextEditingController(
    text: 'Ferretería actual',
  );

  late final List<ProformaFerreteriaItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.solicitud.materiales
        .map(
          (material) => ProformaFerreteriaItem(
            materialNombre: material.nombre,
            cantidadSolicitada: material.cantidad,
            tieneStock: true,
            cantidadDisponible: material.cantidad,
            precioUnitario: material.precio,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _costoEntregaController.dispose();
    _tiempoEntregaController.dispose();
    _observacionesController.dispose();
    _ferreteriaController.dispose();
    super.dispose();
  }

  bool _isValido() {
    if (_items.isEmpty) {
      return false;
    }

    for (final item in _items) {
      if (item.materialNombre.trim().isEmpty) {
        return false;
      }
      if (item.precioUnitario <= 0) {
        return false;
      }
    }

    return true;
  }

  Future<void> _guardarProforma() async {
    if (!_isValido()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa el stock y el precio ofertado de cada material.',
          ),
        ),
      );
      return;
    }

    final proforma = ProformaFerreteria(
      id: 'proforma_${DateTime.now().microsecondsSinceEpoch}',
      solicitudId: widget.solicitud.id,
      ferreteriaNombre: _ferreteriaController.text.trim().isEmpty
          ? 'Ferretería sin identificar'
          : _ferreteriaController.text.trim(),
      fechaRespuesta: DateTime.now(),
      items: _items,
      costoEntrega:
          double.tryParse(_costoEntregaController.text.replaceAll(',', '.')) ??
          0,
      tiempoEntrega: _tiempoEntregaController.text.trim(),
      observaciones: _observacionesController.text.trim(),
      estado: 'enviada',
    );

    await _storage.guardar(proforma);

    final solicitudes = await SolicitudMaterialesStorage().obtenerTodos();
    final index = solicitudes.indexWhere(
      (item) => item.id == widget.solicitud.id,
    );
    if (index != -1) {
      solicitudes[index].estado = EstadoSolicitudMateriales.respondida;
      await SolicitudMaterialesStorage().actualizar(solicitudes[index]);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proforma enviada correctamente.')),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder proforma'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solicitud #${widget.solicitud.id.substring(0, widget.solicitud.id.length > 4 ? 4 : widget.solicitud.id.length).toUpperCase()}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Materiales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._items.asMap().entries.map((entry) {
              final item = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.materialNombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Tiene stock:'),
                          const SizedBox(width: 8),
                          Switch(
                            value: item.tieneStock,
                            onChanged: (value) {
                              setState(() {
                                item.tieneStock = value;
                                if (!value) {
                                  item.cantidadDisponible = 0;
                                } else {
                                  item.cantidadDisponible =
                                      item.cantidadSolicitada;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: item.cantidadDisponible.toStringAsFixed(
                          0,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Cantidad disponible',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          item.cantidadDisponible =
                              double.tryParse(value.replaceAll(',', '.')) ?? 0;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: item.precioUnitario > 0
                            ? item.precioUnitario.toString()
                            : '',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Precio unitario ofertado',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          item.precioUnitario =
                              double.tryParse(value.replaceAll(',', '.')) ?? 0;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: item.observacion,
                        decoration: const InputDecoration(
                          labelText: 'Observación',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          item.observacion = value;
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Datos generales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ferreteriaController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la ferretería',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costoEntregaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Costo de entrega / flete',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tiempoEntregaController,
              decoration: const InputDecoration(
                labelText: 'Tiempo estimado de entrega',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacionesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observaciones generales',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarProforma,
                icon: const Icon(Icons.send),
                label: const Text('ENVIAR PROFORMA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
