import 'mano_obra.dart';
import 'material.dart';

class Presupuesto {
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

  double get totalManoObra => manoObra.fold(0, (s, i) => s + i.subtotal);
  double get totalMateriales => materiales.fold(0, (s, m) => s + m.subtotal);
  double get totalGeneral => totalManoObra + totalMateriales + transporte;
}
