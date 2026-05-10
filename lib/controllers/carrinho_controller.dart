import '../models/item_carrinho.dart';

class CarrinhoController {
  // Lista estática para que os dados não sumam ao trocar de tela
  static List<ItemCarrinho> itens = [];

  // Adiciona um item ao carrinho
  static void adicionar(ItemCarrinho novoItem) {
    itens.add(novoItem);
  }

  // Remove um item da lista pela posição (index)
  static void remover(int index) {
    itens.removeAt(index);
  }

  // Calcula o valor total de todos os itens
  static double get valorTotal {
    double total = 0.0;
    for (var item in itens) {
      total += item.opcao.preco * item.quantidade;
    }
    return total;
  }

  // Limpa o carrinho após o pedido ser enviado ao banco de dados
  static void limpar() {
    itens.clear();
  }
}

