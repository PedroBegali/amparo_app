import 'package:flutter/material.dart';

class IlustracaoEquipe extends StatelessWidget {
  const IlustracaoEquipe({
    super.key,
    this.altura = 150,
    this.esmaecerTopo = true,
    this.esmaecerLaterais = true,
  });

  final double altura;
  final bool esmaecerTopo;
  final bool esmaecerLaterais;

  @override
  Widget build(BuildContext context) {
    Widget imagem = Image.asset(
      "assets/images/equipe_saude.png",
      height: altura,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.medium,
      semanticLabel: "Médica, agente comunitário de saúde e idosa sorrindo",
    );
    return imagem;
  }
}
