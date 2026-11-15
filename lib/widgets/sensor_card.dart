import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.titulo,
    required this.icone,
    required this.valor,
    required this.detalhe,
    this.alerta = false,
  });

  final String titulo;
  final IconData icone;
  final String valor;
  final String detalhe;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final cor = alerta ? corCritico : azulPrincipal;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alerta ? fundoDoNivel("CRITICO") : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alerta ? corCritico.withValues(alpha: 0.4) : bordaSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: alerta ? Colors.white : azulClaro,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: azulEscuro),
                ),
              ),
              if (alerta) const Icon(Icons.warning_rounded, color: corCritico, size: 18),
            ],
          ),
          const Spacer(),
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cor)),
          const SizedBox(height: 2),
          Text(
            detalhe,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: cinzaSuave),
          ),
        ],
      ),
    );
  }
}
