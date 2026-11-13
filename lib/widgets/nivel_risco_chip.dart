import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

// Etiqueta colorida do nível de risco (ícone + texto, não depende só da cor)
class NivelRiscoChip extends StatelessWidget {
  const NivelRiscoChip({super.key, required this.nivel, this.score});

  final String nivel;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final cor = corDoNivel(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconeDoNivel(nivel), size: 16, color: cor),
          const SizedBox(width: 4),
          Text(
            score == null ? rotuloDoNivel(nivel) : "${rotuloDoNivel(nivel)} • $score",
            style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
