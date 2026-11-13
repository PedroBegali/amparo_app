import 'package:amparo_sus_app/mock/mock_data.dart';
import 'package:amparo_sus_app/models/kit.dart';
import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';

class KitRepository {
  // POST /api/v1/kits (vincula o Kit AMPARO ao idoso na triagem)
  Future<Kit> vincular(Kit kit) async {
    if (!ModoApp.offline) {
      try {
        final resposta = await ApiClient.post("/api/v1/kits", kit.toJson());
        return Kit.fromJson(resposta);
      } on OfflineException {
        ModoApp.offline = true;
      }
    }
    if (MockData.kits.any((k) => k.serieLora == kit.serieLora)) {
      throw ApiException(422, "O kit ${kit.serieLora} já está vinculado a outro idoso.");
    }
    kit.id = MockData.kits.length + 1;
    MockData.kits.add(kit);
    return kit;
  }
}
