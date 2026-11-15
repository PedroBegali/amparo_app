import 'package:amparo_sus_app/mock/mock_data.dart';
import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';

class VisitaRepository {
  Future<List<Visita>> getRota(int agenteId) async {
    if (!ModoApp.offline) {
      try {
        final resposta =
            await ApiClient.get("/api/v1/visitas/rota?agenteId=$agenteId&size=50");
        final List conteudo = resposta["content"] as List;
        return conteudo.map((e) => Visita.fromJson(e)).toList();
      } on OfflineException {
        ModoApp.offline = true;
      }
    }
    final rota = MockData.visitas
        .where((v) => v.agenteId == agenteId && v.status == "PENDENTE")
        .toList();
    rota.sort((a, b) {
      final porScore = b.score.compareTo(a.score);
      return porScore != 0 ? porScore : a.dataGeracao.compareTo(b.dataGeracao);
    });
    return rota;
  }

  Future<void> recalcular(int agenteId) async {
    if (ModoApp.offline) return;
    try {
      await ApiClient.post("/api/v1/visitas/rota/recalcular?agenteId=$agenteId", {});
    } on OfflineException {
      ModoApp.offline = true;
    }
  }

  Future<void> concluir(int visitaId, String desfecho, String observacao,
      bool sensoresChecados, String? statusKit) async {
    final corpo = {
      "desfecho": desfecho,
      "observacao": observacao,
      "sensoresChecados": sensoresChecados,
      "statusKit": statusKit,
    };
    if (!ModoApp.offline) {
      try {
        await ApiClient.patch("/api/v1/visitas/$visitaId/concluir", corpo);
        return;
      } on OfflineException {
        ModoApp.offline = true;
      }
    }
    final visita = MockData.visitas.firstWhere((v) => v.id == visitaId);
    if (visita.status != "PENDENTE") {
      throw ApiException(422, "A visita $visitaId já está ${visita.status}.");
    }
    visita.status = "CONCLUIDA";
    visita.desfecho = desfecho;
    visita.observacao = observacao;
  }
}
