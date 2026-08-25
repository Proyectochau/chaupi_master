import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/presupuesto.dart';

class PresupuestoStorage {
  static const _presupuestosKey = 'presupuestos_guardados';

  Future<void> guardar(Presupuesto presupuesto) async {
    final preferences = await SharedPreferences.getInstance();
    final presupuestos = await obtenerTodos();
    presupuestos.add(presupuesto);
    await preferences.setString(
      _presupuestosKey,
      jsonEncode(presupuestos.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<Presupuesto>> obtenerTodos() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getString(_presupuestosKey);
    if (data == null) return [];

    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => Presupuesto.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}