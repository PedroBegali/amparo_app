import 'package:amparo_sus_app/models/leitura.dart';
import 'package:amparo_sus_app/models/prontuario.dart';
import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/repositories/paciente_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/banner_offline.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:amparo_sus_app/widgets/sensor_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TELA 3 - Prontuário de telemetria do idoso (PIR, porta-remédios, colchão e SOS)
class ProntuarioPage extends StatefulWidget {
  const ProntuarioPage({super.key});

  @override
  State<ProntuarioPage> createState() => _ProntuarioPageState();
}

class _ProntuarioPageState extends State<ProntuarioPage> {
  final PacienteRepository pacienteRepository = PacienteRepository();
  final DateFormat formatoHora = DateFormat("dd/MM HH:mm");

  late Visita visita;
  Prontuario? prontuario;
  String? erro;
  bool sensoresChecados = false; // confirmação da checagem dos sensores (setState)
  bool iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      visita = ModalRoute.of(context)!.settings.arguments as Visita;
      iniciado = true;
      carregar();
    }
  }

  Future<void> carregar() async {
    try {
      final dados = await pacienteRepository.getProntuario(visita.pacienteId);
      if (!mounted) return;
      setState(() {
        prontuario = dados;
        erro = null;
      });
    } on ApiException catch (e) {
      setState(() {
        erro = e.detalhe;
      });
    }
  }

  Future<void> registrarDesfecho() async {
    final concluiu = await Navigator.pushNamed(context, "/desfecho", arguments: {
      "visita": visita,
      "kits": prontuario!.kits,
      "sensoresChecados": sensoresChecados,
    });
    if (concluiu == true && mounted) {
      // volta ao dashboard avisando que a visita foi concluída
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(visita.pacienteNome)),
      body: Column(
        children: [
          const BannerOffline(),
          Expanded(child: conteudo()),
        ],
      ),
      bottomNavigationBar: prontuario == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: sensoresChecados,
                      title: const Text("Confirmo a checagem dos sensores do kit"),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (valor) {
                        setState(() {
                          sensoresChecados = valor ?? false;
                        });
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: sensoresChecados ? registrarDesfecho : null,
                        icon: const Icon(Icons.assignment_turned_in),
                        label: Text(sensoresChecados
                            ? "Registrar desfecho da visita"
                            : "Cheque os sensores para concluir"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget conteudo() {
    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: corCritico, size: 48),
            Padding(padding: const EdgeInsets.all(12), child: Text(erro!)),
            OutlinedButton(onPressed: carregar, child: const Text("Tentar novamente")),
          ],
        ),
      );
    }
    if (prontuario == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final p = prontuario!.paciente;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: corDoNivel(p.nivelRisco),
                      child: const Icon(Icons.elderly, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nome,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          Text("${p.idade} anos • CNS ${p.cns}",
                              style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                linhaInfo(Icons.place_outlined, p.endereco),
                linhaInfo(Icons.monitor_heart_outlined, "Condições: ${p.condicoes.replaceAll(",", ", ")}"),
                linhaInfo(Icons.home_outlined, p.moraSozinho ? "Mora sozinho(a)" : "Mora com familiares"),
                linhaInfo(Icons.badge_outlined, "ACS responsável: ${prontuario!.agenteNome}"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    NivelRiscoChip(nivel: p.nivelRisco, score: p.scoreRisco),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Motivo do alerta: ${visita.motivo}",
                    style: TextStyle(color: corDoNivel(visita.nivelRisco), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text("Sensores do Kit AMPARO",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        gradeSensores(),
        const SizedBox(height: 12),
        const Text("Kit LoRa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        for (final kit in prontuario!.kits)
          Card(
            child: ListTile(
              leading: const Icon(Icons.router_outlined, color: azulSus),
              title: Text(kit.serieLora),
              subtitle: Text(
                  "${statusKit[kit.status] ?? kit.status} • bateria ${kit.bateriaPct}% • sinal ${kit.qualidadeSinal}"
                  "${kit.dataUltimoSinal == null ? "" : "\nÚltimo sinal: ${formatoHora.format(kit.dataUltimoSinal!)}"}"),
              isThreeLine: kit.dataUltimoSinal != null,
            ),
          ),
        const SizedBox(height: 12),
        const Text("Últimas leituras", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        for (final leitura in prontuario!.ultimasLeituras)
          ListTile(
            dense: true,
            leading: Icon(iconeSensor(leitura.tipoSensor),
                color: leituraEmAlerta(leitura) ? corCritico : azulSus),
            title: Text(leitura.resumo),
            subtitle: Text(formatoHora.format(leitura.dataLeitura)),
          ),
      ],
    );
  }

  Widget linhaInfo(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icone, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // GridView 2x2 com a última leitura de cada sensor
  Widget gradeSensores() {
    final pir = prontuario!.ultimaDoSensor("PIR");
    final remedio = prontuario!.ultimaDoSensor("PORTA_REMEDIO");
    final colchao = prontuario!.ultimaDoSensor("COLCHAO");
    final sos = prontuario!.ultimaDoSensor("SOS");
    final horasRemedio =
        remedio == null ? null : DateTime.now().difference(remedio.dataLeitura).inHours;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.35,
      children: [
        SensorCard(
          titulo: "Movimento (PIR)",
          icone: Icons.directions_walk,
          valor: pir == null ? "--" : "${pir.minImovel ?? 0} min",
          detalhe: pir == null ? "sem leitura" : "imóvel • ${formatoHora.format(pir.dataLeitura)}",
          alerta: (pir?.minImovel ?? 0) > 240,
        ),
        SensorCard(
          titulo: "Porta-remédios",
          icone: Icons.medication_outlined,
          valor: horasRemedio == null ? "--" : "há ${horasRemedio}h",
          detalhe: remedio == null
              ? "sem abertura"
              : "${remedio.bpm ?? "-"} bpm • SpO2 ${remedio.spo2 ?? "-"}%",
          alerta: (horasRemedio ?? 0) > 24 || (remedio?.spo2 ?? 100) < 90,
        ),
        SensorCard(
          titulo: "Sono (colchão)",
          icone: Icons.bed_outlined,
          valor: colchao == null ? "--" : "${colchao.bpm ?? "-"} bpm",
          detalhe: colchao == null
              ? "sem leitura"
              : colchao.sinaisLeito == false
                  ? "SEM sinais vitais"
                  : "agitação ${colchao.agitacaoNoturna ?? 0}/10",
          alerta: colchao != null && leituraEmAlerta(colchao),
        ),
        SensorCard(
          titulo: "Botão SOS",
          icone: Icons.sos,
          valor: sos?.sos == true ? "ACIONADO" : "OK",
          detalhe: sos == null ? "nenhum acionamento" : formatoHora.format(sos.dataLeitura),
          alerta: sos?.sos == true,
        ),
      ],
    );
  }

  IconData iconeSensor(String tipo) {
    switch (tipo) {
      case "PIR":
        return Icons.directions_walk;
      case "PORTA_REMEDIO":
        return Icons.medication_outlined;
      case "COLCHAO":
        return Icons.bed_outlined;
      default:
        return Icons.sos;
    }
  }

  bool leituraEmAlerta(Leitura l) {
    return l.sos == true ||
        (l.spo2 != null && l.spo2! < 90) ||
        (l.bpm != null && (l.bpm! > 120 || l.bpm! < 45)) ||
        l.sinaisLeito == false ||
        (l.minImovel ?? 0) > 240 ||
        (l.agitacaoNoturna ?? 0) >= 7;
  }
}
