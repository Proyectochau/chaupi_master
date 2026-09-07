import 'material.dart';

enum EstadoSolicitudMateriales {
  borrador,
  pendiente,
  enviada,
  respondida,
  proformaSeleccionada,
  pedidoConfirmado,
  cancelada,
}

class SolicitudMateriales {
  final String id;
  final String presupuestoId;
  final String nombre;
  final DateTime fechaCreacion;
  final List<MaterialItem> materiales;
  EstadoSolicitudMateriales estado;
  String? proformaSeleccionadaId;
  DateTime? fechaPedidoConfirmado;

  SolicitudMateriales({
    required this.id,
    required this.presupuestoId,
    required this.nombre,
    required this.fechaCreacion,
    List<MaterialItem>? materiales,
    this.estado = EstadoSolicitudMateriales.borrador,
    this.proformaSeleccionadaId,
    this.fechaPedidoConfirmado,
  }) : materiales = materiales ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'presupuestoId': presupuestoId,
    'nombre': nombre,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'materiales': materiales.map((item) => item.toJson()).toList(),
    'estado': estado.name,
    'proformaSeleccionadaId': proformaSeleccionadaId,
    'fechaPedidoConfirmado': fechaPedidoConfirmado?.toIso8601String(),
  };

  factory SolicitudMateriales.fromJson(Map<String, dynamic> json) {
    final estadoNombre = json['estado'] as String?;
    final estado = EstadoSolicitudMateriales.values.firstWhere(
      (item) => item.name == estadoNombre,
      orElse: () => EstadoSolicitudMateriales.borrador,
    );

    return SolicitudMateriales(
      id: json['id'] as String,
      presupuestoId: json['presupuestoId'] as String,
      nombre: json['nombre'] as String,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      materiales: (json['materiales'] as List? ?? [])
          .map(
            (item) =>
                MaterialItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      estado: estado,
      proformaSeleccionadaId: json['proformaSeleccionadaId'] as String?,
      fechaPedidoConfirmado: json['fechaPedidoConfirmado'] == null
          ? null
          : DateTime.tryParse(json['fechaPedidoConfirmado'] as String),
    );
  }
}
