import 'package:flutter/material.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const CustomErrorWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryButtonText,
  });

  factory CustomErrorWidget.network({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: '네트워크 오류',
      message: '인터넷 연결을 확인하고 다시 시도해주세요.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryButtonText: '다시 시도',
    );
  }

  factory CustomErrorWidget.location({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: '위치 접근 오류',
      message: '위치 권한을 확인하고 다시 시도해주세요.',
      icon: Icons.location_disabled,
      onRetry: onRetry,
      retryButtonText: '권한 확인',
    );
  }

  factory CustomErrorWidget.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: '오류가 발생했습니다',
      message: message ?? '잠시 후 다시 시도해주세요.',
      icon: Icons.error_outline,
      onRetry: onRetry,
      retryButtonText: '다시 시도',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? '다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}