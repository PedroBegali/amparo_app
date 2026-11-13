class Kit {
  Kit({
    this.id,
    required this.pacienteId,
    required this.serieLora,
    this.status = "ATIVO",
    this.bateriaPct = 100,
    this.rssiDbm,
    this.dataUltimoSinal,
  });

  Kit.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        pacienteId = json["pacienteId"],
        serieLora = json["serieLora"],
        status = json["status"] ?? "ATIVO",
        bateriaPct = json["bateriaPct"] ?? 100,
        rssiDbm = json["rssiDbm"],
        dataUltimoSinal = json["dataUltimoSinal"] == null
            ? null
            : DateTime.parse(json["dataUltimoSinal"]);

  int? id;
  int pacienteId;
  String serieLora;
  String status;
  int bateriaPct;
  int? rssiDbm;
  DateTime? dataUltimoSinal;

  // Qualidade do sinal LoRa a partir do RSSI
  String get qualidadeSinal {
    if (rssiDbm == null) return "sem leitura";
    if (rssiDbm! >= -85) return "bom";
    if (rssiDbm! >= -100) return "regular";
    return "fraco";
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "pacienteId": pacienteId,
      "serieLora": serieLora,
      "status": status,
      "bateriaPct": bateriaPct,
      "rssiDbm": rssiDbm,
    };
  }
}
