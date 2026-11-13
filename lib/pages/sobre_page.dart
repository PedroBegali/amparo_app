import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:flutter/material.dart';

// Tela extra - Sobre o projeto, regra de risco e ODS
class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sobre o AMPARO-SUS")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: Image.asset("assets/images/logo_amparo.png", width: 90)),
          const SizedBox(height: 12),
          const Text(
            "Monitoramento domiciliar passivo via rede LoRa para idosos crônicos de baixa renda. "
            "Sensores na casa (movimento, porta-remédios, colchão e botão SOS) enviam dados "
            "para a UBS sem Wi-Fi ou celular, e o agente recebe a rota de visitas priorizada por risco.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text("Classificação de risco", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          regra("CRITICO", "SOS, SpO2 < 90%, BPM > 120 ou < 45, sem sinais vitais no leito"),
          regra("ALTO", "> 24h sem remédio, BPM 100-120, imóvel > 4h"),
          regra("MODERADO", "agitação noturna ≥ 7, remédio atrasado 12-24h"),
          regra("ESTAVEL", "sem alterações"),
          const SizedBox(height: 16),
          const Text("Objetivos de Desenvolvimento Sustentável",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              ods("3", "Saúde e bem-estar", const Color(0xFF4C9F38)),
              ods("9", "Inovação e infraestrutura", const Color(0xFFFD6925)),
              ods("10", "Redução das desigualdades", const Color(0xFFDD1367)),
              ods("11", "Cidades sustentáveis", const Color(0xFFFD9D24)),
            ],
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy_outlined, color: azulSus),
              title: Text("Uso de IA generativa"),
              subtitle: Text("Claude (Anthropic) foi usado como apoio na revisão do código e da "
                  "documentação. Todo o código foi revisado e testado pela equipe."),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.cloud_outlined, color: azulSus),
              title: Text("API"),
              subtitle: Text(ApiClient.baseUrl),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text("Global Solution 2026/2 • FIAP • CitizenTech",
                style: TextStyle(color: Colors.black45, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget regra(String nivel, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: NivelRiscoChip(nivel: nivel)),
          const SizedBox(width: 8),
          Expanded(child: Text(descricao, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget ods(String numero, String titulo, Color cor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(numero,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
