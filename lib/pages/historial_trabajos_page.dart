import 'package:flutter/material.dart';

import '../models/presupuesto.dart';
import '../services/presupuesto_storage.dart';
import 'resumen_presupuesto_page.dart';

class HistorialTrabajosPage extends StatefulWidget {
  const HistorialTrabajosPage({super.key});

  @override
  State<HistorialTrabajosPage> createState() => _HistorialTrabajosPageState();
}

class _HistorialTrabajosPageState extends State<HistorialTrabajosPage> {
  late Future<List<Presupuesto>> _presupuestosFuture;

  @override
  void initState() {
    super.initState();
    _presupuestosFuture = PresupuestoStorage().obtenerTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de trabajos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Presupuesto>>(
        future: _presupuestosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final presupuestos = snapshot.data ?? [];
          if (presupuestos.isEmpty) {
            return const Center(child: Text('No hay presupuestos guardados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: presupuestos.length,
            itemBuilder: (context, index) {
              final presupuesto = presupuestos[index];
              return Card(
                child: ListTile(
                  title: Text(presupuesto.clienteNombre?.isNotEmpty == true
                      ? presupuesto.clienteNombre!
                      : 'Cliente sin nombre'),
                  subtitle: Text(
                    'Trabajo: ${presupuesto.tipoTrabajo}\n'
                    'Ubicación: ${presupuesto.ubicacion?.isNotEmpty == true ? presupuesto.ubicacion : '-'}\n'
                    'Total: \$${presupuesto.totalGeneral.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResumenPresupuestoPage(
                          presupuesto: presupuesto,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}