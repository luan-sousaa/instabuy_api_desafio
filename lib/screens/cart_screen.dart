import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _cart.items.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_shopping_cart, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("Seu carrinho está vazio"),
          ],
        ),
      )
          : Column(
        children: [
          // LISTA DE PRODUTOS
          Expanded(
            child: ListView.separated(
              itemCount: _cart.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _cart.items[index];
                return ListTile(
                  leading: Image.network(item.fullImageUrl, width: 50),
                  title: Text(item.name),
                  subtitle: Text(
                    'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _cart.remove(item); // Remove e atualiza a tela
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // BARRA DE TOTAL
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      'R\$ ${_cart.total.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Finalizar Pedido", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}