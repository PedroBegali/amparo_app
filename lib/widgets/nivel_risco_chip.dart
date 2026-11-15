import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

class NivelRiscoChip extends StatelessWidget {
  const NivelRiscoChip({super.key, required this.nivel, this.score});

  final String nivel;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final cor = corDoNivel(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fundoDoNivel(nivel),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            score == null ? rotuloDoNivel(nivel) : "${rotuloDoNivel(nivel)} · $score",
            style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
