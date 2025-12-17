class BannerModel {
  final String id;
  final String imageHash; // O código maluco da imagem que vem da API
  final String title;
  final bool isMobile;

  BannerModel({
    required this.id,
    required this.imageHash,
    required this.title,
    required this.isMobile,
  });


  // Essa parte pega o JSON bagunçado e transforma num Objeto Banner bonitinho
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageHash: json['image'] ?? '', // A API chama só de "image"
      title: json['title'] ?? '',
      isMobile: json['is_mobile'] ?? false,
    );
  }
  // O desafio diz que a URL é: https://ibassets.com.br/ib.store.banner/bnr-{image}
  // atalho aqui para não ter que montar isso na tela toda hora.
  String get fullImageUrl {
    return 'https://ibassets.com.br/ib.store.banner/bnr-$imageHash';
  }
}