import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imagemAtual = 0; // Para controlar as bolinhas da galeria

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar transparente para dar foco na foto
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
                  return Image.network(
                    widget.product.getImageUrl(index),
                    fit: BoxFit.contain, // Mostra o produto inteiro sem cortar
                  );
                },
              ),
            ),

            // 2. BOLINHAS INDICADORAS (Só mostra se tiver mais de 1 foto)
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
                      color: Colors.green, // Destaque no preço
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
                    widget.product.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Adicionar ao Carrinho",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}