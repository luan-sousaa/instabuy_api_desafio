import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Quando clicar, vai para a tela de detalhes
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
    child: Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. IMAGEM
            Expanded(
              child: Center(
                child: Image.network(
                  product.fullImageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              ),
            ),

            const SizedBox(height: 3),

            // 3. PREÇO (LÓGICA AJUSTADA)
            if (product.isPromo)
            // Se tiver promoção, usamos ROW para colocar lado a lado
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // Alinha pela base do texto
                children: [
                  // PREÇO NOVO (Preto e Destaque)
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10), // Espaço entre os dois preços
                  // PREÇO ANTIGO (Cinza e Riscado)
                  Text(
                    'R\$ ${product.originalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 12, // Letra menor
                      color: Colors.grey, // COR CINZA
                      decoration: TextDecoration.lineThrough, // RISCADO
                    ),
                  ),
                ],
              )
            else
            // Se NÃO for promoção, mostra só o preço normal preto
              Text(
                'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            const SizedBox(height: 8),

            // 3. NOME DO PRODUTO
            Text(
              product.name,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // BOTÃO DE COMPRAR
            const SizedBox(height: 8),
            SizedBox(

              width: double.infinity,
              height: 40, // Defini uma altura fixa para ficar padronizado
              child: ElevatedButton(
                onPressed: () {
                  // --- LÓGICA DE ADICIONAR AO CARRINHO
                  //salvar no carrinho
                  CartService().add(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          // 1. A FOTINHA DO PRODUTO NO AVISO
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(product.fullImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 2. O TEXTO CONFIRMANDO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Adicionado ao carrinho!",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const Icon(Icons.check, color: Colors.white),
                        ],
                      ),
                      backgroundColor: Colors.green[700], // Verde para indicar sucesso
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange[400],
                  elevation: 0,
                  side: const BorderSide(color: Colors.orange, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),

                ),

                child: const Center(

                  child: Text(

                      'Comprar',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}