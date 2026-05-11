import '../models/item_carrinho.dart';

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
}


