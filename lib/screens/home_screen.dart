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
            final products = snapshot.data!['products'] as List<ProductModel>;

            return CustomScrollView(
              slivers: [
                // 1. ÁREA DOS BANNERS
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Destaques', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),

                      // O CARROSSEL (PageView)
                      SizedBox(
                        height: 180,
                        child: PageView.builder(
                          // onPageChanged: Avisa quando mudou de imagem
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
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10), // Espaço entre banner e bolinhas

                      // AS BOLINHAS INDICADORAS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(banners.length, (index) {
                          // Verifica se essa bolinha é a atual
                          bool isSelected = _bannerAtual == index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 24 : 8, // Se selecionado fica esticado, se não, bolinha
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.amberAccent : Colors.grey[400], // Verde ou Cinza
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Ofertas Imperdíveis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // 2. O GRID DE PRODUTOS (2 por linha)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // <--- AQUI: 2 ITENS POR LINHA
                      childAspectRatio: 0.75,
                      // Define a altura do cartão (mais alto ou mais quadrado)
                      crossAxisSpacing: 10,
                      // Espaço lateral entre cartões
                      mainAxisSpacing: 10, // Espaço vertical entre cartões
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return ProductCard(product: products[index]);
                      },
                      childCount: products.length,
                    ),
                  ),
                ),

                // Um espaço no final pra não ficar colado na borda
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          }

          return const Center(child: Text("Nenhum dado encontrado"));
        },
      ),
    );
  }
}