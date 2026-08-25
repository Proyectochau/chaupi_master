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

  Map<String, dynamic> toJson() => {
        'descripcion': descripcion,
        'tipo': tipo,
        'categoria': categoria,
        'dias': dias,
        'precioDia': precioDia,
      };

  factory ManoObraItem.fromJson(Map<String, dynamic> json) => ManoObraItem(
        descripcion: json['descripcion'] as String,
        tipo: json['tipo'] as String,
        categoria: json['categoria'] as String,
        dias: (json['dias'] as num).toDouble(),
        precioDia: (json['precioDia'] as num).toDouble(),
      );

  double get subtotal => dias * precioDia;
}
