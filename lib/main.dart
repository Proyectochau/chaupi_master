import 'package:flutter/material.dart';
import 'pages/materiales_page.dart';
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleTrabajoPage(
                  tipoTrabajo: tipoTrabajo!,
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
  final String tipoTrabajo;

  const DetalleTrabajoPage({
    super.key,
    required this.tipoTrabajo,
  });
@override
State<DetalleTrabajoPage> createState() => _DetalleTrabajoPageState();
}

class _DetalleTrabajoPageState extends State<DetalleTrabajoPage> {
DateTime? fechaInicio;
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
            'Trabajo: ${widget.tipoTrabajo}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Descripción del trabajo',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del cliente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

const TextField(
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    labelText: 'Teléfono del cliente',
    border: OutlineInputBorder(),
  ),
),
            const SizedBox(height: 15),

TextField(
  readOnly: true,
  decoration:  InputDecoration(
    labelText: fechaInicio == null
    ? 'Fecha estimada de inicio'
    : 'Inicio: ${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}',
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.calendar_today),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MaterialesPage(),
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