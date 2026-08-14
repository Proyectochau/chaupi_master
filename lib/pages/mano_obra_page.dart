import 'package:flutter/material.dart';
import '../models/mano_obra.dart';
import '../models/presupuesto.dart';
import 'materiales_page.dart';

class ManoObraPage extends StatefulWidget {
  final Presupuesto presupuesto;

  const ManoObraPage({super.key, required this.presupuesto});

  @override
  State<ManoObraPage> createState() => _ManoObraPageState();
}

class _ManoObraPageState extends State<ManoObraPage> {
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController funcionController = TextEditingController();
  final TextEditingController diasController = TextEditingController();
  final TextEditingController precioController = TextEditingController();

  late List<ManoObraItem> integrantes;
  String categoriaActual = 'Trabajador';

  double get totalManoObra {
    return widget.presupuesto.totalManoObra;
  }

  void agregarIntegrante() {
    final descripcion = descripcionController.text.trim();
    final funcion = funcionController.text.trim();
    final dias = double.tryParse(diasController.text.replaceAll(',', '.')) ?? 0;
    final precio = double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0;

    if (descripcion.isEmpty || funcion.isEmpty || dias <= 0 || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete todos los campos con valores válidos.'),
        ),
      );
      return;
    }

    setState(() {
      final item = ManoObraItem(
        descripcion: descripcion,
        tipo: funcion,
        categoria: categoriaActual,
        dias: dias,
        precioDia: precio,
      );
      integrantes.add(item);
      // also add to presupuesto (same list reference)
      if (!widget.presupuesto.manoObra.contains(item)) {
        widget.presupuesto.manoObra.add(item);
      }
      descripcionController.clear();
      funcionController.clear();
      diasController.clear();
      precioController.clear();
      categoriaActual = 'Trabajador';
    });
  }

  @override
  void initState() {
    super.initState();
    integrantes = widget.presupuesto.manoObra;
  }

  @override
  void dispose() {
    descripcionController.dispose();
    funcionController.dispose();
    diasController.dispose();
    precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mano de obra / Cuadrilla'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trabajo: ${widget.presupuesto.tipoTrabajo}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Nombre / descripción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: funcionController,
              decoration: const InputDecoration(
                labelText: 'Tipo de trabajador / función',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: diasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Días / jornadas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio por día',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: categoriaActual,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Categoría',
              ),
              items: const [
                DropdownMenuItem(value: 'Trabajador', child: Text('Trabajador')),
                DropdownMenuItem(value: 'Chaupi', child: Text('Chaupi')),
                DropdownMenuItem(value: 'Ayudante', child: Text('Ayudante')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    categoriaActual = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('AGREGAR INTEGRANTE'),
                onPressed: agregarIntegrante,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Total mano de obra: \$${totalManoObra.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: integrantes.isEmpty
                  ? const Center(
                      child: Text('No hay integrantes agregados aún.'),
                    )
                  : ListView.builder(
                      itemCount: integrantes.length,
                      itemBuilder: (context, index) {
                        final integrante = integrantes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(integrante.descripcion),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Función: ${integrante.tipo}'),
                                Text('Categoría: ${integrante.categoria}'),
                                Text('Días: ${integrante.dias}'),
                                Text('Precio/día: \$${integrante.precioDia.toStringAsFixed(2)}'),
                                Text('Subtotal: \$${integrante.subtotal.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaterialesPage(presupuesto: widget.presupuesto),
                    ),
                  );
                },
                child: const Text('CONTINUAR A MATERIALES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
