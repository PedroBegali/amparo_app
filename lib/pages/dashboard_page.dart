import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/repositories/visita_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/banner_offline.dart';
import 'package:amparo_sus_app/widgets/visita_card.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final VisitaRepository visitaRepository = VisitaRepository();
  final AuthRepository authRepository = AuthRepository();

  late Agente agente;
  List<Visita> visitas = [];
  String filtroNivel = "TODOS";
  int concluidasNoTurno = 0;
  bool carregando = true;
  bool iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      agente = ModalRoute.of(context)!.settings.arguments as Agente;
      iniciado = true;
      carregarRota();
    }
  }

  Future<void> carregarRota({bool recalcular = false}) async {
    setState(() {
      carregando = true;
    });
    try {
      if (recalcular) await visitaRepository.recalcular(agente.id);
      final rota = await visitaRepository.getRota(agente.id);
      if (!mounted) return;
      setState(() {
        visitas = rota;
      });
    } on ApiException catch (e) {
      mostrarMensagem(e.detalhe, erro: true);
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  List<Visita> get visitasFiltradas => filtroNivel == "TODOS"
      ? visitas
      : visitas.where((v) => v.nivelRisco == filtroNivel).toList();

  int contarNivel(String nivel) => visitas.where((v) => v.nivelRisco == nivel).length;

  Future<void> abrirProntuario(Visita visita) async {
    // Passa a visita (com o id do paciente) para o prontuário
    final concluiu = await Navigator.pushNamed(context, "/prontuario", arguments: visita);
    if (concluiu == true) {
      setState(() {
        visitas.removeWhere((v) => v.id == visita.id);
        concluidasNoTurno++;
      });
      mostrarMensagem("Visita a ${visita.pacienteNome} concluída!");
    }
  }

  Future<void> abrirTriagem() async {
    final cadastrou = await Navigator.pushNamed(context, "/triagem", arguments: agente);
    if (cadastrou == true) {
      mostrarMensagem("Novo idoso incluído no programa AMPARO.");
    }
  }

  void mostrarMensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: erro ? corCritico : verdeSus),
    );
  }

  Future<void> sair() async {
    await authRepository.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rota do dia"),
        actions: [
          IconButton(
            tooltip: "Recalcular rota",
            icon: const Icon(Icons.refresh),
            onPressed: carregando ? null : () => carregarRota(recalcular: true),
          ),
          IconButton(
            tooltip: "Sobre o AMPARO",
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, "/sobre"),
          ),
          IconButton(tooltip: "Sair", icon: const Icon(Icons.logout), onPressed: sair),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirTriagem,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Nova triagem"),
      ),
      body: Column(
        children: [
          const BannerOffline(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: cabecalhoTurno(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: resumoPorNivel(),
          ),
          filtros(),
          Expanded(child: listaRota()),
        ],
      ),
    );
  }

  Widget cabecalhoTurno() {
    return Card(
      color: azulSus,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.medical_services, color: azulSus),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Olá, ${agente.primeiroNome}!",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${agente.ubs} • ${agente.microarea}",
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Pendentes no turno: ${visitas.length}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Concluídas: $concluidasNoTurno",
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget resumoPorNivel() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      childAspectRatio: 1.25,
      children: [
        for (final nivel in niveisRisco)
          Container(
            decoration: BoxDecoration(
              color: corDoNivel(nivel).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: corDoNivel(nivel).withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${contarNivel(nivel)}",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: corDoNivel(nivel))),
                Text(rotuloDoNivel(nivel),
                    style: TextStyle(fontSize: 11, color: corDoNivel(nivel))),
              ],
            ),
          ),
      ],
    );
  }

  Widget filtros() {
    final opcoes = ["TODOS", ...niveisRisco];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final opcao in opcoes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(opcao == "TODOS" ? "Todos" : rotuloDoNivel(opcao)),
                selected: filtroNivel == opcao,
                selectedColor: opcao == "TODOS"
                    ? azulSus.withValues(alpha: 0.2)
                    : corDoNivel(opcao).withValues(alpha: 0.25),
                onSelected: (_) {
                  setState(() {
                    filtroNivel = opcao;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget listaRota() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    final lista = visitasFiltradas;
    if (lista.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 56, color: verdeSus),
              const SizedBox(height: 8),
              Text(
                visitas.isEmpty
                    ? "Nenhuma visita pendente. Todos os idosos estão estáveis!"
                    : "Nenhuma visita com nível ${rotuloDoNivel(filtroNivel)}.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => carregarRota(recalcular: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final visita = lista[index];
          return VisitaCard(
            visita: visita,
            ordem: visitas.indexOf(visita) + 1,
            onTap: () => abrirProntuario(visita),
          );
        },
      ),
    );
  }
}
