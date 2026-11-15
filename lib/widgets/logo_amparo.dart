import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:flutter/material.dart';

class LogoAmparo extends StatelessWidget {
  const LogoAmparo({
    super.key,
    this.tamanho = 48,
    this.clara = false,
    this.mostrarTexto = true,
  });

  final double tamanho;
  final bool clara;
  final bool mostrarTexto;

  @override
  Widget build(BuildContext context) {
    final cruz = Image.asset(
      clara ? "assets/images/logo_amparo_branca.png" : "assets/images/logo_amparo.png",
      width: tamanho,
      height: tamanho,
      filterQuality: FilterQuality.medium,
    );
    if (!mostrarTexto) return cruz;
    final corTexto = clara ? Colors.white : azulLogo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        cruz,
        SizedBox(width: tamanho * 0.22),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "AMPARO",
              style: TextStyle(
                color: corTexto,
                fontSize: tamanho * 0.32,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "SUS",
              style: TextStyle(
                color: corTexto,
                fontSize: tamanho * 0.62,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
