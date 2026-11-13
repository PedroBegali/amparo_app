import 'package:amparo_sus_app/pages/dashboard_page.dart';
import 'package:amparo_sus_app/pages/desfecho_visita_page.dart';
import 'package:amparo_sus_app/pages/login_page.dart';
import 'package:amparo_sus_app/pages/prontuario_page.dart';
import 'package:amparo_sus_app/pages/sobre_page.dart';
import 'package:amparo_sus_app/pages/triagem_page.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AmparoApp());
}

class AmparoApp extends StatelessWidget {
  const AmparoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AMPARO-SUS",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: azulSus, primary: azulSus, secondary: verdeSus),
        scaffoldBackgroundColor: fundoClaro,
        appBarTheme: const AppBarTheme(
          backgroundColor: azulSus,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: verdeSus,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: verdeSus,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Rotas nomeadas; os parâmetros seguem em "arguments"
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginPage(), // 1
        "/dashboard": (context) => const DashboardPage(), // 2 (Agente)
        "/prontuario": (context) => const ProntuarioPage(), // 3 (Visita)
        "/triagem": (context) => const TriagemPage(), // 4 (Agente)
        "/desfecho": (context) => const DesfechoVisitaPage(), // 5 (Visita + kits)
        "/sobre": (context) => const SobrePage(),
      },
    );
  }
}
