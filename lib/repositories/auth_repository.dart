import 'package:amparo_sus_app/mock/mock_data.dart';
import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/services/api_client.dart';

// Indica se o app está usando os dados locais (API fora do ar)
class ModoApp {
  static bool offline = false;
}

class AuthRepository {
  // POST /auth/login -> guarda o accessToken e devolve o agente logado
  Future<Agente> login(String email, String senha) async {
    try {
      final resposta =
          await ApiClient.post("/auth/login", {"email": email, "senha": senha});
      await ApiClient.salvarToken(resposta["accessToken"]);
      ModoApp.offline = false;
      return Agente.fromJson(resposta["agente"]);
    } on OfflineException {
      // Sem API: login de demonstração com os usuários da massa de teste
      final agente = MockData.agentes.where(
          (a) => a.email == email.toLowerCase() && senha == MockData.senhaPadrao);
      if (agente.isEmpty) {
        throw ApiException(401, "API indisponível e usuário de teste inválido.");
      }
      ModoApp.offline = true;
      return agente.first;
    }
  }

  Future<void> logout() async {
    await ApiClient.salvarToken(null);
    ModoApp.offline = false;
  }
}
