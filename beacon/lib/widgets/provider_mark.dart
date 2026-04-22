import 'package:flutter/material.dart';

import '../app_theme.dart';

class ProviderMark extends StatelessWidget {
  final String assetPath;
  final String semanticLabel;

  const ProviderMark({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        width: AppLayout.providerMarkSize,
        height: AppLayout.providerMarkSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
