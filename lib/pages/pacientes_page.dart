import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/models/paciente.dart';
import 'package:amparo_sus_app/repositories/paciente_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/banner_offline.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:flutter/material.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final PacienteRepository pacienteRepository = PacienteRepository();
  final TextEditingController buscaController = TextEditingController();

  late Agente agente;
  List<Paciente> pacientes = [];
  String busca = "";
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

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
    });
    try {
      final lista = await pacienteRepository.listar(agente);
      lista.sort((a, b) => b.scoreRisco.compareTo(a.scoreRisco));
      if (!mounted) return;
      setState(() {
        pacientes = lista;
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

  List<Paciente> get pacientesFiltrados {
    final termo = busca.trim().toLowerCase();
    if (termo.isEmpty) return pacientes;
    return pacientes.where((p) => p.nome.toLowerCase().contains(termo)).toList();
  }

  Future<void> abrirProntuario(Paciente paciente) async {
    final concluiu = await Navigator.pushNamed(context, "/prontuario", arguments: paciente);
    if (concluiu == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    final lista = pacientesFiltrados;
    return Scaffold(
      appBar: AppBar(title: const Text("Pacientes")),
      body: Column(
        children: [
          const BannerOffline(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: buscaController,
              decoration: InputDecoration(
                hintText: "Buscar pelo nome do idoso",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: busca.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: cinzaSuave,
                        onPressed: () {
                          buscaController.clear();
                          setState(() {
                            busca = "";
                          });
                        },
                      ),
              ),
              onChanged: (valor) {
                setState(() {
                  busca = valor;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "${lista.length} idoso(s) monitorado(s)",
                  style: const TextStyle(fontSize: 13, color: cinzaSuave),
                ),
                const Spacer(),
                Text(
                  agente.isGestor ? agente.ubs : agente.microarea,
                  style: const TextStyle(fontSize: 13, color: azulPrincipal, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: carregar,
                    child: lista.isEmpty
                        ? ListView(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  "Nenhum idoso encontrado.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: cinzaSuave),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: lista.length,
                            itemBuilder: (context, index) => cardPaciente(lista[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget cardPaciente(Paciente paciente) {
    final cor = corDoNivel(paciente.nivelRisco);
    final iniciais = iniciaisDoNome(paciente.nome);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => abrirProntuario(paciente),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: fundoDoNivel(paciente.nivelRisco),
                  child: Text(iniciais, style: TextStyle(color: cor, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paciente.nome,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: azulEscuro),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${paciente.idade} anos · ${condicoesPorExtenso(paciente.condicoes)}",
                        style: const TextStyle(fontSize: 13, color: cinzaTexto),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          NivelRiscoChip(nivel: paciente.nivelRisco, score: paciente.scoreRisco),
                          if (paciente.moraSozinho) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.person_outline_rounded, size: 14, color: cinzaSuave),
                            const Text("Mora só", style: TextStyle(fontSize: 12, color: cinzaSuave)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: cinzaSuave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
