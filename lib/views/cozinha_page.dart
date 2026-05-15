import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';

class CozinhaPage extends StatefulWidget {
  const CozinhaPage({super.key});

  @override
  State<CozinhaPage> createState() => _CozinhaPageState();
}

class _CozinhaPageState extends State<CozinhaPage> {
  final _supabase = Supabase.instance.client;
  String _filtroPesquisa = ""; // Guarda o texto digitado na pesquisa de prontos

  // Altera o status do pedido
  // Altera o status do pedido e força a atualização da tela
  Future<void> _mudarStatusPedido(int id, String novoStatus) async {
    try {
      await _supabase.from('pedidos').update({'status': novoStatus}).match({
        'id': id,
      });

      // ADICIONE ESTA LINHA AQUI:
      // Ela força o Flutter a recarregar o StreamBuilder localmente
      setState(() {});
    } catch (e) {
      debugPrint("Erro ao atualizar status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // DefaultTabController cria as duas abas automaticamente
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Painel da Cozinha",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.azulPrincipal,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.timer), text: "PENDENTES"),
              Tab(
                icon: Icon(Icons.check_circle),
                text: "CONCLUÍDOS / HISTÓRICO",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- ABA 1: PEDIDOS PENDENTES ---
            _construirListaPedidos('Pendente'),

            // --- ABA 2: HISTÓRICO DE PRONTOS + PESQUISA ---
            Column(
              children: [
                // Barra de pesquisa para buscar por mesa ou senha
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Pesquisar por Mesa ou Senha",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (valor) {
                      setState(() {
                        _filtroPesquisa =
                            valor; // Atualiza a busca a cada letra digitada
                      });
                    },
                  ),
                ),
                Expanded(child: _construirListaPedidos('Pronto')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget reaproveitável que constrói as listas puxando do Supabase
  // Widget reaproveitável que constrói as listas puxando do Supabase
  Widget _construirListaPedidos(String statusFiltro) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase
          .from('pedidos')
          .stream(primaryKey: ['id'])
          .eq('status', statusFiltro)
          .order('created_at', ascending: statusFiltro == 'Pendente'),
      builder: (context, snapshot) {
        // CORREÇÃO DO ERRO 1: Adicionado chaves no if de erro
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar"));
        }

        // CORREÇÃO DO ERRO 2: Adicionado chaves no if de carregamento
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var pedidos = snapshot.data!;
      
        // Se for a aba de prontos e tiver texto na barra de pesquisa, filtra a lista localmente
        if (statusFiltro == 'Pronto' && _filtroPesquisa.isNotEmpty) {
          pedidos = pedidos.where((p) {
            final mesa = p['mesa'].toString().toLowerCase();
            final senha = (p['senha'] ?? '').toString().toLowerCase();
            return mesa.contains(_filtroPesquisa.toLowerCase()) ||
                senha.contains(_filtroPesquisa.toLowerCase());
          }).toList();
        }

        if (pedidos.isEmpty) {
          return Center(
            child: Text("Nenhum pedido $statusFiltro por aqui 🏖️"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            final bool isPendente = statusFiltro == 'Pendente';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                title: Text(
                  "MESA ${pedido['mesa']} - Senha: ${pedido['senha'] ?? '---'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    pedido['itens'],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ),
                trailing: isPendente
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _mudarStatusPedido(
                          pedido['id'],
                          'Pronto',
                        ), // P maiúsculo
                        child: const Text(
                          "PRONTO",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () =>
                            _mudarStatusPedido(pedido['id'], 'Pendente'),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text(
                          "REABRIR",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
