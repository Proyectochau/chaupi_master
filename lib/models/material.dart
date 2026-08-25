class MaterialItem {
  final String nombre;
  final double cantidad;
  final double precio;

  MaterialItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cantidad': cantidad,
        'precio': precio,
      };

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        nombre: json['nombre'] as String,
        cantidad: (json['cantidad'] as num).toDouble(),
        precio: (json['precio'] as num).toDouble(),
      );

  double get subtotal => cantidad * precio;
}
//Hola estoy en la rama MF