import 'package:flutter/material.dart';
import 'main.dart' show AppColors;

class OrgDashboardScreen extends StatelessWidget {
  const OrgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Beacon',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: const Center(
        child: Text(
          'Org dashboard coming soon.',
          style: TextStyle(color: AppColors.subtle, fontSize: 16),
        ),
      ),
    );
  }
}