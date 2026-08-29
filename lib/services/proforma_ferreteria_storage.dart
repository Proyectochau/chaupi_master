import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/proforma_ferreteria.dart';

class ProformaFerreteriaStorage {
  static const _proformasKey = 'proformas_ferreteria_guardadas';

  Future<void> guardar(ProformaFerreteria proforma) async {
    final preferences = await SharedPreferences.getInstance();
    final proformas = await obtenerTodos();
    final index = proformas.indexWhere((item) => item.id == proforma.id);

    if (index == -1) {
      proformas.add(proforma);
    } else {
      proformas[index] = proforma;
    }

    await _guardarLista(preferences, proformas);
  }

  Future<List<ProformaFerreteria>> obtenerTodos() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getString(_proformasKey);
    if (data == null) return [];

    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => ProformaFerreteria.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<ProformaFerreteria>> obtenerPorSolicitudId(String solicitudId) async {
    final proformas = await obtenerTodos();
    return proformas.where((item) => item.solicitudId == solicitudId).toList();
  }

  Future<bool> actualizar(ProformaFerreteria proforma) async {
    final preferences = await SharedPreferences.getInstance();
    final proformas = await obtenerTodos();
    final index = proformas.indexWhere((item) => item.id == proforma.id);

    if (index == -1) return false;

    proformas[index] = proforma;
    await _guardarLista(preferences, proformas);
    return true;
  }

  Future<void> _guardarLista(
    SharedPreferences preferences,
    List<ProformaFerreteria> proformas,
  ) async {
    await preferences.setString(
      _proformasKey,
      jsonEncode(proformas.map((proforma) => proforma.toJson()).toList()),
    );
  }
}
