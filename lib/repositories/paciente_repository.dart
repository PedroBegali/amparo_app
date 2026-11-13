import 'package:amparo_sus_app/mock/mock_data.dart';
import 'package:amparo_sus_app/models/paciente.dart';
import 'package:amparo_sus_app/models/prontuario.dart';
import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';

class PacienteRepository {
  // GET /api/v1/pacientes/{id}/prontuario
  Future<Prontuario> getProntuario(int pacienteId) async {
    if (!ModoApp.offline) {
      try {
        final resposta = await ApiClient.get("/api/v1/pacientes/$pacienteId/prontuario");
        return Prontuario.fromJson(resposta);
      } on OfflineException {
        ModoApp.offline = true;
      }
    }
    final paciente = MockData.pacientes.firstWhere((p) => p.id == pacienteId);
    final kits = MockData.kits.where((k) => k.pacienteId == pacienteId).toList();
    final idsKits = kits.map((k) => k.id).toSet();
    final leituras = MockData.leituras.where((l) => idsKits.contains(l.kitId)).toList()
      ..sort((a, b) => b.dataLeitura.compareTo(a.dataLeitura));
    final pendentes = MockData.visitas
        .where((v) => v.pacienteId == pacienteId && v.status == "PENDENTE");
    return Prontuario(
      paciente: paciente,
      agenteNome: MockData.agentes.firstWhere((a) => a.id == paciente.agenteId).nome,
      kits: kits,
      ultimasLeituras: leituras.take(10).toList(),
      alertaPendente: pendentes.isEmpty ? null : pendentes.first,
    );
  }

  // POST /api/v1/pacientes (triagem domiciliar)
  Future<Paciente> cadastrar(Paciente paciente) async {
    if (!ModoApp.offline) {
      try {
        final resposta = await ApiClient.post("/api/v1/pacientes", paciente.toJson());
        return Paciente.fromJson(resposta);
      } on OfflineException {
        ModoApp.offline = true;
      }
    }
    if (MockData.pacientes.any((p) => p.cns == paciente.cns)) {
      throw ApiException(422, "Já existe um idoso cadastrado com o CNS ${paciente.cns}.");
    }
    paciente.id = MockData.pacientes.map((p) => p.id!).reduce((a, b) => a > b ? a : b) + 1;
    MockData.pacientes.add(paciente);
    return paciente;
  }
}
