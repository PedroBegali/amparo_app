import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/models/kit.dart';
import 'package:amparo_sus_app/models/paciente.dart';
import 'package:amparo_sus_app/repositories/kit_repository.dart';
import 'package:amparo_sus_app/repositories/paciente_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TELA 4 - Formulário de avaliação/triagem domiciliar para inclusão no AMPARO
class TriagemPage extends StatefulWidget {
  const TriagemPage({super.key});

  @override
  State<TriagemPage> createState() => _TriagemPageState();
}

class _TriagemPageState extends State<TriagemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cnsController = TextEditingController();
  final TextEditingController nascimentoController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController microareaController = TextEditingController();
  final TextEditingController kitController = TextEditingController(text: "KIT-LORA-");

  final PacienteRepository pacienteRepository = PacienteRepository();
  final KitRepository kitRepository = KitRepository();

  late Agente agente;
  DateTime? dataNascimento;
  final Set<String> condicoes = {};
  bool moraSozinho = false;
  bool erroCondicoes = false;
  bool enviando = false;
  bool iniciado = false;

  static const Map<String, String> opcoesCondicoes = {
    "HAS": "Hipertensão",
    "DM": "Diabetes",
    "ICC": "Insuf. cardíaca",
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      agente = ModalRoute.of(context)!.settings.arguments as Agente;
      // gestor (MA-00) informa a microárea; o agente já vem com a sua
      microareaController.text = agente.isGestor ? "" : agente.microarea;
      iniciado = true;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    cnsController.dispose();
    nascimentoController.dispose();
    enderecoController.dispose();
    microareaController.dispose();
    kitController.dispose();
    super.dispose();
  }

  Future<void> escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: dataNascimento ?? DateTime(hoje.year - 70),
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: "Data de nascimento",
    );
    if (escolhida != null) {
      setState(() {
        dataNascimento = escolhida;
        nascimentoController.text = DateFormat("dd/MM/yyyy").format(escolhida);
      });
    }
  }

  // Ordem fixa HAS,DM,ICC (formato validado pela API)
  String get condicoesFormatadas =>
      opcoesCondicoes.keys.where((c) => condicoes.contains(c)).join(",");

  Future<void> salvar() async {
    final formularioValido = _formKey.currentState!.validate();
    setState(() {
      erroCondicoes = condicoes.isEmpty;
    });
    if (!formularioValido || condicoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Corrija os campos destacados."), backgroundColor: corCritico),
      );
      return;
    }

    setState(() {
      enviando = true;
    });
    try {
      final paciente = await pacienteRepository.cadastrar(Paciente(
        agenteId: agente.isGestor ? 1 : agente.id,
        nome: nomeController.text.trim(),
        cns: cnsController.text.trim(),
        dataNascimento: dataNascimento!,
        endereco: enderecoController.text.trim(),
        microarea: microareaController.text.trim().toUpperCase(),
        condicoes: condicoesFormatadas,
        moraSozinho: moraSozinho,
      ));
      final kit = await kitRepository.vincular(Kit(
        pacienteId: paciente.id!,
        serieLora: kitController.text.trim().toUpperCase(),
      ));
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.verified_user, color: verdeSus, size: 48),
          title: const Text("Idoso incluído no AMPARO"),
          content: Text("${paciente.nome} (${paciente.idade} anos)\n"
              "Kit ${kit.serieLora} vinculado e pronto para instalação.\n"
              "Nível inicial: ${rotuloDoNivel(paciente.nivelRisco)} (score ${paciente.scoreRisco})."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.detalhe), backgroundColor: corCritico),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Triagem domiciliar")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              color: Color(0xFFE8F0FC),
              child: ListTile(
                leading: Icon(Icons.assignment_ind, color: azulSus),
                title: Text("Critérios de inclusão"),
                subtitle: Text("Idoso (60+) com doença crônica e baixa rede de apoio. "
                    "O kit sai da UBS pré-vinculado ao cadastro."),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Nome completo",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? "";
                if (texto.isEmpty) return "Informe o nome do idoso.";
                if (texto.length < 3 || !texto.contains(" ")) return "Informe nome e sobrenome.";
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cnsController,
              keyboardType: TextInputType.number,
              maxLength: 15,
              decoration: const InputDecoration(
                labelText: "Cartão Nacional de Saúde (CNS)",
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || !RegExp(r"^\d{15}$").hasMatch(valor.trim())) {
                  return "O CNS deve ter 15 dígitos.";
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: nascimentoController,
              readOnly: true,
              onTap: escolherData,
              decoration: const InputDecoration(
                labelText: "Data de nascimento",
                prefixIcon: Icon(Icons.cake_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (_) {
                if (dataNascimento == null) return "Selecione a data de nascimento.";
                final idade = DateTime.now().difference(dataNascimento!).inDays ~/ 365;
                if (idade < 60) return "O programa atende idosos com 60 anos ou mais.";
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: enderecoController,
              decoration: const InputDecoration(
                labelText: "Endereço",
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (valor) =>
                  (valor == null || valor.trim().length < 8) ? "Informe o endereço completo." : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: microareaController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: "Microárea",
                      hintText: "MA-01",
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) => RegExp(r"^MA-\d{2}$").hasMatch((valor ?? "").trim().toUpperCase())
                        ? null
                        : "Formato MA-01",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: kitController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: "Série do Kit LoRa",
                      prefixIcon: Icon(Icons.router_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) =>
                        RegExp(r"^KIT-LORA-\d{4}$").hasMatch((valor ?? "").trim().toUpperCase())
                            ? null
                            : "Formato KIT-LORA-0000",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Condições crônicas", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final entrada in opcoesCondicoes.entries)
                  FilterChip(
                    label: Text(entrada.value),
                    selected: condicoes.contains(entrada.key),
                    onSelected: (marcado) {
                      setState(() {
                        if (marcado) {
                          condicoes.add(entrada.key);
                        } else {
                          condicoes.remove(entrada.key);
                        }
                        erroCondicoes = false;
                      });
                    },
                  ),
              ],
            ),
            if (erroCondicoes)
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 12),
                child: Text("Selecione ao menos uma condição.",
                    style: TextStyle(color: corCritico, fontSize: 12)),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Mora sozinho(a) ou passa o dia sem apoio"),
              subtitle: const Text("Aumenta a prioridade nas visitas (+5 no score)"),
              value: moraSozinho,
              onChanged: (valor) {
                setState(() {
                  moraSozinho = valor;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: enviando ? null : salvar,
                icon: enviando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.how_to_reg),
                label: const Text("Incluir no AMPARO e vincular kit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
