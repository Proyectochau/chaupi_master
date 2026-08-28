import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/solicitud_materiales.dart';

class SolicitudMaterialesStorage {
  static const _solicitudesKey = 'solicitudes_materiales_guardadas';

  Future<void> guardar(SolicitudMateriales solicitud) async {
    final preferences = await SharedPreferences.getInstance();
    final solicitudes = await obtenerTodos();
    solicitudes.add(solicitud);
    await _guardarLista(preferences, solicitudes);
  }

  Future<List<SolicitudMateriales>> obtenerTodos() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getString(_solicitudesKey);
    if (data == null) return [];

    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => SolicitudMateriales.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<List<SolicitudMateriales>> obtenerPorEstado(
    EstadoSolicitudMateriales estado,
  ) async {
    final solicitudes = await obtenerTodos();
    return solicitudes.where((solicitud) => solicitud.estado == estado).toList();
  }

  Future<bool> actualizar(SolicitudMateriales solicitud) async {
    final preferences = await SharedPreferences.getInstance();
    final solicitudes = await obtenerTodos();
    final indice = solicitudes.indexWhere((item) => item.id == solicitud.id);

    if (indice == -1) return false;

    solicitudes[indice] = solicitud;
    await _guardarLista(preferences, solicitudes);
    return true;
  }

  Future<bool> eliminar(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final solicitudes = await obtenerTodos();
    final cantidadInicial = solicitudes.length;
    solicitudes.removeWhere((solicitud) => solicitud.id == id);

    if (solicitudes.length == cantidadInicial) return false;

    await _guardarLista(preferences, solicitudes);
    return true;
  }

  Future<void> _guardarLista(
    SharedPreferences preferences,
    List<SolicitudMateriales> solicitudes,
  ) async {
    await preferences.setString(
      _solicitudesKey,
      jsonEncode(solicitudes.map((solicitud) => solicitud.toJson()).toList()),
    );
  }
}
