import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/models/kit.dart';
import 'package:amparo_sus_app/models/leitura.dart';
import 'package:amparo_sus_app/models/paciente.dart';
import 'package:amparo_sus_app/models/visita.dart';

class MockData {
  MockData._();

  static const String senhaPadrao = "amparo123";
  static final DateTime _agora = DateTime.now();

  static DateTime _min(int minutos) =>
      _agora.subtract(Duration(minutes: minutos));

  static final List<Agente> agentes = [
    Agente(id: 1, nome: "Ana Paula Souza", email: "agente@amparo.gov.br", papel: "ROLE_AGENTE", ubs: "UBS Jardim Ângela", microarea: "MA-01"),
    Agente(id: 2, nome: "Carlos Eduardo Mendes", email: "gestor@amparo.gov.br", papel: "ROLE_GESTOR_UBS", ubs: "UBS Jardim Ângela", microarea: "MA-00"),
    Agente(id: 3, nome: "Juliana Ferreira", email: "juliana.ferreira@amparo.gov.br", papel: "ROLE_AGENTE", ubs: "UBS Jardim Ângela", microarea: "MA-02"),
  ];

  static final List<Paciente> pacientes = [
    _p(1, 1, "José Carlos da Silva", "700000000000001", DateTime(1948, 3, 12), "Rua das Palmeiras, 120 - Jardim Ângela", "MA-01", "HAS,ICC", true, "CRITICO", 110),
    _p(2, 1, "Maria das Dores Oliveira", "700000000000002", DateTime(1951, 7, 25), "Rua Benedito Calixto, 45 - Jardim Ângela", "MA-01", "DM", true, "ALTO", 75),
    _p(3, 1, "Antônio Pereira Lima", "700000000000003", DateTime(1945, 11, 2), "Travessa São Jorge, 8 - Jardim Ângela", "MA-01", "ICC", false, "MODERADO", 45),
    _p(4, 1, "Benedita Aparecida Santos", "700000000000004", DateTime(1940, 1, 18), "Rua Esperança, 310 - Jardim Ângela", "MA-01", "HAS,DM", true, "CRITICO", 105),
    _p(5, 1, "Francisco de Assis Ribeiro", "700000000000005", DateTime(1955, 5, 9), "Rua Projetada A, 77 - Jardim Ângela", "MA-01", "HAS", false, "ESTAVEL", 10),
    _p(6, 1, "Joana Batista Ramos", "700000000000006", DateTime(1949, 9, 30), "Rua do Rosário, 15 - Jardim Ângela", "MA-01", "HAS", true, "ALTO", 75),
    _p(7, 3, "Sebastião Moreira", "700000000000007", DateTime(1947, 4, 14), "Rua Guarapiranga, 1020 - Jardim Ângela", "MA-02", "DM,ICC", false, "ALTO", 75),
    _p(8, 3, "Rosa Maria Cardoso", "700000000000008", DateTime(1952, 12, 3), "Rua Santa Luzia, 66 - Jardim Ângela", "MA-02", "HAS", true, "ESTAVEL", 15),
  ];

  static final List<Kit> kits = [
    Kit(id: 1, pacienteId: 1, serieLora: "KIT-LORA-0001", bateriaPct: 92, rssiDbm: -78, dataUltimoSinal: _min(40)),
    Kit(id: 2, pacienteId: 2, serieLora: "KIT-LORA-0002", bateriaPct: 85, rssiDbm: -82, dataUltimoSinal: _min(120)),
    Kit(id: 3, pacienteId: 3, serieLora: "KIT-LORA-0003", bateriaPct: 77, rssiDbm: -90, dataUltimoSinal: _min(60)),
    Kit(id: 4, pacienteId: 4, serieLora: "KIT-LORA-0004", bateriaPct: 64, rssiDbm: -95, dataUltimoSinal: _min(60)),
    Kit(id: 5, pacienteId: 5, serieLora: "KIT-LORA-0005", bateriaPct: 98, rssiDbm: -70, dataUltimoSinal: _min(60)),
    Kit(id: 6, pacienteId: 6, serieLora: "KIT-LORA-0006", bateriaPct: 71, rssiDbm: -88, dataUltimoSinal: _min(60)),
    Kit(id: 7, pacienteId: 7, serieLora: "KIT-LORA-0007", bateriaPct: 88, rssiDbm: -84, dataUltimoSinal: _min(180)),
    Kit(id: 8, pacienteId: 8, serieLora: "KIT-LORA-0008", bateriaPct: 95, rssiDbm: -76, dataUltimoSinal: _min(240)),
  ];

  static final List<Leitura> leituras = [
    _remedio(1, 180, 78, 96), _colchao(1, 480, 70, 3), _pir(1, 60, 30),
    Leitura(kitId: 1, tipoSensor: "SOS", dataLeitura: _min(40), sos: true),
    _remedio(2, 1800, 80, 95), _colchao(2, 540, 68, 2), _pir(2, 120, 45),
    _remedio(3, 240, 82, 94), _colchao(3, 420, 74, 8), _pir(3, 60, 20),
    _remedio(4, 120, 92, 88), _colchao(4, 480, 85, 4), _pir(4, 60, 15),
    _remedio(5, 300, 72, 97), _colchao(5, 480, 64, 1), _pir(5, 60, 25),
    _remedio(6, 360, 76, 96), _colchao(6, 540, 66, 2), _pir(6, 60, 300),
    _remedio(7, 180, 108, 93), _colchao(7, 480, 98, 5),
    _remedio(8, 240, 70, 97), _pir(8, 120, 10),
  ];

  static final List<Visita> visitas = [
    _v(1, pacientes[0], "CRITICO", 110, "Botão SOS acionado nas últimas 24h", 40),
    _v(2, pacientes[1], "ALTO", 75, "Mais de 24h sem abrir o porta-remédios", 360),
    _v(3, pacientes[2], "MODERADO", 45, "Agitação noturna elevada no colchão", 420),
    _v(4, pacientes[3], "CRITICO", 105, "SpO2 abaixo de 90%", 120),
    _v(5, pacientes[5], "ALTO", 75, "Imobilidade diurna acima de 4h", 60),
    _v(6, pacientes[6], "ALTO", 75, "Frequência cardíaca elevada (100-120 bpm)", 180),
  ];


  static Paciente _p(int id, int agenteId, String nome, String cns, DateTime nascimento,
      String endereco, String microarea, String condicoes, bool sozinho, String nivel, int score) {
    return Paciente(
      id: id,
      agenteId: agenteId,
      nome: nome,
      cns: cns,
      dataNascimento: nascimento,
      endereco: endereco,
      microarea: microarea,
      condicoes: condicoes,
      moraSozinho: sozinho,
      nivelRisco: nivel,
      scoreRisco: score,
    );
  }

  static Leitura _remedio(int kit, int minutos, int bpm, int spo2) => Leitura(
      kitId: kit, tipoSensor: "PORTA_REMEDIO", dataLeitura: _min(minutos), bpm: bpm, spo2: spo2, caixaAberta: true);

  static Leitura _colchao(int kit, int minutos, int bpm, int agitacao) => Leitura(
      kitId: kit, tipoSensor: "COLCHAO", dataLeitura: _min(minutos), bpm: bpm, agitacaoNoturna: agitacao, sinaisLeito: true);

  static Leitura _pir(int kit, int minutos, int minImovel) =>
      Leitura(kitId: kit, tipoSensor: "PIR", dataLeitura: _min(minutos), minImovel: minImovel);

  static Visita _v(int id, Paciente p, String nivel, int score, String motivo, int minutos) {
    return Visita(
      id: id,
      pacienteId: p.id!,
      pacienteNome: p.nome,
      pacienteEndereco: p.endereco,
      agenteId: p.agenteId,
      nivelRisco: nivel,
      score: score,
      motivo: motivo,
      status: "PENDENTE",
      dataGeracao: _min(minutos),
    );
  }
}
