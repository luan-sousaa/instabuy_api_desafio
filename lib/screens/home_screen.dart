import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../services/instabuy_service.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

/// [HomeScreen] é o ponto de entrada principal da experiência de compra.
/// Esta classe gerencia a exibição de banners promocionais, busca de produtos
/// e a listagem geral utilizando uma arquitetura baseada em Slivers para alta performance.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Instância do serviço responsável pelas chamadas de API.
  final InstabuyService _service = InstabuyService();

  /// [Future] que armazena a resposta da API.
  /// Definido como uma variável de estado para evitar disparos desnecessários da requisição
  /// toda vez que o widget for reconstruído (rebuild).
  late Future<Map<String, dynamic>> _futureDados;

  /// Controla o índice do banner atualmente visível no [PageView].
  int _bannerAtual = 0;

  /// Estado que armazena a string de busca para filtragem reativa de produtos.
  String _busca = "";

  @override
  void initState() {
    super.initState();
    /// Inicializa a busca de dados no ciclo de vida correto (initState),
    /// garantindo que a requisição ocorra apenas uma vez na criação da tela.
    _futureDados = _service.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              'Instabuy Market',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0, right: 5.0),
        child: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: const Icon(Icons.shopping_cart, color: Colors.white),
        ),
      ),

      /// [FutureBuilder] lida com o consumo da [Future] de forma declarativa.
      /// Ele reconstrói a UI automaticamente baseada no estado da conexão (espera, erro ou sucesso).
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final banners = snapshot.data!['banners'] as List<BannerModel>;
            final allProducts = snapshot.data!['products'] as List<ProductModel>;

            /// Implementação de filtragem client-side utilizando métodos funcionais da List.
            /// Normaliza as strings para 'lowercase' para garantir uma busca case-insensitive.
            final productsFiltrados = allProducts.where((produto) {
              return produto.name.toLowerCase().contains(_busca.toLowerCase());
            }).toList();

            /// O [CustomScrollView] permite a criação de efeitos de rolagem complexos.
            /// O uso de [Slivers] é uma boa prática de performance, pois renderiza apenas
            /// o que está visível na viewport (Lazy Loading).
            return CustomScrollView(
              slivers: [
                /// [SliverToBoxAdapter] permite injetar widgets comuns (não-slivers)
                /// dentro do contexto do CustomScrollView.
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: TextField(
                          onChanged: (textoDigitado) {
                            setState(() {
                              _busca = textoDigitado;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'O que você procura hoje?',
                            prefixIcon: const Icon(Icons.search, color: Colors.orange),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.orange, width: 1),
                            ),
                          ),
                        ),
                      ),

                      /// Lógica condicional para alternar entre visibilidade de Banners e Resultados.
                      if (_busca.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Destaques', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ),

                        /// [PageView.builder] para o carrossel de banners.
                        /// Otimizado para criar widgets sob demanda conforme o usuário desliza.
                        SizedBox(
                          height: 140,
                          child: PageView.builder(
                            onPageChanged: (index) {
                              setState(() {
                                _bannerAtual = index;
                              });
                            },
                            itemCount: banners.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    banners[index].fullImageUrl,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(color: Colors.grey[300]);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Indicadores visuais de paginação (dots).
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(banners.length, (index) {
                            bool isSelected = _bannerAtual == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isSelected ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green : Colors.grey[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Ofertas Imperdíveis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Resultados para "$_busca"', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ),
                      ],
                    ],
                  ),
                ),

                /// Gerenciamento de Empty State dentro da arquitetura de Slivers.
                productsFiltrados.isEmpty
                    ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Nenhum produto encontrado 😕"),
                    ),
                  ),
                )
                    : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    /// [SliverGridDelegateWithFixedCrossAxisCount] define o layout da grade.
                    /// Otimizado para scroll infinito e reuso de memória.
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return ProductCard(product: productsFiltrados[index]);
                      },
                      childCount: productsFiltrados.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          }

          return const Center(child: Text("Nenhum dado encontrado"));
        },
      ),
    );
  }
}