import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Locus',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              '환영합니다!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '당신만의 특별한 장소들을 기록하고 발견하세요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.add_location_alt,
                    title: '장소 추가',
                    subtitle: '새로운 장소를 저장하세요',
                    onTap: () => context.go('/add-place'),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.explore,
                    title: '장소 탐색',
                    subtitle: '근처 장소를 찾아보세요',
                    onTap: () => context.go('/discover'),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.list_alt,
                    title: '장소 목록',
                    subtitle: '저장된 장소를 관리하세요',
                    onTap: () => context.go('/places'),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.settings,
                    title: '설정',
                    subtitle: '앱 설정을 변경하세요',
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}