import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaupi_master/main.dart';
import 'package:chaupi_master/pages/solicitudes_ferreteria_page.dart';
import 'package:chaupi_master/models/solicitud_materiales.dart';
import 'package:chaupi_master/models/material.dart';
import 'dart:convert';
import 'package:chaupi_master/models/proforma_ferreteria.dart';
import 'package:chaupi_master/pages/solicitud_maestro_detalle_page.dart';
import 'package:chaupi_master/services/solicitud_materiales_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('La confirmación del pedido se persiste con su proforma', () {
    final fecha = DateTime(2026, 9, 7, 10, 30);
    final solicitud = SolicitudMateriales(
      id: 'solicitud_confirmada',
      presupuestoId: 'presupuesto_1',
      nombre: 'Solicitud confirmada',
      fechaCreacion: DateTime(2026, 9, 6),
      estado: EstadoSolicitudMateriales.pedidoConfirmado,
      proformaSeleccionadaId: 'proforma_elegida',
      fechaPedidoConfirmado: fecha,
    );

    final recuperada = SolicitudMateriales.fromJson(solicitud.toJson());

    expect(recuperada.estado, EstadoSolicitudMateriales.pedidoConfirmado);
    expect(recuperada.proformaSeleccionadaId, 'proforma_elegida');
    expect(recuperada.fechaPedidoConfirmado, fecha);
  });

  test(
    'Solo la proforma seleccionada queda representada por su referencia',
    () {
      final solicitud = SolicitudMateriales.fromJson({
        'id': 'solicitud_confirmada',
        'presupuestoId': 'presupuesto_1',
        'nombre': 'Solicitud confirmada',
        'fechaCreacion': '2026-09-06T00:00:00.000',
        'materiales': [],
        'estado': 'pedidoConfirmado',
        'proformaSeleccionadaId': 'proforma_elegida',
      });

      expect(solicitud.proformaSeleccionadaId, 'proforma_elegida');
      expect(solicitud.proformaSeleccionadaId, isNot('proforma_otra'));
    },
  );

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

  testWidgets('Se puede confirmar el pedido y se bloquea el cambio', (
    WidgetTester tester,
  ) async {
    final solicitud = SolicitudMateriales(
      id: 'solicitud_widget',
      presupuestoId: 'presupuesto_1',
      nombre: 'Solicitud widget',
      fechaCreacion: DateTime(2026, 9, 6),
      materiales: [MaterialItem(nombre: 'Cemento', cantidad: 1, precio: 10)],
      estado: EstadoSolicitudMateriales.respondida,
    );
    final proformaElegida = ProformaFerreteria(
      id: 'proforma_elegida',
      solicitudId: solicitud.id,
      ferreteriaNombre: 'Ferretería elegida',
      fechaRespuesta: DateTime(2026, 9, 6),
      items: [
        ProformaFerreteriaItem(
          materialNombre: 'Cemento',
          cantidadSolicitada: 1,
          cantidadDisponible: 1,
          precioUnitario: 10,
        ),
      ],
    );
    final proformaOtra = ProformaFerreteria(
      id: 'proforma_otra',
      solicitudId: solicitud.id,
      ferreteriaNombre: 'Otra ferretería',
      fechaRespuesta: DateTime(2026, 9, 6),
    );
    SharedPreferences.setMockInitialValues({
      'solicitudes_materiales_guardadas': jsonEncode([solicitud.toJson()]),
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SolicitudMaestroDetallePage(
          solicitud: solicitud,
          proformas: [proformaElegida, proformaOtra],
        ),
      ),
    );

    final tarjetaProformaElegida = find.ancestor(
      of: find.text('Ferretería elegida'),
      matching: find.byType(Card),
    );
    final botonSeleccionarProforma = find.descendant(
      of: tarjetaProformaElegida,
      matching: find.text('SELECCIONAR PROFORMA'),
    );

    await tester.scrollUntilVisible(
      botonSeleccionarProforma,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(botonSeleccionarProforma, findsOneWidget);
    await Scrollable.ensureVisible(
      tester.element(botonSeleccionarProforma),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    await tester.tap(botonSeleccionarProforma);
    await tester.pumpAndSettle();
    expect(find.text('Confirmar selección'), findsOneWidget);
    expect(find.text('CONFIRMAR'), findsOneWidget);
    await tester.tap(find.text('CONFIRMAR'));
    await tester.pumpAndSettle();
    expect(solicitud.proformaSeleccionadaId, proformaElegida.id);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Proforma seleccionada correctamente.'), findsNothing);

    final confirmarPedidoFinder = find.text('CONFIRMAR PEDIDO');
    await tester.scrollUntilVisible(
      confirmarPedidoFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(confirmarPedidoFinder, findsOneWidget);
    await Scrollable.ensureVisible(
      tester.element(confirmarPedidoFinder),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();

    final confirmarPedidoButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: confirmarPedidoFinder,
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(confirmarPedidoButton.onPressed, isNotNull);
    await tester.tap(confirmarPedidoFinder);
    await tester.pumpAndSettle();
    expect(find.text('Confirmar pedido'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(solicitud.estado, EstadoSolicitudMateriales.pedidoConfirmado);
    expect(solicitud.proformaSeleccionadaId, 'proforma_elegida');
    expect(find.text('PEDIDO CONFIRMADO'), findsOneWidget);
    final cambiarProformaFinder = find.text('CAMBIAR PROFORMA SELECCIONADA');
    expect(cambiarProformaFinder, findsOneWidget);
    final cambiarProformaButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: cambiarProformaFinder,
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(cambiarProformaButton.onPressed, isNull);

    final seleccionarProformaButtons = tester.widgetList<ElevatedButton>(
      find.ancestor(
        of: find.text('SELECCIONAR PROFORMA'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(seleccionarProformaButtons, isNotEmpty);
    for (final button in seleccionarProformaButtons) {
      expect(button.onPressed, isNull);
    }

    expect(find.text('PROFORMA SELECCIONADA'), findsOneWidget);

    final recargada = (await SolicitudMaterialesStorage().obtenerTodos())
        .singleWhere((item) => item.id == solicitud.id);
    expect(recargada.estado, EstadoSolicitudMateriales.pedidoConfirmado);
    expect(recargada.proformaSeleccionadaId, 'proforma_elegida');
  });
}
