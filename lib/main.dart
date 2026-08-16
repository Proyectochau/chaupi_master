import 'package:flutter/material.dart';
import 'pages/mano_obra_page.dart';
import 'models/presupuesto.dart';
import 'pages/ferreterias_page.dart';
void main() {
  runApp(const ChaupiMasterApp());
}

class ChaupiMasterApp extends StatelessWidget {
  const ChaupiMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chaupi Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaupi Master'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
  const SizedBox(height: 10),
  const Text(
    'Bienvenido',
    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 8),
  const Text(
    'Tu asistente para presupuestos de construcción.',
    style: TextStyle(fontSize: 16),
  ),
  const SizedBox(height: 24),
  _ActionCard(
    icon: Icons.calculate_outlined,
    title: 'Crear presupuesto',
    subtitle: 'Arma cotizaciones rápidas y ordenadas.',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreateBudgetPage(),
        ),
      );
    },
  ),
  const SizedBox(height: 12),
  _ActionCard(
    icon: Icons.history_outlined,
    title: 'Historial de trabajos',
    subtitle: 'Revisa clientes, obras y presupuestos anteriores.',
  ),
  const SizedBox(height: 12),
  _ActionCard(
    icon: Icons.storefront_outlined,
    title: 'Ferreterías y materiales',
    subtitle: 'Busca proveedores y productos.',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FerreteriasPage(),
        ),
      );
    },
  ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Empezar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  DateTime? fechaInicio;
  String? tipoTrabajo;

  final List<String> tiposTrabajo = [
    'Albañilería',
    'Electricidad',
    'Plomería',
    'Pintura',
    'Carpintería',
    'Soldadura',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Presupuesto'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione el tipo de trabajo:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: tipoTrabajo,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tipo de trabajo',
              ),
              items: tiposTrabajo.map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (nuevoTipo) {
                setState(() {
                  tipoTrabajo = nuevoTipo;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: tipoTrabajo == null
        ? null
        : () {
            final presupuesto = Presupuesto(tipoTrabajo: tipoTrabajo!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleTrabajoPage(
                  presupuesto: presupuesto,
                ),
              ),
            );
          },
    child: const Text('CONTINUAR'),
  ),
),
          ],
        ),
      ),
    );
  }
}
class DetalleTrabajoPage extends StatefulWidget {
  final Presupuesto presupuesto;

  const DetalleTrabajoPage({
    super.key,
    required this.presupuesto,
  });
@override
State<DetalleTrabajoPage> createState() => _DetalleTrabajoPageState();
}

class _DetalleTrabajoPageState extends State<DetalleTrabajoPage> {
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController duracionController = TextEditingController();
  final TextEditingController notasController = TextEditingController();

  DateTime? fechaInicio;
  String unidadDuracionActual = 'Días';

  @override
  void initState() {
    super.initState();
    descripcionController.text = widget.presupuesto.descripcion ?? '';
    ubicacionController.text = widget.presupuesto.ubicacion ?? '';
    clienteController.text = widget.presupuesto.clienteNombre ?? '';
    telefonoController.text = widget.presupuesto.telefono ?? '';
    duracionController.text = widget.presupuesto.duracionAproximada?.toString() ?? '';
    notasController.text = widget.presupuesto.notasAdicionales ?? '';
    unidadDuracionActual = widget.presupuesto.unidadDuracion ?? 'Días';
    fechaInicio = widget.presupuesto.fechaInicio;
  }

  @override
  void dispose() {
    descripcionController.dispose();
    ubicacionController.dispose();
    clienteController.dispose();
    telefonoController.dispose();
    duracionController.dispose();
    notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Trabajo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Trabajo: ${widget.presupuesto.tipoTrabajo}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del trabajo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: clienteController,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono del cliente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Duración aproximada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: duracionController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: unidadDuracionActual,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Unidad',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Horas', child: Text('Horas')),
                      DropdownMenuItem(value: 'Días', child: Text('Días')),
                      DropdownMenuItem(value: 'Semanas', child: Text('Semanas')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          unidadDuracionActual = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: notasController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas adicionales (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: fechaInicio == null
                    ? 'Fecha estimada de inicio'
                    : 'Inicio: ${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (fecha != null) {
                  setState(() {
                    fechaInicio = fecha;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final duracion = double.tryParse(duracionController.text.replaceAll(',', '.')) ?? 0;
                  if (duracion <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese una duración aproximada mayor a 0.'),
                      ),
                    );
                    return;
                  }

                  widget.presupuesto.descripcion = descripcionController.text.trim();
                  widget.presupuesto.ubicacion = ubicacionController.text.trim();
                  widget.presupuesto.clienteNombre = clienteController.text.trim();
                  widget.presupuesto.telefono = telefonoController.text.trim();
                  widget.presupuesto.fechaInicio = fechaInicio;
                  widget.presupuesto.duracionAproximada = duracion;
                  widget.presupuesto.unidadDuracion = unidadDuracionActual;
                  widget.presupuesto.notasAdicionales = notasController.text.trim().isEmpty
                      ? null
                      : notasController.text.trim();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManoObraPage(
                        presupuesto: widget.presupuesto,
                      ),
                    ),
                  );
                },
                child: const Text('CONTINUAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel principal',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí construiremos las funciones principales de Chaupi Master.',
            ),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.person_outline,
              title: 'Clientes',
              subtitle: 'Gestiona datos de clientes y contactos.',
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.work_outline,
              title: 'Proyectos',
              subtitle: 'Organiza obras, avances y presupuesto.',
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Presupuestos',
              subtitle: 'Crea y revisa cotizaciones.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

 const _ActionCard({
  required this.icon,
  required this.title,
  required this.subtitle,
  this.onTap,
});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}