import 'ferreteria_material.dart';
export 'ferreteria_material.dart';

class Ferreteria {
  final String nombre;
  final String sector;
  final String telefono;
  final String descripcion;
  final bool destacada;
  final List<FerreteriaMaterial> materiales;

  Ferreteria({
    required this.nombre,
    required this.sector,
    required this.telefono,
    required this.descripcion,
    this.destacada = false,
    this.materiales = const [],
  });
}
