import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

class AtalhoCard extends StatelessWidget {
  const AtalhoCard({
    super.key,
    required this.icone,
    required this.titulo,
    required this.cor,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: cor, size: 32),
              const SizedBox(height: 8),
              Text(
                titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: azulEscuro,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
