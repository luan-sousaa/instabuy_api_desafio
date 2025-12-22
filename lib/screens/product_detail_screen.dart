import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
/// Tela de Detalhes do Produto.
///
/// Responsável por exibir todas as informações do produto selecionado,
/// incluindo uma galeria de imagens interativa (Carrosel), descrição completa
/// e a ação de adicionar ao carrinho.
///
/// Implementa a animação [Hero] para criar uma transição fluida entre a listagem e o detalhe.
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Índice da imagem atual no carrossel para controlar os indicadores (bolinhas).
  int _imagemAtual = 0;
  /// Utilitário interno para sanitização de texto HTML.
  ///
  /// A API retorna descrições contendo tags como <br>, <p> e <div>.
  /// Optamos por usar [RegExp] para limpar essas tags e converter em quebras de linha,
  /// mantendo a performance alta e evitando a necessidade de pacotes externos pesados
  /// de renderização HTML para um caso de uso simples.
  String _limparTextoHtml(String htmlString) {
    // 1. Troca tags de quebra de linha (<br>, </p>, </div>) por quebra de linha real (\n)
    String text = htmlString.replaceAll(RegExp(r'<(br|/p|/div)>'), '\n');

    // 2. Remove todas as outras tags HTML (tudo que estiver entre < e >)
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // 3. Remove espaços duplicados e espaços extras no começo/fim
    return text.trim();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar limpa para manter o foco visual nas imagens do produto
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. GALERIA DE FOTOS DO PRODUTO (Carrossel)
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
                child: PageView.builder(
                  itemCount: widget.product.images.isEmpty ? 1 : widget.product.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _imagemAtual = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // LÓGICA DO HERO:
                    // Aplicamos o widget Hero APENAS na primeira imagem (index 0).
                    // Isso conecta visualmente a miniatura da tela anterior com a imagem grande desta tela.
                    // Não aplicamos nos outros índices para evitar conflito de tags duplicadas.
                    if (index == 0) {
                      return Hero(
                        tag: widget.product.id, // A mesma TAG do Card (Importante!)
                        child: Image.network(
                          widget.product.getImageUrl(index),
                          fit: BoxFit.contain,
                        ),
                      );
                    } else {
                      // Se forem as outras fotos da galeria, mostramos normal (sem Hero)
                      return Image.network(
                        widget.product.getImageUrl(index),
                        fit: BoxFit.contain,
                      );
                    }
                  },
                ),
            ),

            // 2. BOLINHAS INDICADORAS (Só mostra se tiver mais de 1 foto)
            // Renderização condicional: só exibe se houver mais de uma imagem.
            if (widget.product.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.product.images.length, (index) {
                    bool isActive = _imagemAtual == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),

            const SizedBox(height: 20),

            // 3. INFORMAÇÕES (Título, Preço, Descrição)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // PREÇO (Com lógica de promoção)
                  if (widget.product.isPromo)
                    Text(
                      'R\$ ${widget.product.originalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    'R\$ ${widget.product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Destaque no preço
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(), // Linha divisória
                  const SizedBox(height: 20),

                  // TÍTULO DA DESCRIÇÃO
                  const Text(
                    "Descrição do Produto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // TEXTO DA DESCRIÇÃO
                  Text(
                      _limparTextoHtml(widget.product.description),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Espaço pro botão não cobrir o texto
          ],
        ),
      ),

      // 4. BOTÃO DE ADICIONAR (Igual ao que fizemos antes)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Adiciona ao carrinho
              CartService().add(widget.product);

              // Feedback Visual
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      const Text("Adicionado ao Carrinho!"),
                    ],
                  ),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),

            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centraliza tudo no meio do botão
                children: [
                Icon(Icons.shopping_cart_outlined, color: Colors.white), // O Ícone
            SizedBox(width: 10), // Um espaço entre o ícone e o texto
            Text(
              "Adicionar ao Carrinho",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ]
            ),
          ),
        ),
      ),
    );
  }
}