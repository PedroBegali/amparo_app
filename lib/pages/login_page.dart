import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
import 'package:amparo_sus_app/widgets/ilustracao_equipe.dart';
import 'package:amparo_sus_app/widgets/logo_amparo.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  bool ocultarSenha = true;
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      carregando = true;
    });
    try {
      final agente = await authRepository.login(
          emailController.text.trim(), senhaController.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/dashboard", arguments: agente);
    } on ApiException catch (e) {
      mostrarErro(e.detalhe);
    } catch (e) {
      mostrarErro("Não foi possível entrar: $e");
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: corCritico),
    );
  }

  void preencherUsuarioTeste(String email) {
    setState(() {
      emailController.text = email;
      senhaController.text = "amparo123";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            cabecalho(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: formulario(),
            ),
          ],
        ),
      ),
    );
  }

  Widget cabecalho() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 36, 24, 0),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [azulPrincipal, azulEscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogoAmparo(tamanho: 64, clara: true),
          SizedBox(height: 24),
          Text(
            "Cuidado invisível para quem mais precisa",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Rota de visitas priorizada pelo risco real de cada idoso da sua área.",
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14, height: 1.4),
          ),
          SizedBox(height: 12),
          Center(child: IlustracaoEquipe(altura: 160)),
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Identificação do agente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: azulEscuro),
          ),
          const SizedBox(height: 4),
          const Text(
            "Entre com seu e-mail institucional da UBS.",
            style: TextStyle(fontSize: 14, color: cinzaSuave),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "E-mail institucional",
              hintText: "agente@amparo.gov.br",
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return "Informe o e-mail.";
              }
              final emailValido = RegExp(r"^[\w.+-]+@[\w-]+\.[\w.]+$").hasMatch(valor.trim());
              if (!emailValido) return "E-mail inválido.";
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: senhaController,
            obscureText: ocultarSenha,
            decoration: InputDecoration(
              labelText: "Senha",
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                color: cinzaSuave,
                onPressed: () {
                  setState(() {
                    ocultarSenha = !ocultarSenha;
                  });
                },
              ),
            ),
            validator: (valor) {
              if (valor == null || valor.isEmpty) return "Informe a senha.";
              if (valor.length < 6) return "A senha tem no mínimo 6 caracteres.";
              return null;
            },
            onFieldSubmitted: (_) => entrar(),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: carregando ? null : entrar,
            icon: carregando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cinzaSuave),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(carregando ? "Entrando..." : "Entrar"),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, "/sobre"),
            icon: const Icon(Icons.info_outline_rounded),
            label: const Text("Conhecer o projeto"),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: azulClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.science_outlined, size: 18, color: azulPrincipal),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Usuários de teste (senha amparo123)",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: azulEscuro),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.person_outline_rounded, size: 18, color: azulPrincipal),
                      label: const Text("Agente"),
                      onPressed: () => preencherUsuarioTeste("agente@amparo.gov.br"),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.manage_accounts_outlined, size: 18, color: azulPrincipal),
                      label: const Text("Gestor UBS"),
                      onPressed: () => preencherUsuarioTeste("gestor@amparo.gov.br"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
