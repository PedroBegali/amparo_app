import 'package:amparo_sus_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class BannerOffline extends StatelessWidget {
  const BannerOffline({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ModoApp.offline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: const Color(0xFFFEF6DC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: Color(0xFF92400E)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "API indisponível: exibindo dados de demonstração.",
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
