import 'package:amparo_sus_app/pages/dashboard_page.dart';
import 'package:amparo_sus_app/pages/desfecho_visita_page.dart';
import 'package:amparo_sus_app/pages/kits_page.dart';
import 'package:amparo_sus_app/pages/login_page.dart';
import 'package:amparo_sus_app/pages/pacientes_page.dart';
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
      title: "AMPARO SUS",
      debugShowCheckedModeBanner: false,
      theme: temaAmparo(),
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFFDCE6F2),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginPage(),
        "/dashboard": (context) => const DashboardPage(),
        "/prontuario": (context) => const ProntuarioPage(),
        "/triagem": (context) => const TriagemPage(),
        "/desfecho": (context) => const DesfechoVisitaPage(),
        "/pacientes": (context) => const PacientesPage(),
        "/kits": (context) => const KitsPage(),
        "/sobre": (context) => const SobrePage(),
      },
    );
  }
}
