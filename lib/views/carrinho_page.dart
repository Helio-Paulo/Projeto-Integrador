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
                // RODAPÉ COM O TOTAL
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40), // Ajustei o fundo aqui!
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
                    mainAxisSize: MainAxisSize.min,
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
                          // CHAMADA CORRIGIDA AQUI:
                          _mostrarPagamento();
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

  // ADICIONE ESTA FUNÇÃO QUE ESTAVA FALTANDO:
  void _mostrarPagamento() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Como deseja pagar?", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.pix, color: Colors.blue),
                title: const Text("Pix"),
                onTap: () {
                  CarrinhoController.formaPagamento = "Pix";
                  Navigator.pop(context);
                  _confirmarPedido();
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.purple),
                title: const Text("Cartão"),
                onTap: () {
                  CarrinhoController.formaPagamento = "Cartão";
                  Navigator.pop(context);
                  _confirmarPedido();
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments, color: Colors.green),
                title: const Text("Dinheiro"),
                onTap: () {
                  CarrinhoController.formaPagamento = "Dinheiro";
                  Navigator.pop(context);
                  _confirmarPedido();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarPedido() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Pedido?"),
        content: Text(
          "Total: R\$ ${CarrinhoController.valorTotal.toStringAsFixed(2)}\n"
          "Pagamento: ${CarrinhoController.formaPagamento}"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("CANCELAR")
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizarVendaSucesso();
            }, 
            child: const Text("CONFIRMAR")
          ),
        ],
      ),
    );
  }

  void _finalizarVendaSucesso() {
    setState(() {
      CarrinhoController.limpar();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pedido enviado com sucesso! ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
