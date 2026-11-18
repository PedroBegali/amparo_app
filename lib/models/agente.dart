class Agente {
  Agente({
    required this.id,
    required this.nome,
    required this.email,
    required this.papel,
    required this.ubs,
    required this.microarea,
  });

  Agente.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        nome = json["nome"],
        email = json["email"],
        papel = json["papel"],
        ubs = json["ubs"],
        microarea = json["microarea"];

  int id;
  String nome;
  String email;
  String papel;
  String ubs;
  String microarea;

  bool get isGestor => papel == "ROLE_GESTOR_UBS";

  String get primeiroNome => nome.split(" ").first;
}
