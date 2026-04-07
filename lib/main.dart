import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Importa o Supabase
import 'package:barraca_app_mobile/views/home_page.dart';

// O main agora é "async" porque ele precisa esperar a conexão com o banco
Future<void> main() async {
  // Garante que os componentes do Flutter carreguem antes da conexão
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Supabase (Substitua pelos seus dados do site)
  await Supabase.initialize(
    // Note que o ID no meio do link tem que ser idêntico ao que você copiou
    url: 'https://mlfsltltcrevaszfixja.supabase.co', 
    
    // A sua chave publicável que você copiou agora
    anonKey: 'sb_publishable_78RUUlwUbGBfztEJ44lQ8g_LIPdQYsV', 
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barraca de Praia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Mantemos a HomePage como a primeira tela
      home: const HomePage(), 
    );
  }
}

