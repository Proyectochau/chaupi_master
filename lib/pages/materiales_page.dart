import 'package:flutter/material.dart';
import '../models/material.dart';
import '../models/presupuesto.dart';
import 'resumen_presupuesto_page.dart';

class MaterialesPage extends StatefulWidget {
  final Presupuesto? presupuesto;

  const MaterialesPage({super.key, this.presupuesto});
@override
State<MaterialesPage> createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController transporteController = TextEditingController();

  late List<MaterialItem> materiales;

  double get totalMateriales {
    if (widget.presupuesto != null) {
      return widget.presupuesto!.totalMateriales;
    }

    return materiales.fold(0, (s, m) => s + m.subtotal);
  }

  double get totalTransporte {
    if (widget.presupuesto != null) {
      return widget.presupuesto!.transporte;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    materiales = widget.presupuesto?.materiales ?? [];
    transporteController.text = widget.presupuesto?.transporte.toString() ?? '0';
  }

  @override
  void dispose() {
    materialController.dispose();
    cantidadController.dispose();
    precioController.dispose();
    transporteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: materialController,
              decoration: const InputDecoration(
                labelText: 'Buscar material',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio unitario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('AGREGAR MATERIAL'),
                onPressed: () {
                  setState(() {
                    final item = MaterialItem(
                      nombre: materialController.text,
                      cantidad: double.tryParse(cantidadController.text.replaceAll(',', '.')) ?? 0,
                      precio: double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0,
                    );
                    materiales.add(item);
                    if (widget.presupuesto != null && !widget.presupuesto!.materiales.contains(item)) {
                      widget.presupuesto!.materiales.add(item);
                    }
                  });

                  materialController.clear();
                  cantidadController.clear();
                  precioController.clear();
                },
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Total materiales: \$${totalMateriales.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transporte / Flete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: transporteController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;
                if (widget.presupuesto != null) {
                  widget.presupuesto!.transporte = parsed;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Costo de transporte',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transporte / Flete: \$${totalTransporte.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Presupuesto guardado correctamente'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR PRESUPUESTO'),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.presupuesto != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResumenPresupuestoPage(presupuesto: widget.presupuesto!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.summarize),
                  label: const Text('VER RESUMEN'),
                ),
              ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: materiales.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    materiales[index].nombre,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${materiales[index].cantidad}'),
                      Text('Precio: ${materiales[index].precio}'),
                      Text('Subtotal: ${materiales[index].subtotal}'),
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