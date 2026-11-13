import 'package:flutter/material.dart';

// Card de um sensor do Kit AMPARO no prontuário (GridView 2x2)
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
    final cor = alerta ? Colors.red.shade700 : Theme.of(context).colorScheme.primary;
    return Card(
      color: alerta ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                if (alerta) Icon(Icons.priority_high, color: cor, size: 18),
              ],
            ),
            const Spacer(),
            Text(valor,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
            const SizedBox(height: 2),
            Text(detalhe, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
