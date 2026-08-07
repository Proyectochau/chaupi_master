import 'package:flutter/material.dart';
import '../models/material.dart';
class MaterialesPage extends StatefulWidget {
  const MaterialesPage({super.key});
@override
State<MaterialesPage> createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  final TextEditingController materialController = TextEditingController();
final TextEditingController cantidadController = TextEditingController();
final TextEditingController precioController = TextEditingController();

final List<MaterialItem> materiales = [];
double get totalMateriales {
  double total = 0;

  for (final material in materiales) {
    total += material.subtotal;
  }

  return total;
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
    materiales.add(
  MaterialItem(
    nombre: materialController.text,
    cantidad: double.parse(cantidadController.text),
    precio: double.parse(precioController.text),
  ),
);
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