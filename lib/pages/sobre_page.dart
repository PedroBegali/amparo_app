import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/ilustracao_equipe.dart';
import 'package:amparo_sus_app/widgets/logo_amparo.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sobre o AMPARO SUS")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF004A9B),
                  alignment: Alignment.bottomCenter,
                  child: const IlustracaoEquipe(altura: 170, esmaecerTopo: false),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      LogoAmparo(tamanho: 56),
                      SizedBox(height: 14),
                      Text(
                        "Monitoramento domiciliar passivo via rede LoRa para idosos crônicos de baixa renda. "
                        "Sensores na casa (movimento, porta-remédios, colchão e botão SOS) enviam dados "
                        "para a UBS sem Wi-Fi ou celular, e o agente recebe a rota de visitas priorizada por risco.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cinzaTexto, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          tituloSecao("Classificação de risco"),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  regra("CRITICO", "SOS, SpO2 < 90%, BPM > 120 ou < 45, sem sinais vitais no leito"),
                  regra("ALTO", "Mais de 24h sem remédio, BPM 100-120, imóvel por mais de 4h"),
                  regra("MODERADO", "Agitação noturna ≥ 7, remédio atrasado entre 12 e 24h"),
                  regra("ESTAVEL", "Sem alterações"),
                ],
              ),
            ),
          ),
          tituloSecao("Objetivos de Desenvolvimento Sustentável"),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              ods("3", "Saúde e bem-estar", const Color(0xFF4C9F38)),
              ods("9", "Inovação e infraestrutura", const Color(0xFFFD6925)),
              ods("10", "Redução das desigualdades", const Color(0xFFDD1367)),
              ods("11", "Cidades sustentáveis", const Color(0xFFFD9D24)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.smart_toy_outlined, color: azulPrincipal),
                  title: Text("Uso de IA generativa",
                      style: TextStyle(fontWeight: FontWeight.w600, color: azulEscuro)),
                  subtitle: Text(
                    "Claude (Anthropic) foi usado como apoio na revisão do código e da "
                    "documentação. Todo o código foi revisado e testado pela equipe.",
                    style: TextStyle(fontSize: 13, color: cinzaSuave),
                  ),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined, color: azulPrincipal),
                  title: const Text("API",
                      style: TextStyle(fontWeight: FontWeight.w600, color: azulEscuro)),
                  subtitle: Text(ApiClient.baseUrl,
                      style: const TextStyle(fontSize: 13, color: cinzaSuave)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Direção visual inspirada no SUS: simplicidade, confiança e inclusão digital.",
              textAlign: TextAlign.center,
              style: TextStyle(color: cinzaSuave, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text("Global Solution 2026/2 · FIAP · CitizenTech",
                style: TextStyle(color: cinzaSuave, fontSize: 12)),
          ),
        ],
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

  Widget regra(String nivel, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Align(alignment: Alignment.centerLeft, child: NivelRiscoChip(nivel: nivel)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(descricao, style: const TextStyle(fontSize: 13, color: cinzaTexto)),
          ),
        ],
      ),
    );
  }

  Widget ods(String numero, String titulo, Color cor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Text(numero,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(titulo,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
