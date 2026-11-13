import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Item da rota prioritária do dia
class VisitaCard extends StatelessWidget {
  const VisitaCard({
    super.key,
    required this.visita,
    required this.ordem,
    required this.onTap,
  });

  final Visita visita;
  final int ordem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = corDoNivel(visita.nivelRisco);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: cor, width: 6)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: cor,
                foregroundColor: Colors.white,
                child: Text("$ordemº", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visita.pacienteNome,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14, color: Colors.black54),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            visita.pacienteEndereco,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(visita.motivo, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        NivelRiscoChip(nivel: visita.nivelRisco, score: visita.score),
                        const Spacer(),
                        Text(
                          "alerta ${DateFormat("dd/MM HH:mm").format(visita.dataGeracao)}",
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
