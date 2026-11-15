import 'package:flutter/material.dart';

const Color azulPrincipal = Color(0xFF005EB8);
const Color azulEscuro = Color(0xFF003B7A);
const Color azulClaro = Color(0xFFEAF4FF);
const Color azulLogo = Color(0xFF405AB3);
const Color verdeApoio = Color(0xFF3FAE5A);
const Color cinzaTexto = Color(0xFF334155);
const Color cinzaSuave = Color(0xFF64748B);
const Color bordaSuave = Color(0xFFE2E8F0);
const Color fundoApp = Color(0xFFF5F8FC);

const Color corCritico = Color(0xFFDC2626);
const Color corAlto = Color(0xFFEA580C);
const Color corModerado = Color(0xFFD97706);
const Color corEstavel = Color(0xFF3FAE5A);

const List<String> niveisRisco = ["CRITICO", "ALTO", "MODERADO", "ESTAVEL"];

Color corDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return corCritico;
    case "ALTO":
      return corAlto;
    case "MODERADO":
      return corModerado;
    default:
      return corEstavel;
  }
}

Color fundoDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return const Color(0xFFFEECEC);
    case "ALTO":
      return const Color(0xFFFFF1E6);
    case "MODERADO":
      return const Color(0xFFFEF6DC);
    default:
      return const Color(0xFFE8F6EC);
  }
}

String rotuloDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return "Crítico";
    case "ALTO":
      return "Alto";
    case "MODERADO":
      return "Moderado";
    default:
      return "Estável";
  }
}

IconData iconeDoNivel(String nivel) {
  switch (nivel) {
    case "CRITICO":
      return Icons.warning_rounded;
    case "ALTO":
      return Icons.error_outline_rounded;
    case "MODERADO":
      return Icons.info_outline_rounded;
    default:
      return Icons.check_circle_outline_rounded;
  }
}

const Map<String, String> desfechos = {
  "VISITA_REALIZADA": "Visita realizada",
  "ORIENTACAO_FAMILIA": "Orientação à família",
  "ENCAMINHADO_UBS": "Encaminhado à UBS",
  "ACIONADO_SAMU": "SAMU acionado",
  "AUSENTE": "Idoso ausente",
};

const Map<String, String> statusKit = {
  "ATIVO": "Ativo",
  "MANUTENCAO": "Manutenção",
  "INATIVO": "Inativo",
};

const Map<String, String> nomesCondicoes = {
  "HAS": "Hipertensão",
  "DM": "Diabetes",
  "ICC": "Insuf. cardíaca",
};

String condicoesPorExtenso(String condicoes) {
  return condicoes
      .split(",")
      .where((c) => c.isNotEmpty)
      .map((c) => nomesCondicoes[c] ?? c)
      .join(", ");
}

String iniciaisDoNome(String nome) {
  final partes = nome.trim().split(" ").where((p) => p.isNotEmpty).toList();
  if (partes.isEmpty) return "";
  if (partes.length == 1) return partes.first[0].toUpperCase();
  return "${partes.first[0]}${partes.last[0]}".toUpperCase();
}

ThemeData temaAmparo() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: "Inter",
    colorScheme: ColorScheme.fromSeed(
      seedColor: azulPrincipal,
      primary: azulPrincipal,
      secondary: verdeApoio,
      surface: Colors.white,
      error: corCritico,
    ),
    scaffoldBackgroundColor: fundoApp,
  );

  final borda = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: bordaSuave),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: cinzaTexto, displayColor: azulEscuro),
    appBarTheme: const AppBarTheme(
      backgroundColor: azulPrincipal,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: "Inter",
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: azulPrincipal,
        foregroundColor: Colors.white,
        disabledBackgroundColor: bordaSuave,
        disabledForegroundColor: cinzaSuave,
        elevation: 0,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontFamily: "Inter", fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: azulPrincipal,
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: azulPrincipal, width: 1.5),
        textStyle: const TextStyle(fontFamily: "Inter", fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: azulPrincipal,
        textStyle: const TextStyle(fontFamily: "Inter", fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      prefixIconColor: azulPrincipal,
      labelStyle: const TextStyle(color: cinzaSuave),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: borda,
      enabledBorder: borda,
      focusedBorder: borda.copyWith(borderSide: const BorderSide(color: azulPrincipal, width: 2)),
      errorBorder: borda.copyWith(borderSide: const BorderSide(color: corCritico)),
      focusedErrorBorder: borda.copyWith(borderSide: const BorderSide(color: corCritico, width: 2)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: bordaSuave),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: azulClaro,
      side: const BorderSide(color: bordaSuave),
      labelStyle: const TextStyle(fontFamily: "Inter", color: cinzaTexto, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: azulClaro,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((estados) => TextStyle(
            fontFamily: "Inter",
            fontSize: 12,
            fontWeight: estados.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: estados.contains(WidgetState.selected) ? azulPrincipal : cinzaSuave,
          )),
      iconTheme: WidgetStateProperty.resolveWith((estados) => IconThemeData(
            color: estados.contains(WidgetState.selected) ? azulPrincipal : cinzaSuave,
          )),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: bordaSuave, space: 1),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
