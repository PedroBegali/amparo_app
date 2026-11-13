import 'package:flutter/material.dart';

// Identidade visual inspirada no padrão gov.br / SUS
const Color azulSus = Color(0xFF1351B4);
const Color azulEscuro = Color(0xFF0C326F);
const Color verdeSus = Color(0xFF168821);
const Color fundoClaro = Color(0xFFF3F6FB);

// Cores dos níveis de risco (mesmos níveis do motor PL/SQL e da API Java)
const Color corCritico = Color(0xFFD32F2F);
const Color corAlto = Color(0xFFF57C00);
const Color corModerado = Color(0xFFF9A825);
const Color corEstavel = Color(0xFF2E7D32);

const List<String> niveisRisco = ["CRITICO", "ALTO", "MODERADO", "ESTAVEL"];

Color corDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return corCritico;
    case "ALTO":
      return corAlto;
    case "MODERADO":
      return corModerado;
    default:
      return corEstavel;
  }
}

String rotuloDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return "Crítico";
    case "ALTO":
      return "Alto";
    case "MODERADO":
      return "Moderado";
    default:
      return "Estável";
  }
}

IconData iconeDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return Icons.emergency;
    case "ALTO":
      return Icons.warning_amber_rounded;
    case "MODERADO":
      return Icons.info_outline;
    default:
      return Icons.check_circle_outline;
  }
}

// Desfechos aceitos pela API (enum Desfecho)
const Map<String, String> desfechos = {
  "VISITA_REALIZADA": "Visita realizada",
  "ORIENTACAO_FAMILIA": "Orientação à família",
  "ENCAMINHADO_UBS": "Encaminhado à UBS",
  "ACIONADO_SAMU": "SAMU acionado",
  "AUSENTE": "Idoso ausente",
};

const Map<String, String> statusKit = {
  "ATIVO": "Ativo",
  "MANUTENCAO": "Manutenção",
  "INATIVO": "Inativo",
};
