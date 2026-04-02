import 'package:flutter/material.dart';
import 'package:barraca_app_mobile/views/home_page.dart'; // Aqui estamos chamando a tela que criamos

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barraca de Praia',
      debugShowCheckedModeBanner: false, // Tira aquela faixa de "debug" do canto
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Aqui dizemos que a primeira tela que o app abre é a HomePage
      home: const HomePage(), 
    );
  }
}

