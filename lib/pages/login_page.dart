import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:amparo_sus_app/services/api_client.dart';
import 'package:amparo_sus_app/utils/cores_sus.dart';
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
    // Valida os campos do formulário antes de chamar a API
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      carregando = true;
    });
    try {
      final agente = await authRepository.login(
          emailController.text.trim(), senhaController.text);
      if (!mounted) return;
      // Passa o agente logado como parâmetro para o dashboard
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
      backgroundColor: azulSus,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset("assets/images/logo_amparo.png", width: 110, height: 110),
                const SizedBox(height: 12),
                const Text(
                  "AMPARO-SUS",
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Cuidado invisível para quem mais precisa",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Identificação do agente",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "E-mail institucional",
                              hintText: "agente@amparo.gov.br",
                              prefixIcon: Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return "Informe o e-mail.";
                              }
                              final emailValido =
                                  RegExp(r"^[\w.+-]+@[\w-]+\.[\w.]+$").hasMatch(valor.trim());
                              if (!emailValido) return "E-mail inválido.";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: senhaController,
                            obscureText: ocultarSenha,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    ocultarSenha ? Icons.visibility : Icons.visibility_off),
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
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: carregando ? null : entrar,
                              icon: carregando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(carregando ? "Entrando..." : "Entrar"),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text("Usuários de teste (senha amparo123):",
                              style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.person, size: 16),
                                label: const Text("Agente"),
                                onPressed: () => preencherUsuarioTeste("agente@amparo.gov.br"),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.manage_accounts, size: 16),
                                label: const Text("Gestor UBS"),
                                onPressed: () => preencherUsuarioTeste("gestor@amparo.gov.br"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
