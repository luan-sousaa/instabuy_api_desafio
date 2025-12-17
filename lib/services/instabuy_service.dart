import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner_model.dart';
import '../models/product_model.dart';

class InstabuyService {
  final String _baseUrl = 'https://api.instabuy.com.br/apiv3/layout?subdomain=bigboxdelivery';

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];

        // 1. Pega os Banners (Isso já estava funcionando)
        List<BannerModel> banners = [];
        if (data['banners'] != null) {
          banners = (data['banners'] as List)
              .map((item) => BannerModel.fromJson(item))
              .toList();
        }

        // 2. Pega os Produtos (AQUI ESTÁ A CORREÇÃO MAGICAMENTE 🪄)
        List<ProductModel> products = [];

        if (data['collection_items'] != null) {
          var prateleiras = data['collection_items'] as List;

          // Para cada prateleira (Açougue, Padaria...)...
          for (var prateleira in prateleiras) {
            // ...verificamos se ela tem produtos dentro ('items')
            if (prateleira['items'] != null) {
              var produtosDaPrateleira = prateleira['items'] as List;

              // Transformamos cada item da prateleira em um Produto e adicionamos na nossa lista geral
              var novosProdutos = produtosDaPrateleira
                  .map((item) => ProductModel.fromJson(item))
                  .toList();

              products.addAll(novosProdutos);
            }
          }
        }

        return {
          'banners': banners,
          'products': products,
        };

      } else {
        throw Exception('Falha ao carregar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}