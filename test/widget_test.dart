import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaupi_master/main.dart';
import 'package:chaupi_master/pages/solicitudes_ferreteria_page.dart';

void main() {
  testWidgets('Chaupi Master inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const ChaupiMasterApp());

    expect(find.text('Chaupi Master'), findsOneWidget);
  });

  testWidgets('La pantalla de solicitudes de ferretería renderiza el título', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SolicitudesFerreteriaPage()));

    expect(find.text('Solicitudes de proforma'), findsOneWidget);
  });
}