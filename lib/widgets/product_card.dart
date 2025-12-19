import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      // ---------------------
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

            const SizedBox(height: 8),

            // 2. NOME DO PRODUTO
            Text(
              product.name,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // 3. PREÇO
            Text(
              'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            //botao de comprar
            ElevatedButton(onPressed: () {  },
                style:
                ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange[400],
                  elevation: 0,
                  side: BorderSide(color: Colors.orange, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                child: Center(
                    child: Text('Comprar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                )
            ),
          ],
        ),
      ),
    );
  }
}