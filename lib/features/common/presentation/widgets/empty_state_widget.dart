import 'package:flutter/material.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.action,
    this.onActionPressed,
    this.actionText,
  });

  factory EmptyStateWidget.noPlaces({
    VoidCallback? onAddPlace,
  }) {
    return EmptyStateWidget(
      title: '저장된 장소가 없습니다',
      subtitle: '첫 번째 장소를 추가해보세요!',
      icon: Icons.place_outlined,
      onActionPressed: onAddPlace,
      actionText: '장소 추가',
    );
  }

  factory EmptyStateWidget.noSearchResults({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      title: '검색 결과가 없습니다',
      subtitle: '다른 조건으로 검색해보세요.',
      icon: Icons.search_off,
      onActionPressed: onRetry,
      actionText: '다시 검색',
    );
  }

  factory EmptyStateWidget.noNearbyPlaces({
    VoidCallback? onExpandRadius,
  }) {
    return EmptyStateWidget(
      title: '근처에 저장된 장소가 없습니다',
      subtitle: '검색 반경을 늘려보거나 새로운 장소를 추가해보세요.',
      icon: Icons.explore_off,
      onActionPressed: onExpandRadius,
      actionText: '반경 확장',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ] else if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}