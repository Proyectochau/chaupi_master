import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/presupuesto.dart';

class PresupuestoStorage {
  static const _presupuestosKey = 'presupuestos_guardados';
  static const _borradoresKey = 'borradores_guardados';

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

  Future<void> guardarBorrador(Presupuesto presupuesto) async {
    final preferences = await SharedPreferences.getInstance();
    final borradores = await obtenerBorradores();
    final ahora = DateTime.now();
    presupuesto.id ??= ahora.microsecondsSinceEpoch.toString();
    presupuesto.fechaActualizacion = ahora;

    final indice = borradores.indexWhere((item) => item.id == presupuesto.id);
    if (indice == -1) {
      borradores.add(presupuesto);
    } else {
      borradores[indice] = presupuesto;
    }

    await preferences.setString(
      _borradoresKey,
      jsonEncode(borradores.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<Presupuesto>> obtenerBorradores() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getString(_borradoresKey);
    if (data == null) return [];

    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => Presupuesto.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> eliminarBorrador(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final borradores = await obtenerBorradores();
    borradores.removeWhere((item) => item.id == id);
    await preferences.setString(
      _borradoresKey,
      jsonEncode(borradores.map((item) => item.toJson()).toList()),
    );
  }
}