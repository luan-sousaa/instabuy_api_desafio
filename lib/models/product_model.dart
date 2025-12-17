class ProductModel {
  final String id;
  final String name;
  final String imageHash;
  final double price;
  final bool isPromo; // Adicionei isso pra gente saber se é promoção

  ProductModel({
    required this.id,
    required this.name,
    required this.imageHash,
    required this.price,
    required this.isPromo,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {

    double precoFinal = 0.0;
    bool emPromocao = false;

    // Verifica se a lista de preços existe e não está vazia
    if (json['prices'] != null && (json['prices'] as List).isNotEmpty) {
      // Pega a primeira opção de preço (geralmente é a unidade padrão)
      var primeiraOpcao = json['prices'][0];

      double? precoRegular = (primeiraOpcao['price'] ?? 0).toDouble();
      double? precoPromo = (primeiraOpcao['promo_price'] ?? 0).toDouble();

      // Se tem promo e ela é maior que zero, ela ganha.
      if (precoPromo != null && precoPromo > 0) {
        precoFinal = precoPromo;
        emPromocao = true;
      } else {
        precoFinal = precoRegular ?? 0.0;
        emPromocao = false;
      }
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Produto sem nome',
      imageHash: json['images'] != null && (json['images'] as List).isNotEmpty
          ? json['images'][0]
          : '',
      price: precoFinal,
      isPromo: emPromocao,
    );
  }

  String get fullImageUrl {
    if (imageHash.isEmpty) return 'https://via.placeholder.com/150';
    return 'https://ibassets.com.br/ib.item.image.medium/m-$imageHash';
  }
}