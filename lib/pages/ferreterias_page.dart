import 'package:flutter/material.dart';
import '../models/ferreteria.dart';
import 'ferreteria_detail_page.dart';
import 'solicitudes_ferreteria_page.dart';

class FerreteriasPage extends StatefulWidget {
  const FerreteriasPage({super.key});

  @override
  State<FerreteriasPage> createState() => _FerreteriasPageState();
}

class _FerreteriasPageState extends State<FerreteriasPage> {
  late List<Ferreteria> ferreterias;

  @override
  void initState() {
    super.initState();
    ferreterias = _mockFerreterias();
    // Mostrar primero las destacadas
    ferreterias.sort((a, b) {
      if (a.destacada && !b.destacada) return -1;
      if (!a.destacada && b.destacada) return 1;
      return a.nombre.compareTo(b.nombre);
    });
  }

  List<Ferreteria> _mockFerreterias() {
    return [
          Ferreteria(
        nombre: 'Ferretería El Buen Clavo',
        sector: 'Centro',
        telefono: '+51 987 654 321',
        descripcion: 'Amplia variedad de materiales para construcción.',
        destacada: true,
        materiales: [
          // ignore: prefer_const_constructors
          FerreteriaMaterial(nombre: 'Cemento', unidad: 'Saco 50kg', precio: 20.0),
          FerreteriaMaterial(nombre: 'Arena', unidad: 'm3', precio: 15.0),
        ],
      ),
      Ferreteria(
        nombre: 'Distribuidora La Esquina',
        sector: 'Bajada',
        telefono: '+51 976 543 210',
        descripcion: 'Productos eléctricos y herramientas.',
        destacada: false,
        materiales: [
          FerreteriaMaterial(nombre: 'Cable 2.5mm', unidad: 'Rollos', precio: 30.0),
        ],
      ),
      Ferreteria(
        nombre: 'Patrocinador ConstruShop',
        sector: 'Industrial',
        telefono: '+51 912 345 678',
        descripcion: 'Mayorista y patrocinador del app.',
        destacada: true,
        materiales: [
          FerreteriaMaterial(nombre: 'Ladrillo', unidad: 'Unidad', precio: 0.5),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ferreterías'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SolicitudesFerreteriaPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.request_quote_outlined),
                label: const Text('SOLICITUDES DE PROFORMA'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: ferreterias.length,
                itemBuilder: (context, index) {
                  final f = ferreterias[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FerreteriaDetailPage(ferreteria: f),
                          ),
                        );
                      },
                      leading: f.destacada
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DESTACADA',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            )
                          : const Icon(Icons.storefront_outlined),
                      title: Text(
                        f.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.sector),
                          const SizedBox(height: 4),
                          Text(f.telefono),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
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
