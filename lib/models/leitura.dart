class Leitura {
  Leitura({
    this.id,
    required this.kitId,
    required this.tipoSensor,
    required this.dataLeitura,
    this.bpm,
    this.spo2,
    this.minImovel,
    this.caixaAberta,
    this.sos,
    this.agitacaoNoturna,
    this.sinaisLeito,
  });

  Leitura.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        kitId = json["kitId"],
        tipoSensor = json["tipoSensor"],
        dataLeitura = DateTime.parse(json["dataLeitura"]),
        bpm = json["bpm"],
        spo2 = json["spo2"],
        minImovel = json["minImovel"],
        caixaAberta = json["caixaAberta"],
        sos = json["sos"],
        agitacaoNoturna = json["agitacaoNoturna"],
        sinaisLeito = json["sinaisLeito"];

  int? id;
  int kitId;
  String tipoSensor;
  DateTime dataLeitura;
  int? bpm;
  int? spo2;
  int? minImovel;
  bool? caixaAberta;
  bool? sos;
  int? agitacaoNoturna;
  bool? sinaisLeito;

  String get resumo {
    switch (tipoSensor) {
      case "PIR":
        return "Movimento: ${minImovel ?? 0} min sem se mover";
      case "PORTA_REMEDIO":
        return "Caixa aberta • ${bpm ?? "-"} bpm • SpO2 ${spo2 ?? "-"}%";
      case "COLCHAO":
        return sinaisLeito == false
            ? "Colchão: SEM sinais vitais"
            : "Sono: ${bpm ?? "-"} bpm • agitação ${agitacaoNoturna ?? 0}/10";
      case "SOS":
        return sos == true ? "BOTÃO SOS ACIONADO" : "Botão SOS";
      default:
        return tipoSensor;
    }
  }
}
