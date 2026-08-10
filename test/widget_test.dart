import 'package:flutter_test/flutter_test.dart';
import 'package:chaupi_master/main.dart';

void main() {
  testWidgets('Chaupi Master inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const ChaupiMasterApp());

    expect(find.text('Chaupi Master'), findsOneWidget);
  });
}