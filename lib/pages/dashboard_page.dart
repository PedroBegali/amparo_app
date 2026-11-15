import 'package:amparo_sus_app/models/agente.dart';
import 'package:amparo_sus_app/models/paciente.dart';
import 'package:amparo_sus_app/models/visita.dart';
import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/repositories/paciente_repository.dart';
import 'package:amparo_sus_app/repositories/visita_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/atalho_card.dart';
import 'package:amparo_sus_app/widgets/banner_offline.dart';
import 'package:amparo_sus_app/widgets/ilustracao_equipe.dart';
import 'package:amparo_sus_app/widgets/logo_amparo.dart';
import 'package:amparo_sus_app/widgets/resumo_card.dart';
import 'package:amparo_sus_app/widgets/visita_card.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final VisitaRepository visitaRepository = VisitaRepository();
  final PacienteRepository pacienteRepository = PacienteRepository();
  final AuthRepository authRepository = AuthRepository();

  late Agente agente;
  List<Visita> visitas = [];
  List<Paciente> pacientes = [];
  String filtroNivel = "TODOS";
  int concluidasNoTurno = 0;
  int abaAtual = 0;
  bool carregando = true;
  bool iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      agente = ModalRoute.of(context)!.settings.arguments as Agente;
      iniciado = true;
      carregar();
    }
  }

  Future<void> carregar({bool recalcular = false}) async {
    setState(() {
      carregando = true;
    });
    try {
      if (recalcular) await visitaRepository.recalcular(agente.id);
      final rota = await visitaRepository.getRota(agente.id);
      final lista = await pacienteRepository.listar(agente);
      if (!mounted) return;
      setState(() {
        visitas = rota;
        pacientes = lista;
      });
    } on ApiException catch (e) {
      mostrarMensagem(e.detalhe, erro: true);
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  List<Visita> get visitasFiltradas => filtroNivel == "TODOS"
      ? visitas
      : visitas.where((v) => v.nivelRisco == filtroNivel).toList();

  List<Visita> get visitasUrgentes =>
      visitas.where((v) => v.nivelRisco == "CRITICO" || v.nivelRisco == "ALTO").toList();

  int contarNivel(String nivel) => visitas.where((v) => v.nivelRisco == nivel).length;

  int get criticos => contarNivel("CRITICO");

  String get saudacao {
    final hora = DateTime.now().hour;
    if (hora < 12) return "Bom dia,";
    if (hora < 18) return "Boa tarde,";
    return "Boa noite,";
  }

  String get nomeExibicao => "${agente.isGestor ? "Gestor" : "Agente"} ${agente.primeiroNome}";

  void irParaAba(int aba, {String? filtro}) {
    setState(() {
      abaAtual = aba;
      if (filtro != null) filtroNivel = filtro;
    });
  }

  Future<void> abrirProntuario(Visita visita) async {
    final concluiu = await Navigator.pushNamed(context, "/prontuario", arguments: visita);
    if (concluiu == true) {
      setState(() {
        visitas.removeWhere((v) => v.id == visita.id);
        concluidasNoTurno++;
      });
      mostrarMensagem("Visita a ${visita.pacienteNome} concluída!");
    }
  }

  Future<void> abrirTriagem() async {
    final cadastrou = await Navigator.pushNamed(context, "/triagem", arguments: agente);
    if (cadastrou == true) {
      mostrarMensagem("Novo idoso incluído no programa AMPARO.");
      carregar();
    }
  }

  Future<void> abrirPacientes() async {
    await Navigator.pushNamed(context, "/pacientes", arguments: agente);
    carregar();
  }

  void mostrarMensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: erro ? corCritico : verdeApoio),
    );
  }

  Future<void> sair() async {
    await authRepository.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraSuperior(),
      body: corpoDaAba(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: bordaSuave))),
        child: NavigationBar(
          selectedIndex: abaAtual,
          onDestinationSelected: (aba) => irParaAba(aba),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: "Início",
            ),
            const NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note_rounded),
              label: "Visitas",
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: criticos > 0,
                label: Text("$criticos"),
                backgroundColor: corCritico,
                child: const Icon(Icons.notifications_none_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: criticos > 0,
                label: Text("$criticos"),
                backgroundColor: corCritico,
                child: const Icon(Icons.notifications_rounded),
              ),
              label: "Alertas",
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget? barraSuperior() {
    if (abaAtual == 1) {
      return AppBar(
        title: const Text("Rota do dia"),
        actions: [
          IconButton(
            tooltip: "Recalcular rota",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: carregando ? null : () => carregar(recalcular: true),
          ),
        ],
      );
    }
    if (abaAtual == 2) {
      return AppBar(title: const Text("Alertas"));
    }
    return null;
  }

  Widget corpoDaAba() {
    switch (abaAtual) {
      case 1:
        return abaVisitas();
      case 2:
        return abaAlertas();
      case 3:
        return abaPerfil();
      default:
        return abaInicio();
    }
  }

  Widget abaInicio() {
    return RefreshIndicator(
      onRefresh: () => carregar(recalcular: true),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  cabecalhoInicio(),
                  const SizedBox(height: 60),
                ],
              ),
              Positioned(left: 16, right: 16, bottom: 0, child: resumoInicio()),
            ],
          ),
          const SizedBox(height: 12),
          const BannerOffline(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                AtalhoCard(
                  icone: Icons.location_on_rounded,
                  titulo: "Rota priorizada",
                  cor: verdeApoio,
                  onTap: () => irParaAba(1),
                ),
                AtalhoCard(
                  icone: Icons.groups_rounded,
                  titulo: "Pacientes",
                  cor: azulPrincipal,
                  onTap: abrirPacientes,
                ),
                AtalhoCard(
                  icone: Icons.warning_rounded,
                  titulo: "Alertas",
                  cor: corCritico,
                  onTap: () => irParaAba(2),
                ),
                AtalhoCard(
                  icone: Icons.health_and_safety_outlined,
                  titulo: "Triagem",
                  cor: azulPrincipal,
                  onTap: abrirTriagem,
                ),
                AtalhoCard(
                  icone: Icons.router_outlined,
                  titulo: "Kits LoRa",
                  cor: azulPrincipal,
                  onTap: () => Navigator.pushNamed(context, "/kits", arguments: agente),
                ),
                AtalhoCard(
                  icone: Icons.info_outline_rounded,
                  titulo: "Sobre o projeto",
                  cor: azulPrincipal,
                  onTap: () => Navigator.pushNamed(context, "/sobre"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Alertas de pacientes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: azulEscuro),
                  ),
                ),
                TextButton(
                  onPressed: () => irParaAba(1, filtro: "TODOS"),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text("Ver todos"), Icon(Icons.chevron_right_rounded, size: 20)],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: carregando
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : visitas.isEmpty
                    ? estadoVazio("Nenhuma visita pendente. Todos os idosos estão estáveis!")
                    : Column(
                        children: [
                          for (final visita in visitas.take(3))
                            VisitaCard(
                              visita: visita,
                              compacto: true,
                              onTap: () => abrirProntuario(visita),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget cabecalhoInicio() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [azulPrincipal, azulEscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(right: 0, bottom: 0, child: IlustracaoEquipe(altura: 140)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 8, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LogoAmparo(tamanho: 42, clara: true),
                    const Spacer(),
                    IconButton(
                      tooltip: "Alertas",
                      onPressed: () => irParaAba(2),
                      icon: Badge(
                        isLabelVisible: criticos > 0,
                        smallSize: 10,
                        backgroundColor: corCritico,
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(saudacao, style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 17)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              nomeExibicao,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: verdeApoio,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Acompanhe as atividades da sua área.",
                        style: TextStyle(color: Color(0xDDFFFFFF), fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${agente.microarea} · ${agente.ubs}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget resumoInicio() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ResumoCard(
              icone: Icons.warning_rounded,
              valor: "$criticos",
              rotulo: "Alertas críticos",
              cor: corCritico,
              fundo: const Color(0xFFFFF5F5),
              onTap: () => irParaAba(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ResumoCard(
              icone: Icons.calendar_month_outlined,
              valor: "${visitas.length}",
              rotulo: "Visitas do dia",
              cor: azulPrincipal,
              fundo: azulClaro,
              onTap: () => irParaAba(1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ResumoCard(
              icone: Icons.groups_outlined,
              valor: "${pacientes.length}",
              rotulo: "Pacientes monitorados",
              cor: verdeApoio,
              fundo: const Color(0xFFF0FAF3),
              onTap: abrirPacientes,
            ),
          ),
        ],
      ),
    );
  }

  Widget abaVisitas() {
    final lista = visitasFiltradas;
    final total = visitas.length + concluidasNoTurno;
    return RefreshIndicator(
      onRefresh: () => carregar(recalcular: true),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const BannerOffline(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pendentes no turno: ${visitas.length}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700, color: azulEscuro),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Concluídas: $concluidasNoTurno",
                                style: const TextStyle(fontSize: 13, color: cinzaSuave),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: azulClaro,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.route_rounded, color: azulPrincipal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : concluidasNoTurno / total,
                        minHeight: 8,
                        color: verdeApoio,
                        backgroundColor: azulClaro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          filtros(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: carregando
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : lista.isEmpty
                    ? estadoVazio(visitas.isEmpty
                        ? "Nenhuma visita pendente. Todos os idosos estão estáveis!"
                        : "Nenhuma visita com nível ${rotuloDoNivel(filtroNivel)}.")
                    : Column(
                        children: [
                          for (final visita in lista)
                            VisitaCard(
                              visita: visita,
                              ordem: visitas.indexOf(visita) + 1,
                              onTap: () => abrirProntuario(visita),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget filtros() {
    final opcoes = ["TODOS", ...niveisRisco];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          for (final opcao in opcoes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: opcao == "TODOS"
                    ? null
                    : CircleAvatar(backgroundColor: corDoNivel(opcao), radius: 5),
                label: Text(opcao == "TODOS"
                    ? "Todos (${visitas.length})"
                    : "${rotuloDoNivel(opcao)} (${contarNivel(opcao)})"),
                selected: filtroNivel == opcao,
                selectedColor: opcao == "TODOS" ? azulClaro : fundoDoNivel(opcao),
                side: BorderSide(
                  color: filtroNivel == opcao
                      ? (opcao == "TODOS" ? azulPrincipal : corDoNivel(opcao))
                      : bordaSuave,
                ),
                onSelected: (_) {
                  setState(() {
                    filtroNivel = opcao;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget abaAlertas() {
    final urgentes = visitasUrgentes;
    return RefreshIndicator(
      onRefresh: () => carregar(recalcular: true),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const BannerOffline(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Visitas por nível de risco",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: azulEscuro),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                for (final nivel in niveisRisco) cardNivel(nivel),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Prioridade imediata",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: azulEscuro),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: urgentes.isEmpty
                ? estadoVazio("Nenhum alerta crítico ou alto no momento.")
                : Column(
                    children: [
                      for (final visita in urgentes)
                        VisitaCard(
                          visita: visita,
                          compacto: true,
                          onTap: () => abrirProntuario(visita),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget cardNivel(String nivel) {
    final cor = corDoNivel(nivel);
    return Material(
      color: fundoDoNivel(nivel),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => irParaAba(1, filtro: nivel),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(iconeDoNivel(nivel), color: cor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${contarNivel(nivel)}",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: cor),
                    ),
                    Text(rotuloDoNivel(nivel), style: TextStyle(fontSize: 13, color: cor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget abaPerfil() {
    final iniciais = iniciaisDoNome(agente.nome);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 32, 20, 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [azulPrincipal, azulEscuro],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  iniciais,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: azulPrincipal),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                agente.nome,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(agente.email, style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: verdeApoio,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  agente.isGestor ? "Gestor da UBS" : "Agente Comunitário de Saúde",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const BannerOffline(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    itemPerfil(Icons.local_hospital_outlined, "Unidade", agente.ubs),
                    const Divider(indent: 56),
                    itemPerfil(Icons.map_outlined, "Microárea", agente.microarea),
                    const Divider(indent: 56),
                    itemPerfil(Icons.groups_outlined, "Pacientes monitorados", "${pacientes.length}"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_outlined, color: azulPrincipal),
                      title: const Text("Servidor da API",
                          style: TextStyle(fontWeight: FontWeight.w600, color: azulEscuro)),
                      subtitle: Text(ApiClient.baseUrl),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ModoApp.offline ? fundoDoNivel("MODERADO") : fundoDoNivel("ESTAVEL"),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ModoApp.offline ? "Demonstração" : "Conectado",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ModoApp.offline ? corModerado : verdeApoio,
                          ),
                        ),
                      ),
                    ),
                    const Divider(indent: 56),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: azulPrincipal),
                      title: const Text("Sobre o AMPARO SUS",
                          style: TextStyle(fontWeight: FontWeight.w600, color: azulEscuro)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: cinzaSuave),
                      onTap: () => Navigator.pushNamed(context, "/sobre"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: sair,
                style: OutlinedButton.styleFrom(
                  foregroundColor: corCritico,
                  side: const BorderSide(color: corCritico, width: 1.5),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Sair"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget itemPerfil(IconData icone, String titulo, String valor) {
    return ListTile(
      leading: Icon(icone, color: azulPrincipal),
      title: Text(titulo, style: const TextStyle(fontSize: 13, color: cinzaSuave)),
      subtitle: Text(
        valor,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: azulEscuro),
      ),
    );
  }

  Widget estadoVazio(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bordaSuave),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, size: 48, color: verdeApoio),
          const SizedBox(height: 8),
          Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: cinzaTexto)),
        ],
      ),
    );
  }
}
