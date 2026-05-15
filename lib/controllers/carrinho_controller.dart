import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_carrinho.dart';
import '../core/globals.dart';
import 'package:flutter/material.dart';

class CarrinhoController {
  static List<ItemCarrinho> itens = [];
  static String formaPagamento = "Dinheiro";

  // Adiciona um item ao carrinho
  static void adicionar(ItemCarrinho novoItem) {
    itens.add(novoItem);
  }

  // Remove um item da lista pela posição (index)
  static void remover(int index) {
    itens.removeAt(index);
  }

  static double get valorTotal {
    double total = 0.0;
    for (var item in itens) {
      total += item.opcao.preco * item.quantidade;
    }
    return total;
  }

  static void limpar() {
    itens.clear();
    formaPagamento = "Dinheiro";
  }

  // --- NOVA FUNÇÃO: ENVIA O PEDIDO PARA A COZINHA ---
  static Future<void> enviarPedidoAoBanco() async {
    if (itens.isEmpty) return;

    // O \n faz cada item aparecer em uma linha nova na cozinha
    String resumo = itens.map((i) => "${i.quantidade}x ${i.opcao.descricao}").join("\n");

    try {
      await Supabase.instance.client.from('pedidos').insert({
        'mesa': Globals.mesaAtiva,
        'itens': resumo,
        'status': 'Pendente', // Usando P maiúsculo como está no seu banco
      });
      
      // Limpamos o carrinho apenas após o sucesso do envio
      limpar();
    } catch (e) {
      debugPrint("Erro ao enviar pedido: $e");
      rethrow; // Repassa o erro para a tela tratar se precisar
    }
  }
}
