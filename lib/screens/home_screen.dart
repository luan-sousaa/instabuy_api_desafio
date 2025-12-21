import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../services/instabuy_service.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Instanciamos nosso serviço (o trabalhador)
  final InstabuyService _service = InstabuyService();

  // 2. Criamos uma variável para guardar a "promessa" dos dados
  late Future<Map<String, dynamic>> _futureDados;
  int _bannerAtual = 0; // Vai guardar qual banner está aparecendo (0, 1, 2...)
  //variavel de busca
  String _busca = "";
  @override
  void initState() {
    super.initState();
    // 3. Assim que a tela nasce, mandamos buscar os dados
    _futureDados = _service.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Substituimos o Text simples por uma Row (Linha)
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza no meio da barra
          mainAxisSize: MainAxisSize.min, // Faz a linha ocupar só o espaço necessário (senão ela estica tudo)
          children: [
            // 1. A IMAGEM (LOGO)
            Image.asset(
              'assets/logo.png',
              height: 40, // Altura para caber na barra
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 10), // Um espacinho entre a logo e o texto

            // 2. O TEXTO
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
        backgroundColor: Colors.orange, // A cor de fundo da barra
        iconTheme: const IconThemeData(color: Colors.white), // Cor dos ícones (voltar, menu) brancos
      ),

      floatingActionButton: Padding(
        // Aqui definimos o quanto ele sobe
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

            // 1. LÓGICA DE FILTRAGEM (Case Insensitive)
            final productsFiltrados = allProducts.where((produto) {
              return produto.name.toLowerCase().contains(_busca.toLowerCase());
            }).toList();

            return CustomScrollView(
              slivers: [
                // ÁREA SUPERIOR (Busca + Banners)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 2. A BARRA DE PESQUISA
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
                              borderRadius: BorderRadius.circular(30), // Borda redondinha
                              borderSide: BorderSide.none, // Sem linha preta em volta
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

                      // 3. SÓ MOSTRA BANNERS SE NÃO TIVER PESQUISANDO
                      // (Se a busca for vazia, mostra os banners. Se tiver texto, esconde)
                      if (_busca.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Destaques', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ),

                        // SEU CARROSSEL DE BANNERS (O código que já existia)
                        SizedBox(
                          height: 140, // Altura ajustada
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
                        // BOLINHAS INDICADORAS
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
                        // Se tiver pesquisando, mostra um título diferente
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Resultados para "$_busca"', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ),
                      ],
                    ],
                  ),
                ),

                // 4. O GRID AGORA USA A LISTA FILTRADA
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        // USA productsFiltrados AO INVÉS DE products
                        return ProductCard(product: productsFiltrados[index]);
                      },
                      childCount: productsFiltrados.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)), // Espaço extra no final
              ],
            );
          }

          return const Center(child: Text("Nenhum dado encontrado"));
        },
      ),
    );
  }
}