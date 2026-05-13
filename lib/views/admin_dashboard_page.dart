import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final supabase = Supabase.instance.client;
  String filtroSelecionado = "Tudo";

  // --- FUNÇÃO 1: FATURAMENTO ---
  Future<double> _getFaturamentoTotal() async {
    var query = supabase.from('pedidos').select('valor_total');
    if (filtroSelecionado == "Hoje") {
      final agora = DateTime.now();
      final inicioDia = DateTime(
        agora.year,
        agora.month,
        agora.day,
      ).toIso8601String();
      query = query.gte('created_at', inicioDia);
    } else if (filtroSelecionado == "Mês") {
      final agora = DateTime.now();
      final inicioMes = DateTime(agora.year, agora.month, 1).toIso8601String();
      query = query.gte('created_at', inicioMes);
    }
    final response = await query;
    double total = 0;
    for (var item in response) {
      total += (item['valor_total'] as num).toDouble();
    }
    return total;
  }

  // --- FUNÇÃO 2: DADOS DO GRÁFICO (ORDENADOS) ---
  Future<Map<String, double>> _getDadosGrafico() async {
    final response = await supabase.from('pedidos').select('itens');
    Map<String, double> contagemProdutos = {};
    for (var registro in response) {
      String itensStr = registro['itens'] ?? "";
      List<String> partes = itensStr.split(',');
      for (var parte in partes) {
        String nome = parte.trim().replaceAll(RegExp(r'^\d+x\s+'), '');
        if (nome.isNotEmpty) {
          contagemProdutos[nome] = (contagemProdutos[nome] ?? 0) + 1;
        }
      }
    }
    // Ordenação do maior para o menor
    var listaOrdenada = contagemProdutos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(listaOrdenada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumo de Vendas",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // BOTÕES DE FILTRO
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Hoje"),
                  _buildFilterChip("Mês"),
                  _buildFilterChip("Tudo"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CARD DE FATURAMENTO
            FutureBuilder<double>(
              future: _getFaturamentoTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final total = snapshot.data ?? 0.0;
                return Card(
                  elevation: 4,
                  color: Colors.green[700],
                  child: ListTile(
                    leading: const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 40,
                    ),
                    title: const Text(
                      "Faturamento Geral",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      NumberFormat.simpleCurrency(
                        locale: 'pt_BR',
                      ).format(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
              "Gráficos e Desempenho",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // --- GRÁFICO PROFISSIONAL ---
            FutureBuilder<Map<String, double>>(
              future: _getDadosGrafico(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final dados = snapshot.data ?? {};
                if (dados.isEmpty) {
                  return const Center(child: Text("Sem vendas ainda."));
                }

                List<BarChartGroupData> barras = [];
                int x = 0;
                dados.forEach((nome, quantidade) {
                  // O primeiro (x=0) será o laranja mais escuro [700]
                  // O segundo (x=1) será o [600], e assim por diante
                  final int tom = (700 - (x * 100)).clamp(300, 700);

                  barras.add(
                    BarChartGroupData(
                      x: x,
                      barRods: [
                        BarChartRodData(
                          toY: quantidade,
                          color: Colors.orange[tom], // Aplica o tom degradê
                          width: 22,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    ),
                  );
                  x++;
                });
                return Container(
                  height: 300,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width:
                          dados.length * 80.0, // Largura para permitir o scroll
                      child: BarChart(
                        BarChartData(
                          maxY:
                              dados.values.reduce((a, b) => a > b ? a : b) + 1,
                          barGroups: barras,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine:
                                false, // Deixa só as horizontais para não poluir
                            horizontalInterval:
                                1, // Uma linha para cada venda (1, 2, 3...)
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                              dashArray: [
                                5,
                                5,
                              ], // Deixa a linha tracejada (estilo profissional)
                            ),
                          ),

                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            // ... continue com o restante do seu titlesData
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (val, meta) {
                                  // O 'meta' já vem aqui do Flutter
                                  if (val.toInt() >= dados.length) {
                                    return const Text("");
                                  }
                                  String nome = dados.keys.elementAt(
                                    val.toInt(),
                                  );

                                  return SideTitleWidget(
                                    meta:
                                        meta, // <--- AJUSTE AQUI: Passe o objeto meta inteiro
                                    space: 10,
                                    child: Text(
                                      nome.length > 5
                                          ? "${nome.substring(0, 5)}."
                                          : nome,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ), // AQUI FOI ONDE FALTAVA FECHAR
          ],
        ),
      ),
    );
  }

  // Função auxiliar (fora do build)
  Widget _buildFilterChip(String label) {
    bool selecionado = filtroSelecionado == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (bool value) {
          setState(() {
            filtroSelecionado = label;
          });
        },
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(
          color: selecionado ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
