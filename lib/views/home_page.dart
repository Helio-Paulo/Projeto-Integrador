import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'login_page.dart';
import 'cardapio_page.dart'; // O Flutter agora sabe que o cardápio existe!

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        title: const Text("Barraca de Praia", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.azulPrincipal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Sua Imagem de Capa
            Image.asset(
              'assets/capa.jpg',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. Botão de Login / Cadastro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulPrincipal,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Vai para a tela de Login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.person_pin_circle, color: Colors.white, size: 30),
                label: const Text(
                  "LOGIN / IDENTIFICAR-SE",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Botão de Cardápio (Ele voltou!)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700], 
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Vai para a tela de Cardápio
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CardapioPage()),
                  );
                },
                icon: const Icon(Icons.restaurant_menu, color: Colors.white, size: 30),
                label: const Text(
                  "VER CARDÁPIO",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

