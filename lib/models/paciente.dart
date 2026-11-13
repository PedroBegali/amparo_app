class Paciente {
  Paciente({
    this.id,
    required this.agenteId,
    required this.nome,
    required this.cns,
    required this.dataNascimento,
    required this.endereco,
    required this.microarea,
    required this.condicoes,
    required this.moraSozinho,
    this.nivelRisco = "ESTAVEL",
    this.scoreRisco = 10,
  });

  Paciente.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        agenteId = json["agenteId"],
        nome = json["nome"],
        cns = json["cns"],
        dataNascimento = DateTime.parse(json["dataNascimento"]),
        endereco = json["endereco"],
        microarea = json["microarea"],
        condicoes = json["condicoes"],
        moraSozinho = json["moraSozinho"] ?? false,
        nivelRisco = json["nivelRisco"] ?? "ESTAVEL",
        scoreRisco = json["scoreRisco"] ?? 10;

  int? id;
  int agenteId;
  String nome;
  String cns;
  DateTime dataNascimento;
  String endereco;
  String microarea;
  String condicoes; // ex.: "HAS,ICC"
  bool moraSozinho;
  String nivelRisco;
  int scoreRisco;

  int get idade {
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      anos--;
    }
    return anos;
  }

  // Formato aceito pela API (LocalDate yyyy-MM-dd)
  String get dataNascimentoIso =>
      "${dataNascimento.year.toString().padLeft(4, "0")}-"
      "${dataNascimento.month.toString().padLeft(2, "0")}-"
      "${dataNascimento.day.toString().padLeft(2, "0")}";

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "agenteId": agenteId,
      "nome": nome,
      "cns": cns,
      "dataNascimento": dataNascimentoIso,
      "endereco": endereco,
      "microarea": microarea,
      "condicoes": condicoes,
      "moraSozinho": moraSozinho,
    };
  }
}
