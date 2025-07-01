import 'package:flutter/material.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String loadingMessage;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.loadingMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loadingMessage,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
