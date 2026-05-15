import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import 'cardapio_page.dart';
import '../core/globals.dart';
import 'admin_dashboard_page.dart';
import 'cozinha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _carregando = false;
  // Controladores para capturar o que o usuário digita
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mesaController = TextEditingController();

  @override
  void dispose() {
    // Limpeza de memória ao sair da tela
    _nomeController.dispose();
    _emailController.dispose();
    _mesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        title: const Text(
          "Identificação",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Como deseja se identificar?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulPrincipal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Você pode entrar apenas com seu nome e mesa, ou fazer um cadastro completo.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Nome
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do Cliente",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-mail ou Telefone (Opcional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_mail_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Mesa
              TextField(
                controller: _mesaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Número da Mesa",
                  hintText: "Ex: 05",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.table_bar_outlined),
                ),
              ),
              const SizedBox(height: 40),

              // Botão Confirmar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulPrincipal,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _carregando
                    ? null
                    : () async {
                        // BLOQUEIA CLIQUE DUPLO
                        String nome = _nomeController.text.trim();
                        String mesa = _mesaController.text.trim();
                        String email = _emailController.text.trim();

                        if (nome.isEmpty || mesa.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Por favor, preencha Nome e Mesa!"),
                            ),
                          );
                          return;
                        }

                        setState(() => _carregando = true); // COMEÇA A CARREGAR

                        try {
                          // --- PASSO 1: VERIFICA SE É ADMIN ---
                          if (nome.toLowerCase() == 'admin' && mesa == '999') {
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminDashboardPage(),
                              ),
                            );
                            return;
                          }

                          // --- PASSO 1.5: VERIFICA SE É A COZINHA (NOVO DESVIO) ---
                          if (nome.toLowerCase() == 'cozinha' &&
                              mesa == '888') {
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              // Aqui você vai criar a CozinhaPage depois, por enquanto o VS Code vai marcar erro
                              MaterialPageRoute(
                                builder: (context) => const CozinhaPage(),
                              ),
                            );
                            return;
                          }

                          // --- PASSO 2: SÓ CHEGA AQUI SE FOR CLIENTE COMUM ---
                          await Supabase.instance.client
                              .from('clientes')
                              .insert({
                                'nome': nome,
                                'mesa': mesa,
                                'email': email.isEmpty
                                    ? 'sem@email.com'
                                    : email,
                              });
                          Globals.mesaAtiva = mesa;

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Identificado com sucesso!"),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CardapioPage(),
                            ),
                          );
                        } catch (erro) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erro ao entrar: $erro")),
                          );
                        } finally {
                          if (mounted) {
                            setState(
                              () => _carregando = false,
                            ); // LIBERA O BOTÃO
                          }
                        }
                      },

                child: const Text(
                  "CONFIRMAR E CONTINUAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
