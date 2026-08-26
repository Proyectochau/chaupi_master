import 'mano_obra.dart';
import 'material.dart';

class Presupuesto {
  String? id;
  DateTime? fechaActualizacion;
  String tipoTrabajo;
  String? descripcion;
  String? ubicacion;
  String? clienteNombre;
  String? telefono;
  DateTime? fechaInicio;
  double? duracionAproximada;
  String? unidadDuracion;
  String? notasAdicionales;
  double transporte;
  final List<String> fotosTrabajo;

  final List<ManoObraItem> manoObra;
  final List<MaterialItem> materiales;

  Presupuesto({
    required this.tipoTrabajo,
    this.id,
    this.fechaActualizacion,
    this.descripcion,
    this.ubicacion,
    this.clienteNombre,
    this.telefono,
    this.fechaInicio,
    this.duracionAproximada,
    this.unidadDuracion,
    this.notasAdicionales,
    this.transporte = 0.0,
    List<String>? fotosTrabajo,
    List<ManoObraItem>? manoObra,
    List<MaterialItem>? materiales,
  })  : fotosTrabajo = fotosTrabajo ?? [],
        manoObra = manoObra ?? [],
        materiales = materiales ?? [];

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (fechaActualizacion != null)
      'fechaActualizacion': fechaActualizacion!.toIso8601String(),
        'tipoTrabajo': tipoTrabajo,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'clienteNombre': clienteNombre,
        'telefono': telefono,
        'fechaInicio': fechaInicio?.toIso8601String(),
        'duracionAproximada': duracionAproximada,
        'unidadDuracion': unidadDuracion,
        'notasAdicionales': notasAdicionales,
        'transporte': transporte,
        'fotosTrabajo': fotosTrabajo,
        'manoObra': manoObra.map((item) => item.toJson()).toList(),
        'materiales': materiales.map((item) => item.toJson()).toList(),
      };

  factory Presupuesto.fromJson(Map<String, dynamic> json) => Presupuesto(
        tipoTrabajo: json['tipoTrabajo'] as String,
        id: json['id'] as String?,
        fechaActualizacion: json['fechaActualizacion'] == null
            ? null
            : DateTime.parse(json['fechaActualizacion'] as String),
        descripcion: json['descripcion'] as String?,
        ubicacion: json['ubicacion'] as String?,
        clienteNombre: json['clienteNombre'] as String?,
        telefono: json['telefono'] as String?,
        fechaInicio: json['fechaInicio'] == null
            ? null
            : DateTime.parse(json['fechaInicio'] as String),
        duracionAproximada: (json['duracionAproximada'] as num?)?.toDouble(),
        unidadDuracion: json['unidadDuracion'] as String?,
        notasAdicionales: json['notasAdicionales'] as String?,
        transporte: (json['transporte'] as num?)?.toDouble() ?? 0.0,
        fotosTrabajo: List<String>.from(json['fotosTrabajo'] as List? ?? []),
        manoObra: (json['manoObra'] as List? ?? [])
            .map((item) => ManoObraItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        materiales: (json['materiales'] as List? ?? [])
            .map((item) => MaterialItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
      );

  double get totalManoObra => manoObra.fold(0, (s, i) => s + i.subtotal);
  double get totalMateriales => materiales.fold(0, (s, m) => s + m.subtotal);
  double get totalGeneral => totalManoObra + totalMateriales + transporte;
}
