import 'package:flutter/material.dart';
import '../controllers/carrinho_controller.dart';
import '../core/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/globals.dart';

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
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 40,
                  ), // Ajustei o fundo aqui!
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

  void _mostrarPagamento() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // O SafeArea evita que o conteúdo fique embaixo da barra do Android
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta o tamanho ao conteúdo
              children: [
                const Text(
                  "Escolha a Forma de Pagamento",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Opção PIX
                ListTile(
                  leading: const Icon(Icons.pix, color: Colors.blue),
                  title: const Text("Pix (Copia e Cola)"),
                  subtitle: const Text("Pague agora para agilizar seu pedido"),
                  onTap: () {
                    CarrinhoController.formaPagamento = "Pix";
                    Navigator.pop(context);
                    _mostrarChavePix(); // Nova função para mostrar a chave
                  },
                ),

                // Opção Cartão
                ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.purple),
                  title: const Text("Cartão de Crédito/Débito"),
                  subtitle: const Text("O entregador levará a maquininha"),
                  onTap: () async {
                    // 1. Guardamos as referências de segurança
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      final supabase = Supabase.instance.client;

                      // Cria o resumo do que foi comprado
                      String resumoItens = CarrinhoController.itens
                          .map(
                            (item) =>
                                "${item.quantidade}x ${item.produto.nome} (${item.opcao.descricao})",
                          )
                          .join("\n"); // MUDANÇA AQUI: trocamos ", " por "\n"

                      // 2. ENVIO PARA O BANCO DE DADOS
                      await supabase.from('pedidos').insert({
                        'itens': resumoItens,
                        'valor_total': CarrinhoController.valorTotal,
                        'forma_pagamento': 'Cartão',
                        'mesa': Globals.mesaAtiva, // Mesa vinda do login
                        'status': 'Pendente',
                      });

                      if (!mounted) return;

                      navigator.pop(); // Fecha o menu de pagamento
                      _finalizarVendaSucesso(); // Limpa o carrinho
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("Erro ao processar cartão: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10), // Espaço extra no final
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarChavePix() {
    const String chavePix = "suachavepix@email.com"; // Sua chave aqui

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pagamento via Pix"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Clique no ícone para copiar a chave:"),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      chavePix,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    onPressed: () {
                      // COMANDO MÁGICO PARA COPIAR
                      Clipboard.setData(const ClipboardData(text: chavePix));

                      // Aviso rápido que copiou
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Chave Pix copiada!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Após pagar, clique em Confirmar.",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("VOLTAR"),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Guardamos as referências ANTES do await para evitar o erro de 'async gaps'
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                final supabase = Supabase.instance.client;

                String resumoItens = CarrinhoController.itens
                    .map(
                      (item) =>
                          "${item.quantidade}x ${item.produto.nome} (${item.opcao.descricao})",
                    )
                    .join(", ");

                // 2. Operação assíncrona (falar com o banco)
                // No arquivo carrinho_page.dart
                await supabase.from('pedidos').insert({
                  'itens': resumoItens,
                  'valor_total': CarrinhoController.valorTotal,
                  'forma_pagamento': 'Pix',
                  'mesa': Globals.mesaAtiva,
                  'status': 'Pendente',
                });

                // 3. Usamos as variáveis que guardamos lá no início
                if (!mounted) return;

                navigator.pop(); // Fecha o diálogo usando a referência salva
                _finalizarVendaSucesso(); // Limpa o carrinho
              } catch (e) {
                if (!mounted) return;

                messenger.showSnackBar(
                  SnackBar(
                    content: Text("Erro ao enviar pedido: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("CONFIRMAR"),
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

    // ACRESCENTE ESTA PARTE AQUI:
    // Como o carrinho acabou de ser limpo, voltamos para o cardápio
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && CarrinhoController.itens.isEmpty) {
        Navigator.of(
          context,
        ).pop(); // Fecha a página do carrinho e volta ao cardápio
      }
    });
  }
}
