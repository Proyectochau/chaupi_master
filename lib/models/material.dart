class MaterialItem {
  final String nombre;
  final double cantidad;
  final double precio;

  MaterialItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  double get subtotal => cantidad * precio;
}