# AMPARO – SUS · App do Agente Comunitário de Saúde (Flutter)

> Global Solution 2026/2 · CitizenTech · Mobile Application Development

| | |
|---|---|
| **Grupo** | AMPARO-SUS |
| **Integrantes** | Denise Santos - RM: 567559 · Lucas Dudena - RM: 567600 · Karen Cardoso - RM: 566870 · Pedro Begali - RM: 567478 |
| **Vídeo (YouTube)** | _link aqui_ |
| **APK** | aba _Releases_ deste repositório (`app-release.apk`) |

## 1. A solução
O **AMPARO – SUS** instala um kit de sensores de baixo custo na casa de idosos crônicos de baixa renda:
- sensor PIR de movimento;
- porta-remédios com sensor cardíaco;
- sensor sob o colchão;
- botão SOS.

O kit envia os dados por **rádio LoRa** até a UBS, sem Wi-Fi, 4G ou smartphone na casa. No servidor, um motor de regras classifica o risco de cada idoso como Crítico, Alto, Moderado ou Estável.

**Este app é a ferramenta de campo do Agente Comunitário de Saúde (ACS).** Em vez da visita "às cegas" por ordem geográfica, o agente abre o app e encontra a **rota do dia priorizada por risco real**. Nela ele consulta o prontuário de telemetria do idoso, registra o desfecho da visita e faz a triagem de novos idosos para o programa.

### Cidadão beneficiado
- **Idosos com hipertensão, diabetes ou insuficiência cardíaca** que moram sozinhos em periferias e áreas sem conectividade. Eles recebem cuidado preventivo antes de uma descompensação virar internação.
- **Agentes Comunitários de Saúde**, que passam a usar o tempo de visita onde ele é mais necessário.

### ODS relacionados
- **ODS 3 – Saúde e Bem-Estar:** reduz internações evitáveis e a mortalidade por doenças crônicas.
- **ODS 9 – Indústria, Inovação e Infraestrutura:** rede IoT LoRa pública e resiliente.
- **ODS 10 – Redução das Desigualdades:** inclusão de idosos sem internet nem letramento digital.
- **ODS 11 – Cidades e Comunidades Sustentáveis:** atenção primária mais eficiente nos bairros.

## 2. Telas e fluxo de navegação
```
Login ──► Dashboard (rota do dia) ──► Prontuário de telemetria ──► Desfecho da visita
   (Agente)        │   (Visita)                    (Visita + kits)        │
                   │                                                      └─ pop(true) → contador atualiza
                   ├──► Triagem domiciliar (Agente) ──► pop(true) → SnackBar
                   └──► Sobre (ODS, regra de risco, IA)
```
| # | Rota | Tela | Destaques |
|---|---|---|---|
| 1 | `/` | **Login / identificação** | `Form` + `GlobalKey<FormState>`, validação de e-mail e senha, botão de mostrar senha, atalhos para os usuários de teste e `SnackBar` de erro |
| 2 | `/dashboard` | **Rota prioritária do dia** | Recebe o `Agente`. Card "Pendentes no turno: N / Concluídas: M", **GridView** com a contagem por nível, **ChoiceChips** que filtram por gravidade (`setState`), `ListView` da rota, recálculo do motor de risco e FAB "Nova triagem" |
| 3 | `/prontuario` | **Prontuário de telemetria** | Recebe a `Visita`. Dados do idoso, **GridView 2×2** dos sensores (PIR, porta-remédios, colchão e SOS) com destaque de alerta, kit LoRa, últimas leituras e **Checkbox** "sensores checados" que libera o botão (`setState`) |
| 4 | `/triagem` | **Formulário de triagem domiciliar** | Recebe o `Agente`. `Form` com nome, CNS (15 dígitos), data de nascimento (`DatePicker`, 60+ anos), endereço, microárea, série do kit (`KIT-LORA-0000`), condições (`FilterChip`) e mora sozinho (`Switch`). Cadastra o idoso, vincula o kit e mostra `AlertDialog` de confirmação |
| 5 | `/desfecho` | **Registro de desfecho e status do kit** | Recebe `{visita, kits, sensoresChecados}`. `DropdownButtonFormField` de desfecho, observação obrigatória para encaminhamentos, bateria com `LinearProgressIndicator`, status do kit e `AlertDialog`. Volta com `pop(true)` |
| + | `/sobre` | Sobre | Regra de risco, ODS (`GridView`) e declaração de IA |

### Gerenciamento de estado (`StatefulWidget` + `setState`)
- **Filtro de alertas por gravidade em tempo real:** `filtroNivel` no dashboard.
- **Concluir uma visita:** remove a visita da lista e atualiza "Pendentes no turno" e "Concluídas".
- **Checkbox de checagem dos sensores:** habilita ou desabilita o botão de desfecho.
- **Outros estados:** mostrar/ocultar senha, chips de condições, switches e indicadores de carregamento.

### Widgets utilizados
`Scaffold`, `AppBar`, `Column`, `Row`, `Container`, `Padding`, `SizedBox`, `Card`, `Image` (logo em `assets/images`), `Icon`, `ListView`, `GridView`, `Form`, `TextFormField`, `DropdownButtonFormField`, `ChoiceChip`, `FilterChip`, `Switch`, `Checkbox`, `SnackBar` e `AlertDialog`.

A identidade visual segue o padrão gov.br/SUS: azul `#1351B4` e verde `#168821`. Cada nível de risco tem uma cor e um ícone próprios.

## 3. Integração com a API Java
O app consome a API Spring Boot do repositório `amparo-sus-api`. A autenticação é por JWT, e o token fica salvo em `shared_preferences`.

| Ação no app | Endpoint |
|---|---|
| Login | `POST /auth/login` |
| Rota do dia | `GET /api/v1/visitas/rota?agenteId=` |
| Recalcular rota | `POST /api/v1/visitas/rota/recalcular?agenteId=` |
| Prontuário | `GET /api/v1/pacientes/{id}/prontuario` |
| Triagem | `POST /api/v1/pacientes` + `POST /api/v1/kits` |
| Desfecho | `PATCH /api/v1/visitas/{id}/concluir` |

**Modo demonstração:** se a API não responder (sem rede ou servidor desligado), os repositórios usam `lib/mock/mock_data.dart`. São os mesmos dados do banco Oracle e da API, e o app mostra um aviso amarelo no topo.

## 4. Como executar
Pré-requisitos: Flutter 3.44+ e um emulador Android ou celular.

```bash
flutter pub get
flutter run
```
- **Emulador Android:** o app acessa a API em `http://10.0.2.2:8080`, que é o `localhost` do computador. Basta subir a API com `./mvnw spring-boot:run`.
- **Celular físico na mesma rede:**
```bash
flutter run --dart-define=API_URL=http://IP_DO_COMPUTADOR:8080
```
- **Gerar o APK de release:**
```bash
flutter build apk --release
```
  O arquivo sai em `build/app/outputs/flutter-apk/app-release.apk`.
- **Fuso horário do emulador:** se o "há X h" do porta-remédios aparecer errado, ajuste o fuso do emulador para Brasília (Configurações > Sistema > Data e hora, ou `adb shell service call alarm 3 s16 America/Sao_Paulo`). A API envia horários locais de Brasília.

**Usuários de teste** (senha `amparo123`):
- `agente@amparo.gov.br`: Ana Paula, com 5 visitas na rota.
- `gestor@amparo.gov.br`: Carlos, gestor da UBS.

**Testes:**
```bash
flutter analyze
flutter test
```

## 5. Estrutura do projeto
```
lib/
  main.dart                 tema SUS + rotas nomeadas
  models/                   agente, paciente, kit, leitura, visita, prontuario (fromJson/toJson)
  services/api_client.dart  HTTP + JWT + tratamento do ErroResponse da API
  repositories/             auth, visita, paciente, kit (API com fallback para mock)
  mock/mock_data.dart       dados de demonstração offline
  pages/                    login, dashboard, prontuario, triagem, desfecho_visita, sobre
  widgets/                  visita_card, sensor_card, nivel_risco_chip, banner_offline
  utils/cores_sus.dart      cores, rótulos e ícones dos níveis de risco
```

## 6. Declaração de uso de IA generativa
| Ferramenta | Para quê |
|---|---|
| Claude (Anthropic) | Apoio na organização das telas, revisão de código Flutter/Dart, sugestão de validações e revisão deste README |

Todo o código foi lido, entendido, executado no emulador e testado pela equipe. Os commits refletem a evolução real do projeto.
