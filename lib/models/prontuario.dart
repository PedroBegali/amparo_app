import 'package:amparo_sus_app/models/kit.dart';
import 'package:amparo_sus_app/models/leitura.dart';
import 'package:amparo_sus_app/models/paciente.dart';
import 'package:amparo_sus_app/models/visita.dart';

class Prontuario {
  Prontuario({
    required this.paciente,
    required this.agenteNome,
    required this.kits,
    required this.ultimasLeituras,
    this.alertaPendente,
  });

  Prontuario.fromJson(Map<String, dynamic> json)
      : paciente = Paciente.fromJson(json["paciente"]),
        agenteNome = json["agenteNome"] ?? "",
        kits = (json["kits"] as List).map((e) => Kit.fromJson(e)).toList(),
        ultimasLeituras = (json["ultimasLeituras"] as List)
            .map((e) => Leitura.fromJson(e))
            .toList(),
        alertaPendente = json["alertaPendente"] == null
            ? null
            : Visita.fromJson(json["alertaPendente"]);

  Paciente paciente;
  String agenteNome;
  List<Kit> kits;
  List<Leitura> ultimasLeituras;
  Visita? alertaPendente;

  Leitura? ultimaDoSensor(String tipo) {
    for (final l in ultimasLeituras) {
      if (l.tipoSensor == tipo) return l;
    }
    return null;
  }
}
