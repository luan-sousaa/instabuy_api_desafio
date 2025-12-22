import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

/// Tela responsável por exibir o Carrinho de Compras.
///
/// Esta tela consome o [CartService] para listar os itens selecionados,
/// permitindo a remoção de produtos e visualização do valor total do pedido.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Acesso à instância única (Singleton) do carrinho.
  // Isso garante que os dados sejam os mesmos em todo o app.
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
      // Renderização Condicional:
      // Se a lista estiver vazia, exibe feedback visual (Ícone + Texto).
      // Se tiver itens, exibe a lista de produtos e o rodapé com total.
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
        // 1. LISTA DE PRODUTOS
        // Usamos Expanded para que a lista ocupe todo o espaço disponível
        // acima da barra de total, permitindo rolagem se houver muitos itens.
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
                    // Formatação de moeda BRL (troca ponto por vírgula)
                    'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Lógica de Remoção:
                      // Envolvemos no setState para que o Flutter saiba que
                      // a tela precisa ser redesenhada após remover o item.
                      setState(() {
                        _cart.remove(item); // Remove e atualiza a tela
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // 2. BARRA DE RESUMO (TOTAL)
          // Container fixo na parte inferior da tela.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              // Sombra suave para destacar a barra do resto da lista
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    // O valor total é calculado dinamicamente pelo getter do Service
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
                    onPressed: () {
                      //sem açao por enquanto
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[400]),
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