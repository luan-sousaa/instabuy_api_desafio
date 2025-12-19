import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../services/instabuy_service.dart';
import '../widgets/product_card.dart';

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
              height: 30, // Altura para caber na barra
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 10), // Um espacinho entre a logo e o texto

            // 2. O TEXTO
            const Text(
              'Instabuy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto branco para contrastar
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.orange, // A cor de fundo da barra
        iconTheme: const IconThemeData(color: Colors.white), // Cor dos ícones (voltar, menu) brancos
      ),

      // Substitua todo o "body: FutureBuilder..." por isso:
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
                // 1. ÁREA DOS BANNERS (Fica no topo)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Destaques', style: TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            // 2. O TRUQUE MÁGICO DO CICLO (%)
                            // O index vai crescer pra sempre (0, 1, 2, 3, 4, 5...)
                            // O % faz ele voltar pro zero quando atinge o tamanho da lista.
                            // Exemplo com 3 banners: 0, 1, 2 -> 0, 1, 2 -> 0...
                            final int bannerIndex = index % banners.length;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  banners[bannerIndex].fullImageUrl,
                                  width: 320,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Ofertas Imperdíveis', style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
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