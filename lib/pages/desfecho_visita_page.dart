import 'package:amparo_sus_app/models/kit.dart';
import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/repositories/visita_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:flutter/material.dart';

class DesfechoVisitaPage extends StatefulWidget {
  const DesfechoVisitaPage({super.key});

  @override
  State<DesfechoVisitaPage> createState() => _DesfechoVisitaPageState();
}

class _DesfechoVisitaPageState extends State<DesfechoVisitaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController observacaoController = TextEditingController();
  final VisitaRepository visitaRepository = VisitaRepository();

  late Visita visita;
  late List<Kit> kits;
  String? desfecho;
  String statusDoKit = "ATIVO";
  bool sensoresChecados = false;
  bool enviando = false;
  bool iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      visita = args["visita"] as Visita;
      kits = args["kits"] as List<Kit>;
      sensoresChecados = args["sensoresChecados"] as bool;
      if (kits.isNotEmpty) statusDoKit = kits.first.status;
      iniciado = true;
    }
  }

  @override
  void dispose() {
    observacaoController.dispose();
    super.dispose();
  }

  bool get observacaoObrigatoria => desfecho == "ENCAMINHADO_UBS" || desfecho == "ACIONADO_SAMU";

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      enviando = true;
    });
    try {
      await visitaRepository.concluir(
        visita.id,
        desfecho!,
        observacaoController.text.trim(),
        sensoresChecados,
        kits.isEmpty ? null : statusDoKit,
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: verdeApoio, size: 56),
          title: const Text("Visita concluída",
              style: TextStyle(fontWeight: FontWeight.w700, color: azulEscuro)),
          content: Text(
            "${visita.pacienteNome}\nDesfecho: ${desfechos[desfecho]}\nKit: ${statusKit[statusDoKit]}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: cinzaTexto, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Voltar para a rota"),
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
      appBar: AppBar(title: const Text("Desfecho da visita")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: fundoDoNivel(visita.nivelRisco),
                      child: Icon(Icons.elderly_rounded, color: corDoNivel(visita.nivelRisco)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visita.pacienteNome,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: azulEscuro),
                          ),
                          const SizedBox(height: 2),
                          Text(visita.motivo, style: const TextStyle(fontSize: 13, color: cinzaTexto)),
                          const SizedBox(height: 6),
                          NivelRiscoChip(nivel: visita.nivelRisco, score: visita.score),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            tituloSecao("Registro da visita"),
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(12),
              initialValue: desfecho,
              decoration: const InputDecoration(
                labelText: "Desfecho",
                prefixIcon: Icon(Icons.fact_check_outlined),
              ),
              items: [
                for (final entrada in desfechos.entries)
                  DropdownMenuItem(value: entrada.key, child: Text(entrada.value)),
              ],
              onChanged: (valor) {
                setState(() {
                  desfecho = valor;
                });
              },
              validator: (valor) => valor == null ? "Selecione o desfecho da visita." : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: observacaoController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: "Observações",
                hintText: "O que foi observado ou orientado na visita",
                alignLabelWithHint: true,
                helperText: observacaoObrigatoria ? "Obrigatório para encaminhamentos" : null,
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? "";
                if (observacaoObrigatoria && texto.length < 10) {
                  return "Descreva o encaminhamento (mín. 10 caracteres).";
                }
                return null;
              },
            ),
            if (kits.isNotEmpty) ...[
              tituloSecao("Status dos kits LoRa"),
              for (final kit in kits)
                Padding(
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
                                decoration: BoxDecoration(
                                    color: azulClaro, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.router_outlined, color: azulPrincipal),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(kit.serieLora,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: azulEscuro)),
                              ),
                              Text("Sinal ${kit.qualidadeSinal}",
                                  style: const TextStyle(fontSize: 12, color: cinzaSuave)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text("Bateria ${kit.bateriaPct}%",
                              style: const TextStyle(fontSize: 12, color: cinzaTexto)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: kit.bateriaPct / 100,
                              minHeight: 8,
                              color: kit.bateriaPct < 30 ? corCritico : verdeApoio,
                              backgroundColor: azulClaro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                borderRadius: BorderRadius.circular(12),
                initialValue: statusDoKit,
                decoration: const InputDecoration(
                  labelText: "Status do kit após a visita",
                  prefixIcon: Icon(Icons.settings_input_antenna_rounded),
                ),
                items: [
                  for (final entrada in statusKit.entries)
                    DropdownMenuItem(value: entrada.key, child: Text(entrada.value)),
                ],
                onChanged: (valor) {
                  setState(() {
                    statusDoKit = valor ?? "ATIVO";
                  });
                },
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: verdeApoio,
              title: const Text("Sensores checados nesta visita",
                  style: TextStyle(fontSize: 14, color: cinzaTexto)),
              value: sensoresChecados,
              onChanged: (valor) {
                setState(() {
                  sensoresChecados = valor;
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: verdeApoio),
              onPressed: enviando ? null : salvar,
              icon: enviando
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_rounded),
              label: const Text("Concluir visita"),
            ),
          ],
        ),
      ),
    );
  }

  Widget tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 0, 12),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: azulEscuro),
      ),
    );
  }
}
