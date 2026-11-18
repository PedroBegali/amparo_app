class Visita {
  Visita({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.pacienteEndereco,
    required this.agenteId,
    required this.nivelRisco,
    required this.score,
    required this.motivo,
    required this.status,
    required this.dataGeracao,
    this.desfecho,
    this.observacao,
  });

  Visita.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        pacienteId = json["pacienteId"],
        pacienteNome = json["pacienteNome"] ?? "",
        pacienteEndereco = json["pacienteEndereco"] ?? "",
        agenteId = json["agenteId"],
        nivelRisco = json["nivelRisco"],
        score = json["score"],
        motivo = json["motivo"],
        status = json["status"] ?? "PENDENTE",
        dataGeracao = DateTime.parse(json["dataGeracao"]),
        desfecho = json["desfecho"],
        observacao = json["observacao"];

  int id;
  int pacienteId;
  String pacienteNome;
  String pacienteEndereco;
  int agenteId;
  String nivelRisco;
  int score;
  String motivo;
  String status;
  DateTime dataGeracao;
  String? desfecho;
  String? observacao;
}
