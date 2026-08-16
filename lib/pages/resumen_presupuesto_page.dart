import 'dart:io';
import 'package:flutter/material.dart';
import '../models/presupuesto.dart';

class ResumenPresupuestoPage extends StatelessWidget {
  final Presupuesto presupuesto;

  const ResumenPresupuestoPage({super.key, required this.presupuesto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Presupuesto'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DATOS DEL TRABAJO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Tipo de trabajo: ${presupuesto.tipoTrabajo}'),
              Text('Descripción: ${presupuesto.descripcion ?? '-'}'),
              Text('Ubicación: ${presupuesto.ubicacion ?? '-'}'),
              Text('Cliente: ${presupuesto.clienteNombre ?? '-'}'),
              Text('Teléfono: ${presupuesto.telefono ?? '-'}'),
              Text('Fecha inicio: ${presupuesto.fechaInicio != null ? '${presupuesto.fechaInicio!.day}/${presupuesto.fechaInicio!.month}/${presupuesto.fechaInicio!.year}' : '-'}'),
              Text('Duración aproximada: ${presupuesto.duracionAproximada != null && presupuesto.duracionAproximada! > 0 ? '${presupuesto.duracionAproximada! % 1 == 0 ? presupuesto.duracionAproximada!.toStringAsFixed(0) : presupuesto.duracionAproximada!.toStringAsFixed(2)} ${presupuesto.unidadDuracion ?? 'Días'}' : '-'}'),
              if ((presupuesto.notasAdicionales ?? '').trim().isNotEmpty)
                Text('Notas adicionales: ${presupuesto.notasAdicionales}'),
              const SizedBox(height: 16),

              const Text('MANO DE OBRA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              presupuesto.manoObra.isEmpty
                  ? const Text('- No hay mano de obra agregada -')
                  : Column(
                      children: presupuesto.manoObra.map((m) {
                        return ListTile(
                          title: Text(m.descripcion),
                          subtitle: Text('Función: ${m.tipo} • Días: ${m.dias} • Precio/día: \$${m.precioDia.toStringAsFixed(2)}'),
                          trailing: Text('\$${m.subtotal.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 8),
              Text('Total mano de obra: \$${presupuesto.totalManoObra.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('MATERIALES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              presupuesto.materiales.isEmpty
                  ? const Text('- No hay materiales agregados -')
                  : Column(
                      children: presupuesto.materiales.map((mat) {
                        return ListTile(
                          title: Text(mat.nombre),
                          subtitle: Text('Cantidad: ${mat.cantidad} • Unidad/Precio: \$${mat.precio.toStringAsFixed(2)}'),
                          trailing: Text('\$${mat.subtotal.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 8),
              Text('Total materiales: \$${presupuesto.totalMateriales.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              if (presupuesto.fotosTrabajo.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('FOTOS DEL TRABAJO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: presupuesto.fotosTrabajo.length,
                    itemBuilder: (context, index) {
                      final path = presupuesto.fotosTrabajo[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('RESUMEN ECONÓMICO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Total mano de obra: \$${presupuesto.totalManoObra.toStringAsFixed(2)}'),
              Text('Total materiales: \$${presupuesto.totalMateriales.toStringAsFixed(2)}'),
              Text('Transporte / Flete: \$${presupuesto.transporte.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('TOTAL GENERAL: \$${presupuesto.totalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
