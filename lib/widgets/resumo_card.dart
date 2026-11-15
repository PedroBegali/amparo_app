import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

class ResumoCard extends StatelessWidget {
  const ResumoCard({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    required this.cor,
    required this.fundo,
    this.onTap,
  });

  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;
  final Color fundo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fundo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x14003B7A), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icone, color: cor, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: azulEscuro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                rotulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontSize: 12, color: cinzaTexto, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
