import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaupi_master/main.dart';
import 'package:chaupi_master/pages/solicitudes_ferreteria_page.dart';
import 'package:chaupi_master/models/solicitud_materiales.dart';
import 'package:chaupi_master/models/material.dart';

void main() {
  testWidgets('Chaupi Master inicia correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChaupiMasterApp());

    expect(find.text('Chaupi Master'), findsOneWidget);
  });

  testWidgets('La pantalla de solicitudes de ferretería renderiza el título', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SolicitudesFerreteriaPage()),
    );

    expect(find.text('Solicitudes de proforma'), findsOneWidget);
  });

  test('La solicitud serializa y recupera la proforma seleccionada', () {
    final solicitud = SolicitudMateriales(
      id: 'solicitud_1',
      presupuestoId: 'presupuesto_1',
      nombre: 'Solicitud de materiales',
      fechaCreacion: DateTime(2026, 9, 6),
      materiales: [MaterialItem(nombre: 'Cemento', cantidad: 2, precio: 20)],
      estado: EstadoSolicitudMateriales.proformaSeleccionada,
      proformaSeleccionadaId: 'proforma_7',
    );

    final recuperada = SolicitudMateriales.fromJson(solicitud.toJson());

    expect(recuperada.estado, EstadoSolicitudMateriales.proformaSeleccionada);
    expect(recuperada.proformaSeleccionadaId, 'proforma_7');
  });

  test('Los datos antiguos sin selección conservan el estado y funcionan', () {
    final recuperada = SolicitudMateriales.fromJson({
      'id': 'solicitud_legacy',
      'presupuestoId': 'presupuesto_legacy',
      'nombre': 'Solicitud antigua',
      'fechaCreacion': '2026-09-06T00:00:00.000',
      'materiales': [],
      'estado': 'respondida',
    });

    expect(recuperada.estado, EstadoSolicitudMateriales.respondida);
    expect(recuperada.proformaSeleccionadaId, isNull);
  });
}
