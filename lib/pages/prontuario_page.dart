import 'package:amparo_sus_app/models/leitura.dart';
import 'package:amparo_sus_app/models/paciente.dart';
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

class ProntuarioPage extends StatefulWidget {
  const ProntuarioPage({super.key});

  @override
  State<ProntuarioPage> createState() => _ProntuarioPageState();
}

class _ProntuarioPageState extends State<ProntuarioPage> {
  final PacienteRepository pacienteRepository = PacienteRepository();
  final DateFormat formatoHora = DateFormat("dd/MM 'às' HH:mm");

  late int pacienteId;
  late String titulo;
  Visita? visita;
  Prontuario? prontuario;
  String? erro;
  bool sensoresChecados = false;
  bool iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      final argumento = ModalRoute.of(context)!.settings.arguments;
      if (argumento is Visita) {
        visita = argumento;
        pacienteId = argumento.pacienteId;
        titulo = argumento.pacienteNome;
      } else {
        final paciente = argumento as Paciente;
        pacienteId = paciente.id!;
        titulo = paciente.nome;
      }
      iniciado = true;
      carregar();
    }
  }

  Future<void> carregar() async {
    try {
      final dados = await pacienteRepository.getProntuario(pacienteId);
      if (!mounted) return;
      setState(() {
        prontuario = dados;
        visita ??= dados.alertaPendente;
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
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prontuário de telemetria")),
      body: Column(
        children: [
          const BannerOffline(),
          Expanded(child: conteudo()),
        ],
      ),
      bottomNavigationBar: prontuario == null ? null : rodape(),
    );
  }

  Widget rodape() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: bordaSuave)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: visita == null
              ? const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: verdeApoio),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Sem visita pendente para este idoso.",
                        style: TextStyle(color: cinzaTexto, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: sensoresChecados,
                      activeColor: verdeApoio,
                      title: const Text(
                        "Confirmo a checagem dos sensores do kit",
                        style: TextStyle(fontSize: 14, color: cinzaTexto),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (valor) {
                        setState(() {
                          sensoresChecados = valor ?? false;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: sensoresChecados ? registrarDesfecho : null,
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: Text(sensoresChecados
                          ? "Registrar desfecho da visita"
                          : "Cheque os sensores para concluir"),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: corCritico, size: 48),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(erro!, textAlign: TextAlign.center),
              ),
              OutlinedButton(onPressed: carregar, child: const Text("Tentar novamente")),
            ],
          ),
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
        cardPaciente(p),
        if (visita != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: fundoDoNivel(visita!.nivelRisco),
              borderRadius: BorderRadius.circular(14),
              border: Border(left: BorderSide(color: corDoNivel(visita!.nivelRisco), width: 4)),
            ),
            child: Row(
              children: [
                Icon(iconeDoNivel(visita!.nivelRisco), color: corDoNivel(visita!.nivelRisco)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Motivo do alerta",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: corDoNivel(visita!.nivelRisco),
                        ),
                      ),
                      Text(
                        visita!.motivo,
                        style: const TextStyle(fontSize: 14, color: cinzaTexto, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        tituloSecao("Sensores do Kit AMPARO"),
        gradeSensores(),
        tituloSecao("Kit LoRa"),
        for (final kit in prontuario!.kits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: azulClaro, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.router_outlined, color: azulPrincipal),
                ),
                title: Text(kit.serieLora,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: azulEscuro)),
                subtitle: Text(
                  "${statusKit[kit.status] ?? kit.status} · bateria ${kit.bateriaPct}% · sinal ${kit.qualidadeSinal}"
                  "${kit.dataUltimoSinal == null ? "" : "\nÚltimo sinal ${formatoHora.format(kit.dataUltimoSinal!)}"}",
                  style: const TextStyle(fontSize: 12, color: cinzaSuave),
                ),
                isThreeLine: kit.dataUltimoSinal != null,
              ),
            ),
          ),
        tituloSecao("Últimas leituras"),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < prontuario!.ultimasLeituras.length; i++) ...[
                if (i > 0) const Divider(indent: 56),
                itemLeitura(prontuario!.ultimasLeituras[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget cardPaciente(Paciente p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: fundoDoNivel(p.nivelRisco),
                  child: Icon(Icons.elderly_rounded, color: corDoNivel(p.nivelRisco), size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: azulEscuro),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${p.idade} anos · CNS ${p.cns}",
                        style: const TextStyle(color: cinzaSuave, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      NivelRiscoChip(nivel: p.nivelRisco, score: p.scoreRisco),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            linhaInfo(Icons.place_outlined, p.endereco),
            linhaInfo(Icons.monitor_heart_outlined, condicoesPorExtenso(p.condicoes)),
            linhaInfo(Icons.home_outlined, p.moraSozinho ? "Mora sozinho(a)" : "Mora com familiares"),
            linhaInfo(Icons.badge_outlined, "ACS responsável: ${prontuario!.agenteNome}"),
          ],
        ),
      ),
    );
  }

  Widget tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 0, 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: azulEscuro),
      ),
    );
  }

  Widget linhaInfo(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 18, color: azulPrincipal),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13, color: cinzaTexto))),
        ],
      ),
    );
  }

  Widget itemLeitura(Leitura leitura) {
    final emAlerta = leituraEmAlerta(leitura);
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: emAlerta ? fundoDoNivel("CRITICO") : azulClaro,
        child: Icon(iconeSensor(leitura.tipoSensor),
            size: 18, color: emAlerta ? corCritico : azulPrincipal),
      ),
      title: Text(leitura.resumo, style: const TextStyle(fontSize: 13, color: cinzaTexto)),
      subtitle: Text(formatoHora.format(leitura.dataLeitura),
          style: const TextStyle(fontSize: 12, color: cinzaSuave)),
    );
  }

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
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        SensorCard(
          titulo: "Movimento (PIR)",
          icone: Icons.directions_walk_rounded,
          valor: pir == null ? "--" : "${pir.minImovel ?? 0} min",
          detalhe: pir == null ? "sem leitura" : "imóvel · ${formatoHora.format(pir.dataLeitura)}",
          alerta: (pir?.minImovel ?? 0) > 240,
        ),
        SensorCard(
          titulo: "Porta-remédios",
          icone: Icons.medication_outlined,
          valor: horasRemedio == null ? "--" : "há ${horasRemedio}h",
          detalhe: remedio == null
              ? "sem abertura"
              : "${remedio.bpm ?? "-"} bpm · SpO2 ${remedio.spo2 ?? "-"}%",
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
          icone: Icons.sos_rounded,
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
        return Icons.directions_walk_rounded;
      case "PORTA_REMEDIO":
        return Icons.medication_outlined;
      case "COLCHAO":
        return Icons.bed_outlined;
      default:
        return Icons.sos_rounded;
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
