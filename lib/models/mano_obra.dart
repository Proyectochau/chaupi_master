class ManoObraItem {
  final String descripcion;
  final String tipo;
  final String categoria;
  final double dias;
  final double precioDia;

  ManoObraItem({
    required this.descripcion,
    required this.tipo,
    required this.categoria,
    required this.dias,
    required this.precioDia,
  });

  double get subtotal => dias * precioDia;
}
