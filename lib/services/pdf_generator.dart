import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/presupuesto.dart';

class PdfGenerator {
  static Future<void> generateAndSharePresupuestoPdf(Presupuesto presupuesto) async {
    final pdf = pw.Document();

    // Agregar página al PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Encabezado
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'CHAUPI MASTER',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Presupuesto de trabajo',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
            ),

            // Datos del trabajo
            pw.Text(
              'DATOS DEL TRABAJO',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Tipo de trabajo: ${presupuesto.tipoTrabajo}'),
                if ((presupuesto.clienteNombre ?? '').isNotEmpty)
                  pw.Text('Nombre del cliente: ${presupuesto.clienteNombre}'),
                if ((presupuesto.telefono ?? '').isNotEmpty)
                  pw.Text('Teléfono: ${presupuesto.telefono}'),
                if ((presupuesto.ubicacion ?? '').isNotEmpty)
                  pw.Text('Ubicación: ${presupuesto.ubicacion}'),
                if (presupuesto.fechaInicio != null)
                  pw.Text('Fecha estimada de inicio: ${presupuesto.fechaInicio!.day}/${presupuesto.fechaInicio!.month}/${presupuesto.fechaInicio!.year}'),
                if ((presupuesto.descripcion ?? '').isNotEmpty)
                  pw.Text('Descripción del trabajo: ${presupuesto.descripcion}'),
                if (presupuesto.duracionAproximada != null && presupuesto.duracionAproximada! > 0)
                  pw.Text('Duración aproximada: ${presupuesto.duracionAproximada! % 1 == 0 ? presupuesto.duracionAproximada!.toStringAsFixed(0) : presupuesto.duracionAproximada!.toStringAsFixed(2)} ${presupuesto.unidadDuracion ?? 'Días'}'),
              ],
            ),
            pw.SizedBox(height: 16),

            // Mano de obra
            pw.Text(
              'MANO DE OBRA / CUADRILLA',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (presupuesto.manoObra.isEmpty)
              pw.Text('- No hay mano de obra agregada -')
            else
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Encabezado de tabla
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Nombre',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Horas',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Tarifa',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Filas de datos
                  ...presupuesto.manoObra.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item.descripcion),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item.dias.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('\$${item.precioDia.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('\$${item.subtotal.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total mano de obra: \$${presupuesto.totalManoObra.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 16),

            // Materiales
            pw.Text(
              'MATERIALES',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (presupuesto.materiales.isEmpty)
              pw.Text('- No hay materiales agregados -')
            else
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Encabezado de tabla
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Nombre',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Cantidad',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Precio Unit.',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Filas de datos
                  ...presupuesto.materiales.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item.nombre),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item.cantidad.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('\$${item.precio.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('\$${item.subtotal.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total materiales: \$${presupuesto.totalMateriales.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 16),

            // Resumen económico
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total mano de obra: \$${presupuesto.totalManoObra.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Total materiales: \$${presupuesto.totalMateriales.toStringAsFixed(2)}'),
                  if (presupuesto.transporte > 0) ...[
                    pw.SizedBox(height: 4),
                    pw.Text('Transporte / Flete: \$${presupuesto.transporte.toStringAsFixed(2)}'),
                  ],
                  pw.SizedBox(height: 8),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'TOTAL GENERAL: \$${presupuesto.totalGeneral.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Notas adicionales
            if ((presupuesto.notasAdicionales ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text(
                'NOTAS ADICIONALES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(presupuesto.notasAdicionales!),
            ],
          ];
        },
      ),
    );

    // Si hay fotos, agregarlas en una página separada
    if (presupuesto.fotosTrabajo.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) {
            return [
              pw.Text(
                'FOTOS DEL TRABAJO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Column(
                children: [
                  ...presupuesto.fotosTrabajo.map((fotoPath) {
                    try {
                      if (File(fotoPath).existsSync()) {
                        final bytes = File(fotoPath).readAsBytesSync();
                        return pw.Column(
                          children: [
                            pw.Image(
                              pw.MemoryImage(bytes),
                              width: 400,
                              height: 300,
                              fit: pw.BoxFit.contain,
                            ),
                            pw.SizedBox(height: 16),
                          ],
                        );
                      }
                    } catch (e) {
                      // Ignorar fotos que no se puedan cargar
                    }
                    return pw.SizedBox.shrink();
                  }),
                ],
              ),
            ];
          },
        ),
      );
    }

    // Mostrar el PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
