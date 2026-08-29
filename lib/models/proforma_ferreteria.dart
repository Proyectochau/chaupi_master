class ProformaFerreteriaItem {
  final String materialNombre;
  final double cantidadSolicitada;
  bool tieneStock;
  double cantidadDisponible;
  double precioUnitario;
  String observacion;

  ProformaFerreteriaItem({
    required this.materialNombre,
    required this.cantidadSolicitada,
    this.tieneStock = false,
    this.cantidadDisponible = 0,
    this.precioUnitario = 0,
    this.observacion = '',
  });

  Map<String, dynamic> toJson() => {
        'materialNombre': materialNombre,
        'cantidadSolicitada': cantidadSolicitada,
        'tieneStock': tieneStock,
        'cantidadDisponible': cantidadDisponible,
        'precioUnitario': precioUnitario,
        'observacion': observacion,
      };

  factory ProformaFerreteriaItem.fromJson(Map<String, dynamic> json) {
    return ProformaFerreteriaItem(
      materialNombre: json['materialNombre'] as String? ?? '',
      cantidadSolicitada: (json['cantidadSolicitada'] as num?)?.toDouble() ?? 0,
      tieneStock: json['tieneStock'] as bool? ?? false,
      cantidadDisponible: (json['cantidadDisponible'] as num?)?.toDouble() ?? 0,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0,
      observacion: json['observacion'] as String? ?? '',
    );
  }
}

class ProformaFerreteria {
  final String id;
  final String solicitudId;
  final DateTime fechaRespuesta;
  final List<ProformaFerreteriaItem> items;
  final double costoEntrega;
  final String tiempoEntrega;
  final String observaciones;
  final String estado;

  ProformaFerreteria({
    required this.id,
    required this.solicitudId,
    required this.fechaRespuesta,
    List<ProformaFerreteriaItem>? items,
    this.costoEntrega = 0,
    this.tiempoEntrega = '',
    this.observaciones = '',
    this.estado = 'enviada',
  }) : items = items ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'solicitudId': solicitudId,
        'fechaRespuesta': fechaRespuesta.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'costoEntrega': costoEntrega,
        'tiempoEntrega': tiempoEntrega,
        'observaciones': observaciones,
        'estado': estado,
      };

  factory ProformaFerreteria.fromJson(Map<String, dynamic> json) {
    return ProformaFerreteria(
      id: json['id'] as String? ?? '',
      solicitudId: json['solicitudId'] as String? ?? '',
      fechaRespuesta: DateTime.parse(json['fechaRespuesta'] as String? ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List? ?? [])
          .map((item) => ProformaFerreteriaItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      costoEntrega: (json['costoEntrega'] as num?)?.toDouble() ?? 0,
      tiempoEntrega: json['tiempoEntrega'] as String? ?? '',
      observaciones: json['observaciones'] as String? ?? '',
      estado: json['estado'] as String? ?? 'enviada',
    );
  }
}
