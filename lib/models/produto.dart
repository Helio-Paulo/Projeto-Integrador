class Produto {
  final String nome;
  final String categoria;
  final String imagemPath;
  final List<OpcaoProduto> opcoes;

  Produto({required this.nome, required this.categoria, required this.imagemPath, required this.opcoes});
}

class OpcaoProduto {
  final String descricao;
  final double preco;

  OpcaoProduto({required this.descricao, required this.preco});
}
