class ProductModel {
  final String id;
  final String name;
  final List<String> images; // AGORA É UMA LISTA DE HASHES
  final String description;  // NOVA PROPRIEDADE
  final double price;
  final double originalPrice;
  final bool isPromo;

  ProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.isPromo,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double precoFinal = 0.0;
    double precoOriginal = 0.0;
    bool emPromocao = false;

    if (json['prices'] != null && (json['prices'] as List).isNotEmpty) {
      var primeiraOpcao = json['prices'][0];
      double regular = (primeiraOpcao['price'] ?? 0).toDouble();
      double promo = (primeiraOpcao['promo_price'] ?? 0).toDouble();

      precoOriginal = regular;

      if (promo > 0) {
        precoFinal = promo;
        emPromocao = true;
      } else {
        precoFinal = regular;
        emPromocao = false;
      }
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Produto sem nome',
      // 1. CAPTURAMOS A LISTA DE IMAGENS
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      // 2. CAPTURAMOS A DESCRIÇÃO (Se não tiver, colocamos um texto padrão)
      description: json['description'] ?? 'Sem descrição detalhada para este produto.',
      price: precoFinal,
      originalPrice: precoOriginal,
      isPromo: emPromocao,
    );
  }

  // Helper para pegar a URL de uma imagem específica da lista
  String getImageUrl(int index) {
    if (images.isEmpty) return 'https://via.placeholder.com/300';
    // Se o índice for maior que a lista, pega a primeira
    String hash = (index < images.length) ? images[index] : images[0];
    return 'https://ibassets.com.br/ib.item.image.big/b-$hash';
  }

  // Atalho para pegar a primeira imagem (para usar no Card da Home)
  String get fullImageUrl => getImageUrl(0);
}