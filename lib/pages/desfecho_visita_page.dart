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
          icon: const Icon(Icons.check_circle, color: verdeSus, size: 48),
          title: const Text("Visita concluída"),
          content: Text(
              "${visita.pacienteNome}\nDesfecho: ${desfechos[desfecho]}\nKit: ${statusKit[statusDoKit]}"),
          actions: [
            TextButton(
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
              child: ListTile(
                leading: const Icon(Icons.elderly, color: azulSus, size: 32),
                title: Text(visita.pacienteNome),
                subtitle: Text(visita.motivo),
                trailing: NivelRiscoChip(nivel: visita.nivelRisco),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: desfecho,
              decoration: const InputDecoration(
                labelText: "Desfecho",
                prefixIcon: Icon(Icons.fact_check_outlined),
                border: OutlineInputBorder(),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: observacaoController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: "Observações",
                hintText: "O que foi observado/orientado na visita",
                border: const OutlineInputBorder(),
                helperText: desfecho == "ENCAMINHADO_UBS" || desfecho == "ACIONADO_SAMU"
                    ? "Obrigatório para encaminhamentos"
                    : null,
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? "";
                final obrigatorio = desfecho == "ENCAMINHADO_UBS" || desfecho == "ACIONADO_SAMU";
                if (obrigatorio && texto.length < 10) {
                  return "Descreva o encaminhamento (mín. 10 caracteres).";
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text("Status dos kits LoRa",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final kit in kits)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.router_outlined, color: azulSus),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(kit.serieLora,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Text("sinal ${kit.qualidadeSinal}",
                              style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Bateria ${kit.bateriaPct}%", style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: kit.bateriaPct / 100,
                        minHeight: 8,
                        color: kit.bateriaPct < 30 ? corCritico : verdeSus,
                        backgroundColor: Colors.black12,
                      ),
                    ],
                  ),
                ),
              ),
            if (kits.isNotEmpty) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: statusDoKit,
                decoration: const InputDecoration(
                  labelText: "Status do kit após a visita",
                  prefixIcon: Icon(Icons.settings_input_antenna),
                  border: OutlineInputBorder(),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Sensores checados nesta visita"),
              value: sensoresChecados,
              onChanged: (valor) {
                setState(() {
                  sensoresChecados = valor;
                });
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: enviando ? null : salvar,
                icon: enviando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text("Concluir visita"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
