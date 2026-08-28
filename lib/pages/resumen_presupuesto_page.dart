import 'dart:io';
import 'package:flutter/material.dart';
import '../models/presupuesto.dart';
import '../models/solicitud_materiales.dart';
import '../services/pdf_generator.dart';
import '../services/solicitud_materiales_storage.dart';

class ResumenPresupuestoPage extends StatefulWidget {
  final Presupuesto presupuesto;

  const ResumenPresupuestoPage({super.key, required this.presupuesto});

  @override
  State<ResumenPresupuestoPage> createState() => _ResumenPresupuestoPageState();
}

class _ResumenPresupuestoPageState extends State<ResumenPresupuestoPage> {
  bool _isGenerating = false;
  bool _isSharing = false;
  bool _isSavingSolicitud = false;

  Future<void> _handleGeneratePdf() async {
    setState(() => _isGenerating = true);
    try {
      await PdfGenerator.generateAndViewPresupuestoPdf(widget.presupuesto);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _handleSharePdf() async {
    setState(() => _isSharing = true);
    try {
      await PdfGenerator.sharePresupuestoPdf(widget.presupuesto);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _handleSolicitarProformas() async {
    if (widget.presupuesto.materiales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega materiales al presupuesto antes de solicitar proformas'),
        ),
      );
      return;
    }

    setState(() => _isSavingSolicitud = true);
    try {
      final ahora = DateTime.now();
      final presupuestoId = widget.presupuesto.id ??
          'presupuesto_${ahora.microsecondsSinceEpoch}';
      widget.presupuesto.id ??= presupuestoId;

      final solicitud = SolicitudMateriales(
        id: 'solicitud_${ahora.microsecondsSinceEpoch}',
        presupuestoId: presupuestoId,
        nombre: 'Solicitud de proformas - ${widget.presupuesto.tipoTrabajo}',
        fechaCreacion: ahora,
        materiales: widget.presupuesto.materiales,
        estado: EstadoSolicitudMateriales.pendiente,
      );

      await SolicitudMaterialesStorage().guardar(solicitud);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de proformas guardada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la solicitud: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingSolicitud = false);
      }
    }
  }

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
              Text('Tipo de trabajo: ${widget.presupuesto.tipoTrabajo}'),
              Text('Descripción: ${widget.presupuesto.descripcion ?? '-'}'),
              Text('Ubicación: ${widget.presupuesto.ubicacion ?? '-'}'),
              Text('Cliente: ${widget.presupuesto.clienteNombre ?? '-'}'),
              Text('Teléfono: ${widget.presupuesto.telefono ?? '-'}'),
              Text('Fecha inicio: ${widget.presupuesto.fechaInicio != null ? '${widget.presupuesto.fechaInicio!.day}/${widget.presupuesto.fechaInicio!.month}/${widget.presupuesto.fechaInicio!.year}' : '-'}'),
              Text('Duración aproximada: ${widget.presupuesto.duracionAproximada != null && widget.presupuesto.duracionAproximada! > 0 ? '${widget.presupuesto.duracionAproximada! % 1 == 0 ? widget.presupuesto.duracionAproximada!.toStringAsFixed(0) : widget.presupuesto.duracionAproximada!.toStringAsFixed(2)} ${widget.presupuesto.unidadDuracion ?? 'Días'}' : '-'}'),
              if ((widget.presupuesto.notasAdicionales ?? '').trim().isNotEmpty)
                Text('Notas adicionales: ${widget.presupuesto.notasAdicionales}'),
              const SizedBox(height: 16),

              const Text('MANO DE OBRA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              widget.presupuesto.manoObra.isEmpty
                  ? const Text('- No hay mano de obra agregada -')
                  : Column(
                      children: widget.presupuesto.manoObra.map((m) {
                        return ListTile(
                          title: Text(m.descripcion),
                          subtitle: Text('Función: ${m.tipo} • Días: ${m.dias} • Precio/día: \$${m.precioDia.toStringAsFixed(2)}'),
                          trailing: Text('\$${m.subtotal.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 8),
              Text('Total mano de obra: \$${widget.presupuesto.totalManoObra.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('MATERIALES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              widget.presupuesto.materiales.isEmpty
                  ? const Text('- No hay materiales agregados -')
                  : Column(
                      children: widget.presupuesto.materiales.map((mat) {
                        return ListTile(
                          title: Text(mat.nombre),
                          subtitle: Text('Cantidad: ${mat.cantidad} • Unidad/Precio: \$${mat.precio.toStringAsFixed(2)}'),
                          trailing: Text('\$${mat.subtotal.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 8),
              Text('Total materiales: \$${widget.presupuesto.totalMateriales.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              if (widget.presupuesto.fotosTrabajo.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('FOTOS DEL TRABAJO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.presupuesto.fotosTrabajo.length,
                    itemBuilder: (context, index) {
                      final path = widget.presupuesto.fotosTrabajo[index];
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
              Text('Total mano de obra: \$${widget.presupuesto.totalManoObra.toStringAsFixed(2)}'),
              Text('Total materiales: \$${widget.presupuesto.totalMateriales.toStringAsFixed(2)}'),
              Text('Transporte / Flete: \$${widget.presupuesto.transporte.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('TOTAL GENERAL: \$${widget.presupuesto.totalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _handleGeneratePdf,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(_isGenerating ? 'GENERANDO...' : 'GENERAR PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _handleSharePdf,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(_isSharing ? 'COMPARTIENDO...' : 'COMPARTIR PRESUPUESTO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSavingSolicitud ? null : _handleSolicitarProformas,
                  icon: _isSavingSolicitud
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.request_quote),
                  label: Text(
                    _isSavingSolicitud ? 'GUARDANDO...' : 'SOLICITAR PROFORMAS',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

