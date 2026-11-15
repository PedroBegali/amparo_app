import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/models/kit.dart';
import 'package:amparo_sus_app/repositories/kit_repository.dart';
import 'package:amparo_sus_app/repositories/paciente_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/banner_offline.dart';
import 'package:amparo_sus_app/widgets/resumo_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KitsPage extends StatefulWidget {
  const KitsPage({super.key});

  @override
  State<KitsPage> createState() => _KitsPageState();
}

class _KitsPageState extends State<KitsPage> {
  final KitRepository kitRepository = KitRepository();
  final PacienteRepository pacienteRepository = PacienteRepository();
  final DateFormat formatoHora = DateFormat("dd/MM 'às' HH:mm");

  late Agente agente;
  List<Kit> kits = [];
  Map<int, String> nomesPacientes = {};
  String filtroStatus = "TODOS";
  bool carregando = true;
  bool iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      agente = ModalRoute.of(context)!.settings.arguments as Agente;
      iniciado = true;
      carregar();
    }
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
    });
    try {
      final pacientes = await pacienteRepository.listar(agente);
      final todos = await kitRepository.listar();
      final nomes = {for (final p in pacientes) p.id!: p.nome};
      if (!mounted) return;
      setState(() {
        nomesPacientes = nomes;
        kits = todos.where((k) => nomes.containsKey(k.pacienteId)).toList()
          ..sort((a, b) => a.bateriaPct.compareTo(b.bateriaPct));
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.detalhe), backgroundColor: corCritico),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  List<Kit> get kitsFiltrados =>
      filtroStatus == "TODOS" ? kits : kits.where((k) => k.status == filtroStatus).toList();

  Color corDoStatus(String status) {
    switch (status) {
      case "ATIVO":
        return verdeApoio;
      case "MANUTENCAO":
        return corModerado;
      default:
        return cinzaSuave;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bateriaBaixa = kits.where((k) => k.bateriaPct < 30).length;
    final ativos = kits.where((k) => k.status == "ATIVO").length;
    return Scaffold(
      appBar: AppBar(title: const Text("Kits LoRa")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregar,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const BannerOffline(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ResumoCard(
                              icone: Icons.router_outlined,
                              valor: "${kits.length}",
                              rotulo: "Kits instalados",
                              cor: azulPrincipal,
                              fundo: azulClaro,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResumoCard(
                              icone: Icons.check_circle_outline_rounded,
                              valor: "$ativos",
                              rotulo: "Ativos",
                              cor: verdeApoio,
                              fundo: const Color(0xFFF0FAF3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResumoCard(
                              icone: Icons.battery_alert_rounded,
                              valor: "$bateriaBaixa",
                              rotulo: "Bateria baixa",
                              cor: corCritico,
                              fundo: const Color(0xFFFFF5F5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      children: [
                        for (final opcao in ["TODOS", ...statusKit.keys])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              showCheckmark: false,
                              label: Text(opcao == "TODOS" ? "Todos" : statusKit[opcao]!),
                              selected: filtroStatus == opcao,
                              onSelected: (_) {
                                setState(() {
                                  filtroStatus = opcao;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: kitsFiltrados.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              "Nenhum kit neste status.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cinzaSuave),
                            ),
                          )
                        : Column(children: [for (final kit in kitsFiltrados) cardKit(kit)]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget cardKit(Kit kit) {
    final corStatus = corDoStatus(kit.status);
    final corBateria = kit.bateriaPct < 30 ? corCritico : verdeApoio;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: azulClaro, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.router_outlined, color: azulPrincipal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kit.serieLora,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: azulEscuro),
                        ),
                        Text(
                          nomesPacientes[kit.pacienteId] ?? "",
                          style: const TextStyle(fontSize: 13, color: cinzaTexto),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: corStatus.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusKit[kit.status] ?? kit.status,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: corStatus),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.battery_std_rounded, size: 16, color: corBateria),
                  const SizedBox(width: 4),
                  Text("Bateria ${kit.bateriaPct}%", style: const TextStyle(fontSize: 12, color: cinzaTexto)),
                  const Spacer(),
                  const Icon(Icons.signal_cellular_alt_rounded, size: 16, color: azulPrincipal),
                  const SizedBox(width: 4),
                  Text("Sinal ${kit.qualidadeSinal}", style: const TextStyle(fontSize: 12, color: cinzaTexto)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: kit.bateriaPct / 100,
                  minHeight: 6,
                  color: corBateria,
                  backgroundColor: azulClaro,
                ),
              ),
              if (kit.dataUltimoSinal != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Último sinal ${formatoHora.format(kit.dataUltimoSinal!)}",
                  style: const TextStyle(fontSize: 12, color: cinzaSuave),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
