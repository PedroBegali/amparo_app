import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

// Aviso exibido quando a API está fora do ar e o app usa os dados locais
class BannerOffline extends StatelessWidget {
  const BannerOffline({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ModoApp.offline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.brown),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "API indisponível: exibindo dados de demonstração.",
              style: TextStyle(fontSize: 12, color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }
}
