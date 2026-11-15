import 'package:flutter/material.dart';

class IlustracaoEquipe extends StatelessWidget {
  const IlustracaoEquipe({super.key, this.altura = 150});

  final double altura;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/equipe_saude.png",
      height: altura,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.medium,
      semanticLabel: "Médica, agente comunitário de saúde e idosa sorrindo",
    );
  }
}
