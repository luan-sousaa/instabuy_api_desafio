import '../models/product_model.dart';

class CartService {
  // singleton
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // A Lista de produtos do carrinho
  final List<ProductModel> _items = [];

  // Adicionar produto ao carrinho
  void add(ProductModel product) {
    _items.add(product);
  }

  // Remover produto do carrinho
  void remove(ProductModel product) {
    _items.remove(product);
  }

  // Pegar todos os itens do carrinho
  List<ProductModel> get items => _items;

  // Calcular o total da conta
  double get total {
    double sum = 0;
    for (var item in _items) {
      sum += item.price;
    }
    return sum;
  }

  // Limpar carrinho
  void clear() {
    _items.clear();
  }
}