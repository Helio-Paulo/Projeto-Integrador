import '../models/produto.dart';

class ItemCarrinho {
  final Produto produto;
  final OpcaoProduto opcao;
  int quantidade;

  ItemCarrinho({
    required this.produto,
    required this.opcao,
    required this.quantidade,
  });
}
