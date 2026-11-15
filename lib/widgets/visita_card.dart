import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/nivel_risco_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisitaCard extends StatelessWidget {
  const VisitaCard({
    super.key,
    required this.visita,
    required this.onTap,
    this.ordem,
    this.compacto = false,
  });

  final Visita visita;
  final VoidCallback onTap;
  final int? ordem;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final cor = corDoNivel(visita.nivelRisco);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: cor, width: 4)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: fundoDoNivel(visita.nivelRisco), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: ordem == null
                      ? Icon(Icons.person_outline_rounded, color: cor)
                      : Text(
                          "$ordemº",
                          style: TextStyle(color: cor, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(child: compacto ? conteudoCompacto() : conteudoCompleto()),
                const Icon(Icons.chevron_right_rounded, color: cinzaSuave),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget conteudoCompacto() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visita.pacienteNome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: azulEscuro),
              ),
              const SizedBox(height: 2),
              Text(
                visita.motivo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: cinzaTexto),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        NivelRiscoChip(nivel: visita.nivelRisco),
      ],
    );
  }

  Widget conteudoCompleto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                visita.pacienteNome,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: azulEscuro),
              ),
            ),
            NivelRiscoChip(nivel: visita.nivelRisco, score: visita.score),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.place_outlined, size: 14, color: cinzaSuave),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                visita.pacienteEndereco,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: cinzaSuave),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(visita.motivo, style: const TextStyle(fontSize: 13, color: cinzaTexto)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.schedule_rounded, size: 14, color: cinzaSuave),
            const SizedBox(width: 4),
            Text(
              "Alerta em ${DateFormat("dd/MM 'às' HH:mm").format(visita.dataGeracao)}",
              style: const TextStyle(fontSize: 12, color: cinzaSuave),
            ),
          ],
        ),
      ],
    );
  }
}
