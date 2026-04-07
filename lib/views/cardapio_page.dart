import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/produto.dart';

class CardapioPage extends StatefulWidget {
  const CardapioPage({super.key});

  @override
  State<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends State<CardapioPage> {
  final List<Produto> meusProdutos = [
    Produto(
      nome: "Água de Coco",
      categoria: "Bebidas",
      imagemPath: "assets/agua_coco.jpg",
      opcoes: [
        OpcaoProduto(descricao: "Com gelo", preco: 12.0),
        OpcaoProduto(descricao: "Sem gelo", preco: 10.0),
      ],
    ),
    Produto(
      nome: "Porção de Batata",
      categoria: "Porções",
      imagemPath: "assets/batata.jpg",
      opcoes: [
        OpcaoProduto(descricao: "Simples", preco: 30.0),
        OpcaoProduto(descricao: "Com Queijo", preco: 45.0),
      ],
    ),
    Produto(
      nome: "Pastel",
      categoria: "Salgados",
      imagemPath: "assets/pastel_geral.jpg",
      opcoes: [
        OpcaoProduto(descricao: "Carne", preco: 15.0),
        OpcaoProduto(descricao: "Queijo", preco: 15.0),
        OpcaoProduto(descricao: "Calabresa", preco: 16.0),
        OpcaoProduto(descricao: "Camarão", preco: 20.0),
      ],
    ),
    Produto(
      nome: "Caipirinha de Limão",
      categoria: "Bebidas",
      imagemPath: "assets/caipirinha_limao.jpg", 
      opcoes: [OpcaoProduto(descricao: "Tradicional", preco: 15.0)],
    ),
    Produto(
      nome: "Caipirinha de Maracujá",
      categoria: "Bebidas",
      imagemPath: "assets/caipirinha_maracuja.jpg",
      opcoes: [OpcaoProduto(descricao: "Maracujá", preco: 20.0)],
    ),
    Produto(
      nome: "Caipirinha de Morango",
      categoria: "Bebidas",
      imagemPath: "assets/caipirinha_morango.jpg",
      opcoes: [OpcaoProduto(descricao: "Morango", preco: 20.0)],
    ),
    Produto(
      nome: "Caipirinha de Pitaya",
      categoria: "Bebidas",
      imagemPath: "assets/caipirinha_pitaya.jpg",
      opcoes: [OpcaoProduto(descricao: "Pitaya", preco: 25.0)],
    ),
    Produto(
      nome: "Sorvete",
      categoria: "Sobremesas",
      imagemPath: "assets/sorvete_chocolate.jpg", 
      opcoes: [
        OpcaoProduto(descricao: "Chocolate", preco: 15.0),
        OpcaoProduto(descricao: "Flocos", preco: 15.0),
        OpcaoProduto(descricao: "Morango", preco: 15.0),
      ],
    ),
    Produto(
      nome: "Refrigerante",
      categoria: "Bebidas",
      imagemPath: "assets/refrigerante_coca_cola.jpg",
      opcoes: [
        OpcaoProduto(descricao: "Coca-Cola", preco: 8.0),
        OpcaoProduto(descricao: "Coca Zero", preco: 8.0),
        OpcaoProduto(descricao: "Guaraná", preco: 8.0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cinzaClaro,
      appBar: AppBar(
        title: const Text("Cardápio", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: meusProdutos.length,
        itemBuilder: (context, index) {
          return CardProduto(produto: meusProdutos[index]);
        },
      ),
    );
  }
}

// ESTA É A CLASSE QUE DESENHA O ITEM (Onde resolvemos o erro de pixels)
class CardProduto extends StatefulWidget {
  final Produto produto;
  const CardProduto({super.key, required this.produto});

  @override
  State<CardProduto> createState() => _CardProdutoState();
}

class _CardProdutoState extends State<CardProduto> {
  OpcaoProduto? opcaoSelecionada;
  int quantidade = 1;

  @override
  void initState() {
    super.initState();
    opcaoSelecionada = widget.produto.opcoes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                widget.produto.imagemPath,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80, width: 80, color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // CONTEÚDO EXPANDIDO (Para não dar erro de pixels)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.produto.nome,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  // Seletor de Opções
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<OpcaoProduto>(
                        isExpanded: true,
                        value: opcaoSelecionada,
                        items: widget.produto.opcoes.map((opcao) {
                          return DropdownMenuItem(
                            value: opcao,
                            child: Text(
                              "${opcao.descricao} - R\$ ${opcao.preco.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (novaOpcao) {
                          setState(() { opcaoSelecionada = novaOpcao; });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Quantidade e Botão Adicionar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () { if (quantidade > 1) setState(() { quantidade--; }); },
                            child: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text("$quantidade", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: () { setState(() { quantidade++; }); },
                            child: const Icon(Icons.add_circle, color: Colors.green, size: 24),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulPrincipal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${widget.produto.nome} adicionado!")),
                          );
                        },
                        child: const Text("Adicionar", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

