import 'package:flutter/material.dart';
import '../models/ferreteria.dart';

class FerreteriaDetailPage extends StatelessWidget {
  final Ferreteria ferreteria;

  const FerreteriaDetailPage({super.key, required this.ferreteria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ferreteria.nombre),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ferreteria.sector,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (ferreteria.destacada)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PATROCINADA',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Teléfono: ${ferreteria.telefono}'),
            const SizedBox(height: 12),
            Text(ferreteria.descripcion),
            const SizedBox(height: 20),
            const Text(
              'Materiales disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: ferreteria.materiales.length,
                itemBuilder: (context, index) {
                  final m = ferreteria.materiales[index];
                  return ListTile(
                    title: Text(m.nombre),
                    subtitle: Text(m.unidad),
                    trailing: Text('\$${m.precio.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
