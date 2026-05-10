import 'package:flutter/material.dart';
import '../controllers/carrinho_controller.dart';
import '../core/app_colors.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meu Carrinho",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CarrinhoController.itens.isEmpty
          ? const Center(
              child: Text("Seu carrinho está vazio!"),
            ) // Se não tiver nada
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: CarrinhoController.itens.length,
                    itemBuilder: (context, index) {
                      final item = CarrinhoController.itens[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.asset(
                            item.produto.imagemPath,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.produto.nome),
                          subtitle: Text(
                            "${item.quantidade}x ${item.opcao.descricao}\n"
                            "R\$ ${(item.opcao.preco * item.quantidade).toStringAsFixed(2)}",
                          ),
                          // BOTÃO DE EXCLUIR (LIXEIRA)
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantidade > 1) {
                                      item.quantidade--;
                                    } else {
                                      CarrinhoController.remover(index);
                                    }
                                  });
                                },
                              ),
                              Text(
                                "${item.quantidade}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.quantidade++;
                                  });
                                },
                              ),
                              // Se quiser manter a lixeira junto com o + e -, pode colocar aqui:
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    CarrinhoController.remover(index);
                                  });
                                },
                              ),
                            ],
                          ), // Fim da Row que substituiu o IconButton antigo
                        ),
                      );
                    },
                  ),
                ),
                // RODAPÉ COM O TOTAL
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: .5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "R\$ ${CarrinhoController.valorTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulPrincipal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          // Aqui chamaremos a função de salvar no Supabase depois!
                        },
                        child: const Text(
                          "FINALIZAR PEDIDO",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

